import 'package:record/record.dart';

import 'app_logger.dart';

/// Records the user's own chant from the microphone, for the Music list.
/// It works on absolute paths; where those files live is
/// [UserMusicStore]'s business.
class MusicRecorderService {
  MusicRecorderService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } on Object catch (error, stack) {
      AppLogger.e('Microphone permission check failed', error, stack);
      return false;
    }
  }

  Future<void> start(String path) =>
      _recorder.start(const RecordConfig(), path: path);

  /// Stops and returns the path written, or null if nothing was recorded.
  Future<String?> stop() => _recorder.stop();

  /// Stops without keeping the file.
  Future<void> cancel() => _recorder.cancel();

  Future<void> dispose() => _recorder.dispose();
}
