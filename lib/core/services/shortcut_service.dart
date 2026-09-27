import 'package:quick_actions/quick_actions.dart';

import 'app_logger.dart';

/// The shortcuts shown when the app icon is long-pressed on the home screen.
class ShortcutService {
  ShortcutService([QuickActions? actions])
    : _actions = actions ?? const QuickActions();

  final QuickActions _actions;

  static const String blackout = 'blackout';

  /// Listens for a chosen shortcut, including the one that launched the app,
  /// then publishes the list in the current language.
  Future<void> register({
    required String blackoutLabel,
    required void Function(String type) onSelected,
  }) async {
    try {
      await _actions.initialize(onSelected);
      await _actions.setShortcutItems([
        ShortcutItem(
          type: blackout,
          localizedTitle: blackoutLabel,
          // An image set on iOS, a drawable on Android.
          icon: 'shortcut_blackout',
        ),
      ]);
    } on Object catch (error, stack) {
      AppLogger.e('Could not register home screen shortcuts', error, stack);
    }
  }
}
