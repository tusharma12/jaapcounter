import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/services/feedback_service.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

class _RecordingFeedback extends FeedbackService {
  _RecordingFeedback() : super(haptics: true, sound: false);

  final events = <String>[];

  @override
  Future<void> bead() async => events.add('bead');

  @override
  Future<void> malaComplete() async => events.add('mala');

  @override
  Future<void> goalReached() async => events.add('goal');
}

void main() {
  test(
    'a mala knocks twice, the goal three times, and the goal wins',
    () async {
      final feedback = _RecordingFeedback();
      final container = await createTestContainer(
        overrides: [feedbackProvider.overrideWithValue(feedback)],
      );
      await container.read(settingsProvider.notifier).setFallbackDailyGoal(216);
      await container.read(jaapControllerProvider.future);
      final controller = container.read(jaapControllerProvider.notifier);

      controller.count(107);
      expect(feedback.events.last, 'bead');
      controller.count();
      expect(feedback.events.last, 'mala', reason: 'bead 108');

      controller.count(107);
      controller.count();
      expect(
        feedback.events.last,
        'goal',
        reason: 'bead 216 ends a mala and meets the goal: the goal is felt',
      );

      controller.count();
      expect(feedback.events.last, 'bead', reason: 'the goal is felt once');
      await controller.flushPendingWrites();
    },
  );
}
