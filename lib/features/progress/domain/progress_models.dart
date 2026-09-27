import 'package:meta/meta.dart';

import '../../../core/utils/day_key.dart';

enum ProgressPeriod { daily, weekly, monthly, yearly }

enum BucketGranularity {
  /// A day of a week, labelled by date and weekday.
  day,

  /// A day of a month, labelled by its date.
  monthDay,

  month,
}

/// One bar of the chart. Labels are formatted by the UI so they follow the
/// app's language.
@immutable
class ProgressBucket {
  const ProgressBucket({
    required this.start,
    required this.value,
    required this.granularity,
    this.isCurrent = false,
    this.isFuture = false,
  });

  final DateTime start;
  final int value;
  final BucketGranularity granularity;

  /// Contains today.
  final bool isCurrent;

  /// Not reached yet, so it is drawn without a track: an empty future day is
  /// not a missed one.
  final bool isFuture;
}

@immutable
class ProgressSummary {
  const ProgressSummary({
    required this.period,
    required this.today,
    required this.anchor,
    required this.rangeStart,
    required this.rangeEnd,
    required this.rangeTotal,
    required this.todayTotal,
    required this.todayMalas,
    required this.lifetimeTotal,
    required this.lifetimeMalas,
    required this.activeDaysInRange,
    required this.buckets,
    required this.focusIndex,
    required this.totalsByDay,
    required this.totalsByMantra,
    required this.dailyGoal,
    required this.malaSize,
    this.mantraId,
  });

  final ProgressPeriod period;

  /// The date the summary was computed for, from the app's clock.
  final DateTime today;

  /// The day the period is shown around: today, unless the user has stepped
  /// back with the arrows.
  final DateTime anchor;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  /// Everything below follows the mantra filter, except [todayTotal],
  /// [todayMalas] and [totalsByMantra], which always cover every mantra.
  final int rangeTotal;
  final int todayTotal;
  final int todayMalas;
  final int lifetimeTotal;

  /// Lifetime malas, counted per mantra against that mantra's own mala size.
  final int lifetimeMalas;

  final int activeDaysInRange;

  final List<ProgressBucket> buckets;

  /// The bar selected when the chart first shows: the one holding [anchor].
  final int focusIndex;

  /// Every day with Jaap, for the week grid.
  final Map<String, int> totalsByDay;

  final Map<String, int> totalsByMantra;

  final int dailyGoal;

  /// Beads per mala, for turning a count into malas: the filtered mantra's
  /// own, or the library's usual size when every mantra is shown.
  final int malaSize;

  /// The mantra the figures are filtered to; null for all of them.
  final String? mantraId;

  /// Whether the anchor can move forward without passing today.
  bool get canGoForward => rangeEnd.isBefore(today);

  bool get isEmpty => lifetimeTotal == 0;

  /// Days of the range that have begun, today included. Days still ahead
  /// cannot have Jaap, so they must not dilute the average.
  int get daysElapsed {
    final end = today.isBefore(rangeEnd) ? today : rangeEnd;
    return DayKeys.daysBetween(rangeStart, end) + 1;
  }

  double get dailyAverage {
    final days = daysElapsed;
    if (days <= 0) return 0;
    return rangeTotal / days;
  }

  double malasFor(int count) => malaSize <= 0 ? 0 : count / malaSize;

  double get goalFraction =>
      dailyGoal <= 0 ? 0 : (todayTotal / dailyGoal).clamp(0.0, 1.0);
}
