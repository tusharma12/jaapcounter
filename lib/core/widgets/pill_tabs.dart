import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// A horizontal set of pills used for period filters and category filters.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    this.scrollable = false,
    super.key,
  });

  final List<T> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T item) labelOf;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final pills = [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(right: Insets.sm),
          child: _Pill(
            label: labelOf(item),
            selected: item == selected,
            onTap: () => onSelected(item),
          ),
        ),
    ];

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.page),
        child: Row(children: pills),
      );
    }
    return Row(
      children: [
        for (final pill in pills) Expanded(child: pill),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.primaryText : palette.card,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.pill),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: selected ? palette.background : palette.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Presets plus a "Custom" escape hatch, used for mala size, daily goal and
/// Sankalp duration.
class PresetSelector extends StatelessWidget {
  const PresetSelector({
    required this.presets,
    required this.value,
    required this.onSelected,
    required this.customLabel,
    required this.onCustom,
    this.labelOf,
    super.key,
  });

  final List<int> presets;
  final int value;
  final ValueChanged<int> onSelected;
  final String customLabel;
  final VoidCallback onCustom;
  final String Function(int value)? labelOf;

  @override
  Widget build(BuildContext context) {
    final isCustom = !presets.contains(value);
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final preset in presets)
          _Pill(
            label: labelOf?.call(preset) ?? '$preset',
            selected: preset == value && !isCustom,
            onTap: () => onSelected(preset),
          ),
        _Pill(
          label: isCustom ? '${labelOf?.call(value) ?? value}' : customLabel,
          selected: isCustom,
          onTap: onCustom,
        ),
      ],
    );
  }
}
