import 'package:meta/meta.dart';

import '../../../core/utils/day_key.dart';

@immutable
class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.best,
    required this.countedToday,
    this.graceDaysHeld = 0,
    this.bridgedDays = const {},
  });

  final int current;
  final int best;

  /// Whether today already qualifies. Until it does, the current streak is the
  /// run that ended yesterday - so the number does not read as broken at 8am.
  final bool countedToday;

  /// Grace days in hand, ready to cover the next missed day.
  final int graceDaysHeld;

  /// Missed days that a grace day covered, so the calendar can show them as
  /// kept rather than broken.
  final Set<String> bridgedDays;

  static const empty = StreakInfo(current: 0, best: 0, countedToday: false);

  @override
  bool operator ==(Object other) =>
      other is StreakInfo &&
      other.current == current &&
      other.best == best &&
      other.countedToday == countedToday &&
      other.graceDaysHeld == graceDaysHeld &&
      other.bridgedDays.length == bridgedDays.length &&
      other.bridgedDays.containsAll(bridgedDays);

  @override
  int get hashCode => Object.hash(
    current,
    best,
    countedToday,
    graceDaysHeld,
    Object.hashAllUnordered(bridgedDays),
  );

  @override
  String toString() => 'StreakInfo(current: $current, best: $best)';
}

/// Streak rules, kept pure so they can be tested across month and year ends.
abstract final class StreakCalculator {
  /// Unbroken qualifying days that earn one grace day.
  static const int daysPerGraceDay = 7;

  /// Grace days that can be held at once. Two covers a weekend away; more
  /// would let the streak drift from the practice it is meant to reflect.
  static const int maxGraceDays = 2;

  /// A day qualifies when its total reaches [goalFor] for that day. With no
  /// goal, any Jaap at all qualifies.
  ///
  /// With [graceDays], every [daysPerGraceDay] qualifying days in a row earn
  /// a grace day (up to [maxGraceDays] held), and a missed day spends one
  /// instead of breaking the streak. A covered day keeps the run alive but
  /// does not add to it. Everything is derived from [totalsByDay], so there
  /// is no stored state to drift, and undo or restore can never disagree.
  static StreakInfo calculate({
    required Map<String, int> totalsByDay,
    required DateTime today,
    required int Function(String day) goalFor,
    bool graceDays = false,
  }) {
    bool qualifies(String day) {
      final total = totalsByDay[day] ?? 0;
      if (total <= 0) return false;
      final goal = goalFor(day);
      return goal <= 0 ? true : total >= goal;
    }

    if (graceDays) {
      return _withGraceDays(
        qualifies: qualifies,
        today: today,
        days: totalsByDay.keys,
      );
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

  static StreakInfo _withGraceDays({
    required bool Function(String day) qualifies,
    required DateTime today,
    required Iterable<String> days,
  }) {
    final todayKey = DayKeys.of(today);
    String? first;
    for (final day in days) {
      if (day.compareTo(todayKey) > 0 || !qualifies(day)) continue;
      if (first == null || day.compareTo(first) < 0) first = day;
    }
    if (first == null) return StreakInfo.empty;

    var run = 0;
    var best = 0;
    var held = 0;
    var sinceEarned = 0;
    final bridged = <String>{};

    void qualified() {
      run++;
      if (run > best) best = run;
      sinceEarned++;
      if (sinceEarned == daysPerGraceDay) {
        sinceEarned = 0;
        if (held < maxGraceDays) held++;
      }
    }

    // Every closed day, oldest first. Today is still open, so it can extend
    // the streak but never spend a grace day.
    for (
      var day = first;
      day.compareTo(todayKey) < 0;
      day = DayKeys.addDays(day, 1)
    ) {
      if (qualifies(day)) {
        qualified();
      } else if (run > 0 && held > 0) {
        held--;
        bridged.add(day);
      } else {
        run = 0;
        held = 0;
        sinceEarned = 0;
        // A broken run's covered days are history, not part of this streak.
        bridged.clear();
      }
    }

    final countedToday = qualifies(todayKey);
    if (countedToday) qualified();

    return StreakInfo(
      current: run,
      best: best,
      countedToday: countedToday,
      graceDaysHeld: held,
      bridgedDays: bridged,
    );
  }
}
