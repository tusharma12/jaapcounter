import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';

void main() {
  test('pace and stopping point survive a round trip', () {
    const config = AutoJaapConfig(
      interval: Duration(seconds: 5),
      stopAfter: AutoJaapStop.never,
    );

    final restored = AutoJaapConfig.fromPrefs(config.toPrefs());

    expect(restored.interval, config.interval);
    expect(restored.stopAfter, AutoJaapStop.never);
  });

  test('preferences saved with the old voice settings still load', () {
    final restored = AutoJaapConfig.fromPrefs([
      '3000',
      'true',
      'goal',
      '0.3',
      '0.8',
      'Lekha',
      'hi-IN',
      'com.apple.voice.enhanced.hi-IN.Lekha',
      'enhanced',
    ]);

    expect(restored.interval, const Duration(seconds: 3));
    expect(restored.stopAfter, AutoJaapStop.goal);
  });

  test('the chant plays unless it was switched off', () {
    expect(const AutoJaapConfig().playChant, isTrue);
    expect(
      AutoJaapConfig.fromPrefs(['2000', 'false', 'mala']).playChant,
      isTrue,
    );

    final off = const AutoJaapConfig().copyWith(playChant: false);
    expect(AutoJaapConfig.fromPrefs(off.toPrefs()).playChant, isFalse);
  });
}
