/// The languages the app is translated into, each named in its own script so
/// a reader finds theirs whatever language the app is showing.
abstract final class AppLanguages {
  static const Map<String, String> names = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
    'gu': 'ગુજરાતી',
    'pa': 'ਪੰਜਾਬੀ',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
  };

  /// Languages written in Devanagari, which show the built-in mantras in
  /// their original script rather than in Roman letters.
  static const Set<String> devanagari = {'hi', 'mr'};

  /// The stories are written in English and Hindi. Marathi readers get the
  /// Hindi telling, in the script they read; everyone else, English.
  static String storyLanguage(String code) => switch (code) {
    'hi' || 'mr' => 'hi',
    _ => code,
  };

  /// The speech recogniser's locale for dictating a mantra.
  static String dictationLocale(String code) => switch (code) {
    'en' => 'en_US',
    _ when names.containsKey(code) => '${code}_IN',
    _ => 'en_US',
  };
}
