import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/notification_service.dart';
import 'package:japmala/features/festivals/data/observance_calendar.g.dart';
import 'package:japmala/features/festivals/domain/observance.dart';
import 'package:japmala/features/festivals/domain/observance_calendar.dart';
import 'package:japmala/features/festivals/presentation/observance_names.dart';
import 'package:japmala/features/reminders/presentation/reminder_controllers.dart';
import 'package:japmala/features/reminders/presentation/reminders_screen.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/l10n/app_localizations.dart';

import '../../support/test_harness.dart';

/// Captures what would be handed to the platform.
class _RecordingNotifications extends NotificationService {
  List<ScheduledReminder> synced = const [];

  @override
  Future<void> sync(List<ScheduledReminder> reminders) async {
    synced = reminders;
  }

  @override
  Future<bool> requestPermission() async => true;
}

void main() {
  const calendar = ObservanceCalendar();

  group('the calendar table', () {
    test('is in date order, every day key well formed', () {
      final starts = observanceCalendar.map((o) => o.start).toList();
      expect(starts, [...starts]..sort());
      final key = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      for (final o in observanceCalendar) {
        expect(o.start, matches(key));
        if (o.end != null) {
          expect(
            o.end!.compareTo(o.start),
            greaterThanOrEqualTo(0),
            reason: '$o',
          );
        }
      }
    });

    test('has two Ekadashis in most months', () {
      final ekadashis = observanceCalendar.where(
        (o) => o.kind == ObservanceKind.ekadashi,
      );
      final byMonth = <String, int>{};
      for (final e in ekadashis) {
        byMonth.update(
          e.start.substring(0, 7),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      // Lunar months drift against the calendar: one or three happen, but
      // never none and never four.
      expect(byMonth.values, everyElement(inInclusiveRange(1, 3)));
    });

    test('every suggested mantra exists in the library', () {
      final ids = BuiltInMantras.all.map((m) => m.id).toSet();
      for (final o in observanceCalendar) {
        final suggested = suggestedMantraFor(o);
        if (suggested != null) expect(ids, contains(suggested), reason: o.id);
      }
    });
  });

  test('Sharad Navratri 2026 runs nine days from Ghatasthapana', () {
    final navratri = calendar
        .on('2026-10-15')
        .singleWhere((o) => o.id == 'sharad-navratri');

    expect(navratri.start, '2026-10-11');
    expect(navratri.lengthInDays, 9);
    expect(navratri.covers('2026-10-19'), isTrue);
    expect(navratri.covers('2026-10-20'), isFalse);
  });

  test('upcoming lists what is running and what starts soon', () {
    final upcoming = calendar.upcoming(DateTime(2026, 10, 15), withinDays: 10);
    final ids = upcoming.map((o) => o.id).toList();

    expect(ids.first, 'sharad-navratri', reason: 'still under way');
    expect(ids, contains('dussehra'));
    expect(ids, contains('ekadashi.papankusha'));
    expect(ids, isNot(contains('ekadashi.indira')), reason: 'already past');
  });

  test('a Vaishnava date is kept where it differs', () {
    final utpanna = calendar
        .on('2026-11-20')
        .singleWhere((o) => o.kind == ObservanceKind.ekadashi);

    expect(utpanna.vaishnavaDay, '2026-11-21');
  });

  testWidgets('every observance has its own name in English and Hindi', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('hi')]) {
      final l10n = await AppL10n.delegate.load(locale);
      final fallbacks = {
        l10n.ekadashiName('none-such'),
        l10n.festivalName('none-such'),
      };
      for (final o in observanceCalendar) {
        expect(
          fallbacks,
          isNot(contains(observanceName(l10n, o))),
          reason: '${o.id} in $locale',
        );
      }
    }
  });

  group('reminders', () {
    late ProviderContainer container;
    late _RecordingNotifications notifications;

    setUp(() async {
      notifications = _RecordingNotifications();
      container = await createTestContainer(
        clock: TestClock(DateTime(2026, 10, 1, 9)),
        overrides: [
          notificationServiceProvider.overrideWithValue(notifications),
        ],
      );
    });

    Future<void> reschedule() async {
      final l10n = await AppL10n.delegate.load(const Locale('en'));
      await container
          .read(remindersProvider.notifier)
          .reschedule(RemindersScreen.copyFrom(l10n));
    }

    test('none are scheduled while the switch is off', () async {
      await reschedule();

      expect(notifications.synced, isEmpty);
    });

    test('the next observances are scheduled once, at 6 am', () async {
      await container
          .read(settingsProvider.notifier)
          .setFestivalReminders(true);
      await reschedule();

      final first = notifications.synced.first;
      expect(
        notifications.synced,
        hasLength(RemindersController.observancesAhead),
      );
      expect(first.title, 'Indira Ekadashi');
      expect(first.body, contains('Indira Ekadashi'));
      expect(first.date, DateTime(2026, 10, 6));
      expect((first.hour, first.minute), (6, 0));
      expect(
        notifications.synced.map((r) => r.id).toSet(),
        hasLength(notifications.synced.length),
        reason: 'ids never collide',
      );
    });
  });
}
