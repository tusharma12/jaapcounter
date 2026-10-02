import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../mantras/presentation/mantra_editor_sheet.dart';
import '../../mantras/domain/mantra_names.dart';
import '../../mantras/presentation/mantras_screen.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';
import '../../settings/domain/mala_style.dart';
import '../../settings/presentation/appearance_sheets.dart';
import '../../settings/presentation/settings_controller.dart';
import 'auto_jaap_controller.dart';
import 'counter_prefs.dart';
import 'jaap_controller.dart';
import 'jaap_state.dart';
import 'widgets/auto_jaap_sheet.dart';
import 'widgets/falling_mantra.dart';
import 'widgets/mala_complete_overlay.dart';
import 'widgets/mala_ring.dart';
import 'widgets/session_pill.dart';
import 'widgets/hardware_count_keys.dart';
import '../../progress/presentation/milestone_labels.dart';
import '../../share/presentation/share_card.dart';

/// The counter. This is the screen the app exists for, so it opens straight
/// into a countable state and everything else is one tap away.
class JaapScreen extends ConsumerStatefulWidget {
  const JaapScreen({super.key});

  @override
  ConsumerState<JaapScreen> createState() => _JaapScreenState();
}

class _JaapScreenState extends ConsumerState<JaapScreen> {
  int? _seenMalaCompletions;
  int? _seenMilestones;
  bool _celebrating = false;
  Timer? _celebrationTimer;

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }

  void _onMalaCompleted() {
    _celebrationTimer?.cancel();
    setState(() => _celebrating = true);
    _celebrationTimer = Timer(Motion.celebration, () {
      if (mounted) setState(() => _celebrating = false);
    });
  }

  /// A lifetime milestone is marked without stopping the count: a snackbar,
  /// not a dialog, so a tap with eyes closed still lands on the counter.
  void _onMilestone(int threshold) {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.milestoneReached(jaapMilestoneLabel(l10n, threshold)),
          ),
          duration: const Duration(seconds: 6),
          margin: const EdgeInsets.all(Insets.lg),
          action: SnackBarAction(
            label: l10n.share,
            onPressed: () => showShareCardSheet(context),
          ),
        ),
      );
  }

  Future<void> _undo() async {
    final l10n = AppL10n.of(context);
    final removed = await ref.read(jaapControllerProvider.notifier).undo();
    if (!mounted) return;
    showAppSnack(context, removed ? l10n.countRemoved : l10n.nothingToUndo);
  }

  Future<void> _toggleSession(JaapState state) async {
    final controller = ref.read(jaapControllerProvider.notifier);
    if (!state.sessionRunning) {
      await controller.startSession();
      return;
    }
    final l10n = AppL10n.of(context);
    final session = await controller.endSession();
    if (!mounted || session == null) return;
    showAppSnack(
      context,
      l10n.sessionSummary(
        session.count,
        session.elapsedAt(DateTime.now()).inMinutes,
      ),
    );
  }

  void _toggleAutoJaap() {
    final auto = ref.read(autoJaapProvider.notifier);
    if (ref.read(autoJaapProvider).running) {
      auto.stop();
    } else {
      showAutoJaapSheet(context);
    }
  }

  Future<void> _addManualCount(JaapState state) async {
    final l10n = AppL10n.of(context);
    final amount = await showNumberPrompt(
      context,
      title: l10n.addCount,
      initialValue: state.mantra.malaSize,
      min: 1,
      max: 100000,
      invalidMessage: l10n.numberOfJaap,
      helperText: l10n.numberOfJaap,
    );
    if (amount == null) return;
    await ref.read(jaapControllerProvider.notifier).addManualCount(amount);
  }

  Future<void> _resetMala() async {
    final l10n = AppL10n.of(context);
    final confirmed = await confirm(
      context,
      title: l10n.resetCurrentMala,
      message: l10n.resetCurrentMalaBody,
      confirmLabel: l10n.resetToday,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(jaapControllerProvider.notifier).resetCurrentMala();
  }

  /// The whole counter area is one target: a tap counts, or, while Auto Jaap
  /// runs, stops it.
  void _onTapArea(bool autoRunning) {
    if (autoRunning) {
      ref.read(autoJaapProvider.notifier).stop();
      return;
    }
    ref.read(jaapControllerProvider.notifier).count();
    ref.read(counterHintSeenProvider.notifier).markSeen();
  }

  Future<void> _onMenu(_MenuAction action, JaapState state) async {
    switch (action) {
      case _MenuAction.undo:
        await _undo();
      case _MenuAction.autoJaap:
        _toggleAutoJaap();
      case _MenuAction.session:
        await _toggleSession(state);
      case _MenuAction.meditation:
        await context.push('/meditation');
      case _MenuAction.blackout:
        await context.push('/blackout');
      case _MenuAction.hideMantra:
        ref.read(hideMantraProvider.notifier).toggle();
      case _MenuAction.fallingMantra:
        final current = ref.read(settingsProvider).fallingMantra;
        await ref.read(settingsProvider.notifier).setFallingMantra(!current);
      case _MenuAction.theme:
        await showThemePicker(context);
      case _MenuAction.background:
        await showBackgroundPicker(context);
      case _MenuAction.addCount:
        await _addManualCount(state);
      case _MenuAction.resetMala:
        await _resetMala();
      case _MenuAction.mantras:
        await context.push('/mantras');
      case _MenuAction.sadhana:
        await context.push('/sadhana');
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(jaapControllerProvider);
    final autoRunning = ref.watch(autoJaapProvider.select((s) => s.running));

    // A finished mala is acknowledged once, from the state's own counter, so
    // the animation cannot be triggered twice by an unrelated rebuild.
    final completions = async.value?.malaCompletions;
    if (completions != null && completions != _seenMalaCompletions) {
      final isFirstBuild = _seenMalaCompletions == null;
      _seenMalaCompletions = completions;
      if (!isFirstBuild) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _onMalaCompleted());
      }
    }

    final milestones = async.value?.milestoneCount;
    if (milestones != null && milestones != _seenMilestones) {
      final isFirstBuild = _seenMilestones == null;
      _seenMilestones = milestones;
      final reached = async.value?.milestone;
      if (!isFirstBuild && reached != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onMilestone(reached);
        });
      }
    }

    return HardwareCountKeys(
      onCount: () => _onTapArea(autoRunning),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: CounterBackdrop()),
            SafeArea(
              child: AsyncView<JaapState>(
                value: async,
                onRetry: () => ref.invalidate(jaapControllerProvider),
                builder: (context, state) => _CounterBody(
                  state: state,
                  celebrating: _celebrating,
                  autoRunning: autoRunning,
                  hideMantra: ref.watch(hideMantraProvider),
                  fallingMantra: ref.watch(
                    settingsProvider.select((s) => s.fallingMantra),
                  ),
                  malaStyle: ref.watch(
                    settingsProvider.select((s) => s.malaStyle),
                  ),
                  showHint: !ref.watch(counterHintSeenProvider),
                  onTap: () => _onTapArea(autoRunning),
                  onMenu: (action) => _onMenu(action, state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MenuAction {
  undo,
  autoJaap,
  session,
  meditation,
  blackout,
  hideMantra,
  fallingMantra,
  theme,
  background,
  addCount,
  resetMala,
  mantras,
  sadhana,
}

class _CounterBody extends StatelessWidget {
  const _CounterBody({
    required this.state,
    required this.celebrating,
    required this.autoRunning,
    required this.hideMantra,
    required this.fallingMantra,
    required this.malaStyle,
    required this.showHint,
    required this.onTap,
    required this.onMenu,
  });

  final JaapState state;
  final bool celebrating;
  final bool autoRunning;
  final bool hideMantra;
  final bool fallingMantra;
  final MalaStyle malaStyle;
  final bool showHint;
  final VoidCallback onTap;
  final ValueChanged<_MenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final position = state.position;

    final hint = autoRunning
        ? l10n.autoJaapTapToStop
        : (showHint ? l10n.tapAnywhere : null);

    return Stack(
      children: [
        // Behind everything. Its own switch alone decides, so the mantra can
        // fall even while the large text is hidden.
        if (fallingMantra)
          Positioned.fill(
            child: FallingMantra(mantra: state.mantra, count: state.lifetime),
          ),
        Column(
          children: [
            _TopBar(
              state: state,
              autoRunning: autoRunning,
              hideMantra: hideMantra,
              onMenu: onMenu,
            ),
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.semanticCounter(
                  position.beadsInCurrentMala,
                  position.malaSize,
                ),
                onTapHint: autoRunning
                    ? l10n.autoJaapStopAction
                    : l10n.tapToCount,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Everything between the top bar and the tab bar counts, so
                  // the thumb can land anywhere without looking.
                  onTapDown: (_) => onTap(),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!hideMantra) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Insets.page,
                                  ),
                                  child: MantraText(
                                    state.mantra,
                                    size: _mantraSize(
                                      state.mantra.displayName(context),
                                    ),
                                    weight: FontWeight.w700,
                                    maxLines: 4,
                                    color: palette.primaryText,
                                  ),
                                ),
                                const SizedBox(height: Insets.xxl),
                              ],
                              MalaRing(
                                beads: position.beadsInCurrentMala,
                                malaSize: position.malaSize,
                                diameter: _ringDiameter(constraints),
                                style: malaStyle,
                                child: MalaRingLabel(
                                  beads: position.beadsInCurrentMala,
                                  malaSize: position.malaSize,
                                ),
                              ),
                              const SizedBox(height: Insets.xxl),
                              Text(
                                l10n.todaysJaap,
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: Insets.xs),
                              Text(
                                '${l10n.counterCount(Fmt.count(state.todayTotal, locale))}'
                                '   |   '
                                '${l10n.counterMalas(Fmt.count(state.todayMalas, locale))}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Insets.sm),
                              Text(
                                l10n.counterTotal(
                                  Fmt.count(state.lifetime, locale),
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: palette.tertiaryText,
                                ),
                              ),
                              const SizedBox(height: Insets.lg),
                              _GoalBar(state: state),
                              const SizedBox(height: Insets.lg),
                              // Reserved even when empty so the layout does not
                              // jump the moment the hint goes away.
                              SizedBox(
                                height: 20,
                                child: AnimatedOpacity(
                                  opacity: hint == null ? 0 : 1,
                                  duration: Motion.medium,
                                  child: Text(
                                    hint ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: autoRunning
                                          ? palette.saffron
                                          : palette.tertiaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: Insets.xxxl * 2,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: MalaCompleteOverlay(
              visible: celebrating,
              malasCompleted: position.completedMalas,
              malaSize: position.malaSize,
              todayTotal: state.todayTotal,
            ),
          ),
        ),
      ],
    );
  }

  /// A single name is set large; a verse steps down so it still fits.
  static double _mantraSize(String text) {
    if (text.contains('\n') || text.length > 24) return 24;
    if (text.length > 10) return 36;
    return 64;
  }

  static double _ringDiameter(BoxConstraints constraints) {
    final byWidth = constraints.maxWidth - Insets.xxxl * 2;
    final byHeight = constraints.maxHeight * 0.4;
    final diameter = byWidth < byHeight ? byWidth : byHeight;
    return diameter.clamp(160.0, 280.0);
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({
    required this.state,
    required this.autoRunning,
    required this.hideMantra,
    required this.onMenu,
  });

  final JaapState state;
  final bool autoRunning;
  final bool hideMantra;
  final ValueChanged<_MenuAction> onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final streak = ref.watch(streakProvider).value?.current ?? 0;
    final fallingMantra = ref.watch(
      settingsProvider.select((s) => s.fallingMantra),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.sm,
        Insets.sm,
        Insets.xs,
        Insets.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MantraChip(state: state),
            ),
          ),
          _StreakChip(days: streak),
          IconButton(
            key: const ValueKey('counter-auto-jaap'),
            onPressed: () => onMenu(_MenuAction.autoJaap),
            tooltip: autoRunning ? l10n.autoJaapStopAction : l10n.autoJaap,
            icon: Icon(
              autoRunning
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
            ),
            color: autoRunning ? palette.saffron : palette.secondaryText,
          ),
          IconButton(
            key: const ValueKey('counter-meditation'),
            onPressed: () => onMenu(_MenuAction.meditation),
            tooltip: l10n.meditationMode,
            icon: const Icon(Icons.self_improvement_rounded),
            color: palette.secondaryText,
          ),
          IconButton(
            onPressed: state.undoAvailable
                ? () => onMenu(_MenuAction.undo)
                : null,
            tooltip: l10n.undo,
            icon: const Icon(Icons.undo_rounded),
            color: palette.secondaryText,
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: l10n.menu,
            icon: Icon(Icons.menu_rounded, color: palette.primaryText),
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            onSelected: onMenu,
            itemBuilder: (context) => [
              _item(
                _MenuAction.autoJaap,
                autoRunning
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                autoRunning ? l10n.autoJaapStopAction : l10n.autoJaap,
              ),
              _item(
                _MenuAction.session,
                state.sessionRunning
                    ? Icons.stop_circle_outlined
                    : Icons.timer_outlined,
                state.sessionRunning ? l10n.endSession : l10n.startSession,
              ),
              _item(
                _MenuAction.meditation,
                Icons.self_improvement_rounded,
                l10n.meditationMode,
              ),
              _item(
                _MenuAction.blackout,
                Icons.dark_mode_outlined,
                l10n.blackoutMode,
              ),
              _item(
                _MenuAction.hideMantra,
                hideMantra
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                hideMantra ? l10n.showMantra : l10n.hideMantra,
              ),
              _item(
                _MenuAction.fallingMantra,
                fallingMantra
                    ? Icons.auto_awesome_motion_outlined
                    : Icons.auto_awesome_motion_rounded,
                fallingMantra ? l10n.stopFallingMantra : l10n.fallingMantra,
              ),
              _item(
                _MenuAction.theme,
                Icons.palette_outlined,
                l10n.changeTheme,
              ),
              _item(
                _MenuAction.background,
                Icons.wallpaper_rounded,
                l10n.counterBackground,
              ),
              _item(
                _MenuAction.addCount,
                Icons.add_box_outlined,
                l10n.addCountManually,
              ),
              _item(
                _MenuAction.resetMala,
                Icons.refresh_rounded,
                l10n.resetCurrentMala,
              ),
              const PopupMenuDivider(),
              _item(
                _MenuAction.mantras,
                Icons.format_list_bulleted_rounded,
                l10n.myMantras,
              ),
              _item(
                _MenuAction.sadhana,
                Icons.auto_awesome_outlined,
                l10n.mySadhana,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static PopupMenuItem<_MenuAction> _item(
    _MenuAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<_MenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: Insets.md),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

class _StreakChip extends ConsumerWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countedToday = ref.watch(streakProvider).value?.countedToday ?? false;
    return Semantics(
      label: AppL10n.of(context).streakDays(days),
      excludeSemantics: true,
      child: StreakBadge(label: '$days', dimmed: !countedToday),
    );
  }
}

class _MantraChip extends ConsumerWidget {
  const _MantraChip({required this.state});

  final JaapState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    if (state.sessionRunning && state.sessionStartedAt != null) {
      return SessionPill(
        startedAt: state.sessionStartedAt!,
        count: state.sessionCount,
        onEnd: () => ref.read(jaapControllerProvider.notifier).endSession(),
      );
    }

    // The top bar names the mantra on one line and opens the picker; the
    // hero text below carries it in full, and stands in when it is hidden.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: InkWell(
        onTap: () => showMantraPicker(context),
        borderRadius: BorderRadius.circular(Radii.pill),
        // Tall enough to be an easy tap target, without widening the chip.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.md,
              vertical: Insets.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The full mantra is shown large below; the chip caps its
                // growth so it stays readable beside the top bar's buttons.
                Flexible(
                  child: Text(
                    state.mantra.displayName(context),
                    textScaler: MediaQuery.textScalerOf(
                      context,
                    ).clamp(maxScaleFactor: 1.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.primaryText,
                    ),
                  ),
                ),
                const SizedBox(width: Insets.xs),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: palette.tertiaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A slim line under the totals: how much of today's goal is done.
class _GoalBar extends StatelessWidget {
  const _GoalBar({required this.state});

  final JaapState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    if (state.dailyGoal <= 0) return const SizedBox.shrink();

    return SizedBox(
      width: 180,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: state.goalFraction, end: state.goalFraction),
              duration: Motion.medium,
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: palette.track,
                color: state.goalReached ? palette.success : palette.saffron,
              ),
            ),
          ),
          const SizedBox(height: Insets.sm),
          Text(
            state.goalReached
                ? l10n.goalReached
                : l10n.goalRemaining(state.goalRemaining),
            style: theme.textTheme.bodySmall?.copyWith(
              color: state.goalReached ? palette.success : palette.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}
