import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/day_key.dart';
import '../../jaap/domain/mala_math.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';
import '../domain/progress_models.dart';

final progressPeriodProvider =
    NotifierProvider<ProgressPeriodController, ProgressPeriod>(
      ProgressPeriodController.new,
    );

class ProgressPeriodController extends Notifier<ProgressPeriod> {
  @override
  ProgressPeriod build() => ProgressPeriod.weekly;

  /// A new period starts from today again: "last month" read as "last year"
  /// would be a surprise.
  void select(ProgressPeriod period) {
    state = period;
    ref.read(progressAnchorProvider.notifier).reset();
  }
}

/// The day the selected period is shown around; null means today.
final progressAnchorProvider =
    NotifierProvider<ProgressAnchorController, DateTime?>(
      ProgressAnchorController.new,
    );

class ProgressAnchorController extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void reset() => state = null;

  /// Moves one period back (negative) or forward. Landing on the last day of
  /// the new period means a past month shows its whole length, and the
  /// anchor is clamped so it never passes today.
  void shift(int steps) {
    final today = DayKeys.dateOnly(ref.read(clockProvider)());
    final from = state ?? today;
    final period = ref.read(progressPeriodProvider);
    final target = switch (period) {
      ProgressPeriod.daily => DateTime(from.year, from.month, from.day + steps),
      ProgressPeriod.weekly => DateTime(
        from.year,
        from.month,
        from.day + 7 * steps,
      ),
      ProgressPeriod.monthly => DayKeys.endOfMonth(
        DateTime(from.year, from.month + steps),
      ),
      ProgressPeriod.yearly => DateTime(from.year + steps, 12, 31),
    };
    final (start, end) = _rangeFor(period, target);
    if (start.isAfter(today)) return;
    final landed = period == ProgressPeriod.daily ? target : end;
    state = landed.isBefore(today) ? landed : null;
  }
}

/// The mantra the statistics are narrowed to; null shows every mantra.
final progressMantraFilterProvider =
    NotifierProvider<ProgressMantraFilter, String?>(ProgressMantraFilter.new);

class ProgressMantraFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? mantraId) => state = mantraId;
}

/// Statistics for the selected period, recomputed whenever the ledger changes.
final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  ref.watch(ledgerRevisionProvider);

  final period = ref.watch(progressPeriodProvider);
  final filter = ref.watch(progressMantraFilterProvider);
  final repo = ref.watch(jaapRepositoryProvider);
  final today = DayKeys.dateOnly(ref.watch(clockProvider)());
  final anchor = ref.watch(progressAnchorProvider) ?? today;
  final mantras = await ref.watch(mantraListProvider.future);
  final byId = {for (final m in mantras) m.id: m};

  final (rangeStart, rangeEnd) = _rangeFor(period, anchor);
  final totalsByMantra = await repo.totalsByMantra();
  // A filter on a mantra with nothing recorded (or since deleted) shows all.
  final mantraId = totalsByMantra.containsKey(filter) ? filter : null;
  final totalsByDay = await repo.totalsByDay(mantraId: mantraId);
  final allByDay = mantraId == null
      ? totalsByDay
      : await repo.totalsByDay(fromDay: DayKeys.of(today));

  int totalBetween(DateTime from, DateTime to) {
    var sum = 0;
    for (final key in DayKeys.keysInRange(from, to)) {
      sum += totalsByDay[key] ?? 0;
    }
    return sum;
  }

  final activeDays = DayKeys.keysInRange(
    rangeStart,
    rangeEnd,
  ).where((key) => (totalsByDay[key] ?? 0) > 0).length;

  // Malas are counted per mantra, because two mantras can use different mala
  // sizes and a single division would be wrong for both.
  var lifetimeMalas = 0;
  for (final entry in totalsByMantra.entries) {
    if (mantraId != null && entry.key != mantraId) continue;
    final size = byId[entry.key]?.malaSize ?? 108;
    lifetimeMalas += MalaMath.malasIn(entry.value, size);
  }

  final malaSize = mantraId == null
      ? _representativeMalaSize(mantras)
      : (byId[mantraId]?.malaSize ?? 108);
  final todayTotal = allByDay[DayKeys.of(today)] ?? 0;
  final buckets = _buckets(period, anchor, today, totalsByDay);

  return ProgressSummary(
    period: period,
    today: today,
    anchor: anchor,
    rangeStart: rangeStart,
    rangeEnd: rangeEnd,
    rangeTotal: totalBetween(rangeStart, rangeEnd),
    todayTotal: todayTotal,
    todayMalas: MalaMath.malasIn(todayTotal, _representativeMalaSize(mantras)),
    lifetimeTotal: totalsByDay.values.fold(0, (a, b) => a + b),
    lifetimeMalas: lifetimeMalas,
    activeDaysInRange: activeDays,
    buckets: buckets,
    focusIndex: _focusIndex(period, anchor, buckets),
    totalsByDay: totalsByDay,
    totalsByMantra: totalsByMantra,
    dailyGoal: ref.watch(dailyGoalProvider),
    malaSize: malaSize,
    mantraId: mantraId,
  );
});

(DateTime, DateTime) _rangeFor(ProgressPeriod period, DateTime anchor) {
  final day = DayKeys.dateOnly(anchor);
  return switch (period) {
    ProgressPeriod.daily => (day, day),
    ProgressPeriod.weekly => (
      DayKeys.startOfWeek(day),
      DayKeys.startOfWeek(day).add(const Duration(days: 6)),
    ),
    ProgressPeriod.monthly => (
      DayKeys.startOfMonth(day),
      DayKeys.endOfMonth(day),
    ),
    ProgressPeriod.yearly => (
      DayKeys.startOfYear(day),
      DateTime(day.year, 12, 31),
    ),
  };
}

List<ProgressBucket> _buckets(
  ProgressPeriod period,
  DateTime anchor,
  DateTime today,
  Map<String, int> totalsByDay,
) {
  int sumOfDays(DateTime from, DateTime to) {
    var sum = 0;
    for (final key in DayKeys.keysInRange(from, to)) {
      sum += totalsByDay[key] ?? 0;
    }
    return sum;
  }

  ProgressBucket day(DateTime date, BucketGranularity granularity) =>
      ProgressBucket(
        start: date,
        value: totalsByDay[DayKeys.of(date)] ?? 0,
        granularity: granularity,
        isCurrent: DayKeys.of(date) == DayKeys.of(today),
        isFuture: date.isAfter(today),
      );

  switch (period) {
    // The day against the six before it, so a single figure has context.
    case ProgressPeriod.daily:
      return List.generate(7, (i) {
        final date = DateTime(anchor.year, anchor.month, anchor.day - 6 + i);
        return day(date, BucketGranularity.day);
      });

    case ProgressPeriod.weekly:
      final start = DayKeys.startOfWeek(anchor);
      return List.generate(7, (i) {
        final date = DateTime(start.year, start.month, start.day + i);
        return day(date, BucketGranularity.day);
      });

    // Every day of the month, and only that month, so the bars add up to
    // the month's total.
    case ProgressPeriod.monthly:
      final daysInMonth = DayKeys.endOfMonth(anchor).day;
      return List.generate(
        daysInMonth,
        (i) => day(
          DateTime(anchor.year, anchor.month, i + 1),
          BucketGranularity.monthDay,
        ),
      );

    case ProgressPeriod.yearly:
      return List.generate(12, (i) {
        final monthStart = DateTime(anchor.year, i + 1);
        final monthEnd = DayKeys.endOfMonth(monthStart);
        return ProgressBucket(
          start: monthStart,
          value: sumOfDays(monthStart, monthEnd),
          granularity: BucketGranularity.month,
          isCurrent:
              monthStart.year == today.year && monthStart.month == today.month,
          isFuture: monthStart.isAfter(today),
        );
      });
  }
}

int _focusIndex(
  ProgressPeriod period,
  DateTime anchor,
  List<ProgressBucket> buckets,
) => switch (period) {
  ProgressPeriod.daily => buckets.length - 1,
  ProgressPeriod.weekly => anchor.weekday - DateTime.monday,
  ProgressPeriod.monthly => anchor.day - 1,
  ProgressPeriod.yearly => anchor.month - 1,
};

/// Mala size to divide a mixed-mantra total by: the active library's most
/// common one, which is 108 in practice.
int _representativeMalaSize(List<Mantra> mantras) {
  if (mantras.isEmpty) return 108;
  final counts = <int, int>{};
  for (final mantra in mantras) {
    counts[mantra.malaSize] = (counts[mantra.malaSize] ?? 0) + 1;
  }
  var best = mantras.first.malaSize;
  var bestCount = 0;
  for (final entry in counts.entries) {
    if (entry.value > bestCount) {
      best = entry.key;
      bestCount = entry.value;
    }
  }
  return best;
}
