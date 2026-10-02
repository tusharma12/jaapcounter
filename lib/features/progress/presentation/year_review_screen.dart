import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../mantras/domain/mantra_names.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../domain/milestones.dart';
import 'milestone_labels.dart';
import 'milestone_providers.dart';

/// A year of practice on one page: the total, the rhythm by month, the best
/// day, the mantra most chanted, and the milestones it brought - with a way to
/// send it on as an image.
class YearReviewScreen extends ConsumerStatefulWidget {
  const YearReviewScreen({super.key});

  @override
  ConsumerState<YearReviewScreen> createState() => _YearReviewScreenState();
}

class _YearReviewScreenState extends ConsumerState<YearReviewScreen> {
  final _cardKey = GlobalKey();
  int? _year;
  bool _sharing = false;

  Future<void> _share(YearReview review) async {
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'japmala-${review.year}.png'));
      await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: l10n.yearShareText(
            review.year,
            Fmt.count(review.total, locale),
          ),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not share the year in review', error, stack);
      if (mounted) showAppSnack(context, l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final years = ref.watch(reviewYearsProvider).value;
    final year = _year ?? ref.watch(clockProvider)().year;
    final index = years?.indexOf(year) ?? -1;
    final hasOlder = years != null && index >= 0 && index < years.length - 1;
    final hasNewer = years != null && index > 0;
    final review = ref.watch(yearReviewProvider(year));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.yearInReview)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.sm,
          Insets.page,
          Insets.xxxl,
        ),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.previousYear,
                onPressed: hasOlder
                    ? () => setState(() => _year = years[index + 1])
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '$year',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.nextYear,
                onPressed: hasNewer
                    ? () => setState(() => _year = years[index - 1])
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          AsyncView<YearReview>(
            value: review,
            onRetry: () => ref.invalidate(yearReviewProvider(year)),
            builder: (context, data) {
              if (data.isEmpty) {
                return EmptyState(title: l10n.yearNoJaap(year));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RepaintBoundary(
                    key: _cardKey,
                    child: _ReviewCard(review: data),
                  ),
                  const SizedBox(height: Insets.xl),
                  FilledButton.icon(
                    onPressed: _sharing ? null : () => _share(data),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.share),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.review});

  final YearReview review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final mantras = ref.watch(mantraListProvider).value ?? const [];
    final topMantra = mantras
        .where((m) => m.id == review.topMantraId)
        .firstOrNull;

    // Painted on the background colour so the shared image is never
    // transparent.
    return ColoredBox(
      color: palette.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            accented: true,
            child: Column(
              children: [
                Text(
                  l10n.yearInReviewTitle(review.year),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: Insets.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.jaapCount(review.total),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: palette.saffron,
                    ),
                  ),
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  l10n.malasCompleted(review.malas),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: l10n.yearActiveDays,
                  value: Fmt.count(review.activeDays, locale),
                ),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: StatTile(
                  label: l10n.yearLongestRun,
                  value: l10n.yearLongestRunValue(review.longestRun),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: l10n.yearBestDay,
                  value: Fmt.count(review.bestDayTotal, locale),
                  caption: review.bestDay == null
                      ? null
                      : Fmt.dayLabel(DayKeys.parse(review.bestDay!), locale),
                ),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: StatTile(
                  label: l10n.yearTopMantra,
                  value: Fmt.count(review.topMantraTotal, locale),
                  caption: topMantra?.displayName(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.yearByMonth, style: theme.textTheme.titleSmall),
                const SizedBox(height: Insets.md),
                _MonthBars(totals: review.monthlyTotals, year: review.year),
              ],
            ),
          ),
          if (review.milestonesReached.isNotEmpty) ...[
            const SizedBox(height: Insets.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.yearMilestones, style: theme.textTheme.titleSmall),
                  const SizedBox(height: Insets.sm),
                  for (final threshold in review.milestonesReached)
                    Padding(
                      padding: const EdgeInsets.only(top: Insets.xs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: 18,
                            color: palette.saffron,
                          ),
                          const SizedBox(width: Insets.sm),
                          Expanded(
                            child: Text(
                              jaapMilestoneLabel(l10n, threshold),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Twelve bars, January to December. Read out as one sentence per month, so
/// a screen reader user hears the same rhythm the bars show.
class _MonthBars extends StatelessWidget {
  const _MonthBars({required this.totals, required this.year});

  final List<int> totals;
  final int year;

  static const double _height = 96;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: palette.tertiaryText, fontSize: 10);
    final peak = totals.fold(0, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var m = 0; m < 12; m++)
          Expanded(
            child: Semantics(
              label:
                  '${Fmt.monthLabel(DateTime(year, m + 1), locale)}: '
                  '${AppL10n.of(context).jaapCount(totals[m])}',
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    Container(
                      height: peak == 0
                          ? 2
                          : (totals[m] / peak * _height).clamp(2, _height),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: totals[m] == 0 ? palette.track : palette.saffron,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(
                      Fmt.monthShort(
                        DateTime(year, m + 1),
                        locale,
                      ).characters.first,
                      style: labelStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
