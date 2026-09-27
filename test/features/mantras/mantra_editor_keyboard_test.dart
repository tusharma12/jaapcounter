import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/mantras/presentation/mantra_editor_sheet.dart';

import '../../support/test_harness.dart';

void main() {
  testWidgets('with the keyboard up the editor scrolls, and never overflows', (
    tester,
  ) async {
    await usePhoneSurface(tester);
    final container = await createTestContainer();
    await pumpScreen(
      tester,
      container,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showMantraEditor(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // An iPhone keyboard, about 336 points tall (the test phone is 1×).
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'no overflow');
    final scroll = find.descendant(
      of: find.byType(MantraEditorSheet),
      matching: find.byType(Scrollable),
    );
    expect(scroll, findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Save'),
      120,
      scrollable: scroll.first,
    );
    // Save sits above the keyboard, not behind it.
    expect(tester.getRect(find.text('Save')).bottom, lessThan(844 - 336));
    expect(find.text('Save').hitTestable(), findsOneWidget);
  });

  testWidgets('the number prompt closes cleanly', (tester) async {
    await usePhoneSurface(tester);
    final container = await createTestContainer();
    int? result;
    await pumpScreen(
      tester,
      container,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await showNumberPrompt(
              context,
              title: 'Mala size',
              initialValue: 108,
              min: 1,
              max: 10000,
              invalidMessage: 'Invalid',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '54');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 54);
    expect(tester.takeException(), isNull);
  });
}
