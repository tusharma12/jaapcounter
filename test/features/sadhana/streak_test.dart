import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/sadhana/domain/sadhana.dart';
import 'package:japmala/features/sadhana/domain/streak.dart';

void main() {
  StreakInfo streakFor(
    Map<String, int> totals, {
    required DateTime today,
    int goal = 108,
  }) {
    return StreakCalculator.calculate(
      totalsByDay: totals,
      today: today,
      goalFor: (_) => goal,
    );
  }

  group('current streak', () {
    test('is zero with no Jaap at all', () {
      final streak = streakFor(const {}, today: DateTime(2026, 9, 3));

      expect(streak.current, 0);
      expect(streak.best, 0);
      expect(streak.countedToday, isFalse);
    });

    test('counts today once the goal is met', () {
      final streak = streakFor(
        {'2026-09-03': 108},
        today: DateTime(2026, 9, 3),
      );

      expect(streak.current, 1);
      expect(streak.countedToday, isTrue);
    });

    test('a day short of the goal does not count', () {
      final streak = streakFor(
        {'2026-09-03': 107},
        today: DateTime(2026, 9, 3),
      );

      expect(streak.current, 0);
      expect(streak.countedToday, isFalse);
    });

    test('survives a morning before today has been chanted', () {
      // The habit is intact; today is simply not finished yet.
      final streak = streakFor(
        {'2026-09-01': 108, '2026-09-02': 216},
        today: DateTime(2026, 9, 3, 8),
      );

      expect(streak.current, 2);
      expect(streak.countedToday, isFalse);
    });

    test('breaks when a day was missed entirely', () {
      final streak = streakFor(
        {'2026-08-30': 108, '2026-09-02': 108, '2026-09-03': 108},
        today: DateTime(2026, 9, 3),
      );

      expect(streak.current, 2);
    });

    test('runs across the end of a month', () {
      final streak = streakFor(
        {
          '2026-08-30': 108,
          '2026-08-31': 108,
          '2026-09-01': 108,
          '2026-09-02': 108,
        },
        today: DateTime(2026, 9, 2),
      );

      expect(streak.current, 4);
    });

    test('runs across the end of a year', () {
      final streak = streakFor(
        {
          '2026-12-30': 108,
          '2026-12-31': 108,
          '2027-01-01': 108,
          '2027-01-02': 108,
        },
        today: DateTime(2027, 1, 2),
      );

      expect(streak.current, 4);
    });

    test('runs across a leap day', () {
      final streak = streakFor(
        {'2028-02-28': 108, '2028-02-29': 108, '2028-03-01': 108},
        today: DateTime(2028, 3, 1),
      );

      expect(streak.current, 3);
    });

    test('with no goal set, any Jaap keeps the streak', () {
      final streak = streakFor(
        {'2026-09-02': 5, '2026-09-03': 1},
        today: DateTime(2026, 9, 3),
        goal: 0,
      );

      expect(streak.current, 2);
    });
  });

  group('best streak', () {
    test('is the longest run in the whole history', () {
      final streak = streakFor(
        {
          // A five-day run in August.
          '2026-08-01': 108,
          '2026-08-02': 108,
          '2026-08-03': 108,
          '2026-08-04': 108,
          '2026-08-05': 108,
          // A two-day run now.
          '2026-09-02': 108,
          '2026-09-03': 108,
        },
        today: DateTime(2026, 9, 3),
      );

      expect(streak.current, 2);
      expect(streak.best, 5);
    });

    test('is never below the current streak', () {
      final streak = streakFor(
        {'2026-09-02': 108, '2026-09-03': 108},
        today: DateTime(2026, 9, 3),
      );

      expect(streak.best, 2);
    });
  });

  group('goals that change over time', () {
    test('each day is judged against the goal that applied to it', () {
      final sadhana = Sadhana(
        id: 's1',
        mantraId: 'builtin.ram',
        dailyGoal: 216,
        startDay: '2026-09-02',
      );

      final streak = StreakCalculator.calculate(
        totalsByDay: const {
          '2026-09-01': 108, // met the old goal of 108
          '2026-09-02': 108, // short of the new Sankalp goal of 216
          '2026-09-03': 216,
        },
        today: DateTime(2026, 9, 3),
        goalFor: (day) => sadhana.coversDay(day) ? sadhana.dailyGoal : 108,
      );

      expect(streak.current, 1, reason: 'the 2nd fell short of the vow');
      expect(streak.best, 1);
    });
  });

  group('Sankalp arithmetic', () {
    final sadhana = Sadhana(
      id: 's1',
      mantraId: 'builtin.ram',
      dailyGoal: 108,
      startDay: '2026-08-17',
      durationDays: 40,
    );

    test('the day number counts from the first day', () {
      expect(sadhana.dayNumber(DateTime(2026, 8, 17)), 1);
      expect(sadhana.dayNumber(DateTime(2026, 9, 3)), 18);
    });

    test('the day number never exceeds the vow', () {
      expect(sadhana.dayNumber(DateTime(2027, 1, 1)), 40);
    });

    test('the last day is the start plus the duration, less one', () {
      expect(sadhana.lastDay, '2026-09-25');
    });

    test('it covers only its own days', () {
      expect(sadhana.coversDay('2026-08-16'), isFalse);
      expect(sadhana.coversDay('2026-08-17'), isTrue);
      expect(sadhana.coversDay('2026-09-25'), isTrue);
      expect(sadhana.coversDay('2026-09-26'), isFalse);
    });

    test('it has run its course only after the last day', () {
      expect(sadhana.hasRunItsCourse(DateTime(2026, 9, 25)), isFalse);
      expect(sadhana.hasRunItsCourse(DateTime(2026, 9, 26)), isTrue);
    });

    test('an open-ended goal never runs out', () {
      final open = sadhana.copyWith(durationDays: null);

      expect(open.isOpenEnded, isTrue);
      expect(open.lastDay, isNull);
      expect(open.hasRunItsCourse(DateTime(2030, 1, 1)), isFalse);
    });
  });
}
