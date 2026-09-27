// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Naam Jap Counter – Smaran';

  @override
  String get tagline => 'Your peaceful digital mala for daily Naam Jap';

  @override
  String get navJaap => 'Jaap';

  @override
  String get navProgress => 'Progress';

  @override
  String get navStories => 'Stories';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get custom => 'Custom';

  @override
  String get active => 'Active';

  @override
  String get off => 'OFF';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tapToCount => 'TAP TO COUNT';

  @override
  String get todaysJaap => 'Today\'s Jaap';

  @override
  String get undo => 'Undo';

  @override
  String get malaComplete => 'Mala Complete';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Malas completed',
      one: '1 Mala completed',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString Jaap';
  }

  @override
  String get nothingToUndo => 'Nothing to undo';

  @override
  String get countRemoved => 'Count removed';

  @override
  String get resetCurrentMala => 'Reset current mala';

  @override
  String get resetCurrentMalaBody =>
      'The beads counted in this mala will be removed. Completed malas are kept.';

  @override
  String get addCountManually => 'Add count manually';

  @override
  String get addCount => 'Add count';

  @override
  String get numberOfJaap => 'Number of Jaap';

  @override
  String get meditationMode => 'Meditation mode';

  @override
  String get startSession => 'Start session';

  @override
  String get endSession => 'End session';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$jaap Jaap in $minutes min';
  }

  @override
  String get myMantras => 'My Mantras';

  @override
  String get addMantra => 'Add Mantra';

  @override
  String get editMantra => 'Edit Mantra';

  @override
  String get malaSize => 'Mala Size';

  @override
  String beads(int count) {
    return '$count beads';
  }

  @override
  String get malaSizeInvalid => 'Mala size must be between 1 and 10,000';

  @override
  String get deleteMantraTitle => 'Delete mantra?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" will be removed. Your recorded Jaap history is kept.';
  }

  @override
  String get optional => 'optional';

  @override
  String get mySadhana => 'My Sadhana';

  @override
  String get todaysGoal => 'Today\'s Goal';

  @override
  String get complete => 'Complete';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Day Streak',
      one: '1 Day Streak',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'Best streak';

  @override
  String sankalpDays(int days) {
    return '$days DAY SANKALP';
  }

  @override
  String dayXofY(int current, int total) {
    return 'Day $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days completed',
      one: '1 day completed',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return 'Started $date';
  }

  @override
  String get createNewSankalp => 'Create New Sankalp';

  @override
  String get createSankalp => 'Create Sankalp';

  @override
  String get chooseMantra => 'Choose Mantra';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get duration => 'Duration';

  @override
  String durationDays(int days) {
    return '$days days';
  }

  @override
  String get reminder => 'Reminder';

  @override
  String get beginSadhana => 'Begin Sadhana';

  @override
  String get noSankalpTitle => 'Begin a Sankalp';

  @override
  String get noSankalpBody =>
      'A Sankalp is a vow to chant a set number of Jaap every day for a chosen number of days.';

  @override
  String get endSankalp => 'End Sankalp';

  @override
  String get endSankalpBody =>
      'Your progress will be kept, but the Sankalp will no longer be active.';

  @override
  String jaapPerDay(int count) {
    return '$count Jaap per day';
  }

  @override
  String goalRemaining(int count) {
    return '$count to go';
  }

  @override
  String get goalReached => 'Daily goal reached';

  @override
  String get setDailyGoal => 'Set daily goal';

  @override
  String get sadhanaGoals => 'Sadhana Goals';

  @override
  String get progress => 'Progress';

  @override
  String get filterDaily => 'Daily';

  @override
  String get filterWeekly => 'Weekly';

  @override
  String get filterMonthly => 'Monthly';

  @override
  String get filterYearly => 'Yearly';

  @override
  String get totalJaap => 'Total Jaap';

  @override
  String get totalMalas => 'Total Malas';

  @override
  String get weeklyJaap => 'Weekly Jaap';

  @override
  String get monthlyJaap => 'Monthly Jaap';

  @override
  String get yearlyJaap => 'Yearly Jaap';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString Goal';
  }

  @override
  String get noJaapYet => 'No Jaap recorded yet';

  @override
  String get noJaapYetBody =>
      'Your first bead is the beginning of the journey.';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get activeDays => 'Active days';

  @override
  String get perMantra => 'By mantra';

  @override
  String get stories => 'Stories';

  @override
  String get storiesSubtitle => 'Short stories for reflection';

  @override
  String get popular => 'Popular';

  @override
  String get read => 'Read';

  @override
  String get listen => 'Listen';

  @override
  String get stopListening => 'Stop';

  @override
  String get textSize => 'Text Size';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favorites';

  @override
  String get share => 'Share';

  @override
  String get all => 'All';

  @override
  String minRead(int minutes) {
    return '$minutes min read';
  }

  @override
  String get noFavoritesTitle => 'No favourites yet';

  @override
  String get noFavoritesBody => 'Tap the heart on a story to keep it here.';

  @override
  String get noStoriesFound => 'No stories found';

  @override
  String get settings => 'Settings';

  @override
  String get sectionJaap => 'JAAP';

  @override
  String get sectionReminders => 'REMINDERS';

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get sectionBackup => 'BACKUP';

  @override
  String get sectionSupport => 'SUPPORT';

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get resetCounts => 'Reset Counts';

  @override
  String get jaapReminders => 'Jaap Reminders';

  @override
  String get streakReminder => 'Streak Reminder';

  @override
  String get goalReminder => 'Goal Reminder';

  @override
  String get theme => 'Theme';

  @override
  String get haptics => 'Haptics';

  @override
  String get sound => 'Sound';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get exportMyData => 'Export My Data';

  @override
  String get rateApp => 'Rate Smaran';

  @override
  String get shareApp => 'Share Smaran';

  @override
  String get feedback => 'Feedback';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get terms => 'Terms';

  @override
  String get aboutApp => 'About Smaran';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get resetTodayTitle => 'Reset today\'s Jaap?';

  @override
  String get resetTodayBody =>
      'All Jaap recorded today will be removed. This cannot be undone.';

  @override
  String get resetAllTitle => 'Reset all Jaap?';

  @override
  String get resetAllBody =>
      'Your entire Jaap history, malas and streaks will be permanently deleted. This cannot be undone.';

  @override
  String get resetToday => 'Reset today';

  @override
  String get resetEverything => 'Reset everything';

  @override
  String get resetDone => 'Counts reset';

  @override
  String get aboutBody =>
      'Smaran is a quiet, private space for your daily Naam Jap. Everything you chant is stored only on this device.';

  @override
  String get madeWith => 'Made with devotion';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get reminderTime => 'Time';

  @override
  String get everyDay => 'Every day';

  @override
  String get noRemindersTitle => 'No reminders yet';

  @override
  String get noRemindersBody =>
      'A gentle nudge at the same time each day makes the practice a habit.';

  @override
  String get notificationsBlocked =>
      'Notifications are turned off for Smaran. Enable them in your device settings.';

  @override
  String get reminderNotificationTitle => 'Time for your Jaap';

  @override
  String get reminderNotificationBody =>
      'A few quiet minutes with your mala 🙏';

  @override
  String get streakNotificationTitle => 'Keep your streak alive';

  @override
  String get streakNotificationBody =>
      'You haven\'t chanted today. One mala keeps it going.';

  @override
  String get goalNotificationTitle => 'Almost there';

  @override
  String get goalNotificationBody =>
      'Finish today\'s goal to complete your Sadhana for the day.';

  @override
  String get createBackup => 'Create backup';

  @override
  String get createBackupBody =>
      'Save a JSON file with all your mantras, Jaap history, goals and settings.';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get restoreBackupBody => 'Choose a Smaran backup file to restore.';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get restoreWarningTitle => 'Replace all data?';

  @override
  String get restoreWarningBody =>
      'Restoring will replace everything currently in Smaran with the contents of the backup file.';

  @override
  String get restore => 'Restore';

  @override
  String restoreSuccess(int count) {
    return 'Restored $count Jaap entries';
  }

  @override
  String get importInvalid => 'This file is not a valid Smaran backup';

  @override
  String get exportShareText => 'My Smaran backup';

  @override
  String get onb1Title => 'Your Digital Jap Mala';

  @override
  String get onb1Body => 'A peaceful way to count every Naam Jap.';

  @override
  String get onb2Title => 'Make Your Sadhana a Habit';

  @override
  String get onb2Body => 'Set a daily goal and build your chanting streak.';

  @override
  String get onb3Title => 'Chant Without Distractions';

  @override
  String get onb3Body =>
      'Enter meditation mode with a clean, peaceful counter.';

  @override
  String get startJap => 'Start Jap';

  @override
  String get blackout => 'Blackout';

  @override
  String get timer => 'Timer';

  @override
  String get exitMeditation => 'Exit meditation mode';

  @override
  String get tapAnywhere => 'Tap anywhere to count';

  @override
  String semanticCounter(int count, int total) {
    return 'Jaap counter. $count of $total beads. Double tap to count one.';
  }

  @override
  String get autoJaap => 'Auto Jaap';

  @override
  String get autoJaapBody =>
      'The app counts for you at a steady pace, so you can chant along hands-free.';

  @override
  String get autoJaapPace => 'Pace';

  @override
  String autoJaapSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get autoJaapStopAfter => 'Stop after';

  @override
  String get autoJaapStopMala => 'One mala';

  @override
  String get autoJaapStopGoal => 'Daily goal';

  @override
  String get autoJaapStopNever => 'Don\'t stop';

  @override
  String get autoJaapStart => 'Start Auto Jaap';

  @override
  String get autoJaapStopAction => 'Stop Auto Jaap';

  @override
  String counterCount(String count) {
    return 'Count: $count';
  }

  @override
  String counterMalas(String count) {
    return 'Malas: $count';
  }

  @override
  String counterTotal(String count) {
    return 'Total: $count';
  }

  @override
  String get autoJaapTapToStop => 'Auto Jaap running · tap anywhere to stop';

  @override
  String get hideMantra => 'Hide mantra';

  @override
  String get showMantra => 'Show mantra';

  @override
  String get changeTheme => 'Change theme';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Menu';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeWhite => 'White';

  @override
  String get themeBlack => 'Black';

  @override
  String get themePastelPink => 'Pastel Pink';

  @override
  String get themeSpiritual => 'Spiritual';

  @override
  String get themeSaffron => 'Saffron';

  @override
  String get themePeaceful => 'Peaceful';

  @override
  String get themeTerracotta => 'Terracotta';

  @override
  String get themeMeditative => 'Meditative';

  @override
  String get themeNature => 'Nature';

  @override
  String get themeRoseGold => 'Rose Gold';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeCharcoal => 'Charcoal';

  @override
  String get counterBackground => 'Counter background';

  @override
  String get counterBackgroundBody =>
      'Shown behind the mantra and beads on the counter.';

  @override
  String get backgroundNone => 'None';

  @override
  String get backgroundDawn => 'Dawn';

  @override
  String get backgroundDusk => 'Dusk';

  @override
  String get backgroundLotus => 'Lotus';

  @override
  String get backgroundForest => 'Forest';

  @override
  String get backgroundOcean => 'Ocean';

  @override
  String get backgroundCosmos => 'Cosmos';

  @override
  String get backgroundPhoto => 'My photo';

  @override
  String get backgroundChoosePhoto => 'Choose a photo';

  @override
  String get backgroundChangePhoto => 'Change photo';

  @override
  String get backgroundRemovePhoto => 'Remove photo';

  @override
  String get backgroundDim => 'Dim background';

  @override
  String get backgroundDimHint => 'More dimming keeps the mantra easy to read.';

  @override
  String get addOwnMantra => 'Add your own mantra';

  @override
  String get addOwnMantraHint =>
      'Any name or mantra, in any script, with your own mala size';

  @override
  String get legendLess => 'Less';

  @override
  String get legendMore => 'More';

  @override
  String get allMantras => 'All mantras';

  @override
  String get previousPeriod => 'Previous';

  @override
  String get nextPeriod => 'Next';

  @override
  String get showStatsFor => 'Show statistics for';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count Jaap · $malas malas';
  }

  @override
  String get dailyJaap => 'Daily Jaap';

  @override
  String get mantraText => 'Mantra';

  @override
  String get mantraTextHint => 'e.g. राम or Om Namah Shivaya';

  @override
  String get mantraRequired => 'Please enter the mantra';

  @override
  String get mantraDescription => 'Description';

  @override
  String get mantraDescriptionHint =>
      'A meaning, a source, or a note to yourself';

  @override
  String get fallingMantra => 'Falling mantra';

  @override
  String get stopFallingMantra => 'Stop falling mantra';

  @override
  String get malaStyle => 'Mala style';

  @override
  String get malaStyleBeads => 'Beads';

  @override
  String get malaStyleRing => 'Progress ring';

  @override
  String get sectionCounter => 'COUNTER';

  @override
  String get showMantraOnCounter => 'Show mantra on counter';

  @override
  String get goalUnitMalas => 'Malas';

  @override
  String get goalUnitJaap => 'Jaap';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count malas',
      one: '1 mala',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'Malas a day';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas malas',
      one: '1 mala',
    );
    return '$_temp0 a day · $jaap Jaap';
  }

  @override
  String get onbMantraTitle => 'Which mantra do you chant?';

  @override
  String get onbMantraBody =>
      'Pick one to begin. You can add more at any time.';

  @override
  String get onbGoalTitle => 'Your daily goal';

  @override
  String get onbGoalBody =>
      'Start small: a steady practice matters more than a big number. You can change it any time.';

  @override
  String get shareProgress => 'Share my progress';

  @override
  String get shareStreakLabel => 'day streak';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0 of Naam Jap in a row, with Smaran 🙏';
  }

  @override
  String get blackoutMode => 'Blackout mode';

  @override
  String get exitBlackout => 'Exit blackout';
}
