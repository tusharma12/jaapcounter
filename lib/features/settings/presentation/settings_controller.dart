import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/theme/app_themes.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/utils/ids.dart';
import '../domain/app_settings.dart';
import '../domain/counter_background.dart';
import '../domain/mala_style.dart';

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsServiceProvider).read();

  Future<void> _save(AppSettings next) async {
    state = next;
    await ref.read(settingsServiceProvider).write(next);
  }

  Future<void> setTheme(AppThemeId id) => _save(state.copyWith(themeId: id));

  /// Switches to a gradient, or to [CounterBackground.none]. A photo chosen
  /// earlier is kept on disk so it can be picked again without re-importing.
  Future<void> setBackground(CounterBackground background) {
    assert(background != CounterBackground.photo, 'Use setBackgroundPhoto');
    return _save(state.copyWith(background: background));
  }

  /// Uses the photo already imported, if there is one.
  Future<void> useSavedPhoto() async {
    final path = state.backgroundPhotoPath;
    if (path == null || !File(path).existsSync()) return;
    await _save(state.copyWith(background: CounterBackground.photo));
  }

  /// Copies [bytes] into the app's documents directory and shows it behind
  /// the counter. The picker's own copy may be temporary, so it is never
  /// referenced directly.
  Future<void> setBackgroundPhoto(Uint8List bytes, {String? extension}) async {
    final dir = await getApplicationDocumentsDirectory();
    final cleaned = (extension ?? '').toLowerCase().replaceAll(
      RegExp('[^a-z0-9]'),
      '',
    );
    final ext = cleaned.isEmpty ? 'jpg' : cleaned;
    // A new name each time, so Flutter's image cache cannot show the old one.
    final file = File(p.join(dir.path, 'background-${newId()}.$ext'));
    await file.writeAsBytes(bytes, flush: true);
    final previous = state.backgroundPhotoPath;
    await _save(
      state.copyWith(
        background: CounterBackground.photo,
        backgroundPhotoPath: file.path,
      ),
    );
    if (previous != null && previous != file.path) _deleteQuietly(previous);
  }

  Future<void> removeBackgroundPhoto() async {
    final previous = state.backgroundPhotoPath;
    await _save(
      state.copyWith(
        background: state.background == CounterBackground.photo
            ? CounterBackground.none
            : state.background,
        backgroundPhotoPath: null,
      ),
    );
    if (previous != null) _deleteQuietly(previous);
  }

  Future<void> setBackgroundDim(double dim) => _save(
    state.copyWith(
      backgroundDim: dim.clamp(
        AppSettings.minBackgroundDim,
        AppSettings.maxBackgroundDim,
      ),
    ),
  );

  void _deleteQuietly(String path) {
    File(path).delete().catchError((Object error, StackTrace stack) {
      AppLogger.e('Could not delete old background', error, stack);
      return File(path);
    });
  }

  Future<void> setLocale(String? code) =>
      _save(state.copyWith(localeCode: code));

  Future<void> setHaptics(bool enabled) =>
      _save(state.copyWith(hapticsEnabled: enabled));

  Future<void> setSound(bool enabled) =>
      _save(state.copyWith(soundEnabled: enabled));

  Future<void> setActiveMantra(String id) =>
      _save(state.copyWith(activeMantraId: id));

  Future<void> setFallbackDailyGoal(int goal) =>
      _save(state.copyWith(fallbackDailyGoal: goal));

  Future<void> setStoryTextScale(double scale) =>
      _save(state.copyWith(storyTextScale: scale.clamp(0.8, 1.8)));

  Future<void> setMalaStyle(MalaStyle style) =>
      _save(state.copyWith(malaStyle: style));

  Future<void> setFallingMantra(bool enabled) =>
      _save(state.copyWith(fallingMantra: enabled));

  Future<void> setKeepScreenOn(bool enabled) =>
      _save(state.copyWith(keepScreenOnInMeditation: enabled));

  Future<void> completeOnboarding() =>
      _save(state.copyWith(onboardingComplete: true));
}

/// Tap feedback follows the haptics and sound settings without every caller
/// having to check them.
final feedbackProvider = Provider<FeedbackService>((ref) {
  final settings = ref.watch(settingsProvider);
  return FeedbackService(
    haptics: settings.hapticsEnabled,
    sound: settings.soundEnabled,
  );
});
