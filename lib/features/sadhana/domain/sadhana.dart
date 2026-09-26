import 'package:meta/meta.dart';

import '../../../core/utils/day_key.dart';

/// A vow: this many Jaap of this mantra, every day, for this many days.
@immutable
class Sadhana {
  const Sadhana({
    required this.id,
    required this.mantraId,
    required this.dailyGoal,
    required this.startDay,
    this.durationDays,
    this.endedDay,
    this.reminderEnabled = false,
    this.reminderMinutes,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String mantraId;
  final int dailyGoal;

  /// First day of the vow, `yyyy-MM-dd`.
  final String startDay;

  /// Length of the Sankalp. Null means open-ended: a daily goal with no end.
  final int? durationDays;

  /// Set when the user ends the vow early, or when it runs to completion.
  final String? endedDay;

  final bool reminderEnabled;

  /// Minutes since midnight, local time.
  final int? reminderMinutes;

  final bool isActive;
  final DateTime? createdAt;

  bool get isOpenEnded => durationDays == null;

  /// Last day covered by the vow, or null when open-ended.
  String? get lastDay => durationDays == null
      ? null
      : DayKeys.addDays(startDay, durationDays! - 1);

  /// 1-based day number on [today], clamped to the vow's length.
  int dayNumber(DateTime today) {
    final elapsed = DayKeys.daysBetween(DayKeys.parse(startDay), today) + 1;
    if (elapsed < 1) return 0;
    if (durationDays != null && elapsed > durationDays!) return durationDays!;
    return elapsed;
  }

  bool coversDay(String day) {
    if (day.compareTo(startDay) < 0) return false;
    final last = lastDay;
    if (last != null && day.compareTo(last) > 0) return false;
    if (endedDay != null && day.compareTo(endedDay!) > 0) return false;
    return true;
  }

  /// True once the calendar has moved past the final day of the vow.
  bool hasRunItsCourse(DateTime today) {
    final last = lastDay;
    if (last == null) return false;
    return DayKeys.of(today).compareTo(last) > 0;
  }

  Duration? get reminderTimeOfDay => reminderMinutes == null
      ? null
      : Duration(minutes: reminderMinutes!);

  Sadhana copyWith({
    String? mantraId,
    int? dailyGoal,
    String? startDay,
    Object? durationDays = _sentinel,
    Object? endedDay = _sentinel,
    bool? reminderEnabled,
    Object? reminderMinutes = _sentinel,
    bool? isActive,
  }) {
    return Sadhana(
      id: id,
      mantraId: mantraId ?? this.mantraId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      startDay: startDay ?? this.startDay,
      durationDays: durationDays == _sentinel
          ? this.durationDays
          : durationDays as int?,
      endedDay: endedDay == _sentinel ? this.endedDay : endedDay as String?,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes == _sentinel
          ? this.reminderMinutes
          : reminderMinutes as int?,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'mantra_id': mantraId,
    'daily_goal': dailyGoal,
    'start_day': startDay,
    'duration_days': durationDays,
    'ended_day': endedDay,
    'reminder_enabled': reminderEnabled ? 1 : 0,
    'reminder_minutes': reminderMinutes,
    'is_active': isActive ? 1 : 0,
    'created_at': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
  };

  factory Sadhana.fromMap(Map<String, Object?> map) => Sadhana(
    id: map['id'] as String,
    mantraId: map['mantra_id'] as String,
    dailyGoal: map['daily_goal'] as int,
    startDay: map['start_day'] as String,
    durationDays: map['duration_days'] as int?,
    endedDay: map['ended_day'] as String?,
    reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
    reminderMinutes: map['reminder_minutes'] as int?,
    isActive: (map['is_active'] as int? ?? 1) == 1,
    createdAt: map['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
  );

  @override
  bool operator ==(Object other) =>
      other is Sadhana &&
      other.id == id &&
      other.mantraId == mantraId &&
      other.dailyGoal == dailyGoal &&
      other.startDay == startDay &&
      other.durationDays == durationDays &&
      other.endedDay == endedDay &&
      other.reminderEnabled == reminderEnabled &&
      other.reminderMinutes == reminderMinutes &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(
    id,
    mantraId,
    dailyGoal,
    startDay,
    durationDays,
    endedDay,
    reminderEnabled,
    reminderMinutes,
    isActive,
  );
}

const Object _sentinel = Object();
