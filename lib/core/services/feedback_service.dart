import 'package:flutter/services.dart';

/// Tap feedback for the counter.
///
/// Haptics are the point of a digital mala — the bead should be felt, not just
/// seen — so this is deliberately cheap to call on every single tap.
class FeedbackService {
  FeedbackService({required this.haptics, required this.sound});

  final bool haptics;
  final bool sound;

  /// One bead.
  Future<void> bead() async {
    if (haptics) await HapticFeedback.selectionClick();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  /// A mala completed: two firm knocks, far enough apart to be felt as two,
  /// so the user can keep their eyes closed and still know 108 has come.
  Future<void> malaComplete() async {
    if (haptics) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(pulseGap);
      await HapticFeedback.heavyImpact();
    }
    if (sound) await SystemSound.play(SystemSoundType.alert);
  }

  /// The day's goal reached: three knocks, one more than a mala, so the two
  /// are never confused.
  Future<void> goalReached() async {
    if (haptics) {
      for (var i = 0; i < 3; i++) {
        if (i > 0) await Future<void>.delayed(pulseGap);
        await HapticFeedback.heavyImpact();
      }
    }
    if (sound) await SystemSound.play(SystemSoundType.alert);
  }

  /// Under ~120 ms, iPhones run two impacts together into one buzz.
  static const Duration pulseGap = Duration(milliseconds: 170);

  /// An undo, a reset — something removed.
  Future<void> removal() async {
    if (haptics) await HapticFeedback.lightImpact();
  }

  FeedbackService copyWith({bool? haptics, bool? sound}) => FeedbackService(
    haptics: haptics ?? this.haptics,
    sound: sound ?? this.sound,
  );
}
