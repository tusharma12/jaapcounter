import 'package:meta/meta.dart';

enum ProgressPeriod { daily, weekly, monthly, yearly }

enum BucketGranularity { day, week, month }

/// One bar of the chart. Labels are formatted by the UI so they follow the
/// app's language.
@immutable
class ProgressBucket {
  const ProgressBucket({
    required this.start,
    required this.value,
    required this.granularity,
    this.isCurrent = false,
  });

  final DateTime start;
  final int value;
  final BucketGranularity granularity;
  final bool isCurrent;
}

@immutable
class ProgressSummary {
  const ProgressSummary({
    required this.period,
    required this.rangeStart,
    required this.rangeEnd,
    required this.rangeTotal,
    required this.rangeMalas,
    required this.todayTotal,
    required this.todayMalas,
    required this.lifetimeTotal,
    required this.lifetimeMalas,
    required this.activeDaysInRange,
    required this.buckets,
    required this.totalsByDay,
    required this.totalsByMantra,
    required this.dailyGoal,
  });

  final ProgressPeriod period;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  final int rangeTotal;
  final int rangeMalas;
  final int todayTotal;
  final int todayMalas;
  final int lifetimeTotal;

  /// Lifetime malas, counted per mantra against that mantra's own mala size.
  final int lifetimeMalas;

  final int activeDaysInRange;

  final List<ProgressBucket> buckets;

  /// Every day with Jaap, for the activity heatmap.
  final Map<String, int> totalsByDay;

  final Map<String, int> totalsByMantra;

  final int dailyGoal;

  bool get isEmpty => lifetimeTotal == 0;

  double get dailyAverage {
    final days = rangeEnd.difference(rangeStart).inDays + 1;
    if (days <= 0) return 0;
    return rangeTotal / days;
  }

  int get bucketPeak =>
      buckets.fold(0, (max, b) => b.value > max ? b.value : max);

  double get goalFraction =>
      dailyGoal <= 0 ? 0 : (todayTotal / dailyGoal).clamp(0.0, 1.0);

  static final empty = ProgressSummary(
    period: ProgressPeriod.weekly,
    rangeStart: DateTime(2000),
    rangeEnd: DateTime(2000),
    rangeTotal: 0,
    rangeMalas: 0,
    todayTotal: 0,
    todayMalas: 0,
    lifetimeTotal: 0,
    lifetimeMalas: 0,
    activeDaysInRange: 0,
    buckets: const [],
    totalsByDay: const {},
    totalsByMantra: const {},
    dailyGoal: 108,
  );
}
