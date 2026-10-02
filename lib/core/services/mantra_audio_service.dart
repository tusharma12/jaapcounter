import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';

import 'app_logger.dart';
import 'voice_note_store.dart';

/// Records and plays back a mantra's own voice note: a recording of the
/// user's own voice chanting it, kept alongside the mantra's text.
///
/// One instance covers both recording and playback so a bottom sheet only
/// ever has one microphone and one player to reason about. It works on
/// absolute paths; where those files live, and what the database stores, is
/// [VoiceNoteStore]'s business.
class MantraAudioService {
  MantraAudioService({AudioRecorder? recorder, AudioPlayer? player})
    : _recorder = recorder ?? AudioRecorder(),
      _player = player ?? AudioPlayer();

  final AudioRecorder _recorder;
  final AudioPlayer _player;

  /// Fires when playback reaches the end of the file.
  Stream<void> get onPlaybackComplete => _player.onPlayerComplete;

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } on Object catch (error, stack) {
      AppLogger.e('Microphone permission check failed', error, stack);
      return false;
    }
  }

  Future<void> startRecording(String path) async {
    await _recorder.start(const RecordConfig(), path: path);
  }

  /// Stops recording and returns the path actually written, or null if
  /// nothing was recorded.
  Future<String?> stopRecording() => _recorder.stop();

  /// Stops recording without keeping the file, for a cancelled sheet.
  Future<void> cancelRecording() => _recorder.cancel();

  /// Recording leaves iOS in a play-and-record session, which routes sound
  /// to the quiet earpiece and obeys the silent switch. Playing a recording
  /// back needs the ordinary playback session.
  Future<void> _prepareToPlay() async {
    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
          ),
        ),
      );
      await _player.setVolume(1);
    } on Object catch (error, stack) {
      AppLogger.e('Could not prepare audio playback', error, stack);
    }
  }

  Future<void> play(String path) async {
    await _player.stop();
    await _prepareToPlay();
    await _player.play(DeviceFileSource(path));
  }

  /// Plays [path] and completes when it ends, is stopped, or after
  /// [timeout], whichever comes first. A broken file must not hold up a
  /// caller that is waiting on it.
  Future<void> playToEnd(
    String path, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _player.stop();
    await _prepareToPlay();
    final ended = _player.onPlayerStateChanged.firstWhere(
      (state) =>
          state == PlayerState.completed ||
          state == PlayerState.stopped ||
          state == PlayerState.disposed,
    );
    await _player.play(DeviceFileSource(path));
    await ended.timeout(timeout, onTimeout: () => PlayerState.stopped);
  }

  Future<void> pausePlayback() => _player.pause();

  Future<void> stopPlayback() => _player.stop();

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
