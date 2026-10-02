import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/services/dictation_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Records what the service asks of the platform recogniser.
class _FakeSpeech extends Fake implements SpeechToText {
  SpeechListenOptions? options;
  SpeechErrorListener? capturedOnError;
  SpeechStatusListener? capturedOnStatus;
  bool throwOnListen = false;

  @override
  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
    Object? debugLogging,
    Object? finalTimeout,
    Object? options,
  }) async {
    capturedOnError = onError;
    capturedOnStatus = onStatus;
    return true;
  }

  @override
  Future<void> listen({
    Object? onResult,
    Object? listenFor,
    Object? pauseFor,
    Object? localeId,
    Object? onSoundLevelChange,
    Object? cancelOnError,
    Object? partialResults,
    Object? onDevice,
    Object? listenMode,
    Object? sampleRate,
    SpeechListenOptions? listenOptions,
  }) async {
    if (throwOnListen) throw StateError('no recogniser');
    options = listenOptions;
  }
}

void main() {
  late _FakeSpeech speech;
  late DictationService dictation;

  setUp(() {
    speech = _FakeSpeech();
    dictation = DictationService(speech: speech);
  });

  test(
    'recognition is always on-device, so no voice leaves the phone',
    () async {
      await dictation.ensureReady();
      await dictation.listen(onResult: (_, _) {}, localeId: 'hi_IN');

      expect(speech.options!.onDevice, isTrue);
      expect(speech.options!.localeId, 'hi_IN');
    },
  );

  test('a permanent recogniser error is reported to the caller', () async {
    var errors = 0;
    await dictation.ensureReady();
    await dictation.listen(
      onResult: (_, _) {},
      localeId: 'hi_IN',
      onError: () => errors++,
    );

    speech.capturedOnError!(SpeechRecognitionError('error_language', true));
    speech.capturedOnError!(SpeechRecognitionError('error_no_match', false));

    expect(errors, 1, reason: 'only a permanent error ends dictation');
  });

  test('the caller hears when listening ends', () async {
    var done = 0;
    await dictation.ensureReady();
    await dictation.listen(
      onResult: (_, _) {},
      localeId: 'en_US',
      onDone: () => done++,
    );

    speech.capturedOnStatus!(SpeechToText.listeningStatus);
    speech.capturedOnStatus!(SpeechToText.doneStatus);

    expect(done, 1);
  });

  test('a recogniser that cannot start is reported, not swallowed', () async {
    var errors = 0;
    speech.throwOnListen = true;
    await dictation.ensureReady();
    await dictation.listen(
      onResult: (_, _) {},
      localeId: 'en_US',
      onError: () => errors++,
    );

    expect(errors, 1);
  });
}
