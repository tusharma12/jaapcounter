import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Small logging seam. Everything the app logs goes through here so a crash
/// reporter can be added later in one place - and so nothing is ever printed
/// with `print`.
abstract final class AppLogger {
  static const String _name = 'japmala';

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
  }

  static void _log(String message, {required int level}) {
    if (kReleaseMode && level < 900) return;
    developer.log(message, name: _name, level: level);
  }
}
