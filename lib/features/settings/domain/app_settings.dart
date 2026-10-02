import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../../../core/constants/app_constants.dart';
import 'counter_background.dart';
import 'mala_style.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.themeId = AppThemeId.system,
    this.localeCode,
    this.hapticsEnabled = true,
    this.soundEnabled = false,
    this.onboardingComplete = false,
    this.activeMantraId,
    this.fallbackDailyGoal = AppConstants.defaultDailyGoal,
    this.storyTextScale = 1.0,
    this.keepScreenOnInMeditation = true,
    this.background = CounterBackground.none,
    this.backgroundPhotoPath,
    this.backgroundDim = defaultBackgroundDim,
    this.fallingMantra = false,
    this.malaStyle = MalaStyle.beads,
    this.hardwareKeyCounting = false,
    this.beadMarkerInterval = 0,
    this.graceDaysEnabled = true,
    this.festivalReminders = false,
    this.lockScreenCounter = false,
  });

  /// Choices for [beadMarkerInterval]; 0 means off.
  static const List<int> beadMarkerIntervals = [0, 27, 54];

  static const double defaultBackgroundDim = 0.45;
  static const double minBackgroundDim = 0.0;
  static const double maxBackgroundDim = 0.85;

  final AppThemeId themeId;

  /// `null` follows the device language.
  final String? localeCode;

  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool onboardingComplete;

  /// The mantra the counter opens on.
  final String? activeMantraId;

  /// Daily goal used when no Sadhana is active.
  final int fallbackDailyGoal;

  final double storyTextScale;
  final bool keepScreenOnInMeditation;

  /// What is drawn behind the counter.
  final CounterBackground background;

  /// The copied photo, inside the app's own documents directory. Only
  /// meaningful when [background] is [CounterBackground.photo].
  final String? backgroundPhotoPath;

  /// How much of the theme's background colour is laid over the picture, so
  /// the mantra and count stay readable on a busy photo.
  final double backgroundDim;

  /// Each bead sends the mantra drifting down behind the counter.
  final bool fallingMantra;

  /// Beads or a plain ring, on the counter and in meditation.
  final MalaStyle malaStyle;

  /// Volume buttons, a headset button or a Bluetooth clicker count a bead,
  /// for chanting with eyes closed or the phone in a pocket.
  final bool hardwareKeyCounting;

  /// A distinct knock every this many beads within a mala, so the user can
  /// feel a quarter or half mala without looking. 0 is off.
  final int beadMarkerInterval;

  /// Whether held grace days can bridge a missed day in the streak.
  final bool graceDaysEnabled;

  /// A notification on the morning of Ekadashi and other observances.
  final bool festivalReminders;

  /// A +1 button on the lock screen, kept in step with the counter. A
  /// per-device choice, so it is not part of a backup.
  final bool lockScreenCounter;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  /// Light or dark as far as the platform is concerned.
  ThemeMode get themeMode => switch (AppThemeSpec.of(themeId)?.brightness) {
    null => ThemeMode.system,
    Brightness.light => ThemeMode.light,
    Brightness.dark => ThemeMode.dark,
  };

  AppSettings copyWith({
    AppThemeId? themeId,
    Object? localeCode = _sentinel,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? onboardingComplete,
    Object? activeMantraId = _sentinel,
    int? fallbackDailyGoal,
    double? storyTextScale,
    bool? keepScreenOnInMeditation,
    CounterBackground? background,
    Object? backgroundPhotoPath = _sentinel,
    double? backgroundDim,
    bool? fallingMantra,
    MalaStyle? malaStyle,
    bool? hardwareKeyCounting,
    int? beadMarkerInterval,
    bool? graceDaysEnabled,
    bool? festivalReminders,
    bool? lockScreenCounter,
  }) {
    return AppSettings(
      themeId: themeId ?? this.themeId,
      localeCode: localeCode == _sentinel
          ? this.localeCode
          : localeCode as String?,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      activeMantraId: activeMantraId == _sentinel
          ? this.activeMantraId
          : activeMantraId as String?,
      fallbackDailyGoal: fallbackDailyGoal ?? this.fallbackDailyGoal,
      storyTextScale: storyTextScale ?? this.storyTextScale,
      keepScreenOnInMeditation:
          keepScreenOnInMeditation ?? this.keepScreenOnInMeditation,
      background: background ?? this.background,
      backgroundPhotoPath: backgroundPhotoPath == _sentinel
          ? this.backgroundPhotoPath
          : backgroundPhotoPath as String?,
      backgroundDim: backgroundDim ?? this.backgroundDim,
      fallingMantra: fallingMantra ?? this.fallingMantra,
      malaStyle: malaStyle ?? this.malaStyle,
      hardwareKeyCounting: hardwareKeyCounting ?? this.hardwareKeyCounting,
      beadMarkerInterval: beadMarkerInterval ?? this.beadMarkerInterval,
      graceDaysEnabled: graceDaysEnabled ?? this.graceDaysEnabled,
      festivalReminders: festivalReminders ?? this.festivalReminders,
      lockScreenCounter: lockScreenCounter ?? this.lockScreenCounter,
    );
  }

  /// Maps the light/dark/system choice older versions stored onto a theme.
  static AppThemeId? themeIdFromLegacyMode(String? mode) => switch (mode) {
    'light' => AppThemeId.white,
    'dark' => AppThemeId.black,
    'system' => AppThemeId.system,
    _ => null,
  };

  /// Parses the `settings` section of a backup. Anything missing or of the
  /// wrong type falls back to [fallback], so an older backup still restores.
  ///
  /// The counter background is deliberately not part of a backup: a photo
  /// lives on this device only.
  factory AppSettings.fromJson(
    Map<String, Object?> json, {
    required AppSettings fallback,
  }) {
    T? read<T>(String key) {
      final value = json[key];
      return value is T ? value : null;
    }

    return fallback.copyWith(
      themeId:
          AppThemeId.tryParse(read<String>('themeId')) ??
          themeIdFromLegacyMode(read<String>('themeMode')),
      localeCode: json.containsKey('localeCode')
          ? read<String>('localeCode')
          : fallback.localeCode,
      hapticsEnabled: read<bool>('hapticsEnabled'),
      soundEnabled: read<bool>('soundEnabled'),
      activeMantraId: json.containsKey('activeMantraId')
          ? read<String>('activeMantraId')
          : fallback.activeMantraId,
      fallbackDailyGoal: read<int>('fallbackDailyGoal'),
      storyTextScale: read<num>('storyTextScale')?.toDouble(),
      keepScreenOnInMeditation: read<bool>('keepScreenOnInMeditation'),
      fallingMantra: read<bool>('fallingMantra'),
      malaStyle: MalaStyle.tryParse(read<String>('malaStyle')),
      hardwareKeyCounting: read<bool>('hardwareKeyCounting'),
      beadMarkerInterval: _validInterval(read<int>('beadMarkerInterval')),
      graceDaysEnabled: read<bool>('graceDaysEnabled'),
      festivalReminders: read<bool>('festivalReminders'),
    );
  }

  Map<String, Object?> toJson() => {
    'themeId': themeId.name,
    // Still written so an older version restoring this backup keeps the
    // closest light/dark choice.
    'themeMode': themeMode.name,
    'localeCode': localeCode,
    'hapticsEnabled': hapticsEnabled,
    'soundEnabled': soundEnabled,
    'activeMantraId': activeMantraId,
    'fallbackDailyGoal': fallbackDailyGoal,
    'storyTextScale': storyTextScale,
    'keepScreenOnInMeditation': keepScreenOnInMeditation,
    'fallingMantra': fallingMantra,
    'malaStyle': malaStyle.name,
    'hardwareKeyCounting': hardwareKeyCounting,
    'beadMarkerInterval': beadMarkerInterval,
    'graceDaysEnabled': graceDaysEnabled,
    'festivalReminders': festivalReminders,
  };

  static int? _validInterval(int? value) =>
      beadMarkerIntervals.contains(value) ? value : null;

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeId == themeId &&
      other.localeCode == localeCode &&
      other.hapticsEnabled == hapticsEnabled &&
      other.soundEnabled == soundEnabled &&
      other.onboardingComplete == onboardingComplete &&
      other.activeMantraId == activeMantraId &&
      other.fallbackDailyGoal == fallbackDailyGoal &&
      other.storyTextScale == storyTextScale &&
      other.keepScreenOnInMeditation == keepScreenOnInMeditation &&
      other.background == background &&
      other.backgroundPhotoPath == backgroundPhotoPath &&
      other.backgroundDim == backgroundDim &&
      other.fallingMantra == fallingMantra &&
      other.malaStyle == malaStyle &&
      other.hardwareKeyCounting == hardwareKeyCounting &&
      other.beadMarkerInterval == beadMarkerInterval &&
      other.graceDaysEnabled == graceDaysEnabled &&
      other.festivalReminders == festivalReminders &&
      other.lockScreenCounter == lockScreenCounter;

  @override
  int get hashCode => Object.hashAll([
    themeId,
    localeCode,
    hapticsEnabled,
    soundEnabled,
    onboardingComplete,
    activeMantraId,
    fallbackDailyGoal,
    storyTextScale,
    keepScreenOnInMeditation,
    background,
    backgroundPhotoPath,
    backgroundDim,
    fallingMantra,
    malaStyle,
    hardwareKeyCounting,
    beadMarkerInterval,
    graceDaysEnabled,
    festivalReminders,
    lockScreenCounter,
  ]);
}

const Object _sentinel = Object();
