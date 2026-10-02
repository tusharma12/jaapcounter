import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import 'app_card.dart';

/// A single figure with its label. Two of these side by side carry most of
/// the Progress screen.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.caption,
    this.accent = false,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return AppCard(
      accented: accent,
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: Insets.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: palette.primaryText,
              ),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: Insets.xs),
            Text(caption!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// The streak, shown as a warm pill. Deliberately the only place a flame
/// appears, so it keeps its meaning.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.label,
    this.dimmed = false,
    this.large = false,
    super.key,
  });

  final String label;

  /// True when today has not been counted yet: the streak is alive but at risk.
  final bool dimmed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    // A themed icon, not the 🔥 emoji: the emoji's fixed orange clashed with
    // every theme that is not saffron.
    final ink = palette.secondary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? Insets.xl : Insets.lg,
        vertical: large ? Insets.md : Insets.sm,
      ),
      decoration: BoxDecoration(
        color: palette.softSecondary,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: large ? 22 : 17,
            // At risk until today is counted, so the flame burns low.
            color: dimmed ? ink.withValues(alpha: 0.45) : ink,
          ),
          SizedBox(width: large ? Insets.sm : Insets.xs),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style:
                  (large
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.titleSmall)
                      ?.copyWith(
                        color: ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
