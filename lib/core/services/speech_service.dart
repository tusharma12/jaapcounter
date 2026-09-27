import 'package:flutter_tts/flutter_tts.dart';

import 'app_logger.dart';

/// Reads stories aloud.
///
/// Wrapped in one place because text-to-speech fails in ordinary ways — no
/// voice for the language, a device with the engine disabled — and none of
/// those should surface as a crash.
class SpeechService {
  SpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    try {
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      // A story should be heard with the silent switch on, and should sit
      // alongside music rather than stop it.
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not configure speech', error, stack);
    }
    _configured = true;
  }

  Future<void> _setLanguage(String localeCode) async {
    // Hindi content needs an Indic voice; anything else falls back to the
    // engine default rather than reading Devanagari with an English voice.
    final language = localeCode == 'hi' ? 'hi-IN' : 'en-US';
    try {
      final available = await _tts.isLanguageAvailable(language);
      if (available == true) await _tts.setLanguage(language);
    } on Object catch (error, stack) {
      AppLogger.e('Speech language $language unavailable', error, stack);
    }
  }

  /// Speaks [text] and completes when the engine has finished.
  Future<void> speak(String text, {required String localeCode}) async {
    await _configure();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.44);
      await _tts.setPitch(1.0);
    } on Object catch (error, stack) {
      AppLogger.e('Could not set speech rate', error, stack);
    }
    await _setLanguage(localeCode);
    await _speak(text);
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } on Object catch (error, stack) {
      AppLogger.e('Speech failed', error, stack);
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } on Object catch (error, stack) {
      AppLogger.e('Could not stop speech', error, stack);
    }
  }
}
