import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_colors.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/app/theme/app_themes.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance() + 0.05;
  final lb = b.computeLuminance() + 0.05;
  return la > lb ? la / lb : lb / la;
}

void main() {
  final palettes = <String, AppPalette>{
    'system light': AppPalette.light(),
    'system dark': AppPalette.dark(),
    for (final id in AppThemeId.values.skip(1))
      id.name: AppTheme.forId(id).extension<AppPalette>()!,
  };

  // WCAG AA: 4.5 for body text, 3 for large text and icons.
  final pairs = <String, (Color, Color, double) Function(AppPalette)>{
    'text on background': (p) => (p.primaryText, p.background, 4.5),
    'text on card': (p) => (p.primaryText, p.card, 4.5),
    'secondary text on card': (p) => (p.secondaryText, p.card, 4.5),
    'streak on its pill': (p) => (p.secondary, p.softSecondary, 4.5),
  };

  // The classic light saffron is the brand colour and is only ever a fill
  // with a text label beside it, so it is held to the fixed themes alone.
  for (final id in AppThemeId.values.skip(2)) {
    test('${id.name}: accent stands out from the background', () {
      final p = AppTheme.forId(id).extension<AppPalette>()!;
      expect(_contrast(p.saffron, p.background), greaterThanOrEqualTo(3));
    });
  }

  for (final MapEntry(key: name, value: palette) in palettes.entries) {
    for (final MapEntry(key: pair, value: pick) in pairs.entries) {
      test('$name: $pair', () {
        final (fg, bg, min) = pick(palette);
        expect(_contrast(fg, bg), greaterThanOrEqualTo(min));
      });
    }
  }
}
