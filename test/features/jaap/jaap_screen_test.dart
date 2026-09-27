import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/jaap/presentation/counter_prefs.dart';
import 'package:japmala/features/jaap/presentation/widgets/falling_mantra.dart';
import 'package:japmala/features/settings/domain/mala_style.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_screen.dart';
import 'package:japmala/features/jaap/presentation/widgets/mala_complete_overlay.dart';
import 'package:japmala/features/jaap/presentation/widgets/mala_ring.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

void main() {
  late TestClock clock;
  late ProviderContainer container;

  setUp(() async {
    clock = TestClock(DateTime(2026, 9, 3, 9));
    container = await createTestContainer(clock: clock);
  });

  Future<void> pumpJaap(WidgetTester tester) async {
    await usePhoneSurface(tester);
    // Haptics on a test device would just log; the behaviour under test is
    // the counting, so they are switched off.
    await container.read(settingsProvider.notifier).setHaptics(false);
    await pumpScreen(tester, container, const JaapScreen());
    await tester.pumpAndSettle();
  }

  testWidgets('shows the mantra, the mala and today\'s total', (tester) async {
    await pumpJaap(tester);

    // Once large on the counter and once in the switcher above it.
    expect(find.text('Ram'), findsNWidgets(2));
    expect(find.byType(MalaRing), findsOneWidget);
    expect(find.text("Today's Jaap"), findsOneWidget);
    expect(find.text('Tap anywhere to count'), findsOneWidget);
    expect(find.text('108'), findsOneWidget, reason: 'the mala size');
  });

  testWidgets('tapping the counter increases the count on screen', (
    tester,
  ) async {
    await pumpJaap(tester);

    await tester.tap(find.byType(MalaRing));
    await tester.pump();

    expect(find.text('1'), findsWidgets);
    expect(container.read(jaapControllerProvider).value!.todayTotal, 1);

    await tester.tap(find.byType(MalaRing));
    await tester.pump();

    expect(container.read(jaapControllerProvider).value!.todayTotal, 2);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tapping away from the ring counts too, and the hint goes', (
    tester,
  ) async {
    await pumpJaap(tester);

    await tester.tap(find.text("Today's Jaap"));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(container.read(jaapControllerProvider).value!.todayTotal, 1);
    expect(find.text('Tap anywhere to count'), findsNothing);
  });

  testWidgets('undo is disabled until something has been counted', (
    tester,
  ) async {
    await pumpJaap(tester);

    expect(
      container.read(jaapControllerProvider).value!.undoAvailable,
      isFalse,
    );

    await tester.tap(find.byType(MalaRing));
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(jaapControllerProvider).value!.undoAvailable, isTrue);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(jaapControllerProvider).value!.todayTotal, 0);
    expect(find.text('Count removed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('finishing a mala acknowledges it without blocking', (
    tester,
  ) async {
    await container.read(jaapControllerProvider.future);
    await container.read(settingsProvider.notifier).setHaptics(false);
    await container.read(jaapControllerProvider.notifier).addManualCount(107);
    await pumpJaap(tester);

    await tester.tap(find.byType(MalaRing));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mala Complete'), findsOneWidget);
    expect(find.text('1 Mala completed · 108 Jaap'), findsOneWidget);

    // It fades on its own: no button to dismiss, nothing to tap through.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedOpacity>(
            find
                .descendant(
                  of: find.byType(MalaCompleteOverlay),
                  matching: find.byType(AnimatedOpacity),
                )
                .first,
          )
          .opacity,
      0,
    );
  });

  testWidgets('the goal line reports what is left and then completion', (
    tester,
  ) async {
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(2);
    await pumpJaap(tester);

    expect(find.text('2 to go'), findsOneWidget);

    await tester.tap(find.byType(MalaRing));
    await tester.pump();
    expect(find.text('1 to go'), findsOneWidget);

    await tester.tap(find.byType(MalaRing));
    await tester.pump();
    expect(find.text('Daily goal reached'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('renders in Hindi when the app is set to Hindi', (tester) async {
    await usePhoneSurface(tester);
    await container.read(settingsProvider.notifier).setHaptics(false);
    await pumpScreen(
      tester,
      container,
      const JaapScreen(),
      locale: const Locale('hi'),
    );
    await tester.pumpAndSettle();

    expect(find.text('आज का जाप'), findsOneWidget);
    expect(find.text('गिनने के लिए कहीं भी स्पर्श करें'), findsOneWidget);
  });

  testWidgets('the mala follows the chosen style', (tester) async {
    await pumpJaap(tester);
    expect(
      tester.widget<MalaRing>(find.byType(MalaRing)).style,
      MalaStyle.beads,
    );

    await container
        .read(settingsProvider.notifier)
        .setMalaStyle(MalaStyle.ring);
    await tester.pumpAndSettle();
    expect(
      tester.widget<MalaRing>(find.byType(MalaRing)).style,
      MalaStyle.ring,
    );
  });

  testWidgets('showing the mantra and making it fall are separate choices', (
    tester,
  ) async {
    await pumpJaap(tester);
    expect(find.byType(FallingMantra), findsNothing, reason: 'off by default');

    // Turned on, hidden text: still falls.
    await container.read(settingsProvider.notifier).setFallingMantra(true);
    container.read(hideMantraProvider.notifier).set(true);
    await tester.pumpAndSettle();
    expect(find.byType(FallingMantra), findsOneWidget);
    expect(find.text('Ram'), findsOneWidget, reason: 'only the switcher');

    // Shown text, falling turned off again.
    container.read(hideMantraProvider.notifier).set(false);
    await container.read(settingsProvider.notifier).setFallingMantra(false);
    await tester.pumpAndSettle();
    expect(find.byType(FallingMantra), findsNothing);
    expect(find.text('Ram'), findsNWidgets(2));
  });

  testWidgets('the header opens meditation mode, the menu toggles falling '
      'mantra', (tester) async {
    await pumpJaap(tester);

    expect(find.byIcon(Icons.self_improvement_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).fallingMantra, isFalse);

    // Off by default, so the menu offers to start it.
    await tester.tap(find.text('Falling mantra'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).fallingMantra, isTrue);

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop falling mantra'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).fallingMantra, isFalse);
  });
}
