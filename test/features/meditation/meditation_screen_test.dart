import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/ambient_chant_service.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/meditation/presentation/meditation_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

/// Records what it is asked to play instead of making a sound.
class _FakeChants implements AmbientChantService {
  final List<String> played = [];
  int stops = 0;

  @override
  String? get playing => played.isEmpty ? null : played.last;

  @override
  Future<void> play(String id) async => played.add(id);

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> fadeOutAndStop({Duration fade = const Duration(seconds: 4)}) =>
      stop();

  @override
  Future<void> dispose() async {}
}

void main() {
  final chants = _FakeChants();

  Future<ProviderContainer> pumpMeditation(WidgetTester tester) async {
    await usePhoneSurface(tester);
    final container = await createTestContainer(
      overrides: [ambientChantProvider.overrideWithValue(chants)],
    );
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

  testWidgets('the Chant sheet plays and stops the background sound', (
    tester,
  ) async {
    chants.played.clear();
    await pumpMeditation(tester);

    await tester.tap(find.text('Chant'));
    await pumpFrames(tester);
    expect(find.text('Play'), findsOneWidget);
    expect(chants.played, isEmpty, reason: 'opening the sheet is silent');

    await tester.tap(find.byKey(const ValueKey('chant-play-stop')));
    await pumpFrames(tester);
    expect(chants.played, ['ram_ram']);
    expect(find.text('Stop'), findsOneWidget);

    final stopsBefore = chants.stops;
    await tester.tap(find.byKey(const ValueKey('chant-play-stop')));
    await pumpFrames(tester);
    expect(chants.stops, stopsBefore + 1);
    expect(find.text('Play'), findsOneWidget);

    // Choosing a sound plays that one.
    await tester.tap(find.text('Sitar and Flute'));
    await pumpFrames(tester);
    expect(chants.played.last, 'sitar_flute');
    expect(find.text('Stop'), findsOneWidget);
  });
}
