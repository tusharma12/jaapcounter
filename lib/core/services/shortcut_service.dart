import 'package:quick_actions/quick_actions.dart';

import 'app_logger.dart';

/// The shortcuts shown when the app icon is long-pressed on the home screen.
class ShortcutService {
  ShortcutService([QuickActions? actions])
    : _actions = actions ?? const QuickActions();

  final QuickActions _actions;

  static const String blackout = 'blackout';
  static const String music = 'music';

  /// Starts listening for a chosen shortcut, including the one that launched
  /// the app. Once per launch.
  Future<void> initialize(void Function(String type) onSelected) async {
    try {
      await _actions.initialize(onSelected);
    } on Object catch (error, stack) {
      AppLogger.e('Could not listen for home screen shortcuts', error, stack);
    }
  }

  /// Publishes the list in the current language. [musicLabel] says what
  /// choosing it will do ("Play music" or "Stop music"), so it is published
  /// again whenever the music starts or stops.
  Future<void> publish({
    required String blackoutLabel,
    required String musicLabel,
  }) async {
    try {
      await _actions.setShortcutItems([
        ShortcutItem(
          type: music,
          localizedTitle: musicLabel,
          icon: 'shortcut_music',
        ),
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
