import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Small logging seam. Everything the app logs goes through here - nothing is
/// ever printed with `print` - and it is also what a diagnostics report is
/// built from.
///
/// Recent entries are kept in memory, and warnings and errors are appended to
/// a small file once [attachFile] has been called, so a crash from the last
/// session is still there to report after a restart. Nothing leaves the
/// device unless the user sends a report themselves.
abstract final class AppLogger {
  static const String _name = 'japmala';

  /// Entries kept in memory for a report.
  static const int bufferSize = 300;

  /// The log file is cut back to its newest half beyond this.
  static const int maxFileBytes = 128 * 1024;

  static final Queue<String> _recent = Queue<String>();
  static File? _file;
  static Future<void> _fileWrites = Future<void>.value();

  static void d(String message) => _log(message, level: 500);
  static void i(String message) => _log(message, level: 800);
  static void w(String message) => _log(message, level: 900);

  static void e(String message, [Object? error, StackTrace? stack]) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stack,
    );
    _remember(
      'E',
      [
        message,
        if (error != null) '$error',
        if (stack != null) _trim(stack),
      ].join('\n'),
    );
  }

  static void _log(String message, {required int level}) {
    // Release builds keep the console to warnings, as before; info still
    // reaches the report, where "scheduled 2 reminders" explains a lot.
    if (!kReleaseMode || level >= 900) {
      developer.log(message, name: _name, level: level);
    }
    if (level >= 800) _remember(level >= 900 ? 'W' : 'I', message);
  }

  static void _remember(String level, String message) {
    final line = '${DateTime.now().toIso8601String()} $level $message';
    _recent.addLast(line);
    while (_recent.length > bufferSize) {
      _recent.removeFirst();
    }
    if (level != 'I') _append(line);
  }

  /// The first frames of a stack are where the fault is; the rest is the
  /// framework calling down to it.
  static String _trim(StackTrace stack) =>
      stack.toString().split('\n').take(12).join('\n');

  /// Starts keeping warnings and errors in [file] across launches.
  static void attachFile(File file) => _file = file;

  static void _append(String line) {
    final file = _file;
    if (file == null) return;
    _fileWrites = _fileWrites.then((_) async {
      try {
        await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
        if (await file.length() > maxFileBytes) {
          final text = await file.readAsString();
          await file.writeAsString(text.substring(text.length ~/ 2));
        }
      } on Object {
        // Logging must never be the thing that breaks the app.
      }
    });
  }

  /// This session's entries, oldest first.
  static List<String> recent() => List.unmodifiable(_recent);

  /// Warnings and errors kept across launches, including earlier sessions.
  static Future<String> persisted() async {
    await _fileWrites;
    final file = _file;
    if (file == null || !await file.exists()) return '';
    return file.readAsString();
  }

  /// Empties the log, for tests and after a report has been sent.
  static Future<void> clear() async {
    _recent.clear();
    await _fileWrites;
    final file = _file;
    if (file != null && await file.exists()) await file.writeAsString('');
  }

  @visibleForTesting
  static void detachFile() => _file = null;
}
