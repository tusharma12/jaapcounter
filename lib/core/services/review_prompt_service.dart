import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/jaap/data/jaap_repository.dart';
import 'app_logger.dart';

/// When to ask for a store rating: only once the app has proved useful - two
/// days of Jaap, or 1000 beads - and then again now and then, at most
/// [maxAsks] times and [gap] apart. iOS shows the box at most three times a
/// year and often stays silent, so one try is too few.
abstract final class ReviewPrompt {
  static const int daysNeeded = 2;
  static const int beadsNeeded = 1000;
  static const int maxAsks = 3;
  static const Duration gap = Duration(days: 120);

  static bool due({
    required int timesAsked,
    required DateTime? lastAsked,
    required DateTime now,
    required int activeDays,
    required int lifetimeBeads,
  }) {
    if (timesAsked >= maxAsks) return false;
    if (lastAsked != null && now.difference(lastAsked) < gap) return false;
    return activeDays >= daysNeeded || lifetimeBeads >= beadsNeeded;
  }
}

/// Shows the system's own rating box at a good moment.
///
/// iOS and Android decide whether the box really appears, so the app counts
/// a try as soon as it has made it. A failure here must never reach the user.
class ReviewPromptService {
  ReviewPromptService({
    required this.prefs,
    required this.repository,
    Future<void> Function()? requestReview,
    DateTime Function()? now,
    this.onAsked,
  }) : _requestReview = requestReview ?? _systemRequest,
       _now = now ?? DateTime.now;

  static const _kTimesAsked = 'review.timesAsked';
  static const _kLastAsked = 'review.lastAsked';
  // Before 1.0.3 the app asked once and only kept this flag.
  static const _kLegacyAsked = 'review.asked';

  final SharedPreferences prefs;
  final JaapRepository repository;

  /// Told each time the app asks, with how many times it has now asked.
  final Future<void> Function(int times)? onAsked;
  final Future<void> Function() _requestReview;
  final DateTime Function() _now;

  static Future<void> _systemRequest() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }

  int get timesAsked =>
      prefs.getInt(_kTimesAsked) ??
      ((prefs.getBool(_kLegacyAsked) ?? false) ? 1 : 0);

  DateTime? get lastAsked {
    final ms = prefs.getInt(_kLastAsked);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Asks if the time has come. Returns whether it asked.
  Future<bool> maybeAsk() async {
    final times = timesAsked;
    if (times >= ReviewPrompt.maxAsks) return false;
    try {
      final now = _now();
      // An old single ask has no date, so the gap counts from the upgrade.
      if (lastAsked == null && times > 0) {
        await prefs.setInt(_kLastAsked, now.millisecondsSinceEpoch);
      }
      final last = lastAsked;
      if (last != null && now.difference(last) < ReviewPrompt.gap) {
        return false;
      }
      final totals = await repository.totalsByDay();
      final activeDays = totals.values.where((total) => total > 0).length;
      final lifetime = totals.values.fold<int>(0, (sum, v) => sum + v);
      if (!ReviewPrompt.due(
        timesAsked: times,
        lastAsked: last,
        now: now,
        activeDays: activeDays,
        lifetimeBeads: lifetime,
      )) {
        return false;
      }
      await prefs.setInt(_kTimesAsked, times + 1);
      await prefs.setInt(_kLastAsked, now.millisecondsSinceEpoch);
      await _requestReview();
      await onAsked?.call(times + 1);
      return true;
    } on Object catch (error, stack) {
      AppLogger.e('Could not ask for a rating', error, stack);
      return false;
    }
  }
}
