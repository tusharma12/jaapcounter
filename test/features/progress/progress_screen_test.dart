import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/progress/domain/progress_models.dart';
import 'package:japmala/features/progress/presentation/progress_providers.dart';
import 'package:japmala/features/progress/presentation/progress_screen.dart';
import 'package:japmala/features/progress/presentation/widgets/activity_heatmap.dart';
import 'package:japmala/features/progress/presentation/widgets/jaap_bar_chart.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

void main() {
  late TestClock clock;
  late ProviderContainer container;

  setUp(() async {
    clock = TestClock(DateTime(2026, 9, 3, 9));
    container = await createTestContainer(clock: clock);
  });

  Future<void> seedWeek() async {
    final repo = container.read(jaapRepositoryProvider);
    // Monday to Thursday of the week containing 2026-09-03.
    const totals = {
      '2026-08-31': 108,
      '2026-09-01': 216,
      '2026-09-02': 108,
      '2026-09-03': 324,
    };
    for (final entry in totals.entries) {
      clock.set(DateTime.parse('${entry.key} 08:00:00'));
      await repo.addBeads(mantraId: 'builtin.ram', delta: entry.value);
    }
    clock.set(DateTime(2026, 9, 3, 9));
    container.read(ledgerRevisionProvider.notifier).bump();
  }

  Future<void> pumpProgress(WidgetTester tester) async {
    await usePhoneSurface(tester);
    await pumpScreen(tester, container, const ProgressScreen());
    await tester.pumpAndSettle();
  }

  testWidgets('invites a first bead when nothing has been chanted', (
    tester,
  ) async {
    await pumpProgress(tester);

    expect(find.text('No Jaap recorded yet'), findsOneWidget);
    expect(find.byType(JaapBarChart), findsNothing);
  });

  testWidgets('shows the streak, today and the lifetime figures', (
    tester,
  ) async {
    await seedWeek();
    await pumpProgress(tester);

    expect(find.text('4 Day Streak'), findsOneWidget);
    expect(find.text('324'), findsWidgets, reason: "today's total");
    expect(find.text('/ 108 Goal'), findsOneWidget);
    expect(find.text('Total Jaap'), findsOneWidget);
    // The same figure is both the lifetime total and this week's total.
    expect(find.text('756'), findsWidgets, reason: 'lifetime Jaap');
    expect(find.text('Total Malas'), findsOneWidget);
    expect(find.text('7'), findsWidgets, reason: '756 / 108 malas');
    expect(find.byType(JaapBarChart), findsOneWidget);

    await tester.scrollUntilVisible(find.byType(ActivityHeatmap), 240);
    expect(find.byType(ActivityHeatmap), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('switching the period changes the range total', (tester) async {
    await seedWeek();
    // Jaap from an earlier month, inside the year but outside the week.
    clock.set(DateTime(2026, 7, 4, 8));
    await container
        .read(jaapRepositoryProvider)
        .addBeads(mantraId: 'builtin.ram', delta: 1000);
    clock.set(DateTime(2026, 9, 3, 9));
    container.read(ledgerRevisionProvider.notifier).bump();

    await pumpProgress(tester);

    expect(container.read(progressPeriodProvider), ProgressPeriod.weekly);
    var summary = await container.read(progressSummaryProvider.future);
    expect(summary.rangeTotal, 756, reason: 'this week only');

    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    summary = await container.read(progressSummaryProvider.future);
    expect(summary.rangeTotal, 1756, reason: 'the whole year');
    expect(summary.buckets.length, 12);
  });

  testWidgets('the heatmap can be moved back but not into the future', (
    tester,
  ) async {
    await seedWeek();
    await pumpProgress(tester);

    expect(container.read(heatmapMonthProvider), DateTime(2026, 9));
    await tester.scrollUntilVisible(
      find.byIcon(Icons.chevron_left_rounded),
      240,
    );

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(container.read(heatmapMonthProvider), DateTime(2026, 8));

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(container.read(heatmapMonthProvider), DateTime(2026, 9));

    // Forward from the current month is disabled, so nothing moves.
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(container.read(heatmapMonthProvider), DateTime(2026, 9));
  });

  testWidgets('breaks the total down by mantra when more than one was used', (
    tester,
  ) async {
    final repo = container.read(jaapRepositoryProvider);
    await repo.addBeads(mantraId: 'builtin.ram', delta: 108);
    await repo.addBeads(mantraId: 'builtin.radha', delta: 54);
    container.read(ledgerRevisionProvider.notifier).bump();

    await pumpProgress(tester);
    await tester.scrollUntilVisible(find.text('Rām'), 240);

    expect(find.text('By mantra'), findsOneWidget);
    expect(find.text('Rām'), findsOneWidget);
    expect(find.text('Rādhā'), findsOneWidget);
  });

  testWidgets('reflects a changed daily goal', (tester) async {
    await seedWeek();
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(1008);
    await pumpProgress(tester);

    expect(find.text('/ 1,008 Goal'), findsOneWidget);
  });
}
