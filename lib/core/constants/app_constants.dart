/// Values that shape behaviour rather than looks.
abstract final class AppConstants {
  /// Mala sizes offered as presets. Anything else is entered as "Custom".
  static const List<int> malaSizePresets = [27, 54, 108];
  static const int defaultMalaSize = 108;
  static const int minMalaSize = 1;
  static const int maxMalaSize = 10000;

  /// Daily goal presets, in Jaap.
  static const List<int> dailyGoalPresets = [27, 54, 108, 216, 324, 1008];
  static const int defaultDailyGoal = 108;

  /// Sankalp duration presets, in days.
  static const List<int> sankalpDurationPresets = [21, 40, 108];
  static const int maxSankalpDays = 1008;

  /// Consecutive taps land in one ledger row while they fall inside this
  /// window, which keeps the database small without losing a single bead:
  /// each tap still writes through, it just increments an existing row.
  static const Duration ledgerCoalesceWindow = Duration(minutes: 2);

  static const int backupSchemaVersion = 1;
  static const String backupFilePrefix = 'japmala-backup';

  static const String supportEmail = 'codivolabs@gmail.com';
  static const String privacyPolicyUrl =
      'https://codivolabs.com/apps/smaran/privacy';
  static const String termsUrl = 'https://codivolabs.com/apps/smaran/terms';
  static const String androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.naamjapcounter.smaran';
  static const String iosStoreUrl =
      'https://apps.apple.com/in/app/naam-jap-counter-smaran/id6816732989';

  /// Opens the App Store's review box directly.
  static const String iosReviewUrl = '$iosStoreUrl?action=write-review';
}
