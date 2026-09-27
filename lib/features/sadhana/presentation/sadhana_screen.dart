import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../jaap/presentation/jaap_controller.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/sadhana.dart';
import '../../share/presentation/share_card.dart';
import '../domain/streak.dart';
import 'create_sankalp_sheet.dart';
import 'daily_goal_picker.dart';
import 'sadhana_controllers.dart';

/// The reason to come back tomorrow: today's goal, the streak, and the vow.
class SadhanaScreen extends ConsumerWidget {
  const SadhanaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final sadhana = ref.watch(activeSadhanaProvider).value;
    final streak = ref.watch(streakProvider).value ?? StreakInfo.empty;
    final jaap = ref.watch(jaapControllerProvider).value;
    final completedDays = ref.watch(sankalpProgressProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mySadhana),
        actions: [
          IconButton(
            tooltip: l10n.shareProgress,
            onPressed: () => showShareCardSheet(context),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.sm,
          Insets.page,
          Insets.xxxl,
        ),
        children: [
          if (jaap != null) ...[
            _TodayGoal(
              mantraDisplay: jaap.mantra,
              todayTotal: jaap.todayTotal,
              goal: jaap.dailyGoal,
              reached: jaap.goalReached,
            ),
            const SizedBox(height: Insets.xl),
          ],
          Center(
            child: StreakBadge(
              label: l10n.dayStreak(streak.current),
              dimmed: !streak.countedToday,
              large: true,
            ),
          ),
          const SizedBox(height: Insets.xl),
          if (sadhana == null)
            _NoSankalp(onCreate: () => showCreateSankalp(context))
          else
            _SankalpCard(
              sadhana: sadhana,
              completedDays: completedDays,
              onEnd: () => _endSankalp(context, ref, sadhana),
            ),
          const SizedBox(height: Insets.xl),
          const _GoalRow(),
          const SizedBox(height: Insets.md),
          if (streak.best > 0)
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.bestStreak,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    l10n.dayStreak(streak.best),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _endSankalp(
    BuildContext context,
    WidgetRef ref,
    Sadhana sadhana,
  ) async {
    final l10n = AppL10n.of(context);
    final confirmed = await confirm(
      context,
      title: l10n.endSankalp,
      message: l10n.endSankalpBody,
      confirmLabel: l10n.endSankalp,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(activeSadhanaProvider.notifier).end();
  }
}

class _TodayGoal extends StatelessWidget {
  const _TodayGoal({
    required this.mantraDisplay,
    required this.todayTotal,
    required this.goal,
    required this.reached,
  });

  final Mantra mantraDisplay;
  final int todayTotal;
  final int goal;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      children: [
        MantraText(mantraDisplay, size: 20, color: palette.secondaryText),
        const SizedBox(height: Insets.xl),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: Fmt.count(todayTotal, locale),
                style: theme.textTheme.displaySmall,
              ),
              TextSpan(
                text: '  /  ${Fmt.count(goal, locale)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: palette.tertiaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.xs),
        Text(l10n.todaysGoal, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Insets.md),
        if (reached)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded, size: 17, color: palette.success),
              const SizedBox(width: Insets.xs),
              Text(
                l10n.complete,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.success,
                ),
              ),
            ],
          )
        else
          Text(
            l10n.goalRemaining(goal - todayTotal),
            style: theme.textTheme.titleSmall?.copyWith(
              color: palette.tertiaryText,
            ),
          ),
      ],
    );
  }
}

class _SankalpCard extends ConsumerWidget {
  const _SankalpCard({
    required this.sadhana,
    required this.completedDays,
    required this.onEnd,
  });

  final Sadhana sadhana;
  final int completedDays;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final total = sadhana.durationDays;
    final today = ref.watch(clockProvider)();
    final dayNumber = sadhana.dayNumber(today);
    final fraction = total == null
        ? 0.0
        : (completedDays / total).clamp(0.0, 1.0);
    // The vow's own mantra decides what a mala is, not the one on screen.
    final malaSize =
        (ref.watch(mantraListProvider).value ?? const <Mantra>[])
            .where((m) => m.id == sadhana.mantraId)
            .firstOrNull
            ?.malaSize ??
        AppConstants.defaultMalaSize;

    return AppCard(
      accented: true,
      child: Column(
        children: [
          Text(
            total == null
                ? l10n.dailyGoal.toUpperCase()
                : l10n.sankalpDays(total),
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.secondaryText,
            ),
          ),
          const SizedBox(height: Insets.lg),
          Text(
            total == null
                ? goalLabel(l10n, sadhana.dailyGoal, malaSize, locale)
                : l10n.dayXofY(dayNumber, total),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: Insets.lg),
          if (total != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.pill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: palette.saffron.withValues(alpha: 0.2),
                color: palette.saffron,
              ),
            ),
            const SizedBox(height: Insets.md),
            Text(
              l10n.daysCompleted(completedDays),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Insets.xs),
            Text(
              goalLabel(l10n, sadhana.dailyGoal, malaSize, locale),
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
              ),
            ),
          ],
          const SizedBox(height: Insets.sm),
          Text(
            l10n.startedOn(
              Fmt.dayLabel(DayKeys.parse(sadhana.startDay), locale),
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Insets.md),
          TextButton(
            onPressed: onEnd,
            style: TextButton.styleFrom(foregroundColor: palette.secondaryText),
            child: Text(l10n.endSankalp),
          ),
        ],
      ),
    );
  }
}

class _NoSankalp extends StatelessWidget {
  const _NoSankalp({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppCard(
      child: EmptyState(
        glyph: '🌱',
        title: l10n.noSankalpTitle,
        body: l10n.noSankalpBody,
        action: FilledButton(
          onPressed: onCreate,
          child: Text(l10n.createNewSankalp),
        ),
      ),
    );
  }
}

/// Standing daily goal, for people who would rather not take a fixed-length
/// vow. Editing it here changes what "today's goal" means everywhere.
class _GoalRow extends ConsumerWidget {
  const _GoalRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);

    return AppCard(
      onTap: () async {
        final value = await showDailyGoalSheet(
          context,
          initial: settings.fallbackDailyGoal,
          malaSize:
              ref.read(activeMantraProvider)?.malaSize ??
              AppConstants.defaultMalaSize,
        );
        if (value == null) return;
        await ref.read(settingsProvider.notifier).setFallbackDailyGoal(value);
        final sadhana = ref.read(activeSadhanaProvider).value;
        if (sadhana != null) {
          await ref
              .read(activeSadhanaProvider.notifier)
              .save(sadhana.copyWith(dailyGoal: value));
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.setDailyGoal,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            l10n.jaapCount(ref.watch(dailyGoalProvider)),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: Insets.sm),
          Icon(
            Icons.chevron_right_rounded,
            color: context.palette.tertiaryText,
          ),
        ],
      ),
    );
  }
}
