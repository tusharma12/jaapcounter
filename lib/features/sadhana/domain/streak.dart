import 'package:meta/meta.dart';

import '../../../core/utils/day_key.dart';

@immutable
class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.best,
    required this.countedToday,
  });

  final int current;
  final int best;

  /// Whether today already qualifies. Until it does, the current streak is the
  /// run that ended yesterday - so the number does not read as broken at 8am.
  final bool countedToday;

  static const empty = StreakInfo(current: 0, best: 0, countedToday: false);

  @override
  bool operator ==(Object other) =>
      other is StreakInfo &&
      other.current == current &&
      other.best == best &&
      other.countedToday == countedToday;

  @override
  int get hashCode => Object.hash(current, best, countedToday);

  @override
  String toString() => 'StreakInfo(current: $current, best: $best)';
}

/// Streak rules, kept pure so they can be tested across month and year ends.
abstract final class StreakCalculator {
  /// A day qualifies when its total reaches [goalFor] for that day. With no
  /// goal, any Jaap at all qualifies.
  static StreakInfo calculate({
    required Map<String, int> totalsByDay,
    required DateTime today,
    required int Function(String day) goalFor,
  }) {
    bool qualifies(String day) {
      final total = totalsByDay[day] ?? 0;
      if (total <= 0) return false;
      final goal = goalFor(day);
      return goal <= 0 ? true : total >= goal;
    }

    final todayKey = DayKeys.of(today);
    final countedToday = qualifies(todayKey);

    // Walk back from today (or yesterday, if today is still open).
    var cursor = countedToday ? todayKey : DayKeys.addDays(todayKey, -1);
    var current = 0;
    while (qualifies(cursor)) {
      current++;
      cursor = DayKeys.addDays(cursor, -1);
    }

    // Best run over the whole history.
    final days = totalsByDay.keys.where(qualifies).toList()..sort();
    var best = 0;
    var run = 0;
    String? previous;
    for (final day in days) {
      if (previous != null && DayKeys.addDays(previous, 1) == day) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      previous = day;
    }

    return StreakInfo(
      current: current,
      best: best > current ? best : current,
      countedToday: countedToday,
    );
  }
}
