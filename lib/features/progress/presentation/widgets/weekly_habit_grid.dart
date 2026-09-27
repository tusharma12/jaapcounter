import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/day_key.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Months of chanting, one column per week and one row per weekday, ending
/// with [anchor]'s week on the right.
///
/// Read across a row and a habit's rhythm shows at once: which weekdays are
/// kept, and where the gaps are. The number of weeks follows the width, so a
/// wider screen simply shows further back.
class WeeklyHabitGrid extends StatelessWidget {
  const WeeklyHabitGrid({
    required this.totalsByDay,
    required this.goal,
    required this.today,
    required this.anchor,
    required this.selected,
    required this.onSelect,
    this.maxWeeks = 26,
    super.key,
  });

  final Map<String, int> totalsByDay;
  final int goal;
  final DateTime today;

  /// The last week shown is the one holding this day.
  final DateTime anchor;

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final int maxWeeks;

  static const double _gap = 3;
  static const double _minCell = 10;
  static const double _maxCell = 18;
  static const double _labelWidth = 26;
  static const double _monthRowHeight = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final todayDate = DayKeys.dateOnly(today);
    final lastWeek = DayKeys.startOfWeek(anchor);
    final selectedKey = DayKeys.of(selected);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: palette.tertiaryText,
      fontSize: 10,
      height: 1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Half a pixel spare, so rounding can never overflow the row.
        final available = constraints.maxWidth - _labelWidth - 0.5;
        final fit = ((available + _gap) / (_minCell + _gap)).floor();
        final weeks = fit.clamp(1, maxWeeks);
        final cell = ((available - _gap * (weeks - 1)) / weeks).clamp(
          _minCell,
          _maxCell,
        );
        final step = cell + _gap;
        final firstWeek = DateTime(
          lastWeek.year,
          lastWeek.month,
          lastWeek.day - 7 * (weeks - 1),
        );
        DateTime weekStart(int column) => DateTime(
          firstWeek.year,
          firstWeek.month,
          firstWeek.day + 7 * column,
        );

        // A month is named above the first week that starts in it.
        final monthLabels = <Widget>[
          for (var c = 1; c < weeks; c++)
            if (weekStart(c).month != weekStart(c - 1).month)
              Positioned(
                left: _labelWidth + c * step,
                top: 0,
                child: Text(
                  Fmt.monthShort(weekStart(c), locale),
                  style: labelStyle,
                  softWrap: false,
                ),
              ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _monthRowHeight,
              width: constraints.maxWidth,
              child: Stack(clipBehavior: Clip.none, children: monthLabels),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monday, Wednesday and Friday are enough to find a row.
                SizedBox(
                  width: _labelWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var d = 0; d < 7; d++)
                        SizedBox(
                          height: step,
                          child: d.isEven && d < 6
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Fmt.weekdayShort(
                                      DateTime(2024, 1, 1 + d),
                                      locale,
                                    ),
                                    style: labelStyle,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                  ),
                                )
                              : null,
                        ),
                    ],
                  ),
                ),
                for (var c = 0; c < weeks; c++)
                  Padding(
                    padding: EdgeInsets.only(right: c == weeks - 1 ? 0 : _gap),
                    child: Column(
                      children: [
                        for (var d = 0; d < 7; d++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: _gap),
                            child: _DayCell(
                              date: DateTime(
                                weekStart(c).year,
                                weekStart(c).month,
                                weekStart(c).day + d,
                              ),
                              today: todayDate,
                              selectedKey: selectedKey,
                              totalsByDay: totalsByDay,
                              goal: goal,
                              size: cell,
                              onSelect: onSelect,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Insets.sm),
            _Legend(
              less: l10n.legendLess,
              more: l10n.legendMore,
              style: labelStyle,
              size: cell.clamp(_minCell, 12),
            ),
          ],
        );
      },
    );
  }
}

/// How strongly a day is filled: nothing, some Jaap, the goal, twice it.
double _intensity(int total, int goal) {
  if (total <= 0) return 0;
  if (goal <= 0) return 0.75;
  if (total >= goal * 2) return 1;
  if (total >= goal) return 0.72;
  return 0.35;
}

Color _fill(AppPalette palette, double intensity) => intensity == 0
    ? palette.track
    : Color.lerp(palette.track, palette.saffron, intensity)!;

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.selectedKey,
    required this.totalsByDay,
    required this.goal,
    required this.size,
    required this.onSelect,
  });

  final DateTime date;
  final DateTime today;
  final String selectedKey;
  final ValueChanged<DateTime> onSelect;
  final Map<String, int> totalsByDay;
  final int goal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(size * 0.28);

    // Days still to come keep their place in the grid but are left blank.
    if (date.isAfter(today)) return SizedBox.square(dimension: size);

    final key = DayKeys.of(date);
    final total = totalsByDay[key] ?? 0;
    final isSelected = key == selectedKey;
    final isToday = key == DayKeys.of(today);

    return GestureDetector(
      onTap: () => onSelect(date),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _fill(palette, _intensity(total, goal)),
          borderRadius: radius,
          border: isSelected
              ? Border.all(color: palette.primaryText, width: 2)
              : isToday
              ? Border.all(color: palette.tertiaryText, width: 1)
              : null,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.less,
    required this.more,
    required this.style,
    required this.size,
  });

  final String less;
  final String more;
  final TextStyle? style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(less, style: style),
        const SizedBox(width: Insets.xs),
        for (final intensity in const [0.0, 0.35, 0.72, 1.0])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _fill(palette, intensity),
                borderRadius: BorderRadius.circular(size * 0.28),
              ),
            ),
          ),
        const SizedBox(width: Insets.xs),
        Text(more, style: style),
      ],
    );
  }
}
