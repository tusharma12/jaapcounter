import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../domain/milestones.dart';

/// Every Jaap across every mantra, and the day each milestone was reached.
final milestoneProgressProvider = FutureProvider<MilestoneProgress>((
  ref,
) async {
  ref.watch(ledgerRevisionProvider);
  final totals = await ref.watch(jaapRepositoryProvider).totalsByDay();
  return MilestoneProgress(
    lifetimeTotal: totals.values.fold(0, (a, b) => a + b),
    reachedOn: Milestones.jaapReachedOn(totals),
  );
});

class MilestoneProgress {
  const MilestoneProgress({
    required this.lifetimeTotal,
    required this.reachedOn,
  });

  final int lifetimeTotal;
  final Map<int, String> reachedOn;

  int? get next => Milestones.nextJaap(lifetimeTotal);
}

/// The years that have any Jaap in them, newest first, always including the
/// current one so the review has somewhere to start.
final reviewYearsProvider = FutureProvider<List<int>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final now = ref.watch(clockProvider)();
  final first = await ref.watch(jaapRepositoryProvider).firstRecordedDay();
  final firstYear = first == null ? now.year : int.parse(first.substring(0, 4));
  return [for (var y = now.year; y >= firstYear; y--) y];
});

final yearReviewProvider = FutureProvider.family<YearReview, int>((
  ref,
  year,
) async {
  ref.watch(ledgerRevisionProvider);
  final repo = ref.watch(jaapRepositoryProvider);
  final from = '$year-01-01';
  final to = '$year-12-31';
  final mantras = await ref.watch(mantraListProvider.future);
  final progress = await ref.watch(milestoneProgressProvider.future);
  return YearReview.from(
    year: year,
    totalsByDay: await repo.totalsByDay(fromDay: from, toDay: to),
    totalsByMantra: await repo.totalsByMantra(fromDay: from, toDay: to),
    mantraMalaSizes: {for (final m in mantras) m.id: m.malaSize},
    milestoneDays: progress.reachedOn,
  );
});
