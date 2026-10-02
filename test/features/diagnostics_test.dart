import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/services/app_logger.dart';
import 'package:japmala/features/diagnostics/data/diagnostics_report.dart';
import 'package:japmala/features/jaap/data/jaap_repository.dart';
import 'package:japmala/features/mantras/data/mantra_repository.dart';
import 'package:japmala/features/settings/domain/app_settings.dart';

import '../support/test_harness.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('diag');
    AppLogger.attachFile(File('${dir.path}/diagnostics.log'));
    await AppLogger.clear();
    addTearDown(() async {
      AppLogger.detachFile();
      await dir.delete(recursive: true);
    });
  });

  test('warnings and errors are kept across launches; info is not', () async {
    AppLogger.i('Scheduled 2 reminder(s)');
    AppLogger.w('Rejected backup file');
    AppLogger.e('Could not open the database', StateError('locked'));

    final kept = await AppLogger.persisted();

    expect(kept, contains('W Rejected backup file'));
    expect(kept, contains('E Could not open the database'));
    expect(kept, contains('locked'));
    expect(kept, isNot(contains('Scheduled 2')));
    expect(AppLogger.recent().join(), contains('Scheduled 2'));
  });

  test('the in-memory log keeps only the newest entries', () {
    for (var i = 0; i < AppLogger.bufferSize + 20; i++) {
      AppLogger.i('entry $i');
    }

    final recent = AppLogger.recent();
    expect(recent, hasLength(AppLogger.bufferSize));
    expect(recent.last, endsWith('entry ${AppLogger.bufferSize + 19}'));
  });

  test('the file is cut back once it grows past its cap', () async {
    final long = 'x' * 1000;
    for (var i = 0; i < 200; i++) {
      AppLogger.w('$i $long');
    }

    final kept = await AppLogger.persisted();
    expect(kept.length, lessThanOrEqualTo(AppLogger.maxFileBytes + 2000));
    expect(kept, contains('199 '), reason: 'the newest survive');
  });

  test('the report describes the app, never what was chanted', () async {
    final db = await openTestDatabase();
    addTearDown(db.close);
    await JaapRepository(db).addBeads(mantraId: 'builtin.ram', delta: 1234);
    await MantraRepository(db).create(name: 'मेरा गुप्त मंत्र');
    AppLogger.e('Something broke');

    final report = await DiagnosticsReport(
      database: db,
      settings: const AppSettings(hardwareKeyCounting: true),
      appVersion: '1.2.0',
      buildNumber: '7',
      platform: 'android 14',
      clock: () => DateTime(2026, 10, 1),
    ).build();

    expect(report, contains('App: 1.2.0 (7)'));
    expect(report, contains('Platform: android 14'));
    expect(report, contains('1 entries, 1 custom mantras'));
    expect(report, contains('buttons on'));
    expect(report, contains('E Something broke'));
    expect(report, isNot(contains('गुप्त')), reason: 'no mantra text');
    expect(report, isNot(contains('1234')), reason: 'no counts');
  });
}
