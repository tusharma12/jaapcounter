import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/providers.dart';
import 'core/services/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
