import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/backup/presentation/backup_screen.dart';
import 'package:japmala/features/jaap/presentation/jaap_screen.dart';
import 'package:japmala/features/mantras/presentation/mantras_screen.dart';
import 'package:japmala/features/meditation/presentation/blackout_screen.dart';
import 'package:japmala/features/meditation/presentation/meditation_screen.dart';
import 'package:japmala/features/onboarding/presentation/onboarding_screen.dart';
import 'package:japmala/features/progress/presentation/progress_screen.dart';
import 'package:japmala/features/progress/presentation/year_review_screen.dart';
import 'package:japmala/features/reminders/presentation/reminders_screen.dart';
import 'package:japmala/features/sadhana/presentation/sadhana_screen.dart';
import 'package:japmala/features/settings/presentation/about_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/features/settings/presentation/settings_screen.dart';
import 'package:japmala/features/stories/presentation/stories_screen.dart';

import 'support/test_harness.dart';

/// Every screen, laid out the way an older user with large text sees it, and
/// checked against the platform accessibility guidelines.
///
/// Much of this app's audience reads at a large text size and some use a
/// screen reader, so a layout that overflows at 200% or a button without a
/// name is a bug, not a nicety.
void main() {
  final screens = <String, Widget Function()>{
    'counter': () => const JaapScreen(),
    'progress': () => const ProgressScreen(),
    'sadhana': () => const SadhanaScreen(),
    'settings': () => const SettingsScreen(),
    'settings counter': () =>
        const SettingsScreen(section: SettingsSection.counter),
    'settings jaap': () => const SettingsScreen(section: SettingsSection.jaap),
    'year in review': () => const YearReviewScreen(),
    'mantras': () => const MantrasScreen(),
    'meditation': () => const MeditationScreen(),
    'blackout': () => const BlackoutScreen(),
    'reminders': () => const RemindersScreen(),
    'backup': () => const BackupScreen(),
    'about': () => const AboutScreen(),
    'stories': () => const StoriesScreen(),
    'onboarding': () => const OnboardingScreen(),
  };

  /// Two weeks of practice, so the charts, streak and milestones all draw.
  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    double textScale = 1,
    String language = 'en',
  }) async {
    final clock = TestClock(DateTime(2026, 10, 15, 9));
    final container = await createTestContainer(clock: clock);
    await container.read(settingsProvider.notifier).setHaptics(false);
    final repo = container.read(jaapRepositoryProvider);
    for (var day = 1; day <= 14; day++) {
      clock.set(DateTime(2026, 10, day, 8));
      await repo.addBeads(mantraId: 'builtin.ram', delta: 120 * day);
    }
    clock.set(DateTime(2026, 10, 15, 9));

    await usePhoneSurface(tester);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpScreen(tester, container, screen, locale: Locale(language));
    // Several screens animate for ever (the ring, the timer), so they are
    // pumped for a while rather than settled.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Scrolls to the end, so what is below the fold is laid out too.
  Future<void> scrollThrough(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isEmpty) return;
    for (var i = 0; i < 6; i++) {
      await tester.drag(
        scrollable.first,
        const Offset(0, -500),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  }

  group('at 200% text nothing overflows', () {
    for (final language in ['en', 'hi']) {
      for (final MapEntry(key: name, value: screen) in screens.entries) {
        testWidgets('$name ($language)', (tester) async {
          await pump(tester, screen(), textScale: 2, language: language);
          await scrollThrough(tester);
          // An overflow is reported as a framework error, which the test
          // binding turns into a failure of this test.
          expect(tester.takeException(), isNull);
          await unmount(tester);
        });
      }
    }
  });

  group('meets the tap target, label and contrast guidelines', () {
    for (final MapEntry(key: name, value: screen) in screens.entries) {
      testWidgets(name, (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, screen());

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        semantics.dispose();
        await unmount(tester);
      });
    }
  });
}
