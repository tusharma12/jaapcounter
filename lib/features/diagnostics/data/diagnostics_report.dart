import 'dart:io' show Platform;

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/app_logger.dart';
import '../../settings/domain/app_settings.dart';

/// A plain-text report for a bug email: what the app and phone are, how the
/// app is set up, and what it logged.
///
/// It deliberately leaves out what the user has chanted - no mantra text, no
/// counts, no notes - only how many rows there are, which is enough to tell a
/// fresh install from a long-used one.
class DiagnosticsReport {
  DiagnosticsReport({
    required Database database,
    required AppSettings settings,
    required String appVersion,
    String? buildNumber,
    String? platform,
    DateTime Function()? clock,
  }) : _db = database,
       _config = settings,
       _version = appVersion,
       _build = buildNumber,
       _platform =
           platform ??
           '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
       _now = clock ?? DateTime.now;

  final Database _db;
  final AppSettings _config;
  final String _version;
  final String? _build;
  final String _platform;
  final DateTime Function() _now;

  Future<String> build() async {
    Future<int> count(String table, [String? where]) async {
      final rows = await _db.rawQuery(
        'SELECT COUNT(*) AS n FROM $table${where == null ? '' : ' WHERE $where'}',
      );
      return (rows.first['n'] as int?) ?? 0;
    }

    final s = _config;
    final persisted = (await AppLogger.persisted()).trim();
    final recent = AppLogger.recent();

    return [
      'JaapMitra diagnostics',
      'Generated: ${_now().toIso8601String()}',
      'App: $_version${_build == null ? '' : ' ($_build)'}',
      'Platform: $_platform',
      'Language: ${s.localeCode ?? 'device'}',
      'Database: schema v${await _db.getVersion()} '
          '(app expects v${AppDatabase.schemaVersion})',
      'Rows: ${await count('jaap_entries')} entries, '
          '${await count('mantras', 'is_built_in = 0')} custom mantras, '
          '${await count('sessions')} sessions, '
          '${await count('sadhanas', 'is_active = 1')} active Sankalp, '
          '${await count('reminders', 'enabled = 1')} reminders on',
      'Settings: theme ${s.themeId.name}, haptics ${_onOff(s.hapticsEnabled)}, '
          'sound ${_onOff(s.soundEnabled)}, buttons ${_onOff(s.hardwareKeyCounting)}, '
          'marker ${s.beadMarkerInterval}, grace ${_onOff(s.graceDaysEnabled)}, '
          'festival reminders ${_onOff(s.festivalReminders)}, '
          'mala ${s.malaStyle.name}, background ${s.background.name}',
      '',
      '--- This session (${recent.length}) ---',
      if (recent.isEmpty) '(nothing logged)' else ...recent,
      '',
      '--- Warnings and errors kept across launches ---',
      if (persisted.isEmpty) '(none)' else persisted,
    ].join('\n');
  }

  static String _onOff(bool value) => value ? 'on' : 'off';
}
