import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:japmala/features/mantras/data/mantra_repository.dart';
import 'package:japmala/features/mantras/domain/mantra.dart';
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
    expect(all.first.name, 'राम राम');
    expect(all.first.description, isNull);
    expect(all.every((m) => m.malaSize == 108), isTrue);
  });

  test('a custom mantra is created with its own mala size', () async {
    final created = await repository.create(
      name: 'सीता राम',
      description: 'Sita and Ram together',
      malaSize: 27,
    );

    expect(created.isBuiltIn, isFalse);
    expect(created.malaSize, 27);
    final stored = (await repository.byId(created.id))!;
    expect(stored.name, 'सीता राम');
    expect(stored.description, 'Sita and Ram together');
  });

  test('an out-of-range mala size is clamped rather than stored', () async {
    final created = await repository.create(name: 'Test', malaSize: 999999);

    expect(created.malaSize, 10000);
  });

  test('a blank description is stored as absent, not empty', () async {
    final created = await repository.create(name: 'Ram', description: '   ');

    expect(created.description, isNull);
    expect(created.hasDescription, isFalse);
  });

  test('a mantra in the old shape reads as mantra plus description', () {
    Mantra legacy(String? devanagari, String? transliteration) =>
        Mantra.fromMap({
          'id': 'x',
          'name': 'Sita Ram',
          'devanagari': devanagari,
          'transliteration': transliteration,
          'mala_size': 108,
        });

    // The Devanagari was what the counter showed; the Latin name is kept.
    expect(legacy('सीता राम', null).name, 'सीता राम');
    expect(legacy('सीता राम', null).description, 'Sita Ram');
    expect(legacy('सीता राम', 'Sītā Rām').description, 'Sītā Rām');
    // Without Devanagari the Latin name is the mantra.
    expect(legacy(null, null).name, 'Sita Ram');
    expect(legacy(' ', null).description, isNull);
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
