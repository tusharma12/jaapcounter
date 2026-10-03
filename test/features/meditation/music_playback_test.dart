import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/ambient_chant_service.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/meditation/presentation/music_playback.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

class _FakeAmbient implements AmbientChantService {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAmbient ambient;

  Future<ProviderContainer> containerWith({
    String? selected,
    bool on = true,
  }) async {
    ambient = _FakeAmbient();
    final container = await createTestContainer(
      preferences: {'meditation.chant': ?selected, 'meditation.chantOn': on},
      overrides: [ambientChantProvider.overrideWithValue(ambient)],
    );
    await container.read(settingsProvider.notifier).setHaptics(false);
    await container.read(settingsProvider.notifier).setSound(false);
    await container.read(jaapControllerProvider.future);
    return container;
  }

  test('Auto Jaap plays the chosen sound and stops it again', () async {
    final c = await containerWith(selected: 'white_noise');
    final auto = c.read(autoJaapProvider.notifier);
    await auto.updateConfig(const AutoJaapConfig(playMusic: true));

    auto.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(ambient.played, ['white_noise']);
    expect(c.read(musicPlaybackProvider).playing, isTrue);

    auto.stop();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(c.read(musicPlaybackProvider).playing, isFalse);
    expect(ambient.stops, 1);
    await c.read(jaapControllerProvider.notifier).flushPendingWrites();
  });

  test('with the sound switch off, Auto Jaap stays silent', () async {
    final c = await containerWith(selected: 'white_noise');

    c.read(autoJaapProvider.notifier).start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    c.read(autoJaapProvider.notifier).stop();

    expect(ambient.played, isEmpty);
    await c.read(jaapControllerProvider.notifier).flushPendingWrites();
  });

  test(
    'music already playing ends with an Auto Jaap run that has sound on',
    () async {
      final c = await containerWith(selected: 'white_noise', on: false);
      await c
          .read(musicPlaybackProvider.notifier)
          .choose('meditation_2', play: true);

      final auto = c.read(autoJaapProvider.notifier);
      await auto.updateConfig(const AutoJaapConfig(playMusic: true));
      auto.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(ambient.played, ['meditation_2'], reason: 'not restarted');

      auto.stop();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(c.read(musicPlaybackProvider).playing, isFalse);
      await c.read(jaapControllerProvider.notifier).flushPendingWrites();
    },
  );

  test(
    'with the sound switch off, Auto Jaap leaves your music alone',
    () async {
      final c = await containerWith(selected: 'white_noise', on: false);
      await c
          .read(musicPlaybackProvider.notifier)
          .choose('meditation_2', play: true);

      final auto = c.read(autoJaapProvider.notifier);
      auto.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      auto.stop();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(c.read(musicPlaybackProvider).playing, isTrue);
      await c.read(jaapControllerProvider.notifier).flushPendingWrites();
    },
  );

  test('choosing and stopping is remembered across launches', () async {
    final c = await containerWith();
    final music = c.read(musicPlaybackProvider.notifier);

    await music.choose('meditation_3', play: true);
    final settings = c.read(settingsServiceProvider);
    expect(settings.meditationChant(), 'meditation_3');
    expect(settings.meditationChantOn(), isTrue);

    await music.stop();
    expect(c.read(musicPlaybackProvider).selectedId, 'meditation_3');
    await music.choose('meditation_3', play: false);
    expect(settings.meditationChantOn(), isFalse);
  });

  test('the last sound is remembered and used with no choice made', () async {
    final c = await containerWith(selected: 'meditation_3', on: false);
    final auto = c.read(autoJaapProvider.notifier);
    await auto.updateConfig(const AutoJaapConfig(playMusic: true));

    auto.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    auto.stop();

    expect(ambient.played, ['meditation_3']);
    expect(
      c.read(settingsServiceProvider).meditationChantOn(),
      isFalse,
      reason: 'Auto Jaap does not turn on Meditation music',
    );
    await c.read(jaapControllerProvider.notifier).flushPendingWrites();
  });
}
