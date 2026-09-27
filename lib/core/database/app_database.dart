import 'package:sqflite/sqflite.dart';

import '../../features/mantras/domain/mantra.dart';
import '../constants/built_in_mantras.dart';
import '../services/app_logger.dart';

/// Opens and migrates the local SQLite database.
///
/// Everything the user records lives here on the device; nothing is sent
/// anywhere. [openTestDatabase] lets the same schema run in unit tests.
abstract final class AppDatabase {
  static const String fileName = 'japmala.db';
  static const int schemaVersion = 5;

  static Future<Database> open({DatabaseFactory? factory}) async {
    final f = factory ?? databaseFactory;
    final dir = await f.getDatabasesPath();
    return f.openDatabase(
      '$dir/$fileName',
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  /// An in-memory database with the production schema, for tests.
  static Future<Database> openInMemory(DatabaseFactory factory) {
    return factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('Creating database schema v$version');
    await _createSchema(db);
    await _seedBuiltInMantras(db);
  }

  static Future<void> _onUpgrade(Database db, int from, int to) async {
    AppLogger.i('Migrating database from v$from to v$to');
    // Future migrations append here, one `if (from < n)` block each, so an
    // install can hop several versions in a single upgrade.
    if (from < 5) {
      // First, because every seeding step below writes a description. Checked,
      // so an upgrade interrupted after this line can safely run again.
      final columns = await db.rawQuery('PRAGMA table_info(mantras)');
      if (!columns.any((c) => c['name'] == 'description')) {
        await db.execute('ALTER TABLE mantras ADD COLUMN description TEXT');
      }
    }
    if (from < 2) {
      // v2 ships Sikh and Jain mantras; seeding ignores rows already present.
      await _seedBuiltInMantras(db);
    }
    if (from < 3) {
      // v3 corrects the Sikh transliterations and adds the full Hare Krishna
      // Mahamantra. Only text still as it shipped is touched, so a user's own
      // edits to a built-in survive.
      const corrections = {
        'builtin.waheguru': ('Vāhegurū', 'Vāheguru'),
        'builtin.satnam-waheguru': ('Satnām Vāhegurū', 'Satnām Vāheguru'),
      };
      for (final MapEntry(key: id, value: (before, after))
          in corrections.entries) {
        await db.update(
          'mantras',
          {'transliteration': after},
          where: 'id = ? AND transliteration = ?',
          whereArgs: [id, before],
        );
      }
      // Built-ins are listed by sort order, so renumber them to make room.
      final batch = db.batch();
      for (final mantra in BuiltInMantras.all) {
        batch.update(
          'mantras',
          {'sort_order': mantra.sortOrder},
          where: 'id = ? AND is_built_in = 1',
          whereArgs: [mantra.id],
        );
      }
      await batch.commit(noResult: true);
      await _seedBuiltInMantras(db);
    }
    if (from < 4) {
      // v4 no longer ships the Mool Mantar, Navkar and Om Hreem Arham Namah.
      await _retireBuiltInMantras(db);
    }
    if (from < 5) {
      // v5: a mantra is its text plus an optional description, in place of
      // a Latin name with optional Devanagari and transliteration. Rows the
      // steps above seeded are already in the new shape and pass unchanged.
      final rows = await db.query('mantras');
      final batch = db.batch();
      for (final row in rows) {
        final (name, description) = Mantra.fromLegacy(
          name: row['name'] as String,
          devanagari: row['devanagari'] as String?,
          transliteration: row['transliteration'] as String?,
        );
        batch.update(
          'mantras',
          {
            'name': name,
            // A built-in's old fields were only its romanised name.
            'description': row['is_built_in'] == 1 ? null : description,
            'devanagari': null,
            'transliteration': null,
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
      await batch.commit(noResult: true);
    }
  }

  /// Removes built-ins that are no longer shipped. One that was never used
  /// simply goes; one with Jaap or a Sankalp recorded against it becomes the
  /// user's own mantra instead, so no history is left pointing at nothing,
  /// and the user can still delete it themselves.
  static Future<void> _retireBuiltInMantras(Database db) async {
    for (final id in BuiltInMantras.retiredIds) {
      final used = await db.rawQuery(
        'SELECT 1 FROM jaap_entries WHERE mantra_id = ? '
        'UNION ALL SELECT 1 FROM sadhanas WHERE mantra_id = ? LIMIT 1',
        [id, id],
      );
      if (used.isEmpty) {
        await db.delete('mantras', where: 'id = ?', whereArgs: [id]);
      } else {
        await db.update(
          'mantras',
          {'is_built_in': 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  static Future<void> _createSchema(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE mantras (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        mala_size INTEGER NOT NULL DEFAULT 108,
        is_built_in INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        mala_base INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // The Jaap ledger. Rows are only ever appended, incremented, decremented
    // or deleted by an explicit user action (undo, reset, restore).
    batch.execute('''
      CREATE TABLE jaap_entries (
        id TEXT PRIMARY KEY,
        mantra_id TEXT NOT NULL,
        count INTEGER NOT NULL,
        day TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        source TEXT NOT NULL DEFAULT 'tap',
        session_id TEXT
      )
    ''');
    batch.execute('CREATE INDEX idx_jaap_day ON jaap_entries (day)');
    batch.execute('CREATE INDEX idx_jaap_mantra ON jaap_entries (mantra_id)');
    batch.execute(
      'CREATE INDEX idx_jaap_mantra_day ON jaap_entries (mantra_id, day)',
    );
    batch.execute(
      'CREATE INDEX idx_jaap_timestamp ON jaap_entries (timestamp DESC)',
    );

    batch.execute('''
      CREATE TABLE sadhanas (
        id TEXT PRIMARY KEY,
        mantra_id TEXT NOT NULL,
        daily_goal INTEGER NOT NULL,
        start_day TEXT NOT NULL,
        duration_days INTEGER,
        ended_day TEXT,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_minutes INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_sadhana_active ON sadhanas (is_active)');

    batch.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        mantra_id TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL DEFAULT 'jaap',
        minutes INTEGER NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        label TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE story_favorites (
        story_id TEXT PRIMARY KEY,
        created_at INTEGER NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  static Future<void> _seedBuiltInMantras(Database db) async {
    final batch = db.batch();
    for (final mantra in BuiltInMantras.all) {
      batch.insert(
        'mantras',
        mantra.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Re-seeds the built-in mantras and retires old ones. Used after a restore,
  /// so a backup made on an older version never leaves the library empty.
  static Future<void> ensureBuiltInMantras(Database db) async {
    await _seedBuiltInMantras(db);
    // A backup from an older version may bring retired built-ins back.
    await _retireBuiltInMantras(db);
  }

  /// Wipes every table and re-seeds. Behind explicit confirmation only.
  static Future<void> clearAll(Database db) async {
    await db.transaction((txn) async {
      for (final table in const [
        'jaap_entries',
        'sadhanas',
        'sessions',
        'reminders',
        'story_favorites',
        'mantras',
      ]) {
        await txn.delete(table);
      }
    });
    await _seedBuiltInMantras(db);
  }
}
