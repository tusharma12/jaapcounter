import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/review_prompt_service.dart';
import 'package:japmala/features/jaap/data/jaap_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/test_harness.dart';

void main() {
  final now = DateTime(2026, 10, 16, 9);

  group('when a rating is due', () {
    bool due({
      int asked = 0,
      DateTime? last,
      int days = 0,
      int beads = 0,
    }) => ReviewPrompt.due(
      timesAsked: asked,
      lastAsked: last,
      now: now,
      activeDays: days,
      lifetimeBeads: beads,
    );

    test('not for a new user', () {
      expect(due(days: 1, beads: 300), isFalse);
      expect(due(days: 1, beads: 999), isFalse);
    });

    test('after two days of Jaap', () => expect(due(days: 2), isTrue));

    test('or after 1000 beads', () => expect(due(beads: 1000), isTrue));

    test('not again within the gap', () {
      final recent = now.subtract(const Duration(days: 119));
      expect(due(asked: 1, last: recent, days: 30), isFalse);
    });

    test('again once the gap has passed', () {
      final old = now.subtract(ReviewPrompt.gap);
      expect(due(asked: 1, last: old, days: 30), isTrue);
    });

    test('never more than three times', () {
      final old = now.subtract(const Duration(days: 400));
      expect(due(asked: 3, last: old, days: 300, beads: 90000), isFalse);
    });
  });

  group('the service', () {
    late JaapRepository repository;
    late SharedPreferences prefs;
    late int requests;
    late DateTime clock;
    late ReviewPromptService service;

    Future<void> setUpService({bool failing = false}) async {
      final container = await createTestContainer();
      repository = container.read(jaapRepositoryProvider);
      prefs = container.read(sharedPreferencesProvider);
      requests = 0;
      clock = now;
      service = ReviewPromptService(
        prefs: prefs,
        repository: repository,
        now: () => clock,
        requestReview: () async {
          requests++;
          if (failing) throw StateError('no store');
        },
      );
    }

    Future<void> chantOn(List<int> days, {int beads = 108}) async {
      for (final day in days) {
        await repository.addBeads(
          mantraId: 'builtin.ram',
          delta: beads,
          at: DateTime(2026, 9, day, 9),
        );
      }
    }

    test('stays quiet until it is due', () async {
      await setUpService();
      await chantOn([3]);

      expect(await service.maybeAsk(), isFalse);
      expect(requests, 0);
    });

    test('asks after two active days, then waits out the gap', () async {
      await setUpService();
      await chantOn([3, 4]);

      expect(await service.maybeAsk(), isTrue);
      expect(await service.maybeAsk(), isFalse, reason: 'too soon');
      clock = now.add(const Duration(days: 60));
      expect(await service.maybeAsk(), isFalse, reason: 'still too soon');
      clock = now.add(ReviewPrompt.gap);
      expect(await service.maybeAsk(), isTrue);
      expect(requests, 2);
      expect(service.timesAsked, 2);
    });

    test('stops after three asks', () async {
      await setUpService();
      await chantOn([3, 4]);

      for (var i = 0; i < 5; i++) {
        clock = now.add(ReviewPrompt.gap * i);
        await service.maybeAsk();
      }
      expect(requests, ReviewPrompt.maxAsks);
    });

    test('asks after 1000 beads on a single day', () async {
      await setUpService();
      await chantOn([3], beads: 1000);

      expect(await service.maybeAsk(), isTrue);
    });

    test('an ask from before the update counts, gap from now', () async {
      await setUpService();
      await prefs.setBool('review.asked', true);
      await chantOn([3, 4]);

      expect(service.timesAsked, 1);
      expect(await service.maybeAsk(), isFalse);
      clock = now.add(ReviewPrompt.gap);
      expect(await service.maybeAsk(), isTrue);
      expect(service.timesAsked, 2);
    });

    test('a store that cannot show the box does not throw', () async {
      await setUpService(failing: true);
      await chantOn([3], beads: 1000);

      await service.maybeAsk();
      expect(service.timesAsked, 1, reason: 'the try still counts');
    });
  });
}
