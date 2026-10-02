import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:japmala/core/constants/app_languages.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/utils/formatters.dart';
import 'package:japmala/features/mantras/domain/mantra_names.dart';
import 'package:japmala/l10n/app_localizations.dart';

void main() {
  Map<String, Object?> arb(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, Object?>;
  final template = arb('en');
  final messageKeys = template.keys.where((k) => !k.startsWith('@')).toSet();

  test('the language picker offers exactly the translated languages', () {
    expect(
      AppL10n.supportedLocales.map((l) => l.languageCode).toSet(),
      AppLanguages.names.keys.toSet(),
    );
  });

  for (final code in AppLanguages.names.keys.where((c) => c != 'en')) {
    test('$code has every message, and every placeholder in it', () {
      final translation = arb(code);
      expect(translation['@@locale'], code);
      expect(
        messageKeys.difference(translation.keys.toSet()),
        isEmpty,
        reason: 'missing messages fall back to English silently',
      );
      for (final key in messageKeys) {
        final placeholders =
            ((template['@$key'] as Map?)?['placeholders'] as Map?)?.keys ??
            const [];
        for (final name in placeholders) {
          expect(
            translation[key] as String,
            contains('{$name'),
            reason: '$code $key needs {$name}',
          );
        }
      }
    });
  }

  test('every language loads and formats a plural without throwing', () async {
    Fmt.useLatinDigits();
    for (final code in AppLanguages.names.keys) {
      final l10n = await AppL10n.delegate.load(Locale(code));
      expect(l10n.dayStreak(3), isNotEmpty);
      expect(l10n.jaapCount(1008), contains('1'));
      expect(l10n.ekadashiName('nirjala'), isNotEmpty);
    }
  });

  test('numbers and dates use Latin digits in every language', () async {
    await initializeDateFormatting();
    Fmt.useLatinDigits();
    for (final code in AppLanguages.names.keys) {
      expect(
        Fmt.count(100000, code),
        matches(RegExp(r'^[0-9,]+$')),
        reason: code,
      );
      expect(
        Fmt.dayLabel(DateTime(2026, 10, 22), code),
        contains('22'),
        reason: code,
      );
    }
  });

  test('Marathi shows the built-in mantras in Devanagari, like Hindi', () {
    final ram = BuiltInMantras.all.first;

    expect(ram.nameIn('mr'), 'राम');
    expect(ram.nameIn('hi'), 'राम');
    expect(ram.nameIn('ta'), 'ராம', reason: 'Tamil reads its own script');
    expect(ram.nameIn('en'), 'Ram');
  });

  test('stories fall back to the telling a reader can read', () {
    expect(AppLanguages.storyLanguage('mr'), 'hi');
    expect(AppLanguages.storyLanguage('hi'), 'hi');
    expect(AppLanguages.storyLanguage('ta'), 'ta');
  });

  test('dictation asks for the Indian variant of each language', () {
    expect(AppLanguages.dictationLocale('en'), 'en_US');
    expect(AppLanguages.dictationLocale('te'), 'te_IN');
    expect(AppLanguages.dictationLocale('fr'), 'en_US');
  });
}
