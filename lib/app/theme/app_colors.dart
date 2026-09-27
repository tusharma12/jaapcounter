import 'package:flutter/material.dart';

/// The JapMala palette.
///
/// Saffron is an accent, never a wash: it is reserved for progress, calls to
/// action, the streak and selected state. Everything else stays quiet.
abstract final class AppColors {
  // Shared accents
  static const saffron = Color(0xFFF5A623);
  static const saffronDeep = Color(0xFFDE8E0C);
  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFD9534F);

  // Light
  static const lightBackground = Color(0xFFF8F7F4);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF171717);
  static const lightSecondary = Color(0xFF707070);
  static const lightTertiary = Color(0xFFA3A3A3);
  static const lightSoftSaffron = Color(0xFFFFF1D6);
  static const lightDivider = Color(0xFFECEAE4);
  static const lightTrack = Color(0xFFEDEBE6);
  static const lightSecondaryAccent = Color(0xFF6B5A43);
  static const lightSoftSecondary = Color(0xFFF0EBE2);

  // Dark
  static const darkBackground = Color(0xFF0F0F0E);
  static const darkCard = Color(0xFF1A1A19);
  static const darkPrimary = Color(0xFFF5F4F1);
  static const darkSecondary = Color(0xFF9C9A94);
  static const darkTertiary = Color(0xFF6E6C67);
  static const darkSoftSaffron = Color(0xFF33260F);
  static const darkDivider = Color(0xFF2A2A28);
  static const darkTrack = Color(0xFF262624);
  static const darkSecondaryAccent = Color(0xFFD8CBB5);
  static const darkSoftSecondary = Color(0xFF26241F);
}

/// Semantic colours resolved for the active brightness, reachable from any
/// [BuildContext] via `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.saffron,
    required this.saffronDeep,
    required this.softSaffron,
    required this.success,
    required this.danger,
    required this.divider,
    required this.track,
    required this.secondary,
    required this.softSecondary,
  });

  factory AppPalette.light() => const AppPalette(
    background: AppColors.lightBackground,
    card: AppColors.lightCard,
    primaryText: AppColors.lightPrimary,
    secondaryText: AppColors.lightSecondary,
    tertiaryText: AppColors.lightTertiary,
    saffron: AppColors.saffron,
    saffronDeep: AppColors.saffronDeep,
    softSaffron: AppColors.lightSoftSaffron,
    success: AppColors.success,
    danger: AppColors.danger,
    divider: AppColors.lightDivider,
    track: AppColors.lightTrack,
    secondary: AppColors.lightSecondaryAccent,
    softSecondary: AppColors.lightSoftSecondary,
  );

  factory AppPalette.dark() => const AppPalette(
    background: AppColors.darkBackground,
    card: AppColors.darkCard,
    primaryText: AppColors.darkPrimary,
    secondaryText: AppColors.darkSecondary,
    tertiaryText: AppColors.darkTertiary,
    saffron: AppColors.saffron,
    saffronDeep: AppColors.saffronDeep,
    softSaffron: AppColors.darkSoftSaffron,
    success: AppColors.success,
    danger: AppColors.danger,
    divider: AppColors.darkDivider,
    track: AppColors.darkTrack,
    secondary: AppColors.darkSecondaryAccent,
    softSecondary: AppColors.darkSoftSecondary,
  );

  final Color background;
  final Color card;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color saffron;
  final Color saffronDeep;
  final Color softSaffron;
  final Color success;
  final Color danger;
  final Color divider;
  final Color track;

  /// A quiet companion to the accent, drawn from the theme's own hue: used
  /// for the streak and other things that should stand out without
  /// competing with progress and calls to action.
  final Color secondary;

  /// A surface tinted with [secondary], for pills and chips that carry it.
  final Color softSecondary;

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? primaryText,
    Color? secondaryText,
    Color? tertiaryText,
    Color? saffron,
    Color? saffronDeep,
    Color? softSaffron,
    Color? success,
    Color? danger,
    Color? divider,
    Color? track,
    Color? secondary,
    Color? softSecondary,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      tertiaryText: tertiaryText ?? this.tertiaryText,
      saffron: saffron ?? this.saffron,
      saffronDeep: saffronDeep ?? this.saffronDeep,
      softSaffron: softSaffron ?? this.softSaffron,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      divider: divider ?? this.divider,
      track: track ?? this.track,
      secondary: secondary ?? this.secondary,
      softSecondary: softSecondary ?? this.softSecondary,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      saffron: Color.lerp(saffron, other.saffron, t)!,
      saffronDeep: Color.lerp(saffronDeep, other.saffronDeep, t)!,
      softSaffron: Color.lerp(softSaffron, other.softSaffron, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      track: Color.lerp(track, other.track, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      softSecondary: Color.lerp(softSecondary, other.softSecondary, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light();
}
