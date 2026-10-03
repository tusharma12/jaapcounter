import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/constants/mantra_scripts.dart';
import 'package:japmala/features/mantras/domain/mantra.dart';
import 'package:japmala/features/mantras/domain/mantra_names.dart';

void main() {
  final ram = BuiltInMantras.all.firstWhere((m) => m.id == 'builtin.ram');

  test('a built-in reads in the app language', () {
    expect(ram.nameIn('en'), 'Ram Ram');
    expect(ram.nameIn('hi'), 'राम राम');
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

  group('in the script of each language', () {
    // The Unicode block each script's letters live in.
    const blocks = {
      'gu': (0x0A80, 0x0AFF),
      'pa': (0x0A00, 0x0A7F),
      'ta': (0x0B80, 0x0BFF),
      'te': (0x0C00, 0x0C7F),
    };

    for (final MapEntry(key: code, value: (start, end)) in blocks.entries) {
      test('$code has every built-in, and only its own letters', () {
        for (final mantra in BuiltInMantras.all) {
          final text = mantra.nameIn(code);
          expect(
            MantraScripts.byLanguage[code]!.containsKey(mantra.id),
            isTrue,
            reason: '${mantra.id} missing in $code',
          );
          for (final rune in text.runes) {
            if (rune == 0x20 || rune == 0x0A) continue;
            expect(
              rune >= start && rune <= end,
              isTrue,
              reason:
                  '${mantra.id} in $code has U+${rune.toRadixString(16)} '
                  '(${String.fromCharCode(rune)}) outside its script',
            );
          }
        }
      });

      test('$code keeps the line break of a two-line mantra', () {
        final gayatri = BuiltInMantras.all.firstWhere(
          (m) => m.id == 'builtin.gayatri',
        );
        expect(gayatri.nameIn(code), contains('\n'));
        expect(
          gayatri.nameIn(code).split('\n').length,
          gayatri.name.split('\n').length,
        );
      });
    }

    test('Marathi reads the stored Devanagari', () {
      expect(ram.nameIn('mr'), 'राम राम');
    });

    test('a language without its own script reads Roman letters', () {
      expect(ram.nameIn('fr'), 'Ram Ram');
    });

    test('a rewritten built-in is not replaced in any script', () {
      final edited = ram.copyWith(name: 'श्री राम');
      for (final code in blocks.keys) {
        expect(edited.nameIn(code), 'श्री राम', reason: code);
      }
    });
  });
}
