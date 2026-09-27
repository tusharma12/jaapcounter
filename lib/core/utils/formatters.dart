import 'package:intl/intl.dart';

/// Number and duration formatting used across screens.
abstract final class Fmt {
  static String count(int value, [String? locale]) =>
      NumberFormat.decimalPattern(locale).format(value);

  /// `m:ss` under an hour, `h:mm:ss` beyond it.
  static String stopwatch(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
    return '$m:$ss';
  }

  static String dayLabel(DateTime date, [String? locale]) =>
      DateFormat.MMMd(locale).format(date);

  static String monthLabel(DateTime date, [String? locale]) =>
      DateFormat.yMMMM(locale).format(date);

  /// "Mon", "सोम".
  static String weekdayShort(DateTime date, [String? locale]) =>
      DateFormat.E(locale).format(date);

  /// "Jan", "जन॰".
  static String monthShort(DateTime date, [String? locale]) =>
      DateFormat.MMM(locale).format(date);

  static String time(DateTime date, [String? locale]) =>
      DateFormat.jm(locale).format(date);
}
