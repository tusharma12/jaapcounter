import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'app_logger.dart';

/// Turns speech into text for a field the user would otherwise have to type,
/// such as a mantra typed in an unfamiliar script.
///
/// Recognition is always on-device. The app promises that nothing leaves the
/// phone, and the platform recognisers otherwise send audio to Apple's or
/// Google's servers. Where the phone has no offline model for the language,
/// dictation fails through [listen]'s `onError` rather than going online.
class DictationService {
  DictationService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _available = false;
  void Function()? _onError;
  void Function()? _onDone;

  bool get isListening => _speech.isListening;

  /// Prepares the engine and asks for the microphone/speech permission if it
  /// has not been granted yet. Safe to call more than once.
  Future<bool> ensureReady() async {
    if (_available) return true;
    try {
      _available = await _speech.initialize(
        onError: (error) {
          AppLogger.e('Dictation error', error.errorMsg, StackTrace.current);
          if (error.permanent) _onError?.call();
        },
        onStatus: (status) {
          if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            _onDone?.call();
          }
        },
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not initialize dictation', error, stack);
      _available = false;
    }
    return _available;
  }

  /// Listens until [stop] is called or the user pauses for a few seconds.
  /// [onResult] is called with the words recognised so far on every update,
  /// and again with the final wording once the user stops speaking.
  /// [onDone] fires when listening ends for any reason, and [onError] when
  /// recognition failed outright, such as no offline model for [localeId].
  Future<void> listen({
    required void Function(String text, bool isFinal) onResult,
    required String localeId,
    void Function()? onDone,
    void Function()? onError,
  }) async {
    _onDone = onDone;
    _onError = onError;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) =>
            onResult(result.recognizedWords, result.finalResult),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          localeId: localeId,
          onDevice: true,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(minutes: 2),
        ),
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not start dictation', error, stack);
      onError?.call();
    }
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } on Object catch (error, stack) {
      AppLogger.e('Could not stop dictation', error, stack);
    }
  }

  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } on Object catch (error, stack) {
      AppLogger.e('Could not cancel dictation', error, stack);
    }
  }
}
