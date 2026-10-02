import '../../../l10n/app_localizations.dart';
import '../domain/observance.dart';

/// An observance's name in the app's language.
///
/// Names live in the ARB files as one ICU `select` per kind, keyed by a
/// camel-cased id (`ekadashi.pausha-putrada` → `paushaPutrada`), so a
/// translator can give every name in their own script.
String observanceName(AppL10n l10n, Observance observance) {
  switch (observance.kind) {
    case ObservanceKind.ekadashi:
      return l10n.ekadashiName(_camel(observance.id.split('.').last));
    case ObservanceKind.festival:
    case ObservanceKind.period:
      return l10n.festivalName(_camel(observance.id));
  }
}

String _camel(String slug) {
  final parts = slug.split('-');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
