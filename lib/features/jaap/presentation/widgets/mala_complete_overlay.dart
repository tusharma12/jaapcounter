import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

/// Shown briefly when a mala is finished.
///
/// It floats above the counter and fades out on its own: finishing a mala
/// should be acknowledged, not interrupted with a dialog to dismiss.
class MalaCompleteOverlay extends StatelessWidget {
  const MalaCompleteOverlay({
    required this.visible,
    required this.malasCompleted,
    required this.malaSize,
    required this.todayTotal,
    super.key,
  });

  final bool visible;
  final int malasCompleted;
  final int malaSize;
  final int todayTotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return IgnorePointer(
      child: AnimatedSlide(
        duration: Motion.medium,
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, -0.35),
        child: AnimatedOpacity(
          duration: Motion.medium,
          opacity: visible ? 1 : 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Insets.page),
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.xl,
              vertical: Insets.lg,
            ),
            decoration: BoxDecoration(
              color: palette.softSaffron,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(
                color: palette.saffron.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Text('🙏', style: TextStyle(fontSize: 22)),
                const SizedBox(height: Insets.sm),
                Text(l10n.malaComplete, style: theme.textTheme.titleLarge),
                const SizedBox(height: Insets.xs),
                Text(
                  '${l10n.malasCompleted(malasCompleted)} · '
                  '${l10n.jaapCount(malaSize)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  '${l10n.todaysJaap}  ${Fmt.count(todayTotal, locale)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
