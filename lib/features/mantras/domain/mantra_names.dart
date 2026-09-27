import 'package:flutter/widgets.dart';

import '../../../core/constants/built_in_mantras.dart';
import 'mantra.dart';

/// What a mantra is called on screen, which for the built-ins depends on the
/// app's language: राम in Hindi, Ram in English.
extension MantraNames on Mantra {
  /// [languageCode] is the app's language; anything but Hindi reads English.
  ///
  /// A built-in the user has rewritten is theirs, and shows as they wrote
  /// it in every language.
  String nameIn(String languageCode) {
    if (!isBuiltIn || languageCode == 'hi') return name;
    final english = BuiltInMantras.english[id];
    if (english == null || name != BuiltInMantras.shippedName(id)) return name;
    return english;
  }

  /// [nameIn] for the language the app is showing.
  String displayName(BuildContext context) =>
      nameIn(Localizations.localeOf(context).languageCode);
}
