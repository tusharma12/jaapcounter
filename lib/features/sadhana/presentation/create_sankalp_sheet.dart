import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../l10n/app_localizations.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../mantras/presentation/mantra_editor_sheet.dart';
import '../../reminders/domain/reminder.dart';
import '../../reminders/presentation/reminder_controllers.dart';
import '../../reminders/presentation/reminders_screen.dart';
import 'daily_goal_picker.dart';
import 'sadhana_controllers.dart';

Future<bool> showCreateSankalp(BuildContext context) async {
  final created = await showAppSheet<bool>(
    context,
    builder: (context) => const CreateSankalpSheet(),
    expand: true,
  );
  return created ?? false;
}

/// Taking a vow: a mantra, a number, a length, and optionally a time of day
/// to be reminded.
class CreateSankalpSheet extends ConsumerStatefulWidget {
  const CreateSankalpSheet({super.key});

  @override
  ConsumerState<CreateSankalpSheet> createState() => _CreateSankalpSheetState();
}

class _CreateSankalpSheetState extends ConsumerState<CreateSankalpSheet> {
  Mantra? _mantra;
  int _dailyGoal = AppConstants.defaultDailyGoal;
  int? _durationDays = 40;
  TimeOfDay? _reminder = const TimeOfDay(hour: 7, minute: 0);
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final mantras = ref.watch(mantraListProvider).value ?? const <Mantra>[];
    final mantra = _mantra ?? ref.watch(activeMantraProvider);

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xl,
        ),
        children: [
          Text(l10n.createSankalp, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Insets.xl),

          _FieldLabel(l10n.chooseMantra),
          if (mantra != null)
            _SelectorTile(
              onTap: () => _pickMantra(mantras),
              child: MantraText(
                mantra,
                size: 20,
                maxLines: 1,
                align: TextAlign.start,
                color: palette.primaryText,
              ),
            ),
          const SizedBox(height: Insets.xl),

          _FieldLabel(l10n.dailyGoal),
          DailyGoalPicker(
            // A new mantra means a new mala size: start its picker afresh.
            key: ValueKey(mantra?.id),
            value: _dailyGoal,
            malaSize: mantra?.malaSize ?? AppConstants.defaultMalaSize,
            onChanged: (value) => setState(() => _dailyGoal = value),
          ),
          const SizedBox(height: Insets.xl),

          _FieldLabel(l10n.duration),
          PresetSelector(
            presets: AppConstants.sankalpDurationPresets,
            value: _durationDays ?? -1,
            labelOf: (days) => l10n.durationDays(days),
            customLabel: l10n.custom,
            onSelected: (value) => setState(() => _durationDays = value),
            onCustom: () async {
              final value = await showNumberPrompt(
                context,
                title: l10n.duration,
                initialValue: _durationDays ?? 40,
                min: 1,
                max: AppConstants.maxSankalpDays,
                invalidMessage: l10n.duration,
              );
              if (value != null) setState(() => _durationDays = value);
            },
          ),
          const SizedBox(height: Insets.xl),

          _FieldLabel(l10n.reminder),
          _SelectorTile(
            trailing: Switch(
              value: _reminder != null,
              onChanged: (on) => setState(
                () =>
                    _reminder = on ? const TimeOfDay(hour: 7, minute: 0) : null,
              ),
            ),
            onTap: _reminder == null
                ? null
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminder!,
                      helpText: l10n.reminderTime,
                    );
                    if (picked != null) setState(() => _reminder = picked);
                  },
            child: Text(
              _reminder == null ? l10n.off : _reminder!.format(context),
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: Insets.xxl),

          FilledButton(
            onPressed: (_saving || mantra == null)
                ? null
                : () => _begin(mantra),
            child: Text(l10n.beginSadhana),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMantra(List<Mantra> mantras) async {
    final selected = await showAppSheet<Mantra>(
      context,
      expand: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            0,
            Insets.page,
            Insets.xl,
          ),
          children: [
            for (final mantra in mantras)
              ListTile(
                title: MantraText(
                  mantra,
                  size: 19,
                  maxLines: 1,
                  align: TextAlign.start,
                  color: context.palette.primaryText,
                ),
                subtitle: mantra.hasDescription
                    ? Text(
                        mantra.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(mantra),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _mantra = selected);
  }

  Future<void> _begin(Mantra mantra) async {
    final l10n = AppL10n.of(context);
    setState(() => _saving = true);

    final reminderMinutes = _reminder == null
        ? null
        : _reminder!.hour * 60 + _reminder!.minute;

    await ref
        .read(activeSadhanaProvider.notifier)
        .begin(
          mantraId: mantra.id,
          dailyGoal: _dailyGoal,
          durationDays: _durationDays,
          reminderEnabled: reminderMinutes != null,
          reminderMinutes: reminderMinutes,
        );

    // A Sankalp with a reminder time also creates the reminder, so the vow
    // and the nudge cannot drift apart.
    if (reminderMinutes != null) {
      final reminders = ref.read(remindersProvider.notifier);
      await reminders.requestPermission();
      await reminders.setSingleton(
        kind: ReminderKind.goal,
        minutes: reminderMinutes,
        enabled: true,
      );
      await reminders.reschedule(RemindersScreen.copyFrom(l10n));
    }

    if (mounted) Navigator.of(context).pop(true);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.md, left: Insets.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({required this.child, this.onTap, this.trailing});

  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.md,
          ),
          child: Row(
            children: [
              Expanded(child: child),
              trailing ??
                  Icon(Icons.expand_more_rounded, color: palette.tertiaryText),
            ],
          ),
        ),
      ),
    );
  }
}
