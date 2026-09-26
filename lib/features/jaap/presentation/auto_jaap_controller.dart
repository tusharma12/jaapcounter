import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/speech_service.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../domain/jaap_entry.dart';
import 'jaap_controller.dart';

/// When automatic Jaap puts itself away.
enum AutoJaapStop { mala, goal, never }

@immutable
class AutoJaapConfig {
  const AutoJaapConfig({
    this.interval = const Duration(seconds: 2),
    this.speakAloud = false,
    this.stopAfter = AutoJaapStop.mala,
    this.voice,
    this.rate = defaultRate,
    this.pitch = defaultPitch,
  });

  // Slower and a little deeper than conversational speech: a chant, not an
  // announcement.
  static const double defaultRate = 0.36;
  static const double defaultPitch = 0.9;
  static const double minRate = 0.2;
  static const double maxRate = 0.6;
  static const double minPitch = 0.6;
  static const double maxPitch = 1.3;

  /// Paces offered in the sheet, in seconds per bead.
  static const List<int> paces = [1, 2, 3, 5, 8];

  /// Time from one bead to the next. When the mantra is spoken aloud and the
  /// voice takes longer than this, the voice sets the pace instead.
  final Duration interval;
  final bool speakAloud;
  final AutoJaapStop stopAfter;

  /// The chosen voice; null means the device's default Hindi voice.
  final TtsVoice? voice;
  final double rate;
  final double pitch;

  AutoJaapConfig copyWith({
    Duration? interval,
    bool? speakAloud,
    AutoJaapStop? stopAfter,
    Object? voice = _sentinel,
    double? rate,
    double? pitch,
  }) {
    return AutoJaapConfig(
      interval: interval ?? this.interval,
      speakAloud: speakAloud ?? this.speakAloud,
      stopAfter: stopAfter ?? this.stopAfter,
      voice: voice == _sentinel ? this.voice : voice as TtsVoice?,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
    );
  }

  List<String> toPrefs() => [
    '${interval.inMilliseconds}',
    '$speakAloud',
    stopAfter.name,
    '$rate',
    '$pitch',
    voice?.name ?? '',
    voice?.locale ?? '',
    voice?.identifier ?? '',
    voice?.quality ?? '',
  ];

  factory AutoJaapConfig.fromPrefs(List<String> values) {
    const fallback = AutoJaapConfig();
    if (values.length < 3) return fallback;
    final ms = int.tryParse(values[0]);
    // Older installs stored only the first three fields.
    String at(int i) => i < values.length ? values[i] : '';
    final voiceName = at(5);
    return AutoJaapConfig(
      interval: ms == null || ms <= 0
          ? fallback.interval
          : Duration(milliseconds: ms),
      speakAloud: values[1] == 'true',
      stopAfter: AutoJaapStop.values.firstWhere(
        (s) => s.name == values[2],
        orElse: () => fallback.stopAfter,
      ),
      rate: (double.tryParse(at(3)) ?? defaultRate).clamp(minRate, maxRate),
      pitch: (double.tryParse(at(4)) ?? defaultPitch).clamp(minPitch, maxPitch),
      voice: voiceName.isEmpty
          ? null
          : TtsVoice(
              name: voiceName,
              locale: at(6),
              identifier: at(7),
              quality: at(8),
            ),
    );
  }
}

const Object _sentinel = Object();

@immutable
class AutoJaapState {
  const AutoJaapState({required this.config, this.running = false});

  final AutoJaapConfig config;
  final bool running;

  AutoJaapState copyWith({AutoJaapConfig? config, bool? running}) =>
      AutoJaapState(
        config: config ?? this.config,
        running: running ?? this.running,
      );
}

/// Voices installed on the device, loaded when the picker first opens.
final ttsVoicesProvider = FutureProvider<List<TtsVoice>>(
  (ref) => ref.watch(speechServiceProvider).voices(),
);

final autoJaapProvider = NotifierProvider<AutoJaapController, AutoJaapState>(
  AutoJaapController.new,
);

/// Counts beads on its own at a steady pace, optionally chanting the mantra
/// aloud before each one.
///
/// Every bead goes through [JaapController.count], so automatic beads are
/// recorded, celebrated and undone exactly like tapped ones.
class AutoJaapController extends Notifier<AutoJaapState> {
  // Bumped on every start and stop. A loop that finds the generation changed
  // under it exits, so a quick stop-then-start never leaves two loops running.
  int _generation = 0;

  @override
  AutoJaapState build() {
    // Chanting one mantra while another is on screen would record beads
    // against the wrong name.
    ref.listen<Mantra?>(activeMantraProvider, (previous, next) {
      if (previous?.id != next?.id) stop();
    });
    ref.onDispose(() {
      _generation++;
      _applyWakelock(false);
    });
    return AutoJaapState(
      config: AutoJaapConfig.fromPrefs(
        ref.read(settingsServiceProvider).autoJaapConfig(),
      ),
    );
  }

  Future<void> updateConfig(AutoJaapConfig config) async {
    state = state.copyWith(config: config);
    await ref.read(settingsServiceProvider).setAutoJaapConfig(config.toPrefs());
  }

  void start() {
    if (state.running) return;
    final jaap = ref.read(jaapControllerProvider).value;
    if (jaap == null) return;

    final generation = ++_generation;
    state = state.copyWith(running: true);
    _applyWakelock(true);
    unawaited(
      _run(
        generation,
        startCompletions: jaap.malaCompletions,
        goalAlreadyReached: jaap.goalReached,
      ),
    );
  }

  void stop() {
    if (!state.running) return;
    _generation++;
    state = state.copyWith(running: false);
    _applyWakelock(false);
    unawaited(ref.read(speechServiceProvider).stop());
  }

  Future<void> _run(
    int generation, {
    required int startCompletions,
    required bool goalAlreadyReached,
  }) async {
    while (generation == _generation) {
      final config = state.config;
      final beadStarted = DateTime.now();

      if (config.speakAloud) {
        final mantra = ref.read(jaapControllerProvider).value?.mantra;
        if (mantra != null) await chant(mantra, config);
        if (generation != _generation) return;
      }

      ref.read(jaapControllerProvider.notifier).count(1, JaapSource.auto);

      final jaap = ref.read(jaapControllerProvider).value;
      if (jaap != null) {
        final done = switch (config.stopAfter) {
          AutoJaapStop.mala => jaap.malaCompletions != startCompletions,
          AutoJaapStop.goal => !goalAlreadyReached && jaap.goalReached,
          AutoJaapStop.never => false,
        };
        if (done) {
          stop();
          return;
        }
      }

      final remaining =
          config.interval - DateTime.now().difference(beadStarted);
      if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    }
  }

  /// Speaks [mantra] once with [config]'s voice. Also used for previews.
  Future<void> chant(Mantra mantra, AutoJaapConfig config) {
    return ref.read(speechServiceProvider).chant(
      mantra.display,
      fallbackLocale: mantra.hasDevanagari ? 'hi' : 'en',
      voice: config.voice,
      rate: config.rate,
      pitch: config.pitch,
    );
  }

  Future<void> _applyWakelock(bool enable) async {
    try {
      await WakelockPlus.toggle(enable: enable);
    } on Object catch (error, stack) {
      AppLogger.e('Could not change the screen wakelock', error, stack);
    }
  }
}
