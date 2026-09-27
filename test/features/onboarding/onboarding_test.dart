import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:japmala/app/theme/app_theme.dart';
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
        child: MaterialApp.router(
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
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Which mantra do you chant?'), findsOneWidget);
    await tester.tap(find.text('राधा'));
    await tester.pumpAndSettle();
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
}
