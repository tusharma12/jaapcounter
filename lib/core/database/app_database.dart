import 'package:sqflite/sqflite.dart';

import '../constants/built_in_mantras.dart';
import '../services/app_logger.dart';

/// Opens and migrates the local SQLite database.
///
/// Everything the user records lives here on the device; nothing is sent
/// anywhere. [openTestDatabase] lets the same schema run in unit tests.
abstract final class AppDatabase {
  static const String fileName = 'japmala.db';
  static const int schemaVersion = 2;

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
    if (from < 2) {
      // v2 ships Sikh and Jain mantras; seeding ignores rows already present.
      await _seedBuiltInMantras(db);
    }
  }

  static Future<void> _createSchema(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE mantras (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        devanagari TEXT,
        transliteration TEXT,
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

  /// Re-seeds the built-in mantras. Used after a restore so a backup made on
  /// an older version never leaves the library empty.
  static Future<void> ensureBuiltInMantras(Database db) =>
      _seedBuiltInMantras(db);

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
