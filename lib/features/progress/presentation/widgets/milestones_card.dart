import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/day_key.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sadhana/domain/streak.dart';
import '../../domain/milestones.dart';
import '../milestone_labels.dart';
import '../milestone_providers.dart';

/// The next lifetime milestone and how far off it is, the ones already
/// reached, and the way into the year in review.
class MilestonesCard extends ConsumerWidget {
  const MilestonesCard({required this.streak, super.key});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final progress = ref.watch(milestoneProgressProvider).value;
    if (progress == null) return const SizedBox.shrink();

    final next = progress.next;
    final previous = Milestones.jaap.lastWhere(
      (t) => t <= progress.lifetimeTotal,
      orElse: () => 0,
    );
    final fraction = next == null
        ? 1.0
        : ((progress.lifetimeTotal - previous) / (next - previous)).clamp(
            0.0,
            1.0,
          );
    final reachedStreaks = Milestones.streakDays
        .where((d) => streak.best >= d)
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (next == null)
            Text(l10n.milestoneAllReached, style: theme.textTheme.titleMedium)
          else ...[
            Text(
              l10n.milestoneNext(jaapMilestoneLabel(l10n, next)),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: Insets.sm),
            Semantics(
              label: l10n.milestoneNext(jaapMilestoneLabel(l10n, next)),
              value: l10n.milestoneToGo(next - progress.lifetimeTotal),
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.pill),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    color: palette.saffron,
                    backgroundColor: palette.track,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Insets.xs),
            Text(
              l10n.milestoneToGo(next - progress.lifetimeTotal),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (progress.reachedOn.isNotEmpty || reachedStreaks.isNotEmpty) ...[
            const SizedBox(height: Insets.lg),
            Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                for (final entry in progress.reachedOn.entries)
                  _MilestoneChip(
                    label: jaapMilestoneLabel(l10n, entry.key),
                    caption: Fmt.dayLabel(DayKeys.parse(entry.value), locale),
                  ),
                for (final days in reachedStreaks)
                  _MilestoneChip(label: l10n.milestoneStreak(days)),
              ],
            ),
          ],
          const SizedBox(height: Insets.md),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_stories_outlined, size: 20),
            title: Text(l10n.yearInReview),
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: palette.tertiaryText,
            ),
            onTap: () => context.push('/year-review'),
          ),
        ],
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip({required this.label, this.caption});

  final String label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.sm,
      ),
      decoration: BoxDecoration(
        color: palette.softSaffron,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 16,
            color: palette.saffron,
          ),
          const SizedBox(width: Insets.xs),
          Flexible(
            child: Text(
              caption == null ? label : '$label · $caption',
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
