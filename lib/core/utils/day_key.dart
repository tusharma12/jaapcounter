/// A day key is a local calendar date rendered as `yyyy-MM-dd`.
///
/// Everything that aggregates Jaap — totals, goals, streaks, the heatmap —
/// keys off this, so a bead counted at 23:59 belongs to that evening and not
/// to the next UTC day.
abstract final class DayKeys {
  static String of(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parse(String key) {
    final parts = key.split('-');
    if (parts.length != 3) {
      throw FormatException('Not a day key: $key');
    }
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static DateTime? tryParse(String key) {
    try {
      return parse(key);
    } on Object {
      return null;
    }
  }

  /// Midnight at the start of [date]'s day, in local time.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime startOfWeek(
    DateTime date, {
    int firstWeekday = DateTime.monday,
  }) {
    final day = dateOnly(date);
    final delta = (day.weekday - firstWeekday + 7) % 7;
    return day.subtract(Duration(days: delta));
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static DateTime startOfYear(DateTime date) => DateTime(date.year);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  /// Calendar days from [from] to [to], ignoring time and DST shifts.
  static int daysBetween(DateTime from, DateTime to) {
    final a = dateOnly(from);
    final b = dateOnly(to);
    return (b.difference(a).inHours / 24).round();
  }

  /// Inclusive list of day keys between two dates.
  static List<String> keysInRange(DateTime from, DateTime to) {
    final start = dateOnly(from);
    final total = daysBetween(from, to);
    if (total < 0) return const [];
    return List.generate(
      total + 1,
      (i) => of(DateTime(start.year, start.month, start.day + i)),
    );
  }

  static String addDays(String key, int days) {
    final d = parse(key);
    return of(DateTime(d.year, d.month, d.day + days));
  }
}

/// Injectable clock, so date-sensitive logic (streaks, day rollover) is
/// testable without waiting for midnight.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
