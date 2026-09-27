import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_themes.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static final ThemeData _light = _build(AppPalette.light(), Brightness.light);
  static final ThemeData _dark = _build(AppPalette.dark(), Brightness.dark);
  static final Map<AppThemeId, ThemeData> _fixed = {};

  static ThemeData light() => _light;
  static ThemeData dark() => _dark;

  /// The theme for a fixed colour theme; [AppThemeId.system] has none and
  /// uses [light] and [dark] instead.
  static ThemeData forId(AppThemeId id) {
    final spec = AppThemeSpec.of(id);
    if (spec == null) return _light;
    return _fixed[id] ??= _build(spec.palette, spec.brightness);
  }

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final text = AppTypography.textTheme(p.primaryText, p.secondaryText);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.saffron,
          brightness: brightness,
        ).copyWith(
          primary: p.saffron,
          // Most themes accent in saffron and want dark ink on it; a deep accent
          // (maroon, rose) needs light ink instead.
          onPrimary:
              ThemeData.estimateBrightnessForColor(p.saffron) == Brightness.dark
              ? Colors.white
              : brightness == Brightness.light
              ? const Color(0xFF3A2500)
              : const Color(0xFF241700),
          surface: p.background,
          onSurface: p.primaryText,
          surfaceContainerHighest: p.card,
          error: p.danger,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      fontFamily: AppTypography.ui,
      fontFamilyFallback: AppTypography.fallback,
      textTheme: text,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.saffron,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: p.track,
          disabledForegroundColor: p.tertiaryText,
          minimumSize: const Size.fromHeight(54),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primaryText,
          textStyle: text.labelLarge,
          minimumSize: const Size(Sizes.minTouch, Sizes.minTouch),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primaryText,
          minimumSize: const Size.fromHeight(54),
          textStyle: text.labelLarge,
          side: BorderSide(color: p.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: p.primaryText, size: 22),
      listTileTheme: ListTileThemeData(
        iconColor: p.secondaryText,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        minVerticalPadding: 14,
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.xl),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.card,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.saffron : p.track,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.saffron : p.divider,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        hintStyle: text.bodyLarge?.copyWith(color: p.tertiaryText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.lg,
          vertical: Insets.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.saffron, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.danger),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.divider,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.primaryText,
        contentTextStyle: text.titleSmall?.copyWith(color: p.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.primaryText,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: p.background),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.saffron,
        linearTrackColor: p.track,
        circularTrackColor: p.track,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
