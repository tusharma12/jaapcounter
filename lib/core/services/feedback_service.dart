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

  /// A mala completed — a firmer, distinct signal so the user can keep their
  /// eyes closed and still know.
  Future<void> malaComplete() async {
    if (haptics) {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.mediumImpact();
    }
    if (sound) await SystemSound.play(SystemSoundType.alert);
  }

  /// An undo, a reset — something removed.
  Future<void> removal() async {
    if (haptics) await HapticFeedback.lightImpact();
  }

  FeedbackService copyWith({bool? haptics, bool? sound}) => FeedbackService(
    haptics: haptics ?? this.haptics,
    sound: sound ?? this.sound,
  );
}
