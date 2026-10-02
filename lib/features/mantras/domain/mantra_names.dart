import 'package:flutter/widgets.dart';

import '../../../core/constants/built_in_mantras.dart';
import '../../../core/constants/mantra_scripts.dart';
import 'mantra.dart';
import '../../../core/constants/app_languages.dart';

/// What a mantra is called on screen, which for the built-ins depends on the
/// app's language: राम in Hindi, Ram in English.
extension MantraNames on Mantra {
  /// [languageCode] is the app's language: Devanagari languages read the
  /// mantra as written, Gujarati, Punjabi, Tamil and Telugu in their own
  /// script, and everything else in Roman letters.
  ///
  /// A built-in the user has rewritten is theirs, and shows as they wrote
  /// it in every language.
  String nameIn(String languageCode) {
    if (!isBuiltIn || AppLanguages.devanagari.contains(languageCode)) {
      return name;
    }
    if (name != BuiltInMantras.shippedName(id)) return name;
    // The language's own script if the mantra has been written in it, else
    // Roman letters, which every reader of these languages can follow.
    return MantraScripts.byLanguage[languageCode]?[id] ??
        BuiltInMantras.english[id] ??
        name;
  }

  /// [nameIn] for the language the app is showing.
  String displayName(BuildContext context) =>
      nameIn(Localizations.localeOf(context).languageCode);
}
