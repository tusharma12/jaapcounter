import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/services/speech_service.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';

void main() {
  test('the chosen voice, speed and pitch survive a round trip', () {
    const config = AutoJaapConfig(
      interval: Duration(seconds: 5),
      speakAloud: true,
      stopAfter: AutoJaapStop.never,
      voice: TtsVoice(
        name: 'Lekha',
        locale: 'hi-IN',
        identifier: 'com.apple.voice.enhanced.hi-IN.Lekha',
        quality: 'enhanced',
      ),
      rate: 0.3,
      pitch: 0.8,
    );

    final restored = AutoJaapConfig.fromPrefs(config.toPrefs());

    expect(restored.interval, config.interval);
    expect(restored.speakAloud, isTrue);
    expect(restored.stopAfter, AutoJaapStop.never);
    expect(restored.voice, config.voice);
    expect(restored.voice!.quality, 'enhanced');
    expect(restored.rate, 0.3);
    expect(restored.pitch, 0.8);
  });

  test('preferences saved before voices existed still load', () {
    final restored = AutoJaapConfig.fromPrefs(['2000', 'true', 'mala']);

    expect(restored.speakAloud, isTrue);
    expect(restored.voice, isNull);
    expect(restored.rate, AutoJaapConfig.defaultRate);
    expect(restored.pitch, AutoJaapConfig.defaultPitch);
  });
}
