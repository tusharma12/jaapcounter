import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/features/sadhana/presentation/daily_goal_picker.dart';
import 'package:japmala/l10n/app_localizations.dart';
import 'package:japmala/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppL10nEn();

  test('a goal of whole malas reads in malas and Jaap', () {
    expect(goalLabel(l10n, 1188, 108, 'en'), '11 malas a day · 1,188 Jaap');
    expect(goalLabel(l10n, 108, 108, 'en'), '1 mala a day · 108 Jaap');
    expect(goalLabel(l10n, 500, 108, 'en'), '500 Jaap per day');
    // A 27-bead mala makes 108 four malas.
    expect(goalLabel(l10n, 108, 27, 'en'), '4 malas a day · 108 Jaap');
  });

  Future<List<int>> pump(WidgetTester tester, int initial, int size) async {
    final changes = <int>[];
    var value = initial;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DailyGoalPicker(
              value: value,
              malaSize: size,
              onChanged: (v) => setState(() {
                value = v;
                changes.add(v);
              }),
            ),
          ),
        ),
      ),
    );
    return changes;
  }

  testWidgets('choosing malas stores Jaap for that mala size', (tester) async {
    final changes = await pump(tester, 108, 108);

    expect(find.text('11 malas'), findsOneWidget, reason: 'opens in malas');
    await tester.tap(find.text('11 malas'));
    await tester.pump();
    expect(changes.last, 1188);
    expect(find.text('11 malas a day · 1,188 Jaap'), findsOneWidget);
  });

  testWidgets('switching an odd Jaap goal to malas rounds it up', (
    tester,
  ) async {
    final changes = await pump(tester, 500, 108);

    expect(find.text('500 Jaap per day'), findsOneWidget, reason: 'in Jaap');
    await tester.tap(find.text('Malas'));
    await tester.pump();
    expect(changes.last, 540, reason: '500 is 4.6 malas, so 5');
  });
}
