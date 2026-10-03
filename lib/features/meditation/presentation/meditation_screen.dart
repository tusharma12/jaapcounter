import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../jaap/presentation/jaap_controller.dart';
import '../../jaap/presentation/jaap_state.dart';
import '../../mantras/domain/mantra_names.dart';
import '../../jaap/presentation/widgets/mala_ring.dart';
import '../../settings/presentation/settings_controller.dart';
import 'music_playback.dart';
import 'music_sheet.dart';
import 'blackout_screen.dart';
import '../../jaap/presentation/widgets/hardware_count_keys.dart';
import '../../jaap/presentation/auto_jaap_actions.dart';
import '../../jaap/presentation/auto_jaap_controller.dart';

/// Distraction-free chanting.
///
/// The mantra, the count and three controls. Blackout opens
/// [BlackoutScreen], the same one Settings offers.
class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  static const List<Duration> _timerPresets = [
    Duration(minutes: 5),
    Duration(minutes: 11),
    Duration(minutes: 21),
    Duration(minutes: 30),
  ];

  final DateTime _enteredAt = DateTime.now();
  Duration? _timerTarget;
  Timer? _ticker;
  bool _timerFinished = false;
  late final MusicPlaybackController _music;
  late final AutoJaapController _auto;

  @override
  void initState() {
    super.initState();
    _music = ref.read(musicPlaybackProvider.notifier);
    _auto = ref.read(autoJaapProvider.notifier);
    // Start what was playing last time; its file may be gone, in which case
    // the screen just opens silent.
    unawaited(_music.resume());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _checkTimer();
    });
    _applyWakelock(_keepAwake);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    // Leaving Meditation ends its music, unless Auto Jaap started it and is
    // still counting.
    final keepForAuto = _auto.isRunning && _music.startedByAuto;
    if (!keepForAuto) unawaited(_music.stop());
    _applyWakelock(false);
    super.dispose();
  }

  /// A sound needs the screen on: when the phone locks, iOS stops it.
  bool get _keepAwake =>
      ref.read(settingsProvider).keepScreenOnInMeditation ||
      ref.read(musicPlaybackProvider).playing;

  Future<void> _applyWakelock(bool enable) async {
    try {
      await WakelockPlus.toggle(enable: enable);
    } on Object catch (error, stack) {
      AppLogger.e('Could not change the screen wakelock', error, stack);
    }
  }

  void _checkTimer() {
    final target = _timerTarget;
    if (target == null || _timerFinished) return;
    if (DateTime.now().difference(_enteredAt) >= target) {
      _timerFinished = true;
      // The loop has run for exactly the sitting; let it fade away.
      unawaited(_music.fadeOutAndStop());
      ref.read(feedbackProvider).malaComplete();
    }
  }

  Future<void> _openBlackout() async {
    await context.push('/blackout');
    // Blackout releases the wakelock as it closes; this screen still wants it.
    if (mounted) {
      _applyWakelock(_keepAwake);
    }
  }

  Future<void> _pickChant() async {
    await showAppSheet<void>(
      context,
      builder: (_) => MusicSheet(
        selected: () => ref.read(musicPlaybackProvider).selectedId,
        playing: () => ref.read(musicPlaybackProvider).playing,
        onChoose: (id, {required play}) async {
          await _music.choose(id, play: play);
          // Starting after the timer ran out begins a fresh sitting.
          if (play && mounted) setState(() => _timerFinished = false);
        },
      ),
    );
  }

  Future<void> _pickTimer() async {
    final l10n = AppL10n.of(context);
    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.off),
              trailing: _timerTarget == null
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                setState(() {
                  _timerTarget = null;
                  _timerFinished = false;
                });
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final preset in _timerPresets)
              ListTile(
                title: Text('${preset.inMinutes} min'),
                trailing: _timerTarget == preset
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() {
                    _timerTarget = preset;
                    _timerFinished = false;
                  });
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: Insets.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(jaapControllerProvider);
    final palette = context.palette;
    // The screen stays on while a sound plays, and goes back to the setting
    // when it stops.
    ref.listen(musicPlaybackProvider.select((m) => m.playing), (_, _) {
      _applyWakelock(_keepAwake);
    });
    reapplyWakelockWhenAutoStops(
      ref,
      mounted: () => mounted,
      reapply: () => _applyWakelock(_keepAwake),
    );

    return HardwareCountKeys(
      onCount: () => countOrStopAuto(ref),
      child: Scaffold(
        backgroundColor: palette.background,
        body: AsyncView<JaapState>(
          value: async,
          builder: (context, state) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => countOrStopAuto(ref),
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 220) {
                Navigator.of(context).maybePop();
              }
            },
            child: SafeArea(
              child: _MeditationView(
                state: state,
                elapsed: DateTime.now().difference(_enteredAt),
                timerTarget: _timerTarget,
                onBlackout: _openBlackout,
                onTimer: _pickTimer,
                chantOn: ref.watch(
                  musicPlaybackProvider.select((m) => m.playing),
                ),
                onChant: _pickChant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeditationView extends ConsumerWidget {
  const _MeditationView({
    required this.state,
    required this.elapsed,
    required this.timerTarget,
    required this.onBlackout,
    required this.onTimer,
    required this.chantOn,
    required this.onChant,
  });

  final JaapState state;
  final Duration elapsed;
  final Duration? timerTarget;
  final VoidCallback onBlackout;
  final VoidCallback onTimer;
  final bool chantOn;
  final VoidCallback onChant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final autoRunning = ref.watch(autoJaapProvider.select((s) => s.running));
    final position = state.position;
    final remaining = timerTarget == null ? null : timerTarget! - elapsed;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: l10n.exitMeditation,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: palette.tertiaryText,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.mantra.displayName(context),
                textAlign: TextAlign.center,
                maxLines: 3,
                style: AppTypography.mantra(
                  size: 30,
                  color: palette.primaryText,
                ),
              ),
              const SizedBox(height: Insets.xxl),
              MalaRing(
                beads: position.beadsInCurrentMala,
                malaSize: position.malaSize,
                diameter: 232,
                style: ref.watch(settingsProvider.select((s) => s.malaStyle)),
                child: MalaRingLabel(
                  beads: position.beadsInCurrentMala,
                  malaSize: position.malaSize,
                  compact: true,
                ),
              ),
              const SizedBox(height: Insets.xxl),
              Text(
                Fmt.stopwatch(
                  remaining == null
                      ? elapsed
                      : (remaining.isNegative ? Duration.zero : remaining),
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: palette.secondaryText,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (remaining != null)
                Padding(
                  padding: const EdgeInsets.only(top: Insets.xs),
                  child: Text(l10n.timer, style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: Insets.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Control(
                icon: chantOn
                    ? Icons.music_note_rounded
                    : Icons.music_off_outlined,
                label: l10n.music,
                active: chantOn,
                onTap: onChant,
              ),
              _Control(
                icon: Icons.timer_outlined,
                label: l10n.timer,
                active: timerTarget != null,
                onTap: onTimer,
              ),
              _Control(
                icon: autoRunning
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                label: autoRunning ? l10n.autoJaapStopAction : l10n.autoJaap,
                active: autoRunning,
                onTap: () => toggleAutoJaap(context, ref),
              ),
              _Control(
                icon: Icons.dark_mode_outlined,
                label: l10n.blackout,
                active: false,
                onTap: onBlackout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final color = active ? palette.saffron : palette.secondaryText;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.sm,
              vertical: Insets.md,
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: Insets.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
