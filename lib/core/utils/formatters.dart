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

  static String weekdayInitial(DateTime date, [String? locale]) {
    final s = DateFormat.E(locale).format(date);
    return s.isEmpty ? '' : s.characters(0);
  }

  static String time(DateTime date, [String? locale]) =>
      DateFormat.jm(locale).format(date);
}

extension on String {
  String characters(int index) => substring(index, index + 1);
}
