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

  void select(ProgressPeriod period) => state = period;
}

/// Statistics for the selected period, recomputed whenever the ledger changes.
final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  ref.watch(ledgerRevisionProvider);

  final period = ref.watch(progressPeriodProvider);
  final repo = ref.watch(jaapRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final mantras = await ref.watch(mantraListProvider.future);

  final (rangeStart, rangeEnd) = _rangeFor(period, now);
  final totalsByDay = await repo.totalsByDay();
  final totalsByMantra = await repo.totalsByMantra();

  int totalBetween(DateTime from, DateTime to) {
    var sum = 0;
    for (final key in DayKeys.keysInRange(from, to)) {
      sum += totalsByDay[key] ?? 0;
    }
    return sum;
  }

  final rangeTotal = totalBetween(rangeStart, rangeEnd);
  final activeDays = DayKeys.keysInRange(rangeStart, rangeEnd)
      .where((key) => (totalsByDay[key] ?? 0) > 0)
      .length;

  // Malas are counted per mantra, because two mantras can use different mala
  // sizes and a single division would be wrong for both.
  final byId = {for (final m in mantras) m.id: m};
  var lifetimeMalas = 0;
  for (final entry in totalsByMantra.entries) {
    final size = byId[entry.key]?.malaSize ?? 108;
    lifetimeMalas += MalaMath.malasIn(entry.value, size);
  }

  final defaultMalaSize = _representativeMalaSize(mantras);
  final todayTotal = totalsByDay[DayKeys.of(now)] ?? 0;

  return ProgressSummary(
    period: period,
    rangeStart: rangeStart,
    rangeEnd: rangeEnd,
    rangeTotal: rangeTotal,
    rangeMalas: MalaMath.malasIn(rangeTotal, defaultMalaSize),
    todayTotal: todayTotal,
    todayMalas: MalaMath.malasIn(todayTotal, defaultMalaSize),
    lifetimeTotal: totalsByDay.values.fold(0, (a, b) => a + b),
    lifetimeMalas: lifetimeMalas,
    activeDaysInRange: activeDays,
    buckets: _buckets(period, now, totalsByDay),
    totalsByDay: totalsByDay,
    totalsByMantra: totalsByMantra,
    dailyGoal: ref.watch(dailyGoalProvider),
  );
});

/// Twelve months of daily totals for the activity heatmap.
final heatmapMonthProvider =
    NotifierProvider<HeatmapMonthController, DateTime>(
      HeatmapMonthController.new,
    );

class HeatmapMonthController extends Notifier<DateTime> {
  @override
  DateTime build() => DayKeys.startOfMonth(ref.watch(clockProvider)());

  void shift(int months) {
    final now = ref.read(clockProvider)();
    final next = DateTime(state.year, state.month + months);
    // Never past the current month: there is nothing to show there yet.
    if (next.isAfter(DayKeys.startOfMonth(now))) return;
    state = next;
  }
}

(DateTime, DateTime) _rangeFor(ProgressPeriod period, DateTime now) {
  final today = DayKeys.dateOnly(now);
  return switch (period) {
    ProgressPeriod.daily => (today, today),
    ProgressPeriod.weekly => (
      DayKeys.startOfWeek(today),
      DayKeys.startOfWeek(today).add(const Duration(days: 6)),
    ),
    ProgressPeriod.monthly => (
      DayKeys.startOfMonth(today),
      DayKeys.endOfMonth(today),
    ),
    ProgressPeriod.yearly => (
      DayKeys.startOfYear(today),
      DateTime(today.year, 12, 31),
    ),
  };
}

List<ProgressBucket> _buckets(
  ProgressPeriod period,
  DateTime now,
  Map<String, int> totalsByDay,
) {
  final today = DayKeys.dateOnly(now);

  int sumOfDays(DateTime from, DateTime to) {
    var sum = 0;
    for (final key in DayKeys.keysInRange(from, to)) {
      sum += totalsByDay[key] ?? 0;
    }
    return sum;
  }

  switch (period) {
    // Both the day and week views show the seven days of this week, which is
    // the shape people actually read a chanting habit in.
    case ProgressPeriod.daily:
    case ProgressPeriod.weekly:
      final start = DayKeys.startOfWeek(today);
      return List.generate(7, (i) {
        final day = start.add(Duration(days: i));
        return ProgressBucket(
          start: day,
          value: totalsByDay[DayKeys.of(day)] ?? 0,
          granularity: BucketGranularity.day,
          isCurrent: DayKeys.of(day) == DayKeys.of(today),
        );
      });

    // Weeks of the current month, so a 31-day month stays readable.
    case ProgressPeriod.monthly:
      final monthStart = DayKeys.startOfMonth(today);
      final monthEnd = DayKeys.endOfMonth(today);
      final buckets = <ProgressBucket>[];
      var cursor = DayKeys.startOfWeek(monthStart);
      while (!cursor.isAfter(monthEnd)) {
        final weekEnd = cursor.add(const Duration(days: 6));
        buckets.add(
          ProgressBucket(
            start: cursor,
            value: sumOfDays(cursor, weekEnd),
            granularity: BucketGranularity.week,
            isCurrent:
                !today.isBefore(cursor) && !today.isAfter(weekEnd),
          ),
        );
        cursor = cursor.add(const Duration(days: 7));
      }
      return buckets;

    case ProgressPeriod.yearly:
      return List.generate(12, (i) {
        final monthStart = DateTime(today.year, i + 1);
        final monthEnd = DayKeys.endOfMonth(monthStart);
        return ProgressBucket(
          start: monthStart,
          value: sumOfDays(monthStart, monthEnd),
          granularity: BucketGranularity.month,
          isCurrent: i + 1 == today.month,
        );
      });
  }
}

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
