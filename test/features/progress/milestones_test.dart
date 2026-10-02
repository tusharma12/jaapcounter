import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/progress/domain/milestones.dart';
import 'package:japmala/features/progress/presentation/year_review_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

void main() {
  group('Milestones', () {
    test('the highest threshold passed is the one reported', () {
      expect(Milestones.jaapCrossed(1007, 1008), 1008);
      expect(Milestones.jaapCrossed(1008, 1009), isNull);
      expect(Milestones.jaapCrossed(99000, 130000), 125000);
      expect(Milestones.jaapCrossed(0, 5), isNull);
    });

    test('the next one is above the total, or none past a crore', () {
      expect(Milestones.nextJaap(0), 1008);
      expect(Milestones.nextJaap(1008), 10000);
      expect(Milestones.nextJaap(10000000), isNull);
    });

    test('each milestone is dated by the day the running total reached it', () {
      final reached = Milestones.jaapReachedOn({
        '2026-01-02': 500,
        '2026-01-01': 600,
        '2026-03-01': 9000,
      });

      expect(reached, {1008: '2026-01-02', 10000: '2026-03-01'});
    });
  });

  group('YearReview', () {
    YearReview review(Map<String, int> days, {Map<String, int>? mantras}) =>
        YearReview.from(
          year: 2026,
          totalsByDay: days,
          totalsByMantra: mantras ?? const {},
          mantraMalaSizes: const {'a': 108, 'b': 27},
          milestoneDays: const {1008: '2026-02-01', 10000: '2027-01-05'},
        );

    test('sums the year, its months and its days', () {
      final r = review({
        '2026-01-01': 108,
        '2026-01-02': 216,
        '2026-03-10': 54,
        '2025-12-31': 999,
      });

      expect(r.total, 378);
      expect(r.activeDays, 3);
      expect(r.monthlyTotals[0], 324);
      expect(r.monthlyTotals[2], 54);
      expect(r.monthlyTotals[11], 0);
    });

    test('names the best day, the earliest of a tie', () {
      final r = review({'2026-05-02': 300, '2026-04-01': 300, '2026-06-01': 1});

      expect(r.bestDay, '2026-04-01');
      expect(r.bestDayTotal, 300);
    });

    test('finds the longest run, across a month end', () {
      final r = review({
        '2026-01-30': 1,
        '2026-01-31': 1,
        '2026-02-01': 1,
        '2026-02-03': 1,
      });

      expect(r.longestRun, 3);
    });

    test('names the top mantra and counts malas by each mantra\'s size', () {
      final r = review({'2026-01-01': 270}, mantras: {'a': 216, 'b': 54});

      expect(r.topMantraId, 'a');
      expect(r.malas, 2 + 2);
    });

    test('lists only the milestones reached that year', () {
      expect(review({'2026-01-01': 1}).milestonesReached, [1008]);
    });

    test('a year with nothing in it is empty', () {
      expect(review(const {}).isEmpty, isTrue);
    });
  });

  group('on the counter', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late ProviderContainer container;

    setUp(() async {
      container = await createTestContainer();
      await container.read(settingsProvider.notifier).setHaptics(false);
    });

    test('passing a lifetime milestone is reported once', () async {
      // 1,000 Jaap already, on another mantra: milestones are lifetime-wide.
      await container
          .read(jaapRepositoryProvider)
          .addBeads(mantraId: 'builtin.radha', delta: 1000);
      await container.read(jaapControllerProvider.future);
      final controller = container.read(jaapControllerProvider.notifier);

      for (var i = 0; i < 7; i++) {
        controller.count();
      }
      expect(container.read(jaapControllerProvider).value!.milestoneCount, 0);

      controller.count();
      final state = container.read(jaapControllerProvider).value!;
      expect(state.milestone, 1008);
      expect(state.milestoneCount, 1);

      controller.count();
      expect(container.read(jaapControllerProvider).value!.milestoneCount, 1);
      await controller.flushPendingWrites();
    });

    test('a manual entry that passes one is reported too', () async {
      await container.read(jaapControllerProvider.future);
      final controller = container.read(jaapControllerProvider.notifier);

      await controller.addManualCount(1100);

      expect(container.read(jaapControllerProvider).value!.milestone, 1008);
    });
  });

  testWidgets('the year in review shows the year and can be stepped back', (
    tester,
  ) async {
    final clock = TestClock(DateTime(2026, 9, 3, 9));
    final container = await createTestContainer(clock: clock);
    final repo = container.read(jaapRepositoryProvider);
    clock.set(DateTime(2025, 6, 1, 8));
    await repo.addBeads(mantraId: 'builtin.ram', delta: 108);
    clock.set(DateTime(2026, 9, 1, 8));
    await repo.addBeads(mantraId: 'builtin.ram', delta: 1008);
    clock.set(DateTime(2026, 9, 3, 9));

    await usePhoneSurface(tester);
    await pumpScreen(tester, container, const YearReviewScreen());
    await tester.pumpAndSettle();

    expect(find.text('Your 2026 in Jaap'), findsOneWidget);
    // Once as the year's total, once as the milestone it reached.
    expect(find.text('1,008 Jaap'), findsNWidgets(2));
    expect(find.text('Milestones this year'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous year'));
    await tester.pumpAndSettle();

    expect(find.text('Your 2025 in Jaap'), findsOneWidget);
    expect(find.text('108 Jaap'), findsOneWidget);
  });
}
