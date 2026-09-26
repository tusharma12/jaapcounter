import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../sadhana/domain/streak.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';
import '../domain/progress_models.dart';
import 'progress_providers.dart';
import 'widgets/activity_heatmap.dart';
import 'widgets/jaap_bar_chart.dart';

/// "Am I becoming more consistent?" — that is the only question this screen
/// is built to answer, so it leads with the streak and today, and keeps the
/// rest to four figures, one chart and a calendar.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final summary = ref.watch(progressSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progress)),
      body: AsyncView<ProgressSummary>(
        value: summary,
        onRetry: () => ref.invalidate(progressSummaryProvider),
        builder: (context, data) => data.isEmpty
            ? EmptyState(
                glyph: '📿',
                title: l10n.noJaapYet,
                body: l10n.noJaapYetBody,
              )
            : _ProgressBody(data: data),
      ),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({required this.data});

  final ProgressSummary data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final streak = ref.watch(streakProvider).value ?? StreakInfo.empty;
    final period = ref.watch(progressPeriodProvider);
    final heatmapMonth = ref.watch(heatmapMonthProvider);
    final mantras = ref.watch(mantraListProvider).value ?? const <Mantra>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.page,
        Insets.sm,
        Insets.page,
        Insets.xxxl,
      ),
      children: [
        Center(
          child: StreakBadge(
            label: l10n.dayStreak(streak.current),
            dimmed: !streak.countedToday,
            large: true,
          ),
        ),
        const SizedBox(height: Insets.xl),

        _TodayCard(data: data),
        const SizedBox(height: Insets.xl),

        PillTabs<ProgressPeriod>(
          items: ProgressPeriod.values,
          selected: period,
          onSelected: ref.read(progressPeriodProvider.notifier).select,
          labelOf: (value) => switch (value) {
            ProgressPeriod.daily => l10n.filterDaily,
            ProgressPeriod.weekly => l10n.filterWeekly,
            ProgressPeriod.monthly => l10n.filterMonthly,
            ProgressPeriod.yearly => l10n.filterYearly,
          },
        ),
        const SizedBox(height: Insets.lg),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      switch (period) {
                        ProgressPeriod.daily ||
                        ProgressPeriod.weekly => l10n.weeklyJaap,
                        ProgressPeriod.monthly => l10n.monthlyJaap,
                        ProgressPeriod.yearly => l10n.yearlyJaap,
                      },
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    Fmt.count(data.rangeTotal, locale),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.lg),
              JaapBarChart(buckets: data.buckets),
            ],
          ),
        ),
        const SizedBox(height: Insets.lg),

        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.totalJaap,
                value: Fmt.count(data.lifetimeTotal, locale),
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: StatTile(
                label: l10n.totalMalas,
                value: Fmt.count(data.lifetimeMalas, locale),
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.dailyAverage,
                value: Fmt.count(data.dailyAverage.round(), locale),
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: StatTile(
                label: l10n.activeDays,
                value: Fmt.count(data.activeDaysInRange, locale),
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.xxl),

        ScreenSectionTitle(l10n.activity),
        AppCard(
          child: ActivityHeatmap(
            month: heatmapMonth,
            totalsByDay: data.totalsByDay,
            goal: data.dailyGoal,
            canGoForward: heatmapMonth.isBefore(
              DayKeys.startOfMonth(DateTime.now()),
            ),
            onShiftMonth: ref.read(heatmapMonthProvider.notifier).shift,
          ),
        ),

        if (data.totalsByMantra.length > 1) ...[
          const SizedBox(height: Insets.xxl),
          ScreenSectionTitle(l10n.perMantra),
          AppCard(
            child: Column(
              children: [
                for (final entry in _sortedMantraTotals(mantras))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.md),
                    child: _MantraTotalRow(
                      name: entry.$1,
                      total: entry.$2,
                      fraction: data.lifetimeTotal == 0
                          ? 0
                          : entry.$2 / data.lifetimeTotal,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<(String, int)> _sortedMantraTotals(List<Mantra> mantras) {
    final byId = {for (final mantra in mantras) mantra.id: mantra};
    final rows = <(String, int)>[
      for (final entry in data.totalsByMantra.entries)
        (byId[entry.key]?.subtitle ?? entry.key, entry.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return rows;
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.data});

  final ProgressSummary data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final reached = data.dailyGoal > 0 && data.todayTotal >= data.dailyGoal;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.todaysJaap, style: theme.textTheme.bodySmall),
          const SizedBox(height: Insets.md),
          // A four-figure total beside a four-figure goal is wider than a
          // small phone, so the pair scales down together rather than clipping.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  Fmt.count(data.todayTotal, locale),
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(width: Insets.sm),
                Text(
                  l10n.ofGoal(data.dailyGoal),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: data.goalFraction,
              minHeight: 8,
              backgroundColor: palette.track,
              color: reached ? palette.success : palette.saffron,
            ),
          ),
          const SizedBox(height: Insets.md),
          Text(
            l10n.malasCompleted(data.todayMalas),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MantraTotalRow extends StatelessWidget {
  const _MantraTotalRow({
    required this.name,
    required this.total,
    required this.fraction,
  });

  final String name;
  final int total;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              Fmt.count(total, locale),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: Insets.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: palette.track,
            color: palette.saffron.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
