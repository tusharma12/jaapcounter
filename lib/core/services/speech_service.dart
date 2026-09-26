import 'package:flutter_tts/flutter_tts.dart';
import 'package:meta/meta.dart';

import 'app_logger.dart';

/// One voice installed on the device.
@immutable
class TtsVoice {
  const TtsVoice({
    required this.name,
    required this.locale,
    this.identifier = '',
    this.quality = '',
  });

  final String name;

  /// BCP-47 language tag, such as `hi-IN`.
  final String locale;

  /// iOS only: the voice's stable identifier.
  final String identifier;

  /// iOS only: `default`, `enhanced` or `premium`.
  final String quality;

  String get language => locale.split(RegExp('[-_]')).first.toLowerCase();

  /// A key that survives a round trip through preferences.
  String get id => identifier.isNotEmpty ? identifier : '$name|$locale';

  Map<String, String> toMap() => {
    'name': name,
    'locale': locale,
    if (identifier.isNotEmpty) 'identifier': identifier,
  };

  static TtsVoice? fromPlatform(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name']?.toString();
    final locale = raw['locale']?.toString();
    if (name == null || locale == null) return null;
    return TtsVoice(
      name: name,
      locale: locale,
      identifier: raw['identifier']?.toString() ?? '',
      quality: raw['quality']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) => other is TtsVoice && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Reads stories aloud and chants mantras for automatic Jaap.
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
      // Chanting should be heard with the silent switch on, and should sit
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

  /// Chants [text] in [voice] (or the default voice for [fallbackLocale]),
  /// at the given rate and pitch, and completes when the voice has finished.
  Future<void> chant(
    String text, {
    required String fallbackLocale,
    required double rate,
    required double pitch,
    TtsVoice? voice,
  }) async {
    await _configure();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate);
      await _tts.setPitch(pitch);
    } on Object catch (error, stack) {
      AppLogger.e('Could not set speech rate', error, stack);
    }
    // Setting a language clears any chosen voice, so the voice goes last.
    await _setLanguage(fallbackLocale);
    if (voice != null) {
      try {
        await _tts.setVoice(voice.toMap());
      } on Object catch (error, stack) {
        AppLogger.e('Voice ${voice.name} unavailable', error, stack);
      }
    }
    await _speak(text);
  }

  /// Every voice installed on the device, best quality first.
  Future<List<TtsVoice>> voices() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return const [];
      final voices = raw.map(TtsVoice.fromPlatform).nonNulls.toSet().toList()
        ..sort((a, b) {
          final byQuality = _qualityRank(b.quality) - _qualityRank(a.quality);
          return byQuality != 0 ? byQuality : a.name.compareTo(b.name);
        });
      return voices;
    } on Object catch (error, stack) {
      AppLogger.e('Could not list voices', error, stack);
      return const [];
    }
  }

  static int _qualityRank(String quality) => switch (quality) {
    'premium' => 2,
    'enhanced' => 1,
    _ => 0,
  };

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
