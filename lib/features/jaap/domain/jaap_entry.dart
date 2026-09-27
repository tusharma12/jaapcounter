import 'package:meta/meta.dart';

import '../../../core/utils/day_key.dart';

/// Where a recorded count came from. Kept in the ledger so imported or
/// manually entered Jaap can be told apart from beads counted in the app.
enum JaapSource {
  tap,
  manual,
  physicalCounter,
  import,

  /// Counted by automatic Jaap rather than a tap.
  auto;

  static JaapSource fromName(String? value) => JaapSource.values.firstWhere(
    (s) => s.name == value,
    orElse: () => JaapSource.tap,
  );
}

/// One row of the append-only Jaap ledger.
///
/// The ledger - not a single running total - is the source of truth. Every
/// derived figure (current mala, today's total, lifetime malas, streaks) is
/// computed from these rows, which is what makes undo, statistics, backup and
/// history safe.
@immutable
class JaapEntry {
  const JaapEntry({
    required this.id,
    required this.mantraId,
    required this.count,
    required this.day,
    required this.timestamp,
    this.source = JaapSource.tap,
    this.sessionId,
  });

  final String id;
  final String mantraId;

  /// Beads recorded by this row. Consecutive taps coalesce into one row, so
  /// this is usually greater than one.
  final int count;

  /// Local calendar day, `yyyy-MM-dd`.
  final String day;

  /// When the row was last written to, in UTC milliseconds.
  final DateTime timestamp;

  final JaapSource source;
  final String? sessionId;

  JaapEntry copyWith({int? count, DateTime? timestamp}) => JaapEntry(
    id: id,
    mantraId: mantraId,
    count: count ?? this.count,
    day: day,
    timestamp: timestamp ?? this.timestamp,
    source: source,
    sessionId: sessionId,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'mantra_id': mantraId,
    'count': count,
    'day': day,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'source': source.name,
    'session_id': sessionId,
  };

  factory JaapEntry.fromMap(Map<String, Object?> map) => JaapEntry(
    id: map['id'] as String,
    mantraId: map['mantra_id'] as String,
    count: map['count'] as int,
    day: map['day'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    source: JaapSource.fromName(map['source'] as String?),
    sessionId: map['session_id'] as String?,
  );

  DateTime get date => DayKeys.parse(day);

  @override
  bool operator ==(Object other) =>
      other is JaapEntry &&
      other.id == id &&
      other.mantraId == mantraId &&
      other.count == count &&
      other.day == day &&
      other.timestamp == timestamp &&
      other.source == source &&
      other.sessionId == sessionId;

  @override
  int get hashCode =>
      Object.hash(id, mantraId, count, day, timestamp, source, sessionId);

  @override
  String toString() => 'JaapEntry($day, $mantraId, +$count, ${source.name})';
}
