import 'package:meta/meta.dart';

enum ReminderKind {
  /// A plain nudge at a chosen time of day.
  jaap,

  /// Fires only in the evening if nothing has been chanted yet.
  streak,

  /// Fires if today's goal is still unfinished.
  goal;

  static ReminderKind fromName(String? value) => ReminderKind.values.firstWhere(
    (k) => k.name == value,
    orElse: () => ReminderKind.jaap,
  );
}

@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.minutes,
    this.kind = ReminderKind.jaap,
    this.enabled = true,
    this.label,
  });

  final String id;

  /// Minutes since local midnight.
  final int minutes;

  final ReminderKind kind;
  final bool enabled;
  final String? label;

  int get hour => minutes ~/ 60;
  int get minute => minutes % 60;

  /// Stable small integer for the platform notification id.
  int get notificationId => id.hashCode & 0x7FFFFFF;

  Reminder copyWith({int? minutes, bool? enabled, String? label}) => Reminder(
    id: id,
    minutes: minutes ?? this.minutes,
    kind: kind,
    enabled: enabled ?? this.enabled,
    label: label ?? this.label,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'kind': kind.name,
    'minutes': minutes,
    'enabled': enabled ? 1 : 0,
    'label': label,
  };

  factory Reminder.fromMap(Map<String, Object?> map) => Reminder(
    id: map['id'] as String,
    minutes: map['minutes'] as int,
    kind: ReminderKind.fromName(map['kind'] as String?),
    enabled: (map['enabled'] as int? ?? 1) == 1,
    label: map['label'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.minutes == minutes &&
      other.kind == kind &&
      other.enabled == enabled &&
      other.label == label;

  @override
  int get hashCode => Object.hash(id, minutes, kind, enabled, label);
}
