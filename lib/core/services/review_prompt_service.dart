import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/jaap/data/jaap_repository.dart';
import 'app_logger.dart';

/// When to ask for a store rating: once, and only after the app has proved
/// useful - three days of Jaap, or 2000 beads, whichever comes first.
abstract final class ReviewPrompt {
  static const int daysNeeded = 3;
  static const int beadsNeeded = 2000;

  static bool due({
    required bool alreadyAsked,
    required int activeDays,
    required int lifetimeBeads,
  }) {
    if (alreadyAsked) return false;
    return activeDays >= daysNeeded || lifetimeBeads >= beadsNeeded;
  }
}

/// Shows the system's own rating box at a good moment.
///
/// iOS and Android decide whether the box really appears (iOS allows it
/// three times a year), so the app marks itself as asked as soon as it has
/// tried, and never asks again. A failure here must never reach the user.
class ReviewPromptService {
  ReviewPromptService({
    required this.prefs,
    required this.repository,
    Future<void> Function()? requestReview,
  }) : _requestReview = requestReview ?? _systemRequest;

  static const _kAsked = 'review.asked';

  final SharedPreferences prefs;
  final JaapRepository repository;
  final Future<void> Function() _requestReview;

  static Future<void> _systemRequest() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }

  bool get alreadyAsked => prefs.getBool(_kAsked) ?? false;

  /// Asks if the time has come. Returns whether it asked.
  Future<bool> maybeAsk() async {
    if (alreadyAsked) return false;
    try {
      final totals = await repository.totalsByDay();
      final activeDays = totals.values.where((total) => total > 0).length;
      final lifetime = totals.values.fold<int>(0, (sum, v) => sum + v);
      if (!ReviewPrompt.due(
        alreadyAsked: false,
        activeDays: activeDays,
        lifetimeBeads: lifetime,
      )) {
        return false;
      }
      await prefs.setBool(_kAsked, true);
      await _requestReview();
      return true;
    } on Object catch (error, stack) {
      AppLogger.e('Could not ask for a rating', error, stack);
      return false;
    }
  }
}
