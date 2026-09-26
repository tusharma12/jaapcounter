import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:japmala/features/mantras/data/mantra_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/test_harness.dart';

void main() {
  late Database db;
  late MantraRepository repository;

  setUp(() async {
    db = await openTestDatabase();
    repository = MantraRepository(db);
    addTearDown(db.close);
  });

  test('a fresh install is seeded with the built-in mantras', () async {
    final all = await repository.all();

    expect(all.length, BuiltInMantras.all.length);
    expect(all.every((m) => m.isBuiltIn), isTrue);
    expect(all.first.name, 'Ram');
    expect(all.first.devanagari, 'राम');
    expect(all.every((m) => m.malaSize == 108), isTrue);
  });

  test('a custom mantra is created with its own mala size', () async {
    final created = await repository.create(
      name: 'Sita Ram',
      devanagari: 'सीता राम',
      transliteration: 'Sītā Rām',
      malaSize: 27,
    );

    expect(created.isBuiltIn, isFalse);
    expect(created.malaSize, 27);
    expect((await repository.byId(created.id))!.devanagari, 'सीता राम');
  });

  test('an out-of-range mala size is clamped rather than stored', () async {
    final created = await repository.create(name: 'Test', malaSize: 999999);

    expect(created.malaSize, 10000);
  });

  test('blank optional fields are stored as absent, not empty', () async {
    final created = await repository.create(
      name: 'Ram',
      devanagari: '   ',
      transliteration: '',
    );

    expect(created.devanagari, isNull);
    expect(created.transliteration, isNull);
    expect(created.display, 'Ram', reason: 'falls back to the Latin name');
  });

  test('a custom mantra can be edited', () async {
    final created = await repository.create(name: 'Ram', malaSize: 108);

    await repository.update(created.copyWith(name: 'Shri Ram', malaSize: 54));

    final stored = (await repository.byId(created.id))!;
    expect(stored.name, 'Shri Ram');
    expect(stored.malaSize, 54);
  });

  test('a custom mantra can be deleted', () async {
    final created = await repository.create(name: 'Temporary');

    await repository.delete(created.id);

    expect(await repository.byId(created.id), isNull);
  });

  test('a built-in mantra cannot be deleted', () async {
    await expectLater(
      repository.delete('builtin.ram'),
      throwsA(isA<BuiltInMantraDeletionError>()),
    );
    expect(await repository.byId('builtin.ram'), isNotNull);
  });

  test('built-in mantras stay ahead of custom ones in the library', () async {
    await repository.create(name: 'Aaa Custom');

    final all = await repository.all();

    expect(all.first.isBuiltIn, isTrue);
    expect(all.last.name, 'Aaa Custom');
  });

  test('a restore re-seeds built-ins that a backup was missing', () async {
    await repository.replaceAll(const []);
    expect((await db.query('mantras')).isEmpty, isTrue);

    await AppDatabase.ensureBuiltInMantras(db);

    expect((await db.query('mantras')).length, BuiltInMantras.all.length);
  });
}
