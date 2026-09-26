import 'package:meta/meta.dart';

/// A stretch of continuous chanting the user chose to time.
@immutable
class JaapSession {
  const JaapSession({
    required this.id,
    required this.mantraId,
    required this.startedAt,
    this.endedAt,
    this.count = 0,
  });

  final String id;
  final String mantraId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int count;

  bool get isRunning => endedAt == null;

  Duration elapsedAt(DateTime now) => (endedAt ?? now).difference(startedAt);

  JaapSession copyWith({DateTime? endedAt, int? count}) => JaapSession(
    id: id,
    mantraId: mantraId,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    count: count ?? this.count,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'mantra_id': mantraId,
    'started_at': startedAt.millisecondsSinceEpoch,
    'ended_at': endedAt?.millisecondsSinceEpoch,
    'count': count,
  };

  factory JaapSession.fromMap(Map<String, Object?> map) => JaapSession(
    id: map['id'] as String,
    mantraId: map['mantra_id'] as String,
    startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
    endedAt: map['ended_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['ended_at'] as int),
    count: (map['count'] as int?) ?? 0,
  );
}
