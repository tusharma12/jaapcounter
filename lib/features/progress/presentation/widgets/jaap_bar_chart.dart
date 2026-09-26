import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/progress_models.dart';

/// Jaap per bucket. Kept spare on purpose: no grid, no axis frame, no legend —
/// the question it answers is "am I becoming more consistent", and clutter
/// makes that harder to see.
class JaapBarChart extends StatelessWidget {
  const JaapBarChart({required this.buckets, this.height = 168, super.key});

  final List<ProgressBucket> buckets;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final peak = buckets.fold<int>(0, (max, b) => b.value > max ? b.value : max);
    // Headroom above the tallest bar so it never touches the top edge.
    final maxY = peak <= 0 ? 10.0 : peak * 1.25;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => palette.primaryText,
              tooltipBorderRadius: BorderRadius.circular(Radii.sm),
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                Fmt.count(rod.toY.round(), locale),
                theme.textTheme.titleSmall!.copyWith(color: palette.background),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  final bucket = buckets[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: Insets.sm),
                    child: Text(
                      _label(bucket, locale),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: bucket.isCurrent
                            ? palette.primaryText
                            : palette.tertiaryText,
                        fontWeight: bucket.isCurrent
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].value.toDouble(),
                    width: _barWidth(buckets.length),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    color: buckets[i].isCurrent
                        ? palette.saffron
                        : palette.saffron.withValues(alpha: 0.42),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: palette.track.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static double _barWidth(int count) {
    if (count <= 7) return 18;
    if (count <= 12) return 12;
    return 8;
  }

  static String _label(ProgressBucket bucket, String locale) {
    return switch (bucket.granularity) {
      BucketGranularity.day => Fmt.weekdayInitial(bucket.start, locale),
      BucketGranularity.week => '${bucket.start.day}',
      BucketGranularity.month =>
        Fmt.monthLabel(bucket.start, locale).characters.take(1).toString(),
    };
  }
}
