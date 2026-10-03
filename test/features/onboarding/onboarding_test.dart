import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/app/theme/app_themes.dart';
import 'package:japmala/features/jaap/presentation/counter_prefs.dart';
import 'package:japmala/features/onboarding/presentation/onboarding_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/l10n/app_localizations.dart';

import '../../support/test_harness.dart';

void main() {
  testWidgets('onboarding ends on the chosen mantra and goal', (tester) async {
    await usePhoneSurface(tester);
    final container = await createTestContainer();
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(path: '/jaap', builder: (_, _) => const Text('counter')),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        // Follows the language setting, as the real app does, so the
        // English / हिन्दी switch shows on screen.
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            locale: ref.watch(settingsProvider).locale,
            theme: AppTheme.light(),
            routerConfig: router,
            localizationsDelegates: const [
              AppL10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppL10n.supportedLocales,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    // The tour of features sits between the welcome and the personal steps.
    expect(find.text('Everything in your hands'), findsOneWidget);
    expect(find.text('Auto Jaap'), findsOneWidget);
    expect(find.text('Bring your own music'), findsOneWidget);
    expect(find.text('Calming sounds'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Which mantra do you chant?'), findsOneWidget);
    expect(container.read(settingsProvider).localeCode, isNull);
    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).localeCode, 'hi');
    expect(find.text('राधा राधा'), findsOneWidget, reason: 'mantras follow');
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).localeCode, 'en');
    expect(find.text('राधा राधा'), findsNothing);

    await tester.tap(find.text('Radha Radha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // How the counter looks and sounds is chosen before the goal.
    expect(find.text('Make it yours'), findsOneWidget);
    await tester.tap(find.text('Ocean'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).themeId, AppThemeId.ocean);
    for (final key in ['onb-show-mantra', 'onb-falling-mantra', 'onb-music']) {
      await tester.scrollUntilVisible(
        find.byKey(ValueKey(key)),
        200,
        scrollable: find.byType(Scrollable).last,
      );
    }
    await tester.tap(find.byKey(const ValueKey('onb-falling-mantra')));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).fallingMantra, isTrue);
    await tester.tap(find.byKey(const ValueKey('onb-show-mantra')));
    await tester.pumpAndSettle();
    expect(container.read(hideMantraProvider), isTrue);
    expect(find.text('Music'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Your daily goal'), findsOneWidget);
    await tester.tap(find.text('11 malas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Jap'));
    await tester.pumpAndSettle();

    final settings = container.read(settingsProvider);
    expect(find.text('counter'), findsOneWidget);
    expect(settings.onboardingComplete, isTrue);
    expect(settings.activeMantraId, 'builtin.radha');
    expect(settings.fallbackDailyGoal, 1188);
  });

  group('the mantra page', () {
    Future<ProviderContainer> pumpMantraPage(WidgetTester tester) async {
      await usePhoneSurface(tester);
      final container = await createTestContainer();
      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, _) => const OnboardingScreen(),
          ),
          GoRoute(path: '/jaap', builder: (_, _) => const Text('counter')),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) => MaterialApp.router(
              locale: ref.watch(settingsProvider).locale,
              theme: AppTheme.light(),
              routerConfig: router,
              localizationsDelegates: const [
                AppL10n.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppL10n.supportedLocales,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      return container;
    }

    testWidgets('shows the mantras in the script of each language', (
      tester,
    ) async {
      await pumpMantraPage(tester);

      for (final (chip, ram) in [
        ('ગુજરાતી', 'રામ રામ'),
        ('ਪੰਜਾਬੀ', 'ਰਾਮ ਰਾਮ'),
        ('தமிழ்', 'ராம ராம'),
        ('తెలుగు', 'రామ రామ'),
        ('मराठी', 'राम राम'),
        ('English', 'Ram Ram'),
      ]) {
        await tester.tap(find.text(chip));
        await tester.pumpAndSettle();
        expect(find.text(ram), findsOneWidget, reason: chip);
      }
    });

    testWidgets('scrolls from the header, not only the list', (tester) async {
      await pumpMantraPage(tester);
      final title = find.text('Which mantra do you chant?');
      expect(title, findsOneWidget);
      final before = tester.getTopLeft(title).dy;

      // Dragging on the title itself: if only the list scrolled, this would
      // do nothing.
      await tester.drag(title, const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(title, findsOneWidget);
      expect(tester.getTopLeft(title).dy, lessThan(before - 50));
    });

    testWidgets('can reach the last mantra and add your own', (tester) async {
      await pumpMantraPage(tester);

      await tester.scrollUntilVisible(
        find.text('Hare Rama Hare Rama Rama Rama Hare Hare'),
        300,
        scrollable: find.byType(Scrollable).last,
      );

      expect(
        find.text('Hare Rama Hare Rama Rama Rama Hare Hare'),
        findsOneWidget,
      );
    });
  });
}
