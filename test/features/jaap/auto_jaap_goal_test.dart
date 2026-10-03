import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_actions.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/l10n/app_localizations.dart';

import '../../support/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  int today() => container.read(jaapControllerProvider).value!.todayTotal;

  Future<void> wait([int ms = 120]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  /// A goal of three beads, and Auto Jaap set to stop at the goal.
  Future<AutoJaapController> startAtGoal() async {
    container = await createTestContainer();
    final settings = container.read(settingsProvider.notifier);
    await settings.setHaptics(false);
    await settings.setSound(false);
    await settings.setFallbackDailyGoal(3);
    await container.read(jaapControllerProvider.future);
    final auto = container.read(autoJaapProvider.notifier);
    await auto.updateConfig(
      const AutoJaapConfig(
        interval: Duration(milliseconds: 30),
        stopAfter: AutoJaapStop.goal,
      ),
    );
    auto.start();
    return auto;
  }

  test('reaching the goal pauses and asks, rather than stopping', () async {
    final auto = await startAtGoal();
    await wait();

    final state = container.read(autoJaapProvider);
    expect(state.awaitingGoalChoice, isTrue);
    expect(state.running, isTrue, reason: 'paused, not stopped');
    expect(today(), 3);

    await wait(200);
    expect(today(), 3, reason: 'no beads while the question is open');

    auto.stop();
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  });

  test('continuing carries on past the goal, without asking again', () async {
    final auto = await startAtGoal();
    await wait();

    auto.continueAfterGoal();
    await wait(250);

    final state = container.read(autoJaapProvider);
    expect(state.awaitingGoalChoice, isFalse);
    expect(state.running, isTrue);
    expect(today(), greaterThan(3));

    auto.stop();
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  });

  test('stopping from the question ends the run at the goal', () async {
    final auto = await startAtGoal();
    await wait();

    auto.stop();
    await wait(200);

    final state = container.read(autoJaapProvider);
    expect(state.running, isFalse);
    expect(state.awaitingGoalChoice, isFalse);
    expect(today(), 3);
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  });

  test('the other stopping points do not ask', () async {
    container = await createTestContainer();
    await container.read(settingsProvider.notifier).setHaptics(false);
    await container.read(settingsProvider.notifier).setSound(false);
    await container.read(settingsProvider.notifier).setFallbackDailyGoal(3);
    await container.read(jaapControllerProvider.future);
    final auto = container.read(autoJaapProvider.notifier);
    await auto.updateConfig(
      const AutoJaapConfig(
        interval: Duration(milliseconds: 30),
        stopAfter: AutoJaapStop.never,
      ),
    );

    auto.start();
    await wait(250);

    expect(container.read(autoJaapProvider).awaitingGoalChoice, isFalse);
    expect(today(), greaterThan(3), reason: 'never stops by itself');
    auto.stop();
    await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  });

  group('the question', () {
    Future<bool?> ask(WidgetTester tester, String button) async {
      bool? answer;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  answer = await showGoalReachedDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Daily goal reached'), findsOneWidget);
      expect(find.textContaining('Keep going or stop'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey(button)));
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('Continue answers yes', (tester) async {
      expect(await ask(tester, 'goal-continue'), isTrue);
    });

    testWidgets('Stop answers no', (tester) async {
      expect(await ask(tester, 'goal-stop'), isFalse);
    });
  });
}
