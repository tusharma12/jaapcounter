import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/providers.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../sadhana/presentation/create_sankalp_sheet.dart';
import '../domain/observance.dart';
import '../domain/observance_calendar.dart';
import 'observance_names.dart';
import 'observance_providers.dart';

/// The next few Ekadashis and festivals, each a way into a Sankalp for it.
class ObservancesCard extends ConsumerWidget {
  const ObservancesCard({this.limit = 5, super.key});

  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final upcoming = ref.watch(upcomingObservancesProvider).take(limit);

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Column(
        children: [
          if (upcoming.isEmpty)
            ListTile(title: Text(l10n.observancesNone))
          else
            for (final observance in upcoming)
              _ObservanceRow(observance: observance),
        ],
      ),
    );
  }
}

class _ObservanceRow extends ConsumerWidget {
  const _ObservanceRow({required this.observance});

  final Observance observance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final theme = Theme.of(context);
    final today = DayKeys.dateOnly(ref.watch(clockProvider)());
    final until = DayKeys.daysBetween(today, DayKeys.parse(observance.start));
    final when = until <= 0
        ? l10n.observanceToday
        : l10n.observanceInDays(until);

    return ListTile(
      leading: Icon(
        switch (observance.kind) {
          ObservanceKind.ekadashi => Icons.nightlight_outlined,
          ObservanceKind.festival => Icons.local_florist_outlined,
          ObservanceKind.period => Icons.calendar_month_outlined,
        },
        size: 20,
        color: until <= 0 ? palette.saffron : null,
      ),
      title: Text(observanceName(l10n, observance)),
      subtitle: Text(observanceDates(context, observance)),
      trailing: Text(
        when,
        style: theme.textTheme.bodySmall?.copyWith(
          color: until <= 0 ? palette.saffron : palette.secondaryText,
          fontWeight: until <= 0 ? FontWeight.w600 : null,
        ),
      ),
      onTap: () => showObservanceSheet(context, observance),
    );
  }
}

/// "22 Oct", or "11 Oct – 19 Oct" for a festival of several days.
String observanceDates(BuildContext context, Observance observance) {
  final l10n = AppL10n.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final start = Fmt.dayLabel(DayKeys.parse(observance.start), locale);
  if (!observance.isMultiDay) return start;
  return l10n.observanceDateRange(
    start,
    Fmt.dayLabel(DayKeys.parse(observance.lastDay), locale),
  );
}

/// What the observance is, when, and a Sankalp that fits it: from its first
/// day (or today, if it is already under way) to its last.
Future<void> showObservanceSheet(BuildContext context, Observance observance) {
  // The Sankalp sheet opens from here, not from this sheet, which is gone by
  // the time it does.
  final outer = context;
  return showAppSheet<void>(
    context,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final l10n = AppL10n.of(context);
        final theme = Theme.of(context);
        final palette = context.palette;
        final locale = Localizations.localeOf(context).toLanguageTag();
        final name = observanceName(l10n, observance);
        final today = DayKeys.dateOnly(ref.watch(clockProvider)());
        final firstDay = DayKeys.parse(observance.start);
        final startAt = firstDay.isAfter(today) ? firstDay : today;
        final days =
            DayKeys.daysBetween(startAt, DayKeys.parse(observance.lastDay)) + 1;

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
                Text(name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: Insets.sm),
                Text(
                  observanceDates(context, observance),
                  style: theme.textTheme.titleMedium,
                ),
                if (observance.vaishnavaDay != null) ...[
                  const SizedBox(height: Insets.xs),
                  Text(
                    l10n.observanceVaishnava(
                      Fmt.dayLabel(
                        DayKeys.parse(observance.vaishnavaDay!),
                        locale,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: Insets.lg),
                Text(
                  l10n.observanceSourceNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
                const SizedBox(height: Insets.xxl),
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    showCreateSankalp(
                      outer,
                      mantraId: suggestedMantraFor(observance),
                      durationDays: days,
                      startAt: startAt == today ? null : startAt,
                      title: l10n.observanceSankalpTitle(name),
                    );
                  },
                  child: Text(l10n.observanceTakeSankalp),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
