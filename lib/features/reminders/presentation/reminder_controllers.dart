import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../core/providers.dart';
import '../../../core/services/notification_service.dart';
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
  });

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

  Future<Reminder> add(int minutes, {ReminderKind kind = ReminderKind.jaap}) async {
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

  /// Creates or moves the one reminder of a kind — used for the streak and
  /// goal reminders, which are single switches in Settings.
  Future<void> setSingleton({
    required ReminderKind kind,
    required int minutes,
    required bool enabled,
  }) async {
    await ref.read(reminderRepositoryProvider).upsertSingleton(
      kind: kind,
      minutes: minutes,
      enabled: enabled,
    );
    ref.invalidateSelf();
  }

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
    ];
    await ref.read(notificationServiceProvider).sync(scheduled);
  }

  /// True when the platform let us post notifications.
  Future<bool> requestPermission() =>
      ref.read(notificationServiceProvider).requestPermission();
}
