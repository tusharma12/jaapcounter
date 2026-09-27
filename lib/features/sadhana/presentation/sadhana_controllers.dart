import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/day_key.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/sadhana.dart';
import '../domain/streak.dart';

final activeSadhanaProvider =
    AsyncNotifierProvider<ActiveSadhanaController, Sadhana?>(
      ActiveSadhanaController.new,
    );

class ActiveSadhanaController extends AsyncNotifier<Sadhana?> {
  @override
  Future<Sadhana?> build() async {
    final repo = ref.watch(sadhanaRepositoryProvider);
    final sadhana = await repo.active();
    if (sadhana == null) return null;

    // A Sankalp that has run past its last day retires itself, so the screen
    // never shows "Day 41 / 40".
    final now = ref.watch(clockProvider)();
    if (sadhana.hasRunItsCourse(now)) {
      await repo.end(sadhana.id, at: now);
      return null;
    }
    return sadhana;
  }

  Future<Sadhana> begin({
    required String mantraId,
    required int dailyGoal,
    int? durationDays,
    bool reminderEnabled = false,
    int? reminderMinutes,
  }) async {
    final sadhana = await ref
        .read(sadhanaRepositoryProvider)
        .create(
          mantraId: mantraId,
          dailyGoal: dailyGoal,
          durationDays: durationDays,
          reminderEnabled: reminderEnabled,
          reminderMinutes: reminderMinutes,
        );
    // The goal a Sankalp sets becomes the app's daily goal from now on.
    await ref.read(settingsProvider.notifier).setFallbackDailyGoal(dailyGoal);
    ref.invalidateSelf();
    return sadhana;
  }

  Future<void> end() async {
    final current = state.value;
    if (current == null) return;
    await ref.read(sadhanaRepositoryProvider).end(current.id);
    ref.invalidateSelf();
  }

  Future<void> save(Sadhana sadhana) async {
    await ref.read(sadhanaRepositoryProvider).update(sadhana);
    ref.invalidateSelf();
  }
}

/// Today's goal: the active Sankalp's, when it applies to the mantra being
/// chanted, otherwise the standing daily goal from Settings.
final dailyGoalProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  final sadhana = ref.watch(activeSadhanaProvider).value;
  if (sadhana == null) return settings.fallbackDailyGoal;
  final activeMantra = ref.watch(activeMantraProvider);
  if (activeMantra == null || sadhana.mantraId == activeMantra.id) {
    return sadhana.dailyGoal;
  }
  return settings.fallbackDailyGoal;
});

/// Goal for an arbitrary day, used by the streak and the calendar.
final goalForDayProvider = Provider<int Function(String day)>((ref) {
  final fallback = ref.watch(settingsProvider).fallbackDailyGoal;
  final sadhana = ref.watch(activeSadhanaProvider).value;
  return (day) {
    if (sadhana != null && sadhana.coversDay(day)) return sadhana.dailyGoal;
    return fallback;
  };
});

/// The streak counts any Jaap, on any mantra: the habit is the point, and a
/// day spent chanting a different name is not a day off.
final streakProvider = FutureProvider<StreakInfo>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final totals = await ref.watch(jaapRepositoryProvider).totalsByDay();
  return StreakCalculator.calculate(
    totalsByDay: totals,
    today: ref.watch(clockProvider)(),
    goalFor: ref.watch(goalForDayProvider),
  );
});

/// Days of the current Sankalp on which the goal was met.
final sankalpProgressProvider = FutureProvider<int>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final sadhana = ref.watch(activeSadhanaProvider).value;
  if (sadhana == null) return 0;

  final now = ref.watch(clockProvider)();
  final totals = await ref
      .watch(jaapRepositoryProvider)
      .totalsByDay(
        fromDay: sadhana.startDay,
        toDay: DayKeys.of(now),
        mantraId: sadhana.mantraId,
      );
  return totals.values.where((total) => total >= sadhana.dailyGoal).length;
});
