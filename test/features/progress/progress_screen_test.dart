import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/progress/domain/progress_models.dart';
import 'package:japmala/features/progress/presentation/progress_providers.dart';
import 'package:japmala/features/progress/presentation/progress_screen.dart';
import 'package:japmala/features/progress/presentation/widgets/jaap_bar_chart.dart';
import 'package:japmala/features/progress/presentation/widgets/weekly_habit_grid.dart';
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
    // The weekly view is the week-by-week grid, not bars.
    expect(find.byType(WeeklyHabitGrid), findsOneWidget);
    expect(find.byType(JaapBarChart), findsNothing);

    // Today, Thursday 3 September, is selected to begin with.
    expect(find.text('Thu, Sep 3 · 324 Jaap · 3 malas'), findsOneWidget);
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

  testWidgets('the arrows step back through weeks, never past today', (
    tester,
  ) async {
    await seedWeek();
    await pumpProgress(tester);

    expect(find.text('Aug 31 – Sep 6'), findsOneWidget);
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Aug 31 – Sep 6'), findsOneWidget, reason: 'no future');

    await tester.tap(find.byTooltip('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('Aug 24 – Aug 30'), findsOneWidget);
    var summary = await container.read(progressSummaryProvider.future);
    expect(summary.rangeTotal, 0, reason: 'nothing chanted that week');

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    summary = await container.read(progressSummaryProvider.future);
    expect(summary.rangeTotal, 756);
    expect(container.read(progressAnchorProvider), isNull);
  });

  testWidgets('a past month shows all of it', (tester) async {
    await seedWeek();
    await pumpProgress(tester);
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Previous'));
    await tester.pumpAndSettle();

    final summary = await container.read(progressSummaryProvider.future);
    expect(find.text('August 2026'), findsOneWidget);
    expect(summary.buckets.length, 31);
    expect(summary.rangeTotal, 108, reason: '31 August only');
    expect(summary.daysElapsed, 31);
  });

  testWidgets('breaks the total down by mantra when more than one was used', (
    tester,
  ) async {
    final repo = container.read(jaapRepositoryProvider);
    await repo.addBeads(mantraId: 'builtin.ram', delta: 108);
    await repo.addBeads(mantraId: 'builtin.radha', delta: 54);
    container.read(ledgerRevisionProvider.notifier).bump();

    await pumpProgress(tester);
    await tester.scrollUntilVisible(find.text('राधा'), 240);

    expect(find.text('By mantra'), findsOneWidget);
    expect(find.text('राम'), findsOneWidget);
    expect(find.text('राधा'), findsOneWidget);
  });

  testWidgets('reflects a changed daily goal', (tester) async {
    await seedWeek();
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(1008);
    await pumpProgress(tester);

    expect(find.text('/ 1,008 Goal'), findsOneWidget);
  });

  testWidgets('the monthly chart is exactly the days of this month', (
    tester,
  ) async {
    await seedWeek();
    await pumpProgress(tester);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    final summary = await container.read(progressSummaryProvider.future);
    expect(summary.buckets.length, 30, reason: 'September has 30 days');
    expect(summary.buckets.first.start, DateTime(2026, 9));
    expect(summary.buckets.last.start, DateTime(2026, 9, 30));
    // 31 August belongs to this week but not to this month.
    final bucketSum = summary.buckets.fold(0, (sum, b) => sum + b.value);
    expect(bucketSum, summary.rangeTotal);
    expect(summary.rangeTotal, 648);
    expect(summary.buckets[2].isCurrent, isTrue, reason: "3 September");
    expect(summary.buckets[3].isFuture, isTrue);
    expect(find.byType(JaapBarChart), findsOneWidget);
  });

  testWidgets('the daily average ignores days that have not come yet', (
    tester,
  ) async {
    await seedWeek();
    await pumpProgress(tester);

    // Monday to Thursday have passed: 756 over 4 days, not 7.
    final weekly = await container.read(progressSummaryProvider.future);
    expect(weekly.daysElapsed, 4);
    expect(weekly.dailyAverage, 189);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    final monthly = await container.read(progressSummaryProvider.future);
    expect(monthly.daysElapsed, 3);
    expect(monthly.dailyAverage, 216);
  });

  testWidgets('the daily view ends on today', (tester) async {
    await seedWeek();
    await pumpProgress(tester);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    final summary = await container.read(progressSummaryProvider.future);
    expect(summary.rangeTotal, 324, reason: "today's Jaap");
    expect(summary.buckets.length, 7);
    expect(summary.buckets.last.start, DateTime(2026, 9, 3));
    expect(summary.buckets.last.isCurrent, isTrue);
    expect(find.text("Today's Jaap"), findsWidgets);
  });

  testWidgets('the yearly chart names each month', (tester) async {
    await seedWeek();
    await pumpProgress(tester);

    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    for (final month in ['Jan', 'Apr', 'Sep', 'Dec']) {
      expect(find.text(month), findsOneWidget, reason: month);
    }
    expect(find.text('J'), findsNothing);
  });

  testWidgets('the mantra filter narrows every figure but today', (
    tester,
  ) async {
    await seedWeek();
    await container
        .read(jaapRepositoryProvider)
        .addBeads(mantraId: 'builtin.radha', delta: 54);
    container.read(ledgerRevisionProvider.notifier).bump();
    await pumpProgress(tester);

    await tester.tap(find.text('All mantras'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('राधा').last);
    await tester.pumpAndSettle();

    final summary = await container.read(progressSummaryProvider.future);
    expect(summary.mantraId, 'builtin.radha');
    expect(summary.rangeTotal, 54);
    expect(summary.lifetimeTotal, 54);
    expect(summary.todayTotal, 378, reason: "today's card covers everything");
    expect(find.text('Per mantra'), findsNothing);
  });

  testWidgets('tapping a bar describes that day', (tester) async {
    await seedWeek();
    await pumpProgress(tester);
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    expect(find.text('Thu, Sep 3 · 324 Jaap · 3 malas'), findsOneWidget);
    final chart = tester.widget<JaapBarChart>(find.byType(JaapBarChart));
    chart.onSelect(4); // Tuesday 1 September
    await tester.pumpAndSettle();
    expect(find.text('Tue, Sep 1 · 216 Jaap · 2 malas'), findsOneWidget);
  });
}
