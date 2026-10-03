import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/ambient_chant_service.dart';
import 'package:japmala/core/services/music_recorder_service.dart';
import 'package:japmala/core/services/user_music_store.dart';
import 'package:japmala/features/meditation/presentation/music_controllers.dart';
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
  Future<void> play(AmbientChant chant) async => played.add(chant.id);

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> fadeOutAndStop({Duration fade = const Duration(seconds: 4)}) =>
      stop();

  @override
  Future<void> dispose() async {}
}

/// Writes a tiny file where the real recorder would, and hands back its path.
class _FakeRecorder implements MusicRecorderService {
  _FakeRecorder({this.allowed = true});

  final bool allowed;
  String? _path;

  @override
  Future<bool> hasPermission() async => allowed;

  @override
  Future<void> start(String path) async {
    _path = path;
    File(path).writeAsBytesSync([1, 2, 3]);
  }

  @override
  Future<String?> stop() async => _path;

  @override
  Future<void> cancel() async {}

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

  /// Lets chained file work finish: each step needs real time to complete
  /// and the test clock to hand its result on.
  Future<void> settleFiles(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
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

  testWidgets('the Auto Jaap sheet has a Sound switch and a choose button', (
    tester,
  ) async {
    chants.played.clear();
    final container = await pumpMeditation(tester);

    await tester.tap(find.text('Auto Jaap'));
    await pumpFrames(tester);
    expect(find.byKey(const ValueKey('auto-jaap-sound')), findsOneWidget);
    expect(find.text('Breath of the Valley'), findsOneWidget);
    expect(container.read(autoJaapProvider).config.playMusic, isFalse);

    await tester.tap(find.byKey(const ValueKey('auto-jaap-sound-switch')));
    await pumpFrames(tester);
    expect(container.read(autoJaapProvider).config.playMusic, isTrue);
    expect(chants.played, isEmpty, reason: 'the switch alone is silent');

    await tester.tap(find.byKey(const ValueKey('auto-jaap-choose-sound')));
    await pumpFrames(tester);
    await tester.tap(find.text('Inner Peace'));
    await pumpFrames(tester);
    expect(chants.played.last, 'meditation_4', reason: 'a preview plays');
  });

  testWidgets('the Chant sheet plays and stops the background sound', (
    tester,
  ) async {
    chants.played.clear();
    await pumpMeditation(tester);

    await tester.tap(find.text('Music'));
    await pumpFrames(tester);
    expect(find.text('Play'), findsOneWidget);
    expect(chants.played, isEmpty, reason: 'opening the sheet is silent');

    await tester.tap(find.byKey(const ValueKey('chant-play-stop')));
    await pumpFrames(tester);
    expect(chants.played, ['breath_of_the_valley']);
    expect(find.text('Stop'), findsOneWidget);

    final stopsBefore = chants.stops;
    await tester.tap(find.byKey(const ValueKey('chant-play-stop')));
    await pumpFrames(tester);
    expect(chants.stops, stopsBefore + 1);
    expect(find.text('Play'), findsOneWidget);

    // Choosing a sound plays that one.
    await tester.tap(find.text('Evening Stillness'));
    await pumpFrames(tester);
    expect(chants.played.last, 'meditation_3');
    expect(find.text('Stop'), findsOneWidget);
  });

  testWidgets('Music is the one place for the user\'s own sound', (
    tester,
  ) async {
    chants.played.clear();
    await usePhoneSurface(tester);
    // Real file work needs real time, not the test clock.
    final base = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('medmusic'),
    ))!;
    addTearDown(() => base.deleteSync(recursive: true));
    final picked = File('${base.path}/bowl.mp3')..writeAsBytesSync([1, 2, 3]);
    final container = await createTestContainer(
      overrides: [
        ambientChantProvider.overrideWithValue(chants),
        userMusicStoreProvider.overrideWithValue(
          UserMusicStore(baseDirectory: () async => base),
        ),
        musicPickerProvider.overrideWithValue(
          () async => PickedMusic(path: picked.path, name: 'Singing bowl'),
        ),
      ],
    );
    await container.read(jaapControllerProvider.future);
    await tester.runAsync(() => container.read(userMusicProvider.future));
    await pumpScreen(tester, container, const MeditationScreen());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Music'));
    await pumpFrames(tester);
    expect(find.text('My music'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Upload'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('music-upload')));
    await settleFiles(tester);

    expect(find.text('Singing bowl'), findsOneWidget);
    expect(chants.played.single, startsWith(userTrackPrefix));
    expect(find.text('Stop'), findsOneWidget, reason: 'it plays at once');

    await tester.tap(find.byTooltip('Remove'));
    await settleFiles(tester);
    expect(find.text('Singing bowl'), findsNothing);
    expect(find.text('Play'), findsOneWidget, reason: 'removal stops it');
  });

  Future<ProviderContainer> pumpWithRecorder(
    WidgetTester tester,
    _FakeRecorder recorder,
  ) async {
    await usePhoneSurface(tester);
    final base = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('medrec'),
    ))!;
    addTearDown(() => base.deleteSync(recursive: true));
    final container = await createTestContainer(
      overrides: [
        ambientChantProvider.overrideWithValue(chants),
        musicRecorderProvider.overrideWithValue(recorder),
        userMusicStoreProvider.overrideWithValue(
          UserMusicStore(baseDirectory: () async => base),
        ),
      ],
    );
    await container.read(jaapControllerProvider.future);
    await tester.runAsync(() => container.read(userMusicProvider.future));
    await pumpScreen(tester, container, const MeditationScreen());
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  testWidgets('a recording becomes a track and plays at once', (tester) async {
    chants.played.clear();
    await pumpWithRecorder(tester, _FakeRecorder());

    await tester.tap(find.text('Music'));
    await pumpFrames(tester);
    await tester.tap(find.byKey(const ValueKey('music-record')));
    await settleFiles(tester);
    expect(
      find.byKey(const ValueKey('music-stop-recording')),
      findsOneWidget,
      reason: 'recording shows a stop button',
    );

    await tester.tap(find.byKey(const ValueKey('music-stop-recording')));
    await settleFiles(tester);
    expect(find.text('Name your recording'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Recording 1'),
      findsOneWidget,
      reason: 'a name is suggested',
    );

    await tester.tap(find.text('Save'));
    await settleFiles(tester);

    expect(find.text('Recording 1'), findsOneWidget);
    expect(chants.played.single, startsWith(userTrackPrefix));
  });

  testWidgets('a recording can be given a name of its own', (tester) async {
    chants.played.clear();
    await pumpWithRecorder(tester, _FakeRecorder());

    await tester.tap(find.text('Music'));
    await pumpFrames(tester);
    await tester.tap(find.byKey(const ValueKey('music-record')));
    await settleFiles(tester);
    await tester.tap(find.byKey(const ValueKey('music-stop-recording')));
    await settleFiles(tester);

    await tester.enterText(
      find.byKey(const ValueKey('music-name-field')),
      '  Morning Om  ',
    );
    await tester.tap(find.text('Save'));
    await settleFiles(tester);

    expect(find.text('Morning Om'), findsOneWidget);
    expect(find.text('Recording 1'), findsNothing);
  });

  testWidgets('an empty name falls back to the suggested one', (tester) async {
    chants.played.clear();
    await pumpWithRecorder(tester, _FakeRecorder());

    await tester.tap(find.text('Music'));
    await pumpFrames(tester);
    await tester.tap(find.byKey(const ValueKey('music-record')));
    await settleFiles(tester);
    await tester.tap(find.byKey(const ValueKey('music-stop-recording')));
    await settleFiles(tester);

    await tester.enterText(find.byKey(const ValueKey('music-name-field')), '');
    await tester.tap(find.text('Save'));
    await settleFiles(tester);

    expect(find.text('Recording 1'), findsOneWidget);
  });

  testWidgets('without microphone access nothing is recorded', (tester) async {
    chants.played.clear();
    await pumpWithRecorder(tester, _FakeRecorder(allowed: false));

    await tester.tap(find.text('Music'));
    await pumpFrames(tester);
    await tester.tap(find.byKey(const ValueKey('music-record')));
    await settleFiles(tester);

    expect(find.byKey(const ValueKey('music-stop-recording')), findsNothing);
    expect(find.text('Microphone access is needed for this'), findsOneWidget);
    expect(find.text('Recording 1'), findsNothing);
  });
}
