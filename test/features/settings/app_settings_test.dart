import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/app/theme/app_themes.dart';
import 'package:japmala/core/services/settings_service.dart';
import 'package:japmala/features/settings/domain/app_settings.dart';
import 'package:japmala/features/settings/domain/counter_background.dart';
import 'package:japmala/features/settings/domain/mala_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'a light or dark choice from an older version becomes a theme',
    () async {
      SharedPreferences.setMockInitialValues({'settings.themeMode': 'dark'});
      final service = SettingsService(await SharedPreferences.getInstance());

      expect(service.read().themeId, AppThemeId.black);
    },
  );

  test('theme and background survive a save', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SettingsService(await SharedPreferences.getInstance());

    await service.write(
      const AppSettings(
        themeId: AppThemeId.lavender,
        background: CounterBackground.forest,
        backgroundDim: 0.6,
      ),
    );
    final restored = service.read();

    expect(restored.themeId, AppThemeId.lavender);
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.background, CounterBackground.forest);
    expect(restored.backgroundDim, 0.6);
  });

  test('a backup restores the theme but never the background', () {
    const current = AppSettings(background: CounterBackground.photo);
    final json = const AppSettings(themeId: AppThemeId.saffron).toJson();

    final restored = AppSettings.fromJson(json, fallback: current);

    expect(restored.themeId, AppThemeId.saffron);
    expect(restored.background, CounterBackground.photo);
  });

  test('an old backup with only a theme mode still restores', () {
    final restored = AppSettings.fromJson(const {
      'themeMode': 'light',
    }, fallback: const AppSettings());

    expect(restored.themeId, AppThemeId.white);
  });

  test('every theme builds, with readable text on its accent', () {
    for (final id in AppThemeId.values) {
      final theme = AppTheme.forId(id);
      final scheme = theme.colorScheme;
      final contrast =
          (scheme.primary.computeLuminance() + 0.05) /
          (scheme.onPrimary.computeLuminance() + 0.05);
      expect(
        contrast > 1 ? contrast : 1 / contrast,
        greaterThan(3),
        reason: '$id accent',
      );
    }
  });

  test('falling mantra is off by default and can be switched on', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SettingsService(await SharedPreferences.getInstance());
    expect(service.read().fallingMantra, isFalse);

    await service.write(service.read().copyWith(fallingMantra: true));
    expect(service.read().fallingMantra, isTrue);
  });

  test(
    'mala style defaults to beads and survives a save and a backup',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = SettingsService(await SharedPreferences.getInstance());
      expect(service.read().malaStyle, MalaStyle.beads);

      await service.write(service.read().copyWith(malaStyle: MalaStyle.ring));
      expect(service.read().malaStyle, MalaStyle.ring);

      final restored = AppSettings.fromJson(
        service.read().toJson(),
        fallback: const AppSettings(),
      );
      expect(restored.malaStyle, MalaStyle.ring);
    },
  );
}
