import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/mantra_audio_service.dart';
import 'package:japmala/core/services/voice_note_store.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/mantras/presentation/mantra_controllers.dart';

import '../../support/test_harness.dart';

/// Stands in for the microphone and speaker: records what it was asked to
/// play and finishes at once, as a very short recording would.
class _FakeAudio implements MantraAudioService {
  final List<String> played = [];
  int stops = 0;

  @override
  Future<void> playToEnd(String path, {Duration? timeout}) async =>
      played.add(path);

  @override
  Future<void> stopPlayback() async => stops++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory base;
  late _FakeAudio audio;

  setUp(() async {
    base = await Directory.systemTemp.createTemp('autovoice');
    addTearDown(() => base.delete(recursive: true));
    audio = _FakeAudio();
  });

  Future<ProviderContainer> containerWith({required bool recorded}) async {
    final store = VoiceNoteStore(baseDirectory: () async => base);
    final container = await createTestContainer(
      overrides: [
        voiceNoteStoreProvider.overrideWithValue(store),
        mantraAudioServiceProvider.overrideWithValue(audio),
      ],
    );
    await store.write('mine.m4a', [1, 2, 3]);
    final mantra = await container
        .read(mantraRepositoryProvider)
        .create(name: 'Om Namah', audioPath: recorded ? 'mine.m4a' : null);
    await container.read(mantraListProvider.future);
    await container.read(mantraListProvider.notifier).setActive(mantra.id);
    await container.read(jaapControllerProvider.future);
    return container;
  }

  // Real timers and real files: the check for the recording touches disk,
  // which a fake clock would never let finish.
  Future<void> runBriefly(
    ProviderContainer container, {
    bool playChant = true,
  }) async {
    final auto = container.read(autoJaapProvider.notifier);
    await auto.updateConfig(
      AutoJaapConfig(
        interval: const Duration(milliseconds: 40),
        stopAfter: AutoJaapStop.never,
        playChant: playChant,
      ),
    );
    auto.start();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    auto.stop();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  }

  test('each automatic bead plays the mantra\'s own recording', () async {
    final container = await containerWith(recorded: true);

    await runBriefly(container);

    expect(audio.played, isNotEmpty);
    expect(audio.played.toSet(), {'${base.path}/mantra_audio/mine.m4a'});
    expect(audio.stops, 1, reason: 'stopping cuts the recording off');
  });

  test('a mantra without a recording stays silent', () async {
    final container = await containerWith(recorded: false);

    await runBriefly(container);

    expect(audio.played, isEmpty);
  });

  test('switching the chant off keeps a recorded mantra silent', () async {
    final container = await containerWith(recorded: true);

    await runBriefly(container, playChant: false);

    expect(audio.played, isEmpty);
    expect(
      container.read(jaapControllerProvider).value!.position.beadsInCurrentMala,
      greaterThan(0),
      reason: 'the beads still count',
    );
  });
}
