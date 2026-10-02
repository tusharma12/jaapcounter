import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

/// Number and duration formatting used across screens.
abstract final class Fmt {
  /// Locales whose CLDR data formats numbers in their own digits (Marathi:
  /// १,००८). The bead count on the ring is plain interpolation, so letting
  /// these through would put 72 on the ring beside १,००८ in the totals; the
  /// app uses Latin digits everywhere, as Hindi already does.
  static const Set<String> _nativeDigitLocales = {'mr'};

  /// Switches those locales to Latin digits for numbers and dates. Call once,
  /// before anything is formatted.
  static void useLatinDigits() {
    for (final code in _nativeDigitLocales) {
      DateFormat.useNativeDigitsByDefaultFor(code, false);
      final s = numberFormatSymbols[code];
      if (s is! NumberSymbols || s.ZERO_DIGIT == '0') continue;
      numberFormatSymbols[code] = NumberSymbols(
        NAME: s.NAME,
        DECIMAL_SEP: s.DECIMAL_SEP,
        GROUP_SEP: s.GROUP_SEP,
        PERCENT: s.PERCENT,
        ZERO_DIGIT: '0',
        PLUS_SIGN: s.PLUS_SIGN,
        MINUS_SIGN: s.MINUS_SIGN,
        EXP_SYMBOL: s.EXP_SYMBOL,
        PERMILL: s.PERMILL,
        INFINITY: s.INFINITY,
        NAN: s.NAN,
        DECIMAL_PATTERN: s.DECIMAL_PATTERN,
        SCIENTIFIC_PATTERN: s.SCIENTIFIC_PATTERN,
        PERCENT_PATTERN: s.PERCENT_PATTERN,
        CURRENCY_PATTERN: s.CURRENCY_PATTERN,
        DEF_CURRENCY_CODE: s.DEF_CURRENCY_CODE,
      );
    }
  }

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
