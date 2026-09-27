import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/features/jaap/presentation/widgets/falling_mantra.dart';
import 'package:japmala/features/mantras/domain/mantra.dart';

void main() {
  const ram = Mantra(id: 'ram', name: 'राम', malaSize: 108);
  const radha = Mantra(id: 'radha', name: 'राधा', malaSize: 108);

  Future<void> pump(
    WidgetTester tester, {
    required Mantra mantra,
    required int count,
    bool reduceMotion = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: FallingMantra(mantra: mantra, count: count),
        ),
      ),
    );
  }

  // Nothing is painted until a mantra is in the air.
  bool falling(WidgetTester tester) => find
      .descendant(
        of: find.byType(FallingMantra),
        matching: find.byType(CustomPaint),
      )
      .evaluate()
      .isNotEmpty;

  testWidgets('a bead sends the mantra falling, then it clears', (
    tester,
  ) async {
    await pump(tester, mantra: ram, count: 10);
    expect(falling(tester), isFalse);

    await pump(tester, mantra: ram, count: 11);
    await tester.pump(const Duration(milliseconds: 100));
    expect(falling(tester), isTrue);

    await tester.pump(const Duration(seconds: 6));
    expect(falling(tester), isFalse, reason: 'every particle has landed');
  });

  testWidgets('undo and switching mantra release nothing', (tester) async {
    await pump(tester, mantra: ram, count: 10);
    await pump(tester, mantra: ram, count: 9);
    await tester.pump(const Duration(milliseconds: 100));
    expect(falling(tester), isFalse, reason: 'undo');

    await pump(tester, mantra: radha, count: 500);
    await tester.pump(const Duration(milliseconds: 100));
    expect(falling(tester), isFalse, reason: 'a different mantra');
  });

  testWidgets('it falls even when the system asks for reduced motion', (
    tester,
  ) async {
    await pump(tester, mantra: ram, count: 10, reduceMotion: true);
    await pump(tester, mantra: ram, count: 11, reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(falling(tester), isTrue, reason: 'only the app setting decides');
  });
}
