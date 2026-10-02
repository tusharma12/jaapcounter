import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/features/mantras/domain/mantra_names.dart';
import 'package:japmala/features/meditation/presentation/blackout_screen.dart';

import '../../support/test_harness.dart';

void main() {
  testWidgets('blackout counts on any tap, and its buttons never do', (
    tester,
  ) async {
    await usePhoneSurface(tester);
    final container = await createTestContainer();
    await container.read(jaapControllerProvider.future);
    int beads() => container
        .read(jaapControllerProvider)
        .value!
        .position
        .beadsInCurrentMala;
    // The app runs in English here, so the built-in shows as "Ram".
    final mantra = container
        .read(jaapControllerProvider)
        .value!
        .mantra
        .nameIn('en');

    await pumpScreen(tester, container, const BlackoutScreen());
    await tester.pumpAndSettle();

    expect(find.text(mantra), findsNothing, reason: 'starts fully black');

    await tester.tap(find.byKey(const ValueKey('blackout-tap-area')));
    await tester.tap(find.byKey(const ValueKey('blackout-tap-area')));
    await tester.pump();
    expect(beads(), 2);

    await tester.tap(find.byKey(const ValueKey('blackout-show-mantra')));
    await tester.pump();
    expect(find.text(mantra), findsOneWidget);
    expect(find.text('2 / 108'), findsOneWidget);
    expect(beads(), 2, reason: 'the show-mantra button is not a bead');

    await tester.tap(find.byKey(const ValueKey('blackout-show-mantra')));
    await tester.pump();
    expect(find.text(mantra), findsNothing);

    await tester.tap(find.byKey(const ValueKey('blackout-exit')));
    await tester.pumpAndSettle();
    expect(beads(), 2, reason: 'nor is exit');

    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
    await tester.pump(const Duration(seconds: 3));
  });

  group('Auto Jaap', () {
    Future<ProviderContainer> pumpBlackout(WidgetTester tester) async {
      await usePhoneSurface(tester);
      final container = await createTestContainer();
      await container.read(settingsProvider.notifier).setHaptics(false);
      await container.read(jaapControllerProvider.future);
      await pumpScreen(tester, container, const BlackoutScreen());
      await tester.pumpAndSettle();
      return container;
    }

    int beads(ProviderContainer c) =>
        c.read(jaapControllerProvider).value!.position.beadsInCurrentMala;

    testWidgets('can be started from the blackout screen', (tester) async {
      final container = await pumpBlackout(tester);

      await tester.tap(find.byKey(const ValueKey('blackout-auto-jaap')));
      await tester.pumpAndSettle();
      expect(find.text('Start Auto Jaap'), findsOneWidget);
      expect(beads(container), 0, reason: 'opening the sheet is not a bead');

      await tester.tap(find.text('Start Auto Jaap'));
      await tester.pumpAndSettle();
      expect(container.read(autoJaapProvider).running, isTrue);

      // The first bead is immediate; the next follows the pace.
      await tester.pump(const Duration(milliseconds: 100));
      expect(beads(container), greaterThanOrEqualTo(1));

      container.read(autoJaapProvider.notifier).stop();
      await container
          .read(jaapControllerProvider.notifier)
          .flushPendingWrites();
      // Let the wait between automatic beads run out before the test ends.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('a tap anywhere stops it instead of counting', (tester) async {
      final container = await pumpBlackout(tester);
      container.read(autoJaapProvider.notifier).start();
      await tester.pump(const Duration(milliseconds: 100));
      final before = beads(container);
      expect(container.read(autoJaapProvider).running, isTrue);

      await tester.tap(find.byKey(const ValueKey('blackout-tap-area')));
      await tester.pump();

      expect(container.read(autoJaapProvider).running, isFalse);
      expect(beads(container), before, reason: 'the stopping tap is no bead');

      // Back to ordinary counting.
      await tester.tap(find.byKey(const ValueKey('blackout-tap-area')));
      await tester.pump();
      expect(beads(container), before + 1);
      await container
          .read(jaapControllerProvider.notifier)
          .flushPendingWrites();
      // Let the wait between automatic beads run out before the test ends.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('its button stops a run that is under way', (tester) async {
      final container = await pumpBlackout(tester);
      container.read(autoJaapProvider.notifier).start();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('blackout-auto-jaap')));
      await tester.pump();

      expect(container.read(autoJaapProvider).running, isFalse);
      expect(find.text('Start Auto Jaap'), findsNothing);
      await container
          .read(jaapControllerProvider.notifier)
          .flushPendingWrites();
      // Let the wait between automatic beads run out before the test ends.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
