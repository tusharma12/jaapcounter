import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import 'app_logger.dart';

/// Anonymous usage analytics through Firebase.
///
/// What a person chants stays on their device: events carry only what
/// happened and plain numbers like a Sankalp's length - never a mantra's
/// name, text or count. The user can turn it off in Settings, and nothing
/// is sent when Firebase could not start (tests, or a build without its
/// config). A failure here must never reach the user.
class AnalyticsService {
  AnalyticsService({required this._enabled});

  bool _enabled;

  FirebaseAnalytics? get _analytics =>
      Firebase.apps.isEmpty ? null : FirebaseAnalytics.instance;

  /// Starts Firebase. Called once from `main`; the app runs on without it.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on Object catch (error, stack) {
      AppLogger.e('Firebase unavailable', error, stack);
    }
  }

  /// Firebase keeps this across launches, so its own events (first open,
  /// sessions) stop too.
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _guard(
      'turn analytics ${enabled ? 'on' : 'off'}',
      (analytics) => analytics.setAnalyticsCollectionEnabled(enabled),
    );
  }

  /// [screen] is a route pattern such as `/stories/:storyId`, never a
  /// filled-in path.
  Future<void> screen(String screen) =>
      _log((a) => a.logScreenView(screenName: screen, screenClass: screen));

  Future<void> malaCompleted({required bool autoJaap}) =>
      _event('mala_complete', {'auto_jaap': autoJaap ? 1 : 0});

  Future<void> sankalpStarted({required int? days, required int dailyGoal}) =>
      _event('sankalp_start', {'days': days ?? 0, 'daily_goal': dailyGoal});

  Future<void> mantraAdded() => _event('mantra_add');

  Future<void> autoJaapStarted() => _event('auto_jaap_start');

  Future<void> onboardingCompleted() => _event('onboarding_complete');

  Future<void> reviewPromptShown({required int times}) =>
      _event('review_prompt', {'times': times});

  Future<void> _event(String name, [Map<String, Object>? parameters]) =>
      _log((a) => a.logEvent(name: name, parameters: parameters));

  Future<void> _log(Future<void> Function(FirebaseAnalytics) send) async {
    if (!_enabled) return;
    await _guard('log analytics', send);
  }

  Future<void> _guard(
    String what,
    Future<void> Function(FirebaseAnalytics) action,
  ) async {
    try {
      final analytics = _analytics;
      if (analytics == null) return;
      await action(analytics);
    } on Object catch (error, stack) {
      AppLogger.e('Could not $what', error, stack);
    }
  }
}
