import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../jaap/presentation/widgets/mala_ring.dart';
import '../../settings/presentation/settings_controller.dart';

/// Distraction-free chanting.
///
/// Normal mode keeps the mantra, the count and three controls. Blackout keeps
/// the mantra and the count, on black, and nothing else — for chanting with
/// the phone face up and the eyes closed.
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

  bool _blackout = false;
  final DateTime _enteredAt = DateTime.now();
  Duration? _timerTarget;
  Timer? _ticker;
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _checkTimer();
    });
    _applyWakelock(ref.read(settingsProvider).keepScreenOnInMeditation);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _applyWakelock(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

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
      ref.read(feedbackProvider).malaComplete();
    }
  }

  void _toggleBlackout() {
    setState(() => _blackout = !_blackout);
    SystemChrome.setEnabledSystemUIMode(
      _blackout ? SystemUiMode.immersive : SystemUiMode.edgeToEdge,
    );
    ref.read(feedbackProvider).removal();
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

    return Scaffold(
      backgroundColor: _blackout ? Colors.black : palette.background,
      body: AsyncView<JaapState>(
        value: async,
        builder: (context, state) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => ref.read(jaapControllerProvider.notifier).count(),
          // Swiping down leaves, so blackout needs no visible chrome.
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 220) {
              if (_blackout) {
                _toggleBlackout();
              } else {
                Navigator.of(context).maybePop();
              }
            }
          },
          child: SafeArea(
            child: _blackout
                ? _BlackoutView(state: state, onExit: _toggleBlackout)
                : _MeditationView(
                    state: state,
                    elapsed: DateTime.now().difference(_enteredAt),
                    timerTarget: _timerTarget,
                    onBlackout: _toggleBlackout,
                    onTimer: _pickTimer,
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
  });

  final JaapState state;
  final Duration elapsed;
  final Duration? timerTarget;
  final VoidCallback onBlackout;
  final VoidCallback onTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final settings = ref.watch(settingsProvider);
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
                state.mantra.display,
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
            children: [
              _Control(
                icon: settings.soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                label: l10n.sound,
                active: settings.soundEnabled,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setSound(!settings.soundEnabled),
              ),
              _Control(
                icon: Icons.timer_outlined,
                label: l10n.timer,
                active: timerTarget != null,
                onTap: onTimer,
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

class _BlackoutView extends StatelessWidget {
  const _BlackoutView({required this.state, required this.onExit});

  final JaapState state;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final position = state.position;
    const dim = Color(0xFF8A8A8A);

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.mantra.display,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: AppTypography.mantra(
                  size: 26,
                  color: const Color(0xFFE8E4DC),
                ),
              ),
              const SizedBox(height: Insets.xxxl),
              Text(
                '${position.beadsInCurrentMala}',
                style: const TextStyle(
                  fontFamily: AppTypography.ui,
                  fontSize: 88,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF2EFE9),
                  letterSpacing: -3,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: Insets.lg),
              Text(
                '${position.malaSize}',
                style: const TextStyle(
                  fontFamily: AppTypography.ui,
                  fontSize: 17,
                  color: dim,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: Insets.sm,
          left: Insets.sm,
          child: IconButton(
            onPressed: onExit,
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF3A3A3A),
            ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.md,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: Insets.xs),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
