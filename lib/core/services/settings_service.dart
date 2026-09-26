import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/domain/app_settings.dart';
import '../constants/app_constants.dart';

/// Key-value preferences. Anything that is a user choice rather than user
/// data lives here; Jaap itself is never stored in preferences.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'settings.themeMode';
  static const _kLocale = 'settings.locale';
  static const _kHaptics = 'settings.haptics';
  static const _kSound = 'settings.sound';
  static const _kOnboarding = 'settings.onboardingComplete';
  static const _kActiveMantra = 'settings.activeMantraId';
  static const _kDailyGoal = 'settings.fallbackDailyGoal';
  static const _kStoryTextScale = 'settings.storyTextScale';
  static const _kKeepAwake = 'settings.keepScreenOnInMeditation';
  static const _kFavouriteStories = 'stories.favourites';
  static const _kAutoJaap = 'autoJaap.config';
  static const _kCounterHintSeen = 'counter.hintSeen';
  static const _kHideMantra = 'counter.hideMantra';

  AppSettings read() {
    return AppSettings(
      themeMode: _themeModeFrom(_prefs.getString(_kThemeMode)),
      localeCode: _prefs.getString(_kLocale),
      hapticsEnabled: _prefs.getBool(_kHaptics) ?? true,
      soundEnabled: _prefs.getBool(_kSound) ?? false,
      onboardingComplete: _prefs.getBool(_kOnboarding) ?? false,
      activeMantraId: _prefs.getString(_kActiveMantra),
      fallbackDailyGoal:
          _prefs.getInt(_kDailyGoal) ?? AppConstants.defaultDailyGoal,
      storyTextScale: _prefs.getDouble(_kStoryTextScale) ?? 1.0,
      keepScreenOnInMeditation: _prefs.getBool(_kKeepAwake) ?? true,
    );
  }

  Future<void> write(AppSettings settings) async {
    await _prefs.setString(_kThemeMode, settings.themeMode.name);
    if (settings.localeCode == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, settings.localeCode!);
    }
    await _prefs.setBool(_kHaptics, settings.hapticsEnabled);
    await _prefs.setBool(_kSound, settings.soundEnabled);
    await _prefs.setBool(_kOnboarding, settings.onboardingComplete);
    if (settings.activeMantraId == null) {
      await _prefs.remove(_kActiveMantra);
    } else {
      await _prefs.setString(_kActiveMantra, settings.activeMantraId!);
    }
    await _prefs.setInt(_kDailyGoal, settings.fallbackDailyGoal);
    await _prefs.setDouble(_kStoryTextScale, settings.storyTextScale);
    await _prefs.setBool(_kKeepAwake, settings.keepScreenOnInMeditation);
  }

  List<String> favouriteStoryIds() =>
      _prefs.getStringList(_kFavouriteStories) ?? const [];

  Future<void> setFavouriteStoryIds(List<String> ids) =>
      _prefs.setStringList(_kFavouriteStories, ids);

  /// Automatic Jaap preferences, stored as `[intervalMs, speakAloud, stopAfter]`.
  List<String> autoJaapConfig() => _prefs.getStringList(_kAutoJaap) ?? const [];

  Future<void> setAutoJaapConfig(List<String> values) =>
      _prefs.setStringList(_kAutoJaap, values);

  /// Whether the "tap anywhere" hint has done its job and can stay hidden.
  bool counterHintSeen() => _prefs.getBool(_kCounterHintSeen) ?? false;

  Future<void> setCounterHintSeen() => _prefs.setBool(_kCounterHintSeen, true);

  bool hideMantra() => _prefs.getBool(_kHideMantra) ?? false;

  Future<void> setHideMantra(bool hidden) => _prefs.setBool(_kHideMantra, hidden);

  static ThemeMode _themeModeFrom(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
