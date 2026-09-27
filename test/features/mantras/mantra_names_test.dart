import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/features/mantras/domain/mantra.dart';
import 'package:japmala/features/mantras/domain/mantra_names.dart';

void main() {
  final ram = BuiltInMantras.all.firstWhere((m) => m.id == 'builtin.ram');

  test('a built-in reads in the app language', () {
    expect(ram.nameIn('en'), 'Ram');
    expect(ram.nameIn('hi'), 'राम');
  });

  test('every built-in has an English name', () {
    for (final mantra in BuiltInMantras.all) {
      final english = mantra.nameIn('en');
      expect(english, isNot(mantra.name), reason: mantra.id);
      expect(Mantra.isDevanagariText(english), isFalse, reason: mantra.id);
    }
  });

  test("a built-in the user rewrote keeps the user's words", () {
    final edited = ram.copyWith(name: 'श्री राम');
    expect(edited.nameIn('en'), 'श्री राम');
    expect(edited.nameIn('hi'), 'श्री राम');
  });

  test('a mantra of their own is never translated', () {
    const own = Mantra(id: 'own', name: 'राम', malaSize: 108);
    expect(own.nameIn('en'), 'राम');
  });
}
