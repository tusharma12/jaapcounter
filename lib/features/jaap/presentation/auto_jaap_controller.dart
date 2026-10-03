import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../meditation/presentation/music_playback.dart';
import '../domain/jaap_entry.dart';
import 'jaap_controller.dart';

/// When automatic Jaap puts itself away.
enum AutoJaapStop { mala, goal, never }

@immutable
class AutoJaapConfig {
  const AutoJaapConfig({
    this.interval = const Duration(seconds: 1),
    this.stopAfter = AutoJaapStop.mala,
    this.playMusic = false,
  });

  /// Paces offered in the sheet, in seconds per bead.
  static const List<int> paces = [1, 2, 3, 5, 8];

  /// Time from one bead to the next.
  final Duration interval;
  final AutoJaapStop stopAfter;

  /// Whether the chosen sound plays while Auto Jaap runs.
  final bool playMusic;

  AutoJaapConfig copyWith({
    Duration? interval,
    AutoJaapStop? stopAfter,
    bool? playMusic,
  }) {
    return AutoJaapConfig(
      interval: interval ?? this.interval,
      stopAfter: stopAfter ?? this.stopAfter,
      playMusic: playMusic ?? this.playMusic,
    );
  }

  // The second slot once held "speak aloud" and is kept empty, so the
  // stored layout stays readable by older versions.
  List<String> toPrefs() => [
    '${interval.inMilliseconds}',
    'false',
    stopAfter.name,
    '$playMusic',
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
      // Longer lists from older versions carry other things here; only an
      // explicit 'true' counts.
      playMusic: values.length > 3 && values[3] == 'true',
    );
  }
}

@immutable
class AutoJaapState {
  const AutoJaapState({
    required this.config,
    this.running = false,
    this.awaitingGoalChoice = false,
  });

  final AutoJaapConfig config;
  final bool running;

  /// The daily goal was reached mid-run: counting is paused until the user
  /// chooses to continue or stop.
  final bool awaitingGoalChoice;

  AutoJaapState copyWith({
    AutoJaapConfig? config,
    bool? running,
    bool? awaitingGoalChoice,
  }) => AutoJaapState(
    config: config ?? this.config,
    running: running ?? this.running,
    awaitingGoalChoice: awaitingGoalChoice ?? this.awaitingGoalChoice,
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

  // Completed by the user's answer to the goal prompt: true to keep going.
  Completer<bool>? _goalChoice;

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

  /// Whether it is counting now; unlike [state], readable from a widget's
  /// dispose, where `ref` is no longer safe.
  bool get isRunning => ref.mounted && state.running;

  void start() {
    if (state.running) return;
    final jaap = ref.read(jaapControllerProvider).value;
    if (jaap == null) return;

    final generation = ++_generation;
    state = state.copyWith(running: true);
    _applyWakelock(true);
    if (state.config.playMusic) {
      unawaited(ref.read(musicPlaybackProvider.notifier).startForAuto());
    }
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
    _answerGoalPrompt(false);
    state = state.copyWith(running: false);
    _applyWakelock(false);
    unawaited(ref.read(musicPlaybackProvider.notifier).stopForAuto());
  }

  /// Keeps counting past the daily goal.
  void continueAfterGoal() => _answerGoalPrompt(true);

  void _answerGoalPrompt(bool keepGoing) {
    final choice = _goalChoice;
    _goalChoice = null;
    if (choice != null && !choice.isCompleted) choice.complete(keepGoing);
    if (state.awaitingGoalChoice) {
      state = state.copyWith(awaitingGoalChoice: false);
    }
  }

  /// Pauses at the goal until the user decides. Counting past a goal is
  /// something to choose, not something to stumble into, and so is stopping:
  /// a sudden halt in the middle of a sitting is jarring.
  Future<bool> _askAboutGoal() {
    final choice = Completer<bool>();
    _goalChoice = choice;
    state = state.copyWith(awaitingGoalChoice: true);
    return choice.future;
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
        switch (config.stopAfter) {
          case AutoJaapStop.mala:
            if (jaap.malaCompletions != startCompletions) {
              stop();
              return;
            }
          case AutoJaapStop.goal:
            if (!goalAlreadyReached && jaap.goalReached) {
              final keepGoing = await _askAboutGoal();
              if (generation != _generation) return;
              if (!keepGoing) {
                stop();
                return;
              }
              // Asked once; from here the run goes on until it is stopped.
              goalAlreadyReached = true;
              continue;
            }
          case AutoJaapStop.never:
            break;
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
