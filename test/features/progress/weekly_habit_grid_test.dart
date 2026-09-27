import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/core/utils/formatters.dart';
import 'package:japmala/features/progress/presentation/widgets/weekly_habit_grid.dart';
import 'package:japmala/l10n/app_localizations.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    double width = 360,
    DateTime? selected,
    ValueChanged<DateTime>? onSelect,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: WeeklyHabitGrid(
                totalsByDay: const {'2026-09-01': 108, '2026-09-03': 20},
                goal: 108,
                // A Thursday.
                today: DateTime(2026, 9, 3),
                anchor: DateTime(2026, 9, 3),
                selected: selected ?? DateTime(2026, 9, 3),
                onSelect: onSelect ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('fills the width with weeks and never overflows', (tester) async {
    for (final width in [280.0, 360.0, 600.0]) {
      await pump(tester, width: width);
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('a tap selects a day; days after today cannot be picked', (
    tester,
  ) async {
    DateTime? picked;
    await pump(tester, onSelect: (day) => picked = day);

    final cells = find.byType(GestureDetector);
    // Mon–Thu of this week are the last four tappable days.
    await tester.tap(cells.last);
    expect(picked, DateTime(2026, 9, 3));
    await tester.tap(cells.at(cells.evaluate().length - 3));
    expect(picked, DateTime(2026, 9, 1));
  });

  test('Hindi weekdays stay whole and distinct', () {
    // 2024-01-05 is a Friday, 2024-01-06 a Saturday: शुक्र and शनि.
    final friday = Fmt.weekdayShort(DateTime(2024, 1, 5), 'hi');
    final saturday = Fmt.weekdayShort(DateTime(2024, 1, 6), 'hi');
    expect(friday, isNot(saturday));
    expect(friday.length, greaterThan(1));
  });
}
