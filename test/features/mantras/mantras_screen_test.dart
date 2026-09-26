import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/mantras/presentation/mantra_controllers.dart';
import 'package:japmala/features/mantras/presentation/mantra_tile.dart';
import 'package:japmala/features/mantras/presentation/mantras_screen.dart';

import '../../support/test_harness.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = await createTestContainer();
  });

  Future<void> pumpLibrary(WidgetTester tester) async {
    await usePhoneSurface(tester);
    await pumpScreen(tester, container, const MantrasScreen());
    await tester.pumpAndSettle();
  }

  testWidgets('lists the built-in mantras with their mala size', (
    tester,
  ) async {
    await pumpLibrary(tester);

    expect(find.text('राम'), findsOneWidget);
    expect(find.text('राधा'), findsOneWidget);
    expect(find.text('ॐ नमः शिवाय'), findsOneWidget);
    expect(find.text('108 beads'), findsWidgets);
  });

  testWidgets('marks the mantra being chanted as active', (tester) async {
    await pumpLibrary(tester);

    expect(find.text('Active'), findsOneWidget);
    expect(container.read(activeMantraProvider)!.id, 'builtin.ram');
  });

  testWidgets('tapping a mantra makes it the active one', (tester) async {
    await pumpLibrary(tester);

    await tester.tap(find.text('राधा'));
    await tester.pumpAndSettle();

    expect(container.read(activeMantraProvider)!.id, 'builtin.radha');
    expect(find.text('Active'), findsOneWidget, reason: 'only ever one');
  });

  testWidgets('a built-in mantra offers editing but not deletion', (
    tester,
  ) async {
    await pumpLibrary(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('a custom mantra can be added and deleted', (tester) async {
    final created = await container
        .read(mantraListProvider.notifier)
        .add(name: 'Sita Ram', devanagari: 'सीता राम', malaSize: 27);
    await pumpLibrary(tester);

    await tester.scrollUntilVisible(find.text('सीता राम'), 200);
    expect(find.text('सीता राम'), findsOneWidget);
    expect(find.text('27 beads'), findsOneWidget);

    await container.read(mantraListProvider.notifier).remove(created.id);
    await tester.pumpAndSettle();

    expect(find.text('सीता राम'), findsNothing);
  });

  testWidgets('the quick picker switches mantra and closes', (tester) async {
    await usePhoneSurface(tester);
    await pumpScreen(tester, container, const MantraPickerSheet());
    await tester.pumpAndSettle();

    expect(find.byType(MantraTile), findsWidgets);
    expect(find.text('My Mantras'), findsOneWidget);

    await tester.tap(find.text('ॐ नमः शिवाय'));
    await tester.pumpAndSettle();

    expect(
      container.read(activeMantraProvider)!.id,
      'builtin.om-namah-shivaya',
    );
  });
}
