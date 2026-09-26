import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.localeCode,
    this.hapticsEnabled = true,
    this.soundEnabled = false,
    this.onboardingComplete = false,
    this.activeMantraId,
    this.fallbackDailyGoal = AppConstants.defaultDailyGoal,
    this.storyTextScale = 1.0,
    this.keepScreenOnInMeditation = true,
  });

  final ThemeMode themeMode;

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

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  AppSettings copyWith({
    ThemeMode? themeMode,
    Object? localeCode = _sentinel,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? onboardingComplete,
    Object? activeMantraId = _sentinel,
    int? fallbackDailyGoal,
    double? storyTextScale,
    bool? keepScreenOnInMeditation,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
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
    );
  }

  /// Parses the `settings` section of a backup. Anything missing or of the
  /// wrong type falls back to [fallback], so an older backup still restores.
  factory AppSettings.fromJson(
    Map<String, Object?> json, {
    required AppSettings fallback,
  }) {
    T? read<T>(String key) {
      final value = json[key];
      return value is T ? value : null;
    }

    return fallback.copyWith(
      themeMode: switch (read<String>('themeMode')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => null,
      },
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
    );
  }

  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'localeCode': localeCode,
    'hapticsEnabled': hapticsEnabled,
    'soundEnabled': soundEnabled,
    'activeMantraId': activeMantraId,
    'fallbackDailyGoal': fallbackDailyGoal,
    'storyTextScale': storyTextScale,
    'keepScreenOnInMeditation': keepScreenOnInMeditation,
  };

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.localeCode == localeCode &&
      other.hapticsEnabled == hapticsEnabled &&
      other.soundEnabled == soundEnabled &&
      other.onboardingComplete == onboardingComplete &&
      other.activeMantraId == activeMantraId &&
      other.fallbackDailyGoal == fallbackDailyGoal &&
      other.storyTextScale == storyTextScale &&
      other.keepScreenOnInMeditation == keepScreenOnInMeditation;

  @override
  int get hashCode => Object.hash(
    themeMode,
    localeCode,
    hapticsEnabled,
    soundEnabled,
    onboardingComplete,
    activeMantraId,
    fallbackDailyGoal,
    storyTextScale,
    keepScreenOnInMeditation,
  );
}

const Object _sentinel = Object();
