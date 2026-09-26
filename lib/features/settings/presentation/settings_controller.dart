import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/services/feedback_service.dart';
import '../domain/app_settings.dart';

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsServiceProvider).read();

  Future<void> _save(AppSettings next) async {
    state = next;
    await ref.read(settingsServiceProvider).write(next);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _save(state.copyWith(themeMode: mode));

  Future<void> setLocale(String? code) =>
      _save(state.copyWith(localeCode: code));

  Future<void> setHaptics(bool enabled) =>
      _save(state.copyWith(hapticsEnabled: enabled));

  Future<void> setSound(bool enabled) =>
      _save(state.copyWith(soundEnabled: enabled));

  Future<void> setActiveMantra(String id) =>
      _save(state.copyWith(activeMantraId: id));

  Future<void> setFallbackDailyGoal(int goal) =>
      _save(state.copyWith(fallbackDailyGoal: goal));

  Future<void> setStoryTextScale(double scale) =>
      _save(state.copyWith(storyTextScale: scale.clamp(0.8, 1.8)));

  Future<void> setKeepScreenOn(bool enabled) =>
      _save(state.copyWith(keepScreenOnInMeditation: enabled));

  Future<void> completeOnboarding() =>
      _save(state.copyWith(onboardingComplete: true));
}

/// Tap feedback follows the haptics and sound settings without every caller
/// having to check them.
final feedbackProvider = Provider<FeedbackService>((ref) {
  final settings = ref.watch(settingsProvider);
  return FeedbackService(
    haptics: settings.hapticsEnabled,
    sound: settings.soundEnabled,
  );
});
