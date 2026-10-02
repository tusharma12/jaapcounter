import '../../../l10n/app_localizations.dart';

/// How a lifetime Jaap milestone is spoken of: "1,008 Jaap", "1 lakh Jaap",
/// "Sava lakh Jaap", "1 crore Jaap".
String jaapMilestoneLabel(AppL10n l10n, int threshold) => switch (threshold) {
  125000 => l10n.milestoneSavaLakh,
  10000000 => l10n.milestoneCrore,
  >= 100000 when threshold % 100000 == 0 => l10n.milestoneLakh(
    threshold ~/ 100000,
  ),
  _ => l10n.jaapCount(threshold),
};
