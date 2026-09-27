import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
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
    this.stopAfter = AutoJaapStop.mala,
  });

  /// Paces offered in the sheet, in seconds per bead.
  static const List<int> paces = [1, 2, 3, 5, 8];

  /// Time from one bead to the next.
  final Duration interval;
  final AutoJaapStop stopAfter;

  AutoJaapConfig copyWith({Duration? interval, AutoJaapStop? stopAfter}) {
    return AutoJaapConfig(
      interval: interval ?? this.interval,
      stopAfter: stopAfter ?? this.stopAfter,
    );
  }

  // The second slot once held "speak aloud" and is kept empty, so the
  // stored layout stays readable by older versions.
  List<String> toPrefs() => [
    '${interval.inMilliseconds}',
    'false',
    stopAfter.name,
  ];

  /// Reads what [toPrefs] wrote, and also the longer lists older versions
  /// stored with voice settings, whose extra fields are ignored.
  factory AutoJaapConfig.fromPrefs(List<String> values) {
    const fallback = AutoJaapConfig();
    if (values.length < 3) return fallback;
    final ms = int.tryParse(values[0]);
    return AutoJaapConfig(
      interval: ms == null || ms <= 0
          ? fallback.interval
          : Duration(milliseconds: ms),
      stopAfter: AutoJaapStop.values.firstWhere(
        (s) => s.name == values[2],
        orElse: () => fallback.stopAfter,
      ),
    );
  }
}

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

final autoJaapProvider = NotifierProvider<AutoJaapController, AutoJaapState>(
  AutoJaapController.new,
);

/// Counts beads on its own at a steady pace.
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
  }

  Future<void> _run(
    int generation, {
    required int startCompletions,
    required bool goalAlreadyReached,
  }) async {
    while (generation == _generation) {
      final config = state.config;
      final beadStarted = DateTime.now();

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

  Future<void> _applyWakelock(bool enable) async {
    try {
      await WakelockPlus.toggle(enable: enable);
    } on Object catch (error, stack) {
      AppLogger.e('Could not change the screen wakelock', error, stack);
    }
  }
}
