import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/app/theme/app_themes.dart';
import 'package:japmala/features/mantras/domain/mantra.dart';
import 'package:japmala/features/sadhana/domain/sadhana.dart';
import 'package:japmala/features/share/presentation/share_card.dart';
import 'package:japmala/l10n/app_localizations.dart';

void main() {
  final data = ShareCardData(
    streak: 18,
    lifetimeJaap: 43200,
    lifetimeMalas: 400,
    today: DateTime(2026, 9, 3),
    mantra: const Mantra(
      id: 'm',
      name:
          'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे\nहरे राम हरे राम राम राम हरे हरे',
      malaSize: 108,
    ),
    sadhana: Sadhana(
      id: 's',
      mantraId: 'm',
      dailyGoal: 1728,
      startDay: '2026-08-17',
      durationDays: 40,
    ),
    sankalpCompletedDays: 17,
  );

  for (final (locale, theme) in [
    (const Locale('en'), AppTheme.light()),
    (const Locale('hi'), AppTheme.forId(AppThemeId.lavender)),
  ]) {
    testWidgets('the card fits its frame in $locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          theme: theme,
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Center(child: ShareCard(data: data)),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(ShareCard)), ShareCard.size);
      expect(find.text('18'), findsOneWidget);
    });
  }
}
