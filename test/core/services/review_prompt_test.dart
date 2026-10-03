import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/review_prompt_service.dart';
import 'package:japmala/features/jaap/data/jaap_repository.dart';

import '../../support/test_harness.dart';

void main() {
  group('when a rating is due', () {
    bool due({bool asked = false, int days = 0, int beads = 0}) =>
        ReviewPrompt.due(
          alreadyAsked: asked,
          activeDays: days,
          lifetimeBeads: beads,
        );

    test('not for a new user', () {
      expect(due(days: 1, beads: 300), isFalse);
      expect(due(days: 2, beads: 1999), isFalse);
    });

    test('after three days of Jaap', () => expect(due(days: 3), isTrue));

    test('or after 2000 beads', () => expect(due(beads: 2000), isTrue));

    test('never twice', () {
      expect(due(asked: true, days: 30, beads: 90000), isFalse);
    });
  });

  group('the service', () {
    late JaapRepository repository;
    late int requests;
    late ReviewPromptService service;

    Future<void> setUpService({bool failing = false}) async {
      final container = await createTestContainer();
      repository = container.read(jaapRepositoryProvider);
      requests = 0;
      service = ReviewPromptService(
        prefs: container.read(sharedPreferencesProvider),
        repository: repository,
        requestReview: () async {
          requests++;
          if (failing) throw StateError('no store');
        },
      );
    }

    test('stays quiet until it is due', () async {
      await setUpService();
      await repository.addBeads(
        mantraId: 'builtin.ram',
        delta: 108,
        at: DateTime(2026, 9, 3, 9),
      );

      expect(await service.maybeAsk(), isFalse);
      expect(requests, 0);
    });

    test('asks once after three active days', () async {
      await setUpService();
      for (final day in [3, 4, 5]) {
        await repository.addBeads(
          mantraId: 'builtin.ram',
          delta: 108,
          at: DateTime(2026, 9, day, 9),
        );
      }

      expect(await service.maybeAsk(), isTrue);
      expect(await service.maybeAsk(), isFalse, reason: 'only once');
      expect(requests, 1);
      expect(service.alreadyAsked, isTrue);
    });

    test('asks after 2000 beads on a single day', () async {
      await setUpService();
      await repository.addBeads(
        mantraId: 'builtin.ram',
        delta: 2000,
        at: DateTime(2026, 9, 3, 9),
      );

      expect(await service.maybeAsk(), isTrue);
    });

    test('a store that cannot show the box does not throw', () async {
      await setUpService(failing: true);
      await repository.addBeads(
        mantraId: 'builtin.ram',
        delta: 2000,
        at: DateTime(2026, 9, 3, 9),
      );

      await service.maybeAsk();
      expect(service.alreadyAsked, isTrue, reason: 'it does not retry');
    });
  });
}
