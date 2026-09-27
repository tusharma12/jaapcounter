import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/mantras/presentation/mantra_controllers.dart';
import 'package:japmala/features/sadhana/presentation/sadhana_controllers.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

void main() {
  // The controller touches haptics, which needs a binding even in a plain test.
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestClock clock;
  late ProviderContainer container;

  setUp(() async {
    clock = TestClock(DateTime(2026, 9, 3, 9));
    container = await createTestContainer(clock: clock);
  });

  JaapController controller() =>
      container.read(jaapControllerProvider.notifier);

  test('opens on the first mantra with an empty count', () async {
    final state = await container.read(jaapControllerProvider.future);

    expect(state.mantra.id, 'builtin.ram');
    expect(state.lifetime, 0);
    expect(state.todayTotal, 0);
    expect(state.position.beadsInCurrentMala, 0);
    expect(state.undoAvailable, isFalse);
  });

  test('a tap is reflected on screen without waiting for the write', () async {
    await container.read(jaapControllerProvider.future);

    controller().count();

    // No await: the state is already updated in the same turn as the tap.
    final state = container.read(jaapControllerProvider).value!;
    expect(state.todayTotal, 1);
    expect(state.position.beadsInCurrentMala, 1);
  });

  test('100 rapid taps are all persisted', () async {
    await container.read(jaapControllerProvider.future);

    for (var i = 0; i < 100; i++) {
      controller().count();
    }
    await controller().flushPendingWrites();

    expect(container.read(jaapControllerProvider).value!.todayTotal, 100);
    expect(
      await container.read(jaapRepositoryProvider).lifetimeFor('builtin.ram'),
      100,
    );
  });

  test('the mala rolls over on the 108th bead', () async {
    final state = await container.read(jaapControllerProvider.future);

    for (var i = 0; i < 107; i++) {
      controller().count();
    }
    final beforeLast = container.read(jaapControllerProvider).value!;
    expect(beforeLast.position.beadsInCurrentMala, 107);
    expect(beforeLast.position.completedMalas, 0);
    expect(beforeLast.malaCompletions, 0);

    controller().count();

    final after = container.read(jaapControllerProvider).value!;
    expect(after.position.beadsInCurrentMala, 0);
    expect(after.position.completedMalas, 1);
    expect(after.todayTotal, 108);
    expect(
      after.malaCompletions,
      1,
      reason: 'the screen is told once, so it can celebrate once',
    );
    expect(state.mantra.malaSize, 108);
  });

  test('undo removes one bead and reports success', () async {
    await container.read(jaapControllerProvider.future);
    controller().count();
    controller().count();

    final removed = await controller().undo();

    expect(removed, isTrue);
    expect(container.read(jaapControllerProvider).value!.todayTotal, 1);
  });

  test('undo on an empty ledger reports nothing to undo', () async {
    await container.read(jaapControllerProvider.future);

    expect(await controller().undo(), isFalse);
  });

  test('resetting the mala keeps the day and lifetime totals', () async {
    await container.read(jaapControllerProvider.future);
    for (var i = 0; i < 40; i++) {
      controller().count();
    }

    await controller().resetCurrentMala();
    await container.read(jaapControllerProvider.future);

    final state = container.read(jaapControllerProvider).value!;
    expect(state.position.beadsInCurrentMala, 0);
    expect(state.todayTotal, 40, reason: 'the Jaap was still chanted');
    expect(state.lifetime, 40);
  });

  test('a manual entry is added to the same totals', () async {
    await container.read(jaapControllerProvider.future);

    await controller().addManualCount(216);

    final state = container.read(jaapControllerProvider).value!;
    expect(state.todayTotal, 216);
    expect(state.position.completedMalas, 2);
  });

  test('switching mantra shows that mantra\'s own count', () async {
    await container.read(jaapControllerProvider.future);
    for (var i = 0; i < 5; i++) {
      controller().count();
    }
    await controller().flushPendingWrites();

    await container
        .read(mantraListProvider.notifier)
        .setActive('builtin.radha');
    final radhaState = await container.read(jaapControllerProvider.future);

    expect(radhaState.mantra.id, 'builtin.radha');
    expect(radhaState.todayTotal, 0);
    expect(radhaState.position.beadsInCurrentMala, 0);

    await container.read(mantraListProvider.notifier).setActive('builtin.ram');
    final ramState = await container.read(jaapControllerProvider.future);

    expect(ramState.todayTotal, 5);
  });

  test('a new day starts the day total again', () async {
    await container.read(jaapControllerProvider.future);
    controller().count();
    await controller().flushPendingWrites();

    clock.set(DateTime(2026, 9, 4, 6));
    controller().count();
    await controller().flushPendingWrites();

    final state = container.read(jaapControllerProvider).value!;
    expect(state.todayTotal, 1, reason: 'today starts from zero');
    expect(state.lifetime, 2, reason: 'the mala carries on across midnight');
    expect(state.position.beadsInCurrentMala, 2);

    final repo = container.read(jaapRepositoryProvider);
    expect(await repo.dayTotal('2026-09-03', mantraId: 'builtin.ram'), 1);
    expect(await repo.dayTotal('2026-09-04', mantraId: 'builtin.ram'), 1);
  });

  test('goal progress follows the standing daily goal', () async {
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(3);
    await container.read(jaapControllerProvider.future);

    controller().count();
    controller().count();

    var state = container.read(jaapControllerProvider).value!;
    expect(state.dailyGoal, 3);
    expect(state.goalReached, isFalse);
    expect(state.goalRemaining, 1);

    controller().count();

    state = container.read(jaapControllerProvider).value!;
    expect(state.goalReached, isTrue);
    expect(state.goalFraction, 1.0);
  });

  test('a Sankalp goal takes over from the standing goal', () async {
    await container.read(jaapControllerProvider.future);

    await container
        .read(activeSadhanaProvider.notifier)
        .begin(mantraId: 'builtin.ram', dailyGoal: 1008, durationDays: 40);
    final state = await container.read(jaapControllerProvider.future);

    expect(state.dailyGoal, 1008);
  });

  test('a session records only the beads counted inside it', () async {
    await container.read(jaapControllerProvider.future);
    controller().count();

    await controller().startSession();
    for (var i = 0; i < 4; i++) {
      controller().count();
    }
    expect(
      container.read(jaapControllerProvider).value!.sessionRunning,
      isTrue,
    );

    clock.advance(const Duration(minutes: 6));
    final session = await controller().endSession();

    expect(session!.count, 4);
    expect(session.elapsedAt(clock()).inMinutes, 6);
    expect(container.read(jaapControllerProvider).value!.todayTotal, 5);
    expect(
      container.read(jaapControllerProvider).value!.sessionRunning,
      isFalse,
    );
  });

  test('the streak is met once the day\'s goal is reached', () async {
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(2);
    await container.read(jaapControllerProvider.future);

    controller().count();
    controller().count();
    await controller().flushPendingWrites();
    container.read(ledgerRevisionProvider.notifier).bump();

    final streak = await container.read(streakProvider.future);
    expect(streak.current, 1);
    expect(streak.countedToday, isTrue);
  });
}
