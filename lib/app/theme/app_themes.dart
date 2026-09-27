import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The colour themes offered in the theme picker.
///
/// [system] follows the device between the classic light and dark palettes;
/// every other theme is fixed, whatever the device is set to.
enum AppThemeId {
  system,
  white,
  black,
  pastelPink,
  spiritual,
  saffron,
  peaceful,
  terracotta,
  meditative,
  nature,
  roseGold,
  ocean,
  lavender,
  charcoal;

  static AppThemeId? tryParse(String? name) =>
      AppThemeId.values.where((id) => id.name == name).firstOrNull;
}

/// One fixed theme: its swatch in the picker and the palette it applies.
@immutable
class AppThemeSpec {
  const AppThemeSpec._({
    required this.swatch,
    required this.brightness,
    required this.palette,
  });

  /// Derives a full palette from a background and an accent, so each theme
  /// only has to name the two colours that make it what it is.
  factory AppThemeSpec._derive({
    required Color background,
    required Color accent,
    Brightness? brightness,
  }) {
    final b = brightness ?? ThemeData.estimateBrightnessForColor(background);
    final dark = b == Brightness.dark;
    final ink = dark ? Colors.white : const Color(0xFF1A1208);
    Color mix(Color over, double amount) =>
        Color.lerp(background, over, amount)!;

    return AppThemeSpec._(
      swatch: background,
      brightness: b,
      palette: AppPalette(
        background: background,
        card: dark ? mix(Colors.white, 0.07) : mix(Colors.white, 0.55),
        primaryText: dark ? const Color(0xFFF7F4EE) : ink,
        secondaryText: mix(ink, dark ? 0.74 : 0.62),
        tertiaryText: mix(ink, dark ? 0.44 : 0.42),
        saffron: accent,
        saffronDeep: Color.lerp(
          accent,
          dark ? Colors.white : Colors.black,
          0.18,
        )!,
        softSaffron: mix(accent, dark ? 0.2 : 0.18),
        success: AppColors.success,
        danger: AppColors.danger,
        divider: mix(ink, dark ? 0.12 : 0.1),
        track: mix(ink, dark ? 0.1 : 0.08),
        // The background's own hue, lifted on a dark theme and deepened on a
        // light one, so it always belongs to the theme.
        secondary: dark
            ? mix(Colors.white, 0.84)
            : Color.lerp(background, Colors.black, 0.74)!,
        softSecondary: dark
            ? mix(Colors.white, 0.12)
            : Color.lerp(background, Colors.black, 0.08)!,
      ),
    );
  }

  final Color swatch;
  final Brightness brightness;
  final AppPalette palette;

  static final Map<AppThemeId, AppThemeSpec> _specs = {
    AppThemeId.white: AppThemeSpec._(
      swatch: Colors.white,
      brightness: Brightness.light,
      palette: AppPalette.light(),
    ),
    AppThemeId.black: AppThemeSpec._(
      swatch: Colors.black,
      brightness: Brightness.dark,
      palette: AppPalette.dark().copyWith(
        background: Colors.black,
        card: const Color(0xFF121212),
        divider: const Color(0xFF222222),
        track: const Color(0xFF1E1E1E),
        softSecondary: const Color(0xFF1A1917),
      ),
    ),
    AppThemeId.pastelPink: AppThemeSpec._derive(
      background: const Color(0xFFFFD6E0),
      accent: const Color(0xFFC2185B),
    ),
    AppThemeId.spiritual: AppThemeSpec._derive(
      background: const Color(0xFF1A1B2E),
      accent: AppColors.saffron,
    ),
    // Saffron on saffron would vanish, so this one accents in deep maroon.
    AppThemeId.saffron: AppThemeSpec._derive(
      background: const Color(0xFFFF9933),
      accent: const Color(0xFF7A1F00),
      brightness: Brightness.light,
    ),
    AppThemeId.peaceful: AppThemeSpec._derive(
      background: const Color(0xFF0F3B3A),
      accent: const Color(0xFFF5C16C),
    ),
    // A touch deeper than raw terracotta, so pale text on it stays legible.
    AppThemeId.terracotta: AppThemeSpec._derive(
      background: const Color(0xFF783C11),
      accent: const Color(0xFFFFD27F),
      brightness: Brightness.dark,
    ),
    AppThemeId.meditative: AppThemeSpec._derive(
      background: const Color(0xFF121C3D),
      accent: AppColors.saffron,
    ),
    AppThemeId.nature: AppThemeSpec._derive(
      background: const Color(0xFF1E4630),
      accent: const Color(0xFFF5C16C),
    ),
    AppThemeId.roseGold: AppThemeSpec._derive(
      background: const Color(0xFF4A2C2A),
      accent: const Color(0xFFE8B4A0),
    ),
    AppThemeId.ocean: AppThemeSpec._derive(
      background: const Color(0xFF0A3A5C),
      accent: const Color(0xFFFFB347),
    ),
    AppThemeId.lavender: AppThemeSpec._derive(
      background: const Color(0xFF2D1B4E),
      accent: const Color(0xFFC9A7FF),
    ),
    AppThemeId.charcoal: AppThemeSpec._derive(
      background: const Color(0xFF2B2B2B),
      accent: AppColors.saffron,
    ),
  };

  /// The fixed theme for [id]; `null` for [AppThemeId.system].
  static AppThemeSpec? of(AppThemeId id) => _specs[id];
}
