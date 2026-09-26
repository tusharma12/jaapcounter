import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/utils/day_key.dart';
import 'package:japmala/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens the production schema in memory. Tests exercise the same SQL the
/// app ships, which is the only way ledger behaviour is worth testing.
///
/// The no-isolate factory matters for widget tests: `testWidgets` runs inside
/// a fake async zone, and work completing on a background isolate would never
/// be delivered while `pumpAndSettle` spins the fake clock.
Future<Database> openTestDatabase() async {
  sqfliteFfiInit();
  return AppDatabase.openInMemory(databaseFactoryFfiNoIsolate);
}

/// A clock the test moves by hand, so day rollover and streaks are testable.
class TestClock {
  TestClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  void set(DateTime value) => _now = value;

  void advance(Duration duration) => _now = _now.add(duration);

  void advanceDays(int days) =>
      _now = DateTime(_now.year, _now.month, _now.day + days, _now.hour, _now.minute);

  String get today => DayKeys.of(_now);
}

/// A container wired to an in-memory database and empty preferences.
Future<ProviderContainer> createTestContainer({
  TestClock? clock,
  Map<String, Object> preferences = const {},
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  final database = await openTestDatabase();
  final testClock = clock ?? TestClock(DateTime(2026, 9, 3, 9));

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      databaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(testClock.call),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  addTearDown(database.close);
  return container;
}

/// Sizes the test surface like a phone, so layouts are exercised at the
/// dimensions they ship at rather than the 800x600 default.
Future<void> usePhoneSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Pumps a screen inside the app's theme and localisations.
Future<void> pumpScreen(
  WidgetTester tester,
  ProviderContainer container,
  Widget screen, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pump();
}
