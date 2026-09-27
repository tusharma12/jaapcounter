import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('upgrading to v3 fixes shipped text and keeps user edits', () async {
    final dir = await Directory.systemTemp.createTemp('japmala');
    addTearDown(() => dir.delete(recursive: true));
    final factory = databaseFactoryFfi;
    await factory.setDatabasesPath(dir.path);

    // A v2 install: Waheguru as shipped, Satnam Waheguru edited by the user.
    final v2 = await factory.openDatabase(
      '${dir.path}/${AppDatabase.fileName}',
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE mantras (
              id TEXT PRIMARY KEY, name TEXT NOT NULL, devanagari TEXT,
              transliteration TEXT, mala_size INTEGER NOT NULL DEFAULT 108,
              is_built_in INTEGER NOT NULL DEFAULT 0,
              sort_order INTEGER NOT NULL DEFAULT 0,
              mala_base INTEGER NOT NULL DEFAULT 0)
          ''');
          // Only the columns the migrations read.
          await db.execute(
            'CREATE TABLE jaap_entries (id TEXT PRIMARY KEY, mantra_id TEXT)',
          );
          await db.execute(
            'CREATE TABLE sadhanas (id TEXT PRIMARY KEY, mantra_id TEXT)',
          );
          for (final (id, translit, order) in [
            ('builtin.waheguru', 'Vāhegurū', 8),
            ('builtin.satnam-waheguru', 'My spelling', 9),
          ]) {
            await db.insert('mantras', {
              'id': id,
              'name': id,
              'transliteration': translit,
              'is_built_in': 1,
              'sort_order': order,
            });
          }
        },
      ),
    );
    await v2.close();

    final db = await AppDatabase.open(factory: factory);
    addTearDown(db.close);
    Future<Map<String, Object?>> row(String id) async =>
        (await db.query('mantras', where: 'id = ?', whereArgs: [id])).single;

    // v3 renumbered the built-ins; v5 then folded the old name, Devanagari
    // and transliteration into a single mantra text with no description.
    expect((await row('builtin.waheguru'))['sort_order'], 9);
    expect((await row('builtin.waheguru'))['transliteration'], isNull);
    expect((await row('builtin.waheguru'))['description'], isNull);
    expect((await row('builtin.hare-krishna-mahamantra'))['sort_order'], 5);
  });

  test('retired built-ins go, unless they have Jaap to keep', () async {
    final dir = await Directory.systemTemp.createTemp('japmala');
    addTearDown(() => dir.delete(recursive: true));
    final factory = databaseFactoryFfi;
    await factory.setDatabasesPath(dir.path);

    // A v3 install with all three retired mantras, one of them chanted.
    final v3 = await AppDatabase.open(factory: factory);
    // Put back the columns a real v3 install had, then claim to be v3.
    await v3.execute('ALTER TABLE mantras ADD COLUMN devanagari TEXT');
    await v3.execute('ALTER TABLE mantras ADD COLUMN transliteration TEXT');
    await v3.setVersion(3);
    for (final id in [
      'builtin.mool-mantar',
      'builtin.navkar',
      'builtin.om-hreem-arham-namah',
    ]) {
      await v3.insert('mantras', {
        'id': id,
        'name': id,
        'is_built_in': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await v3.insert('jaap_entries', {
      'id': 'e1',
      'mantra_id': 'builtin.navkar',
      'count': 108,
      'day': '2026-09-01',
      'timestamp': 0,
    });
    await v3.close();

    final db = await AppDatabase.open(factory: factory);
    addTearDown(db.close);
    final rows = {for (final row in await db.query('mantras')) row['id']: row};

    expect(rows.containsKey('builtin.mool-mantar'), isFalse);
    expect(rows.containsKey('builtin.om-hreem-arham-namah'), isFalse);
    expect(
      rows['builtin.navkar']!['is_built_in'],
      0,
      reason: 'kept as the user\'s own, with its 108 Jaap',
    );
  });

  test('v5 turns a custom mantra into its text plus a description', () async {
    final dir = await Directory.systemTemp.createTemp('japmala');
    addTearDown(() => dir.delete(recursive: true));
    final factory = databaseFactoryFfi;
    await factory.setDatabasesPath(dir.path);

    final v4 = await AppDatabase.open(factory: factory);
    await v4.execute('ALTER TABLE mantras ADD COLUMN devanagari TEXT');
    await v4.execute('ALTER TABLE mantras ADD COLUMN transliteration TEXT');
    await v4.insert('mantras', {
      'id': 'mine',
      'name': 'Sita Ram',
      'devanagari': 'सीता राम',
      'is_built_in': 0,
    });
    await v4.insert('mantras', {'id': 'plain', 'name': 'Jai Mata Di'});
    await v4.setVersion(4);
    await v4.close();

    final db = await AppDatabase.open(factory: factory);
    addTearDown(db.close);
    final rows = {for (final r in await db.query('mantras')) r['id']: r};

    expect(rows['mine']!['name'], 'सीता राम');
    expect(rows['mine']!['description'], 'Sita Ram');
    expect(rows['plain']!['name'], 'Jai Mata Di');
    expect(rows['plain']!['description'], isNull);
    expect(rows['builtin.ram']!['name'], 'राम');
  });
}
