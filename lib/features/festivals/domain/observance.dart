import 'package:meta/meta.dart';

import '../../../core/utils/day_key.dart';

enum ObservanceKind {
  /// The eleventh lunar day, twice a month: a day of fasting and Jaap.
  ekadashi,

  /// A festival of one day, or a few (Navratri).
  festival,

  /// A sacred month, such as Shravan or Kartik.
  period,
}

/// A day, or a run of days, in the observance calendar.
@immutable
class Observance {
  const Observance({
    required this.id,
    required this.kind,
    required this.start,
    this.end,
    this.vaishnavaDay,
  });

  /// `ekadashi.<name>` or the festival's own id, such as `sharad-navratri`.
  final String id;
  final ObservanceKind kind;

  /// First day, `yyyy-MM-dd`.
  final String start;

  /// Last day, inclusive, for observances longer than a day.
  final String? end;

  /// Where the Vaishnava (ISKCON) Ekadashi falls a day after the Smarta one.
  final String? vaishnavaDay;

  String get lastDay => end ?? start;

  int get lengthInDays =>
      DayKeys.daysBetween(DayKeys.parse(start), DayKeys.parse(lastDay)) + 1;

  bool get isMultiDay => lengthInDays > 1;

  bool covers(String day) =>
      day.compareTo(start) >= 0 && day.compareTo(lastDay) <= 0;

  @override
  bool operator ==(Object other) =>
      other is Observance && other.id == id && other.start == start;

  @override
  int get hashCode => Object.hash(id, start);

  @override
  String toString() => 'Observance($id, $start)';
}
