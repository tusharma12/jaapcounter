import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/sadhana/presentation/sadhana_controllers.dart';
import 'package:japmala/features/sadhana/presentation/sadhana_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

void main() {
  late TestClock clock;
  late ProviderContainer container;

  setUp(() async {
    clock = TestClock(DateTime(2026, 9, 3, 9));
    container = await createTestContainer(clock: clock);
  });

  Future<void> pumpSadhana(WidgetTester tester) async {
    await usePhoneSurface(tester);
    await pumpScreen(tester, container, const SadhanaScreen());
    await tester.pumpAndSettle();
  }

  testWidgets('offers a Sankalp when none is running', (tester) async {
    await pumpSadhana(tester);

    expect(find.text('Begin a Sankalp'), findsOneWidget);
    expect(find.text('Create New Sankalp'), findsOneWidget);
    expect(find.text('0 Day Streak'), findsOneWidget);
  });

  testWidgets("shows today's goal against today's Jaap", (tester) async {
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(108);
    await container.read(jaapControllerProvider.future);
    await container.read(jaapControllerProvider.notifier).addManualCount(54);

    await pumpSadhana(tester);

    expect(find.text("Today's Goal"), findsOneWidget);
    // The total and the goal are one rich-text line: "54  /  108".
    expect(find.textContaining('54  /  108'), findsOneWidget);
    expect(find.text('54 to go'), findsOneWidget);
  });

  testWidgets('marks the day complete once the goal is met', (tester) async {
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(108);
    await container.read(jaapControllerProvider.future);
    await container.read(jaapControllerProvider.notifier).addManualCount(108);

    await pumpSadhana(tester);

    expect(find.text('Complete'), findsOneWidget);
  });

  testWidgets('a running Sankalp shows the day and the days completed', (
    tester,
  ) async {
    // A 40 day vow begun 17 days ago, kept on 3 of those days.
    clock.set(DateTime(2026, 8, 17, 8));
    await container.read(activeSadhanaProvider.notifier).begin(
      mantraId: 'builtin.ram',
      dailyGoal: 108,
      durationDays: 40,
    );
    final repo = container.read(jaapRepositoryProvider);
    for (final day in [17, 18, 19]) {
      clock.set(DateTime(2026, 8, day, 8));
      await repo.addBeads(mantraId: 'builtin.ram', delta: 108);
    }
    clock.set(DateTime(2026, 9, 3, 9));
    container.read(ledgerRevisionProvider.notifier).bump();
    container.invalidate(activeSadhanaProvider);

    await pumpSadhana(tester);

    expect(find.text('40 DAY SANKALP'), findsOneWidget);
    expect(find.text('Day 18 / 40'), findsOneWidget);
    expect(find.text('3 days completed'), findsOneWidget);
    expect(find.text('Started Aug 17'), findsOneWidget);
    expect(find.text('End Sankalp'), findsOneWidget);
  });

  testWidgets('a Sankalp that has run its course retires itself', (
    tester,
  ) async {
    clock.set(DateTime(2026, 8, 17, 8));
    await container.read(activeSadhanaProvider.notifier).begin(
      mantraId: 'builtin.ram',
      dailyGoal: 108,
      durationDays: 5,
    );

    // Well past the fifth day.
    clock.set(DateTime(2026, 9, 3, 9));
    container.invalidate(activeSadhanaProvider);
    await pumpSadhana(tester);

    expect(await container.read(activeSadhanaProvider.future), isNull);
    expect(find.text('Begin a Sankalp'), findsOneWidget);
  });

  testWidgets('the streak counts the days the goal was met', (tester) async {
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(108);
    final repo = container.read(jaapRepositoryProvider);
    for (final day in [1, 2, 3]) {
      clock.set(DateTime(2026, 9, day, 8));
      await repo.addBeads(mantraId: 'builtin.ram', delta: 108);
    }
    clock.set(DateTime(2026, 9, 3, 9));
    container.read(ledgerRevisionProvider.notifier).bump();

    await pumpSadhana(tester);

    expect(find.text('3 Day Streak'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Best streak'), 200);
    expect(find.text('Best streak'), findsOneWidget);
  });
}
