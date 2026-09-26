import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/day_key.dart';
import '../../../../core/utils/formatters.dart';

/// A month of chanting at a glance.
///
/// Filled squares are days the goal was met, part-filled are days with some
/// Jaap: more legible than a wall of numbers, and it makes gaps obvious
/// without shaming them.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    required this.month,
    required this.totalsByDay,
    required this.goal,
    required this.onShiftMonth,
    this.canGoForward = false,
    super.key,
  });

  final DateTime month;
  final Map<String, int> totalsByDay;
  final int goal;
  final ValueChanged<int> onShiftMonth;
  final bool canGoForward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final firstOfMonth = DateTime(month.year, month.month);
    final daysInMonth = DayKeys.endOfMonth(firstOfMonth).day;
    // Monday-first grid, matching the week the rest of the app uses.
    final leadingBlanks = (firstOfMonth.weekday - DateTime.monday + 7) % 7;
    final cells = leadingBlanks + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                Fmt.monthLabel(firstOfMonth, locale),
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => onShiftMonth(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: canGoForward ? () => onShiftMonth(1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: Insets.sm),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    Fmt.weekdayInitial(
                      DateTime(2024, 1, 1).add(Duration(days: i)),
                      locale,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.tertiaryText,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Insets.sm),
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.xs),
            child: Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(
                    child: _Cell(
                      day: _dayFor(row, column, leadingBlanks, daysInMonth),
                      month: firstOfMonth,
                      totalsByDay: totalsByDay,
                      goal: goal,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static int? _dayFor(int row, int column, int leadingBlanks, int daysInMonth) {
    final index = row * 7 + column - leadingBlanks + 1;
    if (index < 1 || index > daysInMonth) return null;
    return index;
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.month,
    required this.totalsByDay,
    required this.goal,
  });

  final int? day;
  final DateTime month;
  final Map<String, int> totalsByDay;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    if (day == null) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }

    final date = DateTime(month.year, month.month, day!);
    final total = totalsByDay[DayKeys.of(date)] ?? 0;
    final isToday = DayKeys.of(date) == DayKeys.of(DateTime.now());

    final (background, foreground) = switch (total) {
      0 => (palette.track.withValues(alpha: 0.6), palette.tertiaryText),
      _ when goal > 0 && total >= goal * 2 => (
        palette.saffronDeep,
        Colors.white,
      ),
      _ when goal <= 0 || total >= goal => (palette.saffron, Colors.white),
      _ => (palette.softSaffron, palette.secondaryText),
    };

    return Padding(
      padding: const EdgeInsets.all(2),
      child: AspectRatio(
        aspectRatio: 1,
        child: Tooltip(
          message: '${Fmt.dayLabel(date)} · $total',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(Radii.sm),
              border: isToday
                  ? Border.all(color: palette.primaryText, width: 1.4)
                  : null,
            ),
            child: Center(
              child: Text(
                '${day!}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
