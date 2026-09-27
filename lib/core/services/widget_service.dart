import 'dart:io' show Platform;

import 'package:home_widget/home_widget.dart';

import '../../app/theme/app_colors.dart';
import 'app_logger.dart';

/// Pushes counter state to the home screen widgets.
///
/// The widget reads these values straight from shared storage, so it renders
/// current numbers without the Flutter engine ever starting.
class WidgetService {
  static const String iOSAppGroupId = 'group.com.japmala.japmala';
  static const String androidProviderName = 'JapMalaWidgetProvider';
  static const String iOSWidgetName = 'JapMalaWidget';

  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(iOSAppGroupId);
    }
    _configured = true;
  }

  Future<void> publish({
    required String mantraDisplay,
    required int beadsInCurrentMala,
    required int malaSize,
    required int todayTotal,
    required int todayMalas,
    required int streak,
    AppPalette? palette,
  }) async {
    try {
      await _ensureConfigured();
      await Future.wait([
        HomeWidget.saveWidgetData<String>('mantra', mantraDisplay),
        HomeWidget.saveWidgetData<int>('beads', beadsInCurrentMala),
        HomeWidget.saveWidgetData<int>('malaSize', malaSize),
        HomeWidget.saveWidgetData<int>('todayTotal', todayTotal),
        HomeWidget.saveWidgetData<int>('todayMalas', todayMalas),
        HomeWidget.saveWidgetData<int>('streak', streak),
        HomeWidget.saveWidgetData<int>(
          'updatedAt',
          DateTime.now().millisecondsSinceEpoch,
        ),
        // The chosen theme's colours as ARGB; absent for Auto, where the
        // widget follows the system's light and dark like the app does.
        for (final (key, color) in [
          ('colorBackground', palette?.background),
          ('colorText', palette?.primaryText),
          ('colorSecondaryText', palette?.secondaryText),
          ('colorAccent', palette?.saffron),
          ('colorTrack', palette?.track),
          ('colorStreak', palette?.secondary),
        ])
          HomeWidget.saveWidgetData<int>(key, color?.toARGB32()),
      ]);
      await HomeWidget.updateWidget(
        androidName: androidProviderName,
        iOSName: iOSWidgetName,
      );
    } on Object catch (error, stack) {
      // A widget that fails to refresh must never break counting.
      AppLogger.e('Widget update failed', error, stack);
    }
  }
}
