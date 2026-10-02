import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/app_themes.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/domain/counter_background.dart';
import '../../features/settings/domain/mala_style.dart';
import '../constants/app_constants.dart';

/// Key-value preferences. Anything that is a user choice rather than user
/// data lives here; Jaap itself is never stored in preferences.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  /// Written by versions that only knew light, dark and system; read once
  /// so an upgrade keeps the user's choice.
  static const _kLegacyThemeMode = 'settings.themeMode';
  static const _kThemeId = 'settings.themeId';
  static const _kBackground = 'settings.background';
  static const _kBackgroundPhoto = 'settings.backgroundPhoto';
  static const _kBackgroundDim = 'settings.backgroundDim';
  static const _kFallingMantra = 'settings.fallingMantra';
  static const _kMalaStyle = 'settings.malaStyle';
  static const _kLocale = 'settings.locale';
  static const _kHaptics = 'settings.haptics';
  static const _kSound = 'settings.sound';
  static const _kOnboarding = 'settings.onboardingComplete';
  static const _kActiveMantra = 'settings.activeMantraId';
  static const _kDailyGoal = 'settings.fallbackDailyGoal';
  static const _kStoryTextScale = 'settings.storyTextScale';
  static const _kKeepAwake = 'settings.keepScreenOnInMeditation';
  static const _kHardwareKeys = 'settings.hardwareKeyCounting';
  static const _kBeadMarker = 'settings.beadMarkerInterval';
  static const _kGraceDays = 'settings.graceDays';
  static const _kFestivalReminders = 'settings.festivalReminders';
  static const _kLockScreenCounter = 'settings.lockScreenCounter';
  static const _kFavouriteStories = 'stories.favourites';
  static const _kAutoJaap = 'autoJaap.config';
  static const _kCounterHintSeen = 'counter.hintSeen';
  static const _kHideMantra = 'counter.hideMantra';

  AppSettings read() {
    return AppSettings(
      themeId:
          AppThemeId.tryParse(_prefs.getString(_kThemeId)) ??
          AppSettings.themeIdFromLegacyMode(
            _prefs.getString(_kLegacyThemeMode),
          ) ??
          AppThemeId.system,
      localeCode: _prefs.getString(_kLocale),
      hapticsEnabled: _prefs.getBool(_kHaptics) ?? true,
      soundEnabled: _prefs.getBool(_kSound) ?? false,
      onboardingComplete: _prefs.getBool(_kOnboarding) ?? false,
      activeMantraId: _prefs.getString(_kActiveMantra),
      fallbackDailyGoal:
          _prefs.getInt(_kDailyGoal) ?? AppConstants.defaultDailyGoal,
      storyTextScale: _prefs.getDouble(_kStoryTextScale) ?? 1.0,
      keepScreenOnInMeditation: _prefs.getBool(_kKeepAwake) ?? true,
      background:
          CounterBackground.tryParse(_prefs.getString(_kBackground)) ??
          CounterBackground.none,
      backgroundPhotoPath: _prefs.getString(_kBackgroundPhoto),
      backgroundDim:
          (_prefs.getDouble(_kBackgroundDim) ??
                  AppSettings.defaultBackgroundDim)
              .clamp(
                AppSettings.minBackgroundDim,
                AppSettings.maxBackgroundDim,
              ),
      fallingMantra: _prefs.getBool(_kFallingMantra) ?? false,
      malaStyle:
          MalaStyle.tryParse(_prefs.getString(_kMalaStyle)) ?? MalaStyle.beads,
      hardwareKeyCounting: _prefs.getBool(_kHardwareKeys) ?? false,
      beadMarkerInterval: switch (_prefs.getInt(_kBeadMarker)) {
        final v? when AppSettings.beadMarkerIntervals.contains(v) => v,
        _ => 0,
      },
      graceDaysEnabled: _prefs.getBool(_kGraceDays) ?? true,
      festivalReminders: _prefs.getBool(_kFestivalReminders) ?? false,
      lockScreenCounter: _prefs.getBool(_kLockScreenCounter) ?? false,
    );
  }

  Future<void> write(AppSettings settings) async {
    await _prefs.setString(_kThemeId, settings.themeId.name);
    await _prefs.remove(_kLegacyThemeMode);
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
    await _prefs.setString(_kBackground, settings.background.name);
    if (settings.backgroundPhotoPath == null) {
      await _prefs.remove(_kBackgroundPhoto);
    } else {
      await _prefs.setString(_kBackgroundPhoto, settings.backgroundPhotoPath!);
    }
    await _prefs.setDouble(_kBackgroundDim, settings.backgroundDim);
    await _prefs.setBool(_kFallingMantra, settings.fallingMantra);
    await _prefs.setString(_kMalaStyle, settings.malaStyle.name);
    await _prefs.setBool(_kHardwareKeys, settings.hardwareKeyCounting);
    await _prefs.setInt(_kBeadMarker, settings.beadMarkerInterval);
    await _prefs.setBool(_kGraceDays, settings.graceDaysEnabled);
    await _prefs.setBool(_kFestivalReminders, settings.festivalReminders);
    await _prefs.setBool(_kLockScreenCounter, settings.lockScreenCounter);
  }

  List<String> favouriteStoryIds() =>
      _prefs.getStringList(_kFavouriteStories) ?? const [];

  Future<void> setFavouriteStoryIds(List<String> ids) =>
      _prefs.setStringList(_kFavouriteStories, ids);

  /// Automatic Jaap preferences, stored as `[intervalMs, _, stopAfter, ...]`.
  List<String> autoJaapConfig() => _prefs.getStringList(_kAutoJaap) ?? const [];

  Future<void> setAutoJaapConfig(List<String> values) =>
      _prefs.setStringList(_kAutoJaap, values);

  /// Whether the "tap anywhere" hint has done its job and can stay hidden.
  bool counterHintSeen() => _prefs.getBool(_kCounterHintSeen) ?? false;

  Future<void> setCounterHintSeen() => _prefs.setBool(_kCounterHintSeen, true);

  bool hideMantra() => _prefs.getBool(_kHideMantra) ?? false;

  Future<void> setHideMantra(bool hidden) =>
      _prefs.setBool(_kHideMantra, hidden);
}
