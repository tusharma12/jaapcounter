import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/ambient_chant_service.dart';

import '../../support/test_harness.dart';

void main() {
  test('every chant has its loop file, and loops stay small', () {
    for (final chant in AmbientChantService.chants) {
      final file = File('assets/chants/loops/${chant.id}.m4a');
      expect(file.existsSync(), isTrue, reason: '${chant.id} is missing');
      expect(
        file.lengthSync(),
        lessThan(2 * 1024 * 1024),
        reason: '${chant.id} should be a short loop, not a full recording',
      );
    }
  });

  test('chant ids are unique and found by id', () {
    final ids = AmbientChantService.chants.map((c) => c.id).toList();

    expect(ids.toSet().length, ids.length);
    expect(AmbientChantService.byId('white_noise')?.label, 'Soft Noise');
    expect(AmbientChantService.byId('nope'), isNull);
    expect(AmbientChantService.byId(null), isNull);
  });

  test('the chosen chant is remembered, and can be cleared', () async {
    final container = await createTestContainer();
    final settings = container.read(settingsServiceProvider);

    expect(settings.meditationChant(), isNull);
    await settings.setMeditationChant('meditation_3');
    expect(settings.meditationChant(), 'meditation_3');
    await settings.setMeditationChant(null);
    expect(settings.meditationChant(), isNull);
  });
}
