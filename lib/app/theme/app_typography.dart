import 'package:flutter/material.dart';

/// Typography for JapMala.
///
/// UI text is Inter; Devanagari falls back to Noto Sans Devanagari so a mantra
/// written in Devanagari renders correctly inside otherwise-Latin UI text.
abstract final class AppTypography {
  static const String ui = 'Inter';
  static const String devanagari = 'NotoSansDevanagari';
  static const List<String> fallback = [devanagari];

  /// Style for a mantra rendered in Devanagari. Devanagari needs a little more
  /// line height than Latin to keep matras from crowding.
  static TextStyle mantra({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: devanagari,
      fontSize: size,
      height: 1.5,
      fontWeight: weight,
      color: color,
    );
  }

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle base(
      double size,
      FontWeight weight, {
      double height = 1.35,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: ui,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? primary,
      );
    }

    return TextTheme(
      // Counter numerals and other hero figures.
      displayLarge: base(72, FontWeight.w600, height: 1.05, letterSpacing: -2),
      displayMedium: base(
        56,
        FontWeight.w600,
        height: 1.05,
        letterSpacing: -1.5,
      ),
      displaySmall: base(40, FontWeight.w600, height: 1.1, letterSpacing: -1),
      headlineLarge: base(30, FontWeight.w600, letterSpacing: -0.6),
      headlineMedium: base(24, FontWeight.w600, letterSpacing: -0.4),
      headlineSmall: base(20, FontWeight.w600, letterSpacing: -0.2),
      titleLarge: base(18, FontWeight.w600),
      titleMedium: base(16, FontWeight.w500),
      titleSmall: base(14, FontWeight.w500),
      bodyLarge: base(16, FontWeight.w400, height: 1.5),
      bodyMedium: base(14, FontWeight.w400, height: 1.5, color: secondary),
      bodySmall: base(12, FontWeight.w400, height: 1.45, color: secondary),
      labelLarge: base(15, FontWeight.w600, letterSpacing: 0.2),
      labelMedium: base(13, FontWeight.w500, color: secondary),
      // Section headers in Settings.
      labelSmall: base(
        11,
        FontWeight.w600,
        letterSpacing: 1.1,
        color: secondary,
      ),
    );
  }
}
