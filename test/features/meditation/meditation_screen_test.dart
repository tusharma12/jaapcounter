import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/meditation/presentation/meditation_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

void main() {
  Future<ProviderContainer> pumpMeditation(WidgetTester tester) async {
    await usePhoneSurface(tester);
    final container = await createTestContainer();
    await container.read(settingsProvider.notifier).setHaptics(false);
    await container.read(jaapControllerProvider.future);
    await pumpScreen(tester, container, const MeditationScreen());
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  /// Runs animations to the end. This screen has a ticking timer, so
  /// pumpAndSettle would never return; and one long pump would only start a
  /// slide-in, not finish it.
  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  int beads(ProviderContainer c) =>
      c.read(jaapControllerProvider).value!.position.beadsInCurrentMala;

  testWidgets('offers Auto Jaap beside the other controls', (tester) async {
    await pumpMeditation(tester);

    expect(find.text('Auto Jaap'), findsOneWidget);
    expect(find.text('Timer'), findsWidgets);
    expect(find.text('Blackout'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'four controls fit');
  });

  testWidgets('its control opens the sheet, and starting runs it', (
    tester,
  ) async {
    final container = await pumpMeditation(tester);

    await tester.tap(find.text('Auto Jaap'));
    await pumpFrames(tester);
    expect(find.text('Start Auto Jaap'), findsOneWidget);
    expect(beads(container), 0, reason: 'the control is not a bead');

    await tester.tap(find.text('Start Auto Jaap'));
    await pumpFrames(tester);
    expect(container.read(autoJaapProvider).running, isTrue);
    expect(find.text('Stop Auto Jaap'), findsOneWidget);

    container.read(autoJaapProvider.notifier).stop();
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('the same control stops it, and a tap stops it too', (
    tester,
  ) async {
    final container = await pumpMeditation(tester);
    container.read(autoJaapProvider.notifier).start();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Stop Auto Jaap'));
    await tester.pump();
    expect(container.read(autoJaapProvider).running, isFalse);

    container.read(autoJaapProvider.notifier).start();
    await tester.pump(const Duration(milliseconds: 300));
    final before = beads(container);
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    expect(container.read(autoJaapProvider).running, isFalse);
    expect(beads(container), before, reason: 'the stopping tap is no bead');
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('a tap counts when Auto Jaap is not running', (tester) async {
    final container = await pumpMeditation(tester);

    await tester.tapAt(const Offset(200, 300));
    await tester.pump();

    expect(beads(container), 1);
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
    await tester.pump(const Duration(seconds: 3));
  });
}
