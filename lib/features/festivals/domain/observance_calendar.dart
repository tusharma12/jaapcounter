import '../../../core/utils/day_key.dart';
import '../data/observance_calendar.g.dart';
import 'observance.dart';

/// Looks up the observance calendar: what falls today, and what is coming.
///
/// The dates are a fixed, published table (see `tool/observances.json`), not
/// computed: tithis depend on sunrise and differ by tradition, and a wrong
/// Ekadashi would mislead someone who fasts on it.
class ObservanceCalendar {
  const ObservanceCalendar([this.all = observanceCalendar]);

  final List<Observance> all;

  /// Observances still running or starting within [withinDays] of [today],
  /// soonest first.
  List<Observance> upcoming(DateTime today, {int withinDays = 45}) {
    final todayKey = DayKeys.of(today);
    final horizon = DayKeys.addDays(todayKey, withinDays);
    return [
      for (final o in all)
        if (o.lastDay.compareTo(todayKey) >= 0 &&
            o.start.compareTo(horizon) <= 0)
          o,
    ]..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Observances covering [day], such as an Ekadashi or a day of Navratri.
  List<Observance> on(String day) => [
    for (final o in all)
      if (o.covers(day)) o,
  ];

  /// The last day the table knows about. Past it, nothing is shown.
  String? get lastKnownDay => all.isEmpty
      ? null
      : all.map((o) => o.lastDay).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
}

/// The mantra a Sankalp for this observance starts on, if the library has
/// one that fits. The user can always choose another.
String? suggestedMantraFor(Observance observance) {
  if (observance.kind == ObservanceKind.ekadashi) {
    return 'builtin.om-namo-bhagavate-vasudevaya';
  }
  return switch (observance.id) {
    'sharad-navratri' || 'chaitra-navratri' => 'builtin.om-dum-durgayei-namah',
    'dussehra' || 'ram-navami' => 'builtin.ram',
    'diwali' => 'builtin.om-shri-mahalakshmyai-namah',
    'kartik-month' || 'kartik-purnima' => 'builtin.om-namo-narayanaya',
    'guru-nanak-jayanti' => 'builtin.waheguru',
    'makar-sankranti' => 'builtin.gayatri',
    'vasant-panchami' => 'builtin.om-aim-saraswatyai-namah',
    'maha-shivaratri' || 'shravan-month' => 'builtin.om-namah-shivaya',
    'holi' => 'builtin.radhe-krishna',
    'hanuman-jayanti' => 'builtin.om-hanumate-namah',
    'krishna-janmashtami' => 'builtin.hare-krishna-mahamantra',
    'ganesh-chaturthi' => 'builtin.om-gam-ganapataye-namah',
    _ => null,
  };
}
