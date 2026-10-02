import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../core/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/day_key.dart';
import '../../festivals/domain/observance.dart';
import '../../festivals/presentation/observance_providers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/reminder.dart';

/// Already-translated notification wording, handed in from the widget layer
/// because only it can reach the localisations.
@immutable
class ReminderCopy {
  const ReminderCopy({
    required this.jaapTitle,
    required this.jaapBody,
    required this.streakTitle,
    required this.streakBody,
    required this.goalTitle,
    required this.goalBody,
    this.observanceName,
    this.observanceBody,
  });

  /// An observance's name and its notification line, for Ekadashi and
  /// festival reminders. Absent, none are scheduled.
  final String Function(Observance)? observanceName;
  final String Function(String name)? observanceBody;

  final String jaapTitle;
  final String jaapBody;
  final String streakTitle;
  final String streakBody;
  final String goalTitle;
  final String goalBody;

  (String, String) forKind(ReminderKind kind) => switch (kind) {
    ReminderKind.jaap => (jaapTitle, jaapBody),
    ReminderKind.streak => (streakTitle, streakBody),
    ReminderKind.goal => (goalTitle, goalBody),
  };
}

final remindersProvider =
    AsyncNotifierProvider<RemindersController, List<Reminder>>(
      RemindersController.new,
    );

class RemindersController extends AsyncNotifier<List<Reminder>> {
  @override
  Future<List<Reminder>> build() => ref.watch(reminderRepositoryProvider).all();

  Future<Reminder> add(
    int minutes, {
    ReminderKind kind = ReminderKind.jaap,
  }) async {
    final reminder = await ref
        .read(reminderRepositoryProvider)
        .create(minutes: minutes, kind: kind);
    ref.invalidateSelf();
    return reminder;
  }

  Future<void> setEnabled(Reminder reminder, bool enabled) async {
    await ref
        .read(reminderRepositoryProvider)
        .update(reminder.copyWith(enabled: enabled));
    ref.invalidateSelf();
  }

  Future<void> setTime(Reminder reminder, int minutes) async {
    await ref
        .read(reminderRepositoryProvider)
        .update(reminder.copyWith(minutes: minutes));
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(reminderRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  /// Creates or moves the one reminder of a kind - used for the streak and
  /// goal reminders, which are single switches in Settings.
  Future<void> setSingleton({
    required ReminderKind kind,
    required int minutes,
    required bool enabled,
  }) async {
    await ref
        .read(reminderRepositoryProvider)
        .upsertSingleton(kind: kind, minutes: minutes, enabled: enabled);
    ref.invalidateSelf();
  }

  /// First id for observance notifications; ordinary reminders stay below.
  static const int observanceIdBase = 0x10000000;

  /// Ekadashi and festival notifications scheduled ahead. Kept well under
  /// iOS's limit of 64 pending notifications, and topped up on every launch.
  static const int observancesAhead = 12;

  /// Rewrites the platform schedule from the stored reminders. Called after
  /// any change and whenever the app's language changes.
  Future<void> reschedule(ReminderCopy copy) async {
    final reminders = state.value ?? await future;
    final scheduled = [
      for (final reminder in reminders.where((r) => r.enabled))
        ScheduledReminder(
          id: reminder.notificationId,
          hour: reminder.hour,
          minute: reminder.minute,
          title: copy.forKind(reminder.kind).$1,
          body: copy.forKind(reminder.kind).$2,
        ),
      ..._observanceReminders(copy),
    ];
    await ref.read(notificationServiceProvider).sync(scheduled);
  }

  List<ScheduledReminder> _observanceReminders(ReminderCopy copy) {
    final name = copy.observanceName;
    final body = copy.observanceBody;
    if (name == null || body == null) return const [];
    if (!ref.read(settingsProvider).festivalReminders) return const [];
    final upcoming = ref
        .read(observanceCalendarProvider)
        .upcoming(ref.read(clockProvider)(), withinDays: 120)
        .take(observancesAhead);
    var i = 0;
    return [
      for (final observance in upcoming)
        ScheduledReminder(
          id: observanceIdBase + i++,
          hour: 6,
          minute: 0,
          title: name(observance),
          body: body(name(observance)),
          date: DayKeys.parse(observance.start),
        ),
    ];
  }

  /// True when the platform let us post notifications.
  Future<bool> requestPermission() =>
      ref.read(notificationServiceProvider).requestPermission();
}
