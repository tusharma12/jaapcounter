import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/providers.dart';
import 'core/services/app_logger.dart';
import 'core/utils/formatters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Fmt.useLatinDigits();

  // First, so a failure opening the database is itself on record.
  try {
    final support = await getApplicationSupportDirectory();
    await support.create(recursive: true);
    AppLogger.attachFile(File('${support.path}/diagnostics.log'));
  } on Object catch (error, stack) {
    AppLogger.e('Diagnostics log unavailable', error, stack);
  }

  // Everything the app needs to render its first frame is opened here, so no
  // screen has to deal with an uninitialised repository.
  final preferences = await SharedPreferences.getInstance();
  final database = await AppDatabase.open();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (details) {
    AppLogger.e('Uncaught framework error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  // Errors outside the framework - a failed future nobody awaited - would
  // otherwise vanish without a trace.
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e('Uncaught error', error, stack);
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        databaseProvider.overrideWithValue(database),
      ],
      child: const JapMalaApp(),
    ),
  );
}
