import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/day_key.dart';
import '../../jaap/domain/jaap_entry.dart';
import '../../jaap/domain/jaap_session.dart';
import '../../mantras/domain/mantra.dart';
import '../../reminders/domain/reminder.dart';
import '../../sadhana/domain/sadhana.dart';
import '../../settings/domain/app_settings.dart';

/// What a restore actually restored, so the user can be told.
class BackupImportResult {
  const BackupImportResult({
    required this.entries,
    required this.mantras,
    required this.jaap,
  });

  final int entries;
  final int mantras;
  final int jaap;
}

/// Raised when a chosen file is not a Smaran backup, or is from a newer
/// version than this app understands.
class InvalidBackupException implements Exception {
  const InvalidBackupException([this.reason]);

  final String? reason;

  @override
  String toString() => 'InvalidBackupException(${reason ?? 'unreadable'})';
}

/// Export and import of everything the app holds, as one readable JSON file.
///
/// The file is plain and documented by its own field names on purpose: a
/// person's years of Jaap should not be locked inside an opaque blob.
class BackupService {
  BackupService({
    required Database database,
    required SettingsService settingsService,
    required String version,
    Clock? clock,
  }) : _db = database,
       _settings = settingsService,
       _appVersion = version,
       _now = clock ?? systemClock;

  final Database _db;
  final SettingsService _settings;
  final String _appVersion;
  final Clock _now;

  static const String _appTag = 'japmala';

  Future<Map<String, Object?>> buildBackup() async {
    final mantras = (await _db.query(
      'mantras',
    )).map(Mantra.fromMap).toList(growable: false);
    final entries = await _db.query('jaap_entries', orderBy: 'timestamp ASC');
    final sadhanas = await _db.query('sadhanas');
    final sessions = await _db.query('sessions');
    final reminders = await _db.query('reminders');

    return {
      'app': _appTag,
      'schemaVersion': AppConstants.backupSchemaVersion,
      'appVersion': _appVersion,
      'exportedAt': _now().toIso8601String(),
      'mantras': mantras.map((m) => m.toMap()).toList(),
      'jaapEntries': entries,
      'sadhanas': sadhanas,
      'sessions': sessions,
      'reminders': reminders,
      'favouriteStories': _settings.favouriteStoryIds(),
      'settings': _settings.read().toJson(),
    };
  }

  /// Writes a backup into the app's documents directory and returns the file.
  Future<File> writeBackupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final stamp = DayKeys.of(_now());
    final file = File(
      '${directory.path}/${AppConstants.backupFilePrefix}-$stamp.json',
    );
    final json = const JsonEncoder.withIndent(
      '  ',
    ).convert(await buildBackup());
    await file.writeAsString(json, flush: true);
    AppLogger.i('Wrote backup to ${file.path}');
    return file;
  }

  /// Validates and restores a backup, replacing what is in the app.
  ///
  /// Everything is parsed and checked before a single row is written, so a
  /// truncated or foreign file cannot leave the database half-replaced.
  Future<BackupImportResult> restore(String rawJson) async {
    final Map<String, Object?> data;
    try {
      data = jsonDecode(rawJson) as Map<String, Object?>;
    } on Object {
      throw const InvalidBackupException('not JSON');
    }

    if (data['app'] != _appTag) {
      throw const InvalidBackupException('not a Smaran backup');
    }
    final schema = data['schemaVersion'];
    if (schema is! int || schema > AppConstants.backupSchemaVersion) {
      throw const InvalidBackupException('unsupported schema version');
    }

    final mantras = _parseList(data['mantras'], Mantra.fromMap);
    final entries = _parseList(data['jaapEntries'], JaapEntry.fromMap);
    final sadhanas = _parseList(data['sadhanas'], Sadhana.fromMap);
    final sessions = _parseList(data['sessions'], JaapSession.fromMap);
    final reminders = _parseList(data['reminders'], Reminder.fromMap);

    await _db.transaction((txn) async {
      for (final table in const [
        'jaap_entries',
        'mantras',
        'sadhanas',
        'sessions',
        'reminders',
      ]) {
        await txn.delete(table);
      }

      final batch = txn.batch();
      void insertAll(String table, List<Map<String, Object?>> rows) {
        for (final row in rows) {
          batch.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      insertAll('mantras', mantras.map((m) => m.toMap()).toList());
      insertAll('jaap_entries', entries.map((e) => e.toMap()).toList());
      insertAll('sadhanas', sadhanas.map((s) => s.toMap()).toList());
      insertAll('sessions', sessions.map((s) => s.toMap()).toList());
      insertAll('reminders', reminders.map((r) => r.toMap()).toList());
      await batch.commit(noResult: true);
    });

    // A backup made before a mantra shipped should not remove it.
    await AppDatabase.ensureBuiltInMantras(_db);

    final restoredSettings = data['settings'];
    if (restoredSettings is Map<String, Object?>) {
      await _settings.write(
        AppSettings.fromJson(restoredSettings, fallback: _settings.read()),
      );
    }

    final favourites = (data['favouriteStories'] as List<Object?>? ?? const [])
        .map((id) => id.toString())
        .toList();
    await _settings.setFavouriteStoryIds(favourites);

    final jaap = entries.fold<int>(0, (sum, entry) => sum + entry.count);
    AppLogger.i('Restored ${entries.length} entries ($jaap Jaap)');

    return BackupImportResult(
      entries: entries.length,
      mantras: mantras.length,
      jaap: jaap,
    );
  }

  static List<T> _parseList<T>(
    Object? raw,
    T Function(Map<String, Object?>) fromMap,
  ) {
    if (raw == null) return [];
    if (raw is! List) {
      throw const InvalidBackupException('malformed section');
    }
    try {
      return raw
          .cast<Map<String, Object?>>()
          .map(fromMap)
          .toList(growable: false);
    } on Object catch (error, stack) {
      AppLogger.e('Backup section could not be parsed', error, stack);
      throw const InvalidBackupException('malformed record');
    }
  }
}
