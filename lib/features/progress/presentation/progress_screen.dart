import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
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
import 'widgets/jaap_bar_chart.dart';
import 'widgets/weekly_habit_grid.dart';

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
        builder: (context, data) => data.totalsByMantra.isEmpty
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final streak = ref.watch(streakProvider).value ?? StreakInfo.empty;
    final period = ref.watch(progressPeriodProvider);
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
        const SizedBox(height: Insets.md),

        _PeriodBar(data: data, mantras: mantras),
        const SizedBox(height: Insets.md),

        _ChartCard(data: data),
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

        if (data.mantraId == null && data.totalsByMantra.length > 1) ...[
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
        (byId[entry.key]?.name ?? entry.key, entry.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return rows;
  }
}

/// "‹ 31 Aug – 6 Sep ›" and which mantra the figures are for.
class _PeriodBar extends ConsumerWidget {
  const _PeriodBar({required this.data, required this.mantras});

  final ProgressSummary data;
  final List<Mantra> mantras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final anchor = ref.read(progressAnchorProvider.notifier);

    final label = switch (data.period) {
      ProgressPeriod.daily => DateFormat.MMMEd(locale).format(data.anchor),
      ProgressPeriod.weekly =>
        '${DateFormat.MMMd(locale).format(data.rangeStart)} – '
            '${DateFormat.MMMd(locale).format(data.rangeEnd)}',
      ProgressPeriod.monthly => Fmt.monthLabel(data.anchor, locale),
      ProgressPeriod.yearly => DateFormat.y(locale).format(data.anchor),
    };

    final byId = {for (final m in mantras) m.id: m};
    final filterName = data.mantraId == null
        ? l10n.allMantras
        : (byId[data.mantraId]?.name ?? l10n.allMantras);

    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousPeriod,
          visualDensity: VisualDensity.compact,
          onPressed: () => anchor.shift(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: theme.textTheme.titleMedium),
          ),
        ),
        IconButton(
          tooltip: l10n.nextPeriod,
          visualDensity: VisualDensity.compact,
          onPressed: data.canGoForward ? () => anchor.shift(1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        const SizedBox(width: Insets.sm),
        // Only worth offering once more than one mantra has been chanted.
        if (data.totalsByMantra.length > 1)
          Flexible(
            child: ActionChip(
              avatar: Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: palette.secondaryText,
              ),
              label: Text(
                filterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              shape: const StadiumBorder(),
              side: BorderSide(
                color: data.mantraId == null
                    ? palette.divider
                    : palette.saffron,
              ),
              onPressed: () => _pickMantra(context, ref),
            ),
          ),
      ],
    );
  }

  Future<void> _pickMantra(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final byId = {for (final m in mantras) m.id: m};
    final chanted = [
      for (final id in data.totalsByMantra.keys)
        if (byId[id] != null) byId[id]!,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final filter = ref.read(progressMantraFilterProvider.notifier);

    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Insets.page,
                  0,
                  Insets.page,
                  Insets.sm,
                ),
                child: Text(
                  l10n.showStatsFor,
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
              ),
              for (final entry in <(String?, String)>[
                (null, l10n.allMantras),
                for (final m in chanted) (m.id, m.name),
              ])
                ListTile(
                  title: Text(entry.$2),
                  trailing: entry.$1 == data.mantraId
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    filter.select(entry.$1);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: Insets.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// The period's chart — the week grid for Weekly, bars for the rest — and a
/// line under it saying what the selected day or month holds.
class _ChartCard extends StatefulWidget {
  const _ChartCard({required this.data});

  final ProgressSummary data;

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  DateTime? _selected;

  @override
  void didUpdateWidget(_ChartCard old) {
    super.didUpdateWidget(old);
    // A different period, range or mantra starts from its own focus again.
    final a = old.data;
    final b = widget.data;
    if (a.period != b.period ||
        a.rangeStart != b.rangeStart ||
        a.mantraId != b.mantraId) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final isWeekly = data.period == ProgressPeriod.weekly;

    final focus =
        data.buckets[data.focusIndex.clamp(0, data.buckets.length - 1)];
    final selected = _selected ?? focus.start;
    final selectedIndex = data.buckets.indexWhere((b) => b.start == selected);

    // What the selection line describes: a day, or a month on Yearly.
    final (String label, int count) = switch (data.period) {
      ProgressPeriod.yearly when selectedIndex >= 0 => (
        Fmt.monthLabel(selected, locale),
        data.buckets[selectedIndex].value,
      ),
      _ => (
        DateFormat.MMMEd(locale).format(selected),
        data.totalsByDay[DayKeys.of(selected)] ?? 0,
      ),
    };
    final malas = NumberFormat('0.#', locale).format(data.malasFor(count));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(switch (data.period) {
                  ProgressPeriod.daily => l10n.dailyJaap,
                  ProgressPeriod.weekly => l10n.weeklyJaap,
                  ProgressPeriod.monthly => l10n.monthlyJaap,
                  ProgressPeriod.yearly => l10n.yearlyJaap,
                }, style: theme.textTheme.titleMedium),
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
          if (isWeekly)
            WeeklyHabitGrid(
              totalsByDay: data.totalsByDay,
              goal: data.dailyGoal,
              today: data.today,
              anchor: data.anchor,
              selected: selected,
              onSelect: (day) => setState(() => _selected = day),
            )
          else
            JaapBarChart(
              buckets: data.buckets,
              selectedIndex: selectedIndex,
              onSelect: (i) =>
                  setState(() => _selected = data.buckets[i].start),
            ),
          const SizedBox(height: Insets.md),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.lg,
                vertical: Insets.sm,
              ),
              decoration: BoxDecoration(
                color: palette.softSaffron,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Text(
                l10n.selectionSummary(label, Fmt.count(count, locale), malas),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.primaryText,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            Text(Fmt.count(total, locale), style: theme.textTheme.bodyMedium),
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
