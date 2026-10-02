import 'package:meta/meta.dart';

/// Lifetime Jaap and streak lengths worth marking.
///
/// The Jaap thresholds follow how counts are spoken of in practice: a
/// thousand and eight, a lakh, sava lakh (1.25 lakh, the traditional count for
/// a purascharana), up to a crore. The streak lengths are the familiar vow
/// lengths - 21 and 40 days - between a week and a year.
abstract final class Milestones {
  static const List<int> jaap = [
    1008,
    10000,
    100000,
    125000,
    500000,
    1000000,
    10000000,
  ];

  static const List<int> streakDays = [7, 21, 40, 108, 365];

  /// The highest Jaap milestone passed in going from [before] to [after], or
  /// null if none was.
  static int? jaapCrossed(int before, int after) {
    int? crossed;
    for (final threshold in jaap) {
      if (before < threshold && after >= threshold) crossed = threshold;
    }
    return crossed;
  }

  /// The next Jaap milestone above [total], or null past the last.
  static int? nextJaap(int total) {
    for (final threshold in jaap) {
      if (total < threshold) return threshold;
    }
    return null;
  }

  /// The day each Jaap milestone was reached, from the daily totals. Only
  /// milestones already reached appear.
  static Map<int, String> jaapReachedOn(Map<String, int> totalsByDay) {
    final days = totalsByDay.keys.toList()..sort();
    final reached = <int, String>{};
    var running = 0;
    var next = 0;
    for (final day in days) {
      running += totalsByDay[day]!;
      while (next < jaap.length && running >= jaap[next]) {
        reached[jaap[next]] = day;
        next++;
      }
      if (next == jaap.length) break;
    }
    return reached;
  }
}

/// One year of practice, summarised for the year in review.
@immutable
class YearReview {
  const YearReview({
    required this.year,
    required this.total,
    required this.malas,
    required this.activeDays,
    required this.longestRun,
    required this.monthlyTotals,
    this.bestDay,
    this.bestDayTotal = 0,
    this.topMantraId,
    this.topMantraTotal = 0,
    this.milestonesReached = const [],
  });

  final int year;
  final int total;
  final int malas;
  final int activeDays;

  /// The longest run of consecutive days with any Jaap, within the year.
  final int longestRun;

  /// Twelve totals, January first.
  final List<int> monthlyTotals;

  final String? bestDay;
  final int bestDayTotal;
  final String? topMantraId;
  final int topMantraTotal;

  /// Jaap milestones first reached during this year.
  final List<int> milestonesReached;

  bool get isEmpty => total == 0;

  /// Builds the review from [totalsByDay] for the year (keys `yyyy-MM-dd`),
  /// the year's per-mantra totals, and the whole history's milestone days.
  factory YearReview.from({
    required int year,
    required Map<String, int> totalsByDay,
    required Map<String, int> totalsByMantra,
    required Map<String, int> mantraMalaSizes,
    required Map<int, String> milestoneDays,
  }) {
    final prefix = '$year-';
    final inYear = {
      for (final e in totalsByDay.entries)
        if (e.key.startsWith(prefix) && e.value > 0) e.key: e.value,
    };

    final days = inYear.keys.toList()..sort();
    final monthly = List<int>.filled(12, 0);
    String? bestDay;
    var bestTotal = 0;
    var longest = 0;
    var run = 0;
    DateTime? previous;
    // Oldest first, so the earliest of two equal best days is the one named.
    for (final key in days) {
      final total = inYear[key]!;
      monthly[int.parse(key.substring(5, 7)) - 1] += total;
      if (total > bestTotal) {
        bestDay = key;
        bestTotal = total;
      }

      final date = DateTime.parse(key);
      final consecutive =
          previous != null &&
          DateTime(previous.year, previous.month, previous.day + 1) == date;
      run = consecutive ? run + 1 : 1;
      if (run > longest) longest = run;
      previous = date;
    }

    String? topId;
    var topTotal = 0;
    var malas = 0;
    for (final e in totalsByMantra.entries) {
      final size = mantraMalaSizes[e.key] ?? 108;
      if (size > 0) malas += e.value ~/ size;
      if (e.value > topTotal) {
        topId = e.key;
        topTotal = e.value;
      }
    }

    return YearReview(
      year: year,
      total: inYear.values.fold(0, (a, b) => a + b),
      malas: malas,
      activeDays: inYear.length,
      longestRun: longest,
      monthlyTotals: monthly,
      bestDay: bestDay,
      bestDayTotal: bestTotal,
      topMantraId: topId,
      topMantraTotal: topTotal,
      milestonesReached: [
        for (final e in milestoneDays.entries)
          if (e.value.startsWith(prefix)) e.key,
      ]..sort(),
    );
  }
}
