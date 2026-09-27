import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
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
    final mantra = container.read(jaapControllerProvider).value!.mantra.name;

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
  });
}
