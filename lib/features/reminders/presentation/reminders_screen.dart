import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/reminder.dart';
import 'reminder_controllers.dart';
import '../../festivals/presentation/observance_names.dart';

/// Daily nudges. Deliberately plain: a list of times, each of which can be
/// switched off without being deleted.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  static ReminderCopy copyFrom(AppL10n l10n) => ReminderCopy(
    jaapTitle: l10n.reminderNotificationTitle,
    jaapBody: l10n.reminderNotificationBody,
    streakTitle: l10n.streakNotificationTitle,
    streakBody: l10n.streakNotificationBody,
    goalTitle: l10n.goalNotificationTitle,
    goalBody: l10n.goalNotificationBody,
    observanceName: (o) => observanceName(l10n, o),
    observanceBody: l10n.festivalNotificationBody,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final reminders = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jaapReminders)),
      body: AsyncView<List<Reminder>>(
        value: reminders,
        onRetry: () => ref.invalidate(remindersProvider),
        builder: (context, all) {
          final jaapReminders = all
              .where((r) => r.kind == ReminderKind.jaap)
              .toList();
          if (jaapReminders.isEmpty) {
            return EmptyState(
              glyph: '🔔',
              title: l10n.noRemindersTitle,
              body: l10n.noRemindersBody,
              action: FilledButton(
                onPressed: () => _addReminder(context, ref),
                child: Text(l10n.addReminder),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.sm,
              Insets.page,
              Insets.xxxl * 2,
            ),
            children: [
              AppCardGroup(
                children: [
                  for (final reminder in jaapReminders)
                    _ReminderRow(reminder: reminder),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addReminder(context, ref),
        icon: const Icon(Icons.add_alarm_rounded),
        label: Text(l10n.addReminder),
      ),
    );
  }

  Future<void> _addReminder(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: l10n.reminderTime,
    );
    if (picked == null) return;

    final controller = ref.read(remindersProvider.notifier);
    final granted = await controller.requestPermission();
    await controller.add(picked.hour * 60 + picked.minute);
    await controller.reschedule(copyFrom(l10n));

    if (!granted && context.mounted) {
      showAppSnack(
        context,
        l10n.notificationsBlocked,
        duration: const Duration(seconds: 4),
      );
    }
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final theme = Theme.of(context);
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    final controller = ref.read(remindersProvider.notifier);

    return ListTile(
      title: Text(
        time.format(context),
        style: theme.textTheme.titleLarge?.copyWith(
          color: reminder.enabled ? palette.primaryText : palette.tertiaryText,
        ),
      ),
      subtitle: Text(l10n.everyDay),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          helpText: l10n.reminderTime,
        );
        if (picked == null) return;
        await controller.setTime(reminder, picked.hour * 60 + picked.minute);
        await controller.reschedule(RemindersScreen.copyFrom(l10n));
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: reminder.enabled,
            onChanged: (enabled) async {
              if (enabled) await controller.requestPermission();
              await controller.setEnabled(reminder, enabled);
              await controller.reschedule(RemindersScreen.copyFrom(l10n));
            },
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: () async {
              await controller.remove(reminder.id);
              await controller.reschedule(RemindersScreen.copyFrom(l10n));
            },
            icon: Icon(Icons.close_rounded, color: palette.tertiaryText),
          ),
        ],
      ),
    );
  }
}
