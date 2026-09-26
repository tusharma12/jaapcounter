import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:japmala/core/services/settings_service.dart';
import 'package:japmala/features/backup/data/backup_service.dart';
import 'package:japmala/features/jaap/data/jaap_repository.dart';
import 'package:japmala/features/jaap/domain/jaap_entry.dart';
import 'package:japmala/features/mantras/data/mantra_repository.dart';
import 'package:japmala/features/reminders/data/reminder_repository.dart';
import 'package:japmala/features/sadhana/data/sadhana_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/test_harness.dart';

void main() {
  late Database db;
  late TestClock clock;
  late SettingsService settings;
  late BackupService backup;
  late JaapRepository jaap;
  late MantraRepository mantras;
  late SadhanaRepository sadhanas;
  late ReminderRepository reminders;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = await openTestDatabase();
    clock = TestClock(DateTime(2026, 9, 3, 9));
    settings = SettingsService(await SharedPreferences.getInstance());
    backup = BackupService(
      database: db,
      settingsService: settings,
      version: '1.0.0',
      clock: clock.call,
    );
    jaap = JaapRepository(db, clock: clock.call);
    mantras = MantraRepository(db);
    sadhanas = SadhanaRepository(db, clock: clock.call);
    reminders = ReminderRepository(db);
    addTearDown(db.close);
  });

  Future<void> seed() async {
    await jaap.addBeads(mantraId: 'builtin.ram', delta: 108);
    clock.advance(const Duration(minutes: 10));
    await jaap.addBeads(
      mantraId: 'builtin.radha',
      delta: 54,
      source: JaapSource.manual,
    );
    await mantras.create(name: 'Sita Ram', devanagari: 'सीता राम', malaSize: 27);
    await sadhanas.create(
      mantraId: 'builtin.ram',
      dailyGoal: 216,
      durationDays: 40,
    );
    await reminders.create(minutes: 7 * 60);
    await settings.setFavouriteStoryIds(['squirrel-and-shri-ram']);
  }

  test('a backup contains every kind of record', () async {
    await seed();

    final data = await backup.buildBackup();

    expect(data['app'], 'japmala');
    expect(data['schemaVersion'], 1);
    expect(data['appVersion'], '1.0.0');
    expect((data['jaapEntries'] as List).length, 2);
    expect(
      (data['mantras'] as List).length,
      BuiltInMantras.all.length + 1,
    );
    expect((data['sadhanas'] as List).length, 1);
    expect((data['reminders'] as List).length, 1);
    expect(data['favouriteStories'], ['squirrel-and-shri-ram']);
    expect(data['settings'], isA<Map<String, Object?>>());
  });

  test('a backup survives a round trip through JSON and a wipe', () async {
    await seed();
    final json = jsonEncode(await backup.buildBackup());

    await AppDatabase.clearAll(db);
    expect(await jaap.lifetimeTotal(), 0);

    final result = await backup.restore(json);

    expect(result.entries, 2);
    expect(result.jaap, 162);
    expect(await jaap.lifetimeFor('builtin.ram'), 108);
    expect(await jaap.lifetimeFor('builtin.radha'), 54);
    expect((await sadhanas.active())!.dailyGoal, 216);
    expect((await reminders.all()).single.minutes, 420);
    expect(settings.favouriteStoryIds(), ['squirrel-and-shri-ram']);
    expect(
      (await mantras.all()).any((m) => m.name == 'Sita Ram'),
      isTrue,
      reason: 'custom mantras come back too',
    );
  });

  test('restoring replaces what was there rather than merging', () async {
    await seed();
    final json = jsonEncode(await backup.buildBackup());

    // Jaap counted after the backup was taken.
    clock.advanceDays(1);
    await jaap.addBeads(mantraId: 'builtin.ram', delta: 500);
    expect(await jaap.lifetimeTotal(), 662);

    await backup.restore(json);

    expect(await jaap.lifetimeTotal(), 162);
  });

  test('restoring re-applies the saved preferences', () async {
    await settings.write(
      settings.read().copyWith(
        hapticsEnabled: false,
        fallbackDailyGoal: 1008,
        localeCode: 'hi',
      ),
    );
    final json = jsonEncode(await backup.buildBackup());

    await settings.write(
      settings.read().copyWith(
        hapticsEnabled: true,
        fallbackDailyGoal: 27,
        localeCode: 'en',
      ),
    );

    await backup.restore(json);

    final restored = settings.read();
    expect(restored.hapticsEnabled, isFalse);
    expect(restored.fallbackDailyGoal, 1008);
    expect(restored.localeCode, 'hi');
  });

  test('a backup with no mantras still leaves the built-ins in place', () async {
    final json = jsonEncode({
      'app': 'japmala',
      'schemaVersion': 1,
      'mantras': <Object>[],
      'jaapEntries': <Object>[],
    });

    await backup.restore(json);

    expect((await mantras.all()).length, BuiltInMantras.all.length);
  });

  group('rejects files that are not ours', () {
    test('a file that is not JSON', () async {
      await expectLater(
        backup.restore('not json at all'),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('JSON from another app', () async {
      await expectLater(
        backup.restore(jsonEncode({'app': 'someOtherApp'})),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('a schema newer than this version understands', () async {
      await expectLater(
        backup.restore(jsonEncode({'app': 'japmala', 'schemaVersion': 99})),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('a malformed record inside an otherwise valid file', () async {
      await expectLater(
        backup.restore(
          jsonEncode({
            'app': 'japmala',
            'schemaVersion': 1,
            'jaapEntries': [
              {'id': 'x', 'mantra_id': 'builtin.ram'},
            ],
          }),
        ),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('nothing is written when a file is rejected', () async {
      await seed();
      final before = await jaap.lifetimeTotal();

      await expectLater(
        backup.restore(jsonEncode({'app': 'nope'})),
        throwsA(isA<InvalidBackupException>()),
      );

      expect(await jaap.lifetimeTotal(), before);
    });
  });
}
