import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../l10n/app_localizations.dart';
import '../../mantras/presentation/mantra_editor_sheet.dart';

/// "11 malas a day · 1,188 Jaap", or "500 Jaap per day" when the goal is not
/// a whole number of malas.
String goalLabel(AppL10n l10n, int goal, int malaSize, String locale) {
  if (malaSize > 0 && goal > 0 && goal % malaSize == 0) {
    return l10n.goalMalasPerDay(goal ~/ malaSize, Fmt.count(goal, locale));
  }
  return l10n.jaapPerDay(goal);
}

enum _Unit { malas, jaap }

/// A daily goal chosen in malas or in Jaap. Either way the value is Jaap
/// (beads), so the rest of the app never has to know which the user picked;
/// malas are converted with the mantra's own [malaSize].
class DailyGoalPicker extends StatefulWidget {
  const DailyGoalPicker({
    required this.value,
    required this.malaSize,
    required this.onChanged,
    super.key,
  });

  final int value;
  final int malaSize;
  final ValueChanged<int> onChanged;

  /// Common vows: 16 is the daily round count for the Hare Krishna
  /// Mahamantra, 11 and 21 are traditional counts for most others.
  static const List<int> malaPresets = [1, 3, 5, 11, 16, 21];

  @override
  State<DailyGoalPicker> createState() => _DailyGoalPickerState();
}

class _DailyGoalPickerState extends State<DailyGoalPicker> {
  // Opens in malas whenever the goal is a whole number of them.
  late _Unit _unit = _wholeMalas ? _Unit.malas : _Unit.jaap;

  int get _size => widget.malaSize <= 0 ? 108 : widget.malaSize;
  bool get _wholeMalas => widget.value % _size == 0;

  Future<void> _custom() async {
    final l10n = AppL10n.of(context);
    final malas = _unit == _Unit.malas;
    final value = await showNumberPrompt(
      context,
      title: malas ? l10n.malasPerDay : l10n.numberOfJaap,
      initialValue: malas
          ? (widget.value / _size).ceil().clamp(1, 1000)
          : widget.value,
      min: 1,
      max: malas ? 1000 : 100000,
      invalidMessage: malas ? l10n.malasPerDay : l10n.numberOfJaap,
    );
    if (value != null) widget.onChanged(malas ? value * _size : value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final malas = _unit == _Unit.malas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<_Unit>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: _Unit.malas, label: Text(l10n.goalUnitMalas)),
            ButtonSegment(value: _Unit.jaap, label: Text(l10n.goalUnitJaap)),
          ],
          selected: {_unit},
          onSelectionChanged: (selection) {
            final next = selection.first;
            setState(() => _unit = next);
            // Moving to malas rounds up to the next whole mala, so the goal
            // shown is always one the unit can express.
            if (next == _Unit.malas && !_wholeMalas) {
              widget.onChanged((widget.value / _size).ceil() * _size);
            }
          },
        ),
        const SizedBox(height: Insets.md),
        PresetSelector(
          presets: malas
              ? DailyGoalPicker.malaPresets
              : AppConstants.dailyGoalPresets,
          value: malas
              ? (_wholeMalas ? widget.value ~/ _size : -1)
              : widget.value,
          labelOf: (v) => malas ? l10n.malaCount(v) : Fmt.count(v, locale),
          customLabel: l10n.custom,
          onSelected: (v) => widget.onChanged(malas ? v * _size : v),
          onCustom: _custom,
        ),
        const SizedBox(height: Insets.sm),
        Padding(
          padding: const EdgeInsets.only(left: Insets.xs),
          child: Text(
            goalLabel(l10n, widget.value, _size, locale),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

/// The picker in a sheet with a Save button; returns the new goal in Jaap.
Future<int?> showDailyGoalSheet(
  BuildContext context, {
  required int initial,
  required int malaSize,
}) {
  return showAppSheet<int>(
    context,
    builder: (sheetContext) => _GoalSheet(initial: initial, malaSize: malaSize),
  );
}

class _GoalSheet extends StatefulWidget {
  const _GoalSheet({required this.initial, required this.malaSize});

  final int initial;
  final int malaSize;

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late int _goal = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.setDailyGoal,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: Insets.xl),
            DailyGoalPicker(
              value: _goal,
              malaSize: widget.malaSize,
              onChanged: (v) => setState(() => _goal = v),
            ),
            const SizedBox(height: Insets.xxl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_goal),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
