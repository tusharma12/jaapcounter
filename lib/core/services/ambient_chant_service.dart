import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// One background sound for meditation: a short loop that ships with the
/// app, or a file the user recorded or picked.
@immutable
class AmbientChant {
  /// A bundled loop. [id] is also its file name under assets/chants/loops/.
  const AmbientChant(this.id, this.label) : filePath = null;

  /// The user's own sound, at an absolute path on this phone today.
  const AmbientChant.file(this.id, this.label, String this.filePath);

  final String id;
  final String label;
  final String? filePath;

  bool get isUserFile => filePath != null;

  Source get source => isUserFile
      ? DeviceFileSource(filePath!)
      : AssetSource('chants/loops/$id.m4a');
}

/// Quiet background sound for meditation.
///
/// Each track repeats for as long as the session lasts. The bundled ones are
/// short seamless loops (about a minute, stereo AAC), so the app ships a little audio
/// rather than a recording as long as the longest sitting. It has its own player, so
/// it can sound together with a mantra's own recording during Auto Jaap.
class AmbientChantService {
  AmbientChantService([this._player]);

  static const List<AmbientChant> chants = [
    AmbientChant('breath_of_the_valley', 'Breath of the Valley'),
    AmbientChant('morning_high_plateau', 'Morning on the High Plateau'),
    AmbientChant('white_noise', 'Soft Noise'),
    AmbientChant('meditation_2', 'Still Waters'),
    AmbientChant('meditation_3', 'Evening Stillness'),
    AmbientChant('meditation_4', 'Inner Peace'),
  ];

  static const double _volume = 0.7;

  AudioPlayer? _player;
  String? _playing;
  // Bumped on every play and stop, so a fade that has been overtaken stops
  // touching the volume.
  int _generation = 0;

  /// The id now playing, or null.
  String? get playing => _playing;

  static AmbientChant? byId(String? id) {
    for (final chant in chants) {
      if (chant.id == id) return chant;
    }
    return null;
  }

  AudioPlayer get _audio => _player ??= AudioPlayer();

  Future<void> play(AmbientChant chant) async {
    final generation = ++_generation;
    try {
      final player = _audio;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
          ),
        ),
      );
      await player.setVolume(_volume);
      if (generation != _generation) return;
      await player.play(chant.source);
      _playing = chant.id;
    } on Object catch (error, stack) {
      // No background sound must ever stop the sitting itself.
      _playing = null;
      AppLogger.e('Could not play the background chant', error, stack);
    }
  }

  /// Fades out over [fade] and stops. Used when a timer runs out.
  Future<void> fadeOutAndStop({
    Duration fade = const Duration(seconds: 4),
  }) async {
    final player = _player;
    if (player == null || _playing == null) return;
    final generation = ++_generation;
    const steps = 16;
    try {
      for (var i = steps - 1; i >= 0; i--) {
        if (generation != _generation) return;
        await player.setVolume(_volume * i / steps);
        await Future<void>.delayed(fade ~/ steps);
      }
      if (generation == _generation) await _stopNow(player);
    } on Object catch (error, stack) {
      AppLogger.e('Could not fade out the background chant', error, stack);
    }
  }

  Future<void> stop() async {
    _generation++;
    final player = _player;
    if (player == null || _playing == null) return;
    await _stopNow(player);
  }

  Future<void> _stopNow(AudioPlayer player) async {
    _playing = null;
    try {
      await player.stop();
    } on Object catch (error, stack) {
      AppLogger.e('Could not stop the background chant', error, stack);
    }
  }

  Future<void> dispose() async {
    _generation++;
    _playing = null;
    final player = _player;
    _player = null;
    await player?.dispose();
  }
}
