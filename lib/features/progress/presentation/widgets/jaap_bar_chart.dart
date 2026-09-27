import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/progress_models.dart';

/// Jaap per bucket. Kept spare on purpose: no grid, no axis frame, no legend —
/// the question it answers is "am I becoming more consistent", and clutter
/// makes that harder to see.
///
/// A tap selects a bar rather than popping a tooltip; the caller shows what
/// the selected bar holds underneath, where a thumb does not cover it.
class JaapBarChart extends StatelessWidget {
  const JaapBarChart({
    required this.buckets,
    required this.selectedIndex,
    required this.onSelect,
    this.height = 168,
    super.key,
  });

  final List<ProgressBucket> buckets;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final peak = buckets.fold<int>(
      0,
      (max, b) => b.value > max ? b.value : max,
    );
    // Headroom above the tallest bar so it never touches the top edge.
    final maxY = peak <= 0 ? 10.0 : peak * 1.25;
    final twoLineLabels =
        buckets.isNotEmpty &&
        buckets.first.granularity == BucketGranularity.day;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Each label gets its bar's share of the width and shrinks to fit
        // it, so "Sep" and "सित॰" never run into a neighbour.
        final slot = constraints.maxWidth / buckets.length;

        Widget label(ProgressBucket bucket, bool selected) {
          final style = theme.textTheme.bodySmall?.copyWith(
            height: 1.25,
            color: selected || bucket.isCurrent
                ? palette.primaryText
                : palette.tertiaryText,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          );
          final text = switch (bucket.granularity) {
            BucketGranularity.day =>
              '${bucket.start.day}\n${Fmt.weekdayShort(bucket.start, locale)}',
            // Every fifth date, plus the first: 31 labels would run together.
            BucketGranularity.monthDay =>
              bucket.start.day == 1 || bucket.start.day % 5 == 0
                  ? '${bucket.start.day}'
                  : '',
            BucketGranularity.month => Fmt.monthShort(bucket.start, locale),
          };
          if (text.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: Insets.sm),
            child: SizedBox(
              width: slot,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(text, textAlign: TextAlign.center, style: style),
              ),
            ),
          );
        }

        return SizedBox(
          height: height + (twoLineLabels ? 14 : 0),
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                // The whole column is the target, not just the painted bar,
                // so a day with nothing chanted can still be picked.
                allowTouchBarBackDraw: true,
                touchCallback: (event, response) {
                  final spot = response?.spot;
                  if (event is FlTapUpEvent && spot != null) {
                    onSelect(spot.touchedBarGroupIndex);
                  }
                },
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: twoLineLabels ? 40 : 26,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      return label(buckets[index], index == selectedIndex);
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
                        color: i == selectedIndex
                            ? palette.saffron
                            : palette.saffron.withValues(alpha: 0.42),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: !buckets[i].isFuture,
                          toY: maxY,
                          color: i == selectedIndex
                              ? palette.saffron.withValues(alpha: 0.16)
                              : palette.track.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static double _barWidth(int count) {
    if (count <= 7) return 18;
    if (count <= 12) return 12;
    // A whole month: thin enough that 31 bars keep a gap between them.
    return 5;
  }
}
