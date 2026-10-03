// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppL10nPa extends AppL10n {
  AppL10nPa([String locale = 'pa']) : super(locale);

  @override
  String get appName => 'ਨਾਮ ਜਪ ਕਾਊਂਟਰ – ਸਿਮਰਨ';

  @override
  String get tagline => 'ਰੋਜ਼ਾਨਾ ਨਾਮ ਜਪ ਲਈ ਤੁਹਾਡੀ ਸ਼ਾਂਤ ਡਿਜੀਟਲ ਮਾਲਾ';

  @override
  String get navJaap => 'ਜਾਪ';

  @override
  String get navProgress => 'ਤਰੱਕੀ';

  @override
  String get navStories => 'ਕਥਾਵਾਂ';

  @override
  String get navSettings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get save => 'ਸੰਭਾਲੋ';

  @override
  String get delete => 'ਮਿਟਾਓ';

  @override
  String get edit => 'ਸੋਧੋ';

  @override
  String get close => 'ਬੰਦ ਕਰੋ';

  @override
  String get next => 'ਅੱਗੇ';

  @override
  String get skip => 'ਛੱਡੋ';

  @override
  String get retry => 'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get custom => 'ਆਪਣੀ ਪਸੰਦ';

  @override
  String get active => 'ਚਾਲੂ';

  @override
  String get off => 'ਬੰਦ';

  @override
  String get somethingWentWrong => 'ਕੁਝ ਗੜਬੜ ਹੋ ਗਈ';

  @override
  String get tapToCount => 'ਗਿਣਨ ਲਈ ਛੋਹੋ';

  @override
  String get todaysJaap => 'ਅੱਜ ਦਾ ਜਾਪ';

  @override
  String get undo => 'ਵਾਪਸ ਲਓ';

  @override
  String get malaComplete => 'ਮਾਲਾ ਪੂਰੀ';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਮਾਲਾਵਾਂ ਪੂਰੀਆਂ',
      one: '1 ਮਾਲਾ ਪੂਰੀ',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ਜਾਪ';
  }

  @override
  String get nothingToUndo => 'ਵਾਪਸ ਲੈਣ ਲਈ ਕੁਝ ਨਹੀਂ';

  @override
  String get countRemoved => 'ਗਿਣਤੀ ਹਟਾਈ ਗਈ';

  @override
  String get resetCurrentMala => 'ਮੌਜੂਦਾ ਮਾਲਾ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get resetCurrentMalaBody =>
      'ਇਸ ਮਾਲਾ ਵਿੱਚ ਗਿਣੇ ਮਣਕੇ ਹਟਾ ਦਿੱਤੇ ਜਾਣਗੇ। ਪੂਰੀਆਂ ਹੋਈਆਂ ਮਾਲਾਵਾਂ ਸੰਭਾਲੀਆਂ ਰਹਿਣਗੀਆਂ।';

  @override
  String get addCountManually => 'ਗਿਣਤੀ ਆਪ ਜੋੜੋ';

  @override
  String get addCount => 'ਗਿਣਤੀ ਜੋੜੋ';

  @override
  String get numberOfJaap => 'ਜਾਪ ਦੀ ਗਿਣਤੀ';

  @override
  String get meditationMode => 'ਧਿਆਨ ਮੋਡ';

  @override
  String get startSession => 'ਸੈਸ਼ਨ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get endSession => 'ਸੈਸ਼ਨ ਸਮਾਪਤ ਕਰੋ';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$minutes ਮਿੰਟ ਵਿੱਚ $jaap ਜਾਪ';
  }

  @override
  String get myMantras => 'ਮੇਰੇ ਮੰਤਰ';

  @override
  String get addMantra => 'ਮੰਤਰ ਜੋੜੋ';

  @override
  String get editMantra => 'ਮੰਤਰ ਸੋਧੋ';

  @override
  String get malaSize => 'ਮਾਲਾ ਦਾ ਆਕਾਰ';

  @override
  String beads(int count) {
    return '$count ਮਣਕੇ';
  }

  @override
  String get malaSizeInvalid =>
      'ਮਾਲਾ ਦਾ ਆਕਾਰ 1 ਤੋਂ 10,000 ਦੇ ਵਿਚਕਾਰ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ';

  @override
  String get deleteMantraTitle => 'ਮੰਤਰ ਮਿਟਾਉਣਾ ਹੈ?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" ਹਟਾ ਦਿੱਤਾ ਜਾਵੇਗਾ। ਤੁਹਾਡਾ ਦਰਜ ਜਾਪ ਇਤਿਹਾਸ ਸੰਭਾਲਿਆ ਰਹੇਗਾ।';
  }

  @override
  String get optional => 'ਵਿਕਲਪਿਕ';

  @override
  String get mySadhana => 'ਮੇਰੀ ਸਾਧਨਾ';

  @override
  String get todaysGoal => 'ਅੱਜ ਦਾ ਟੀਚਾ';

  @override
  String get complete => 'ਪੂਰਾ';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਦਿਨਾਂ ਦੀ ਲੜੀ',
      one: '1 ਦਿਨ ਦੀ ਲੜੀ',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'ਸਭ ਤੋਂ ਲੰਬੀ ਲੜੀ';

  @override
  String sankalpDays(int days) {
    return '$days ਦਿਨਾਂ ਦਾ ਸੰਕਲਪ';
  }

  @override
  String dayXofY(int current, int total) {
    return 'ਦਿਨ $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਦਿਨ ਪੂਰੇ',
      one: '1 ਦਿਨ ਪੂਰਾ',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return '$date ਤੋਂ ਸ਼ੁਰੂ';
  }

  @override
  String get createNewSankalp => 'ਨਵਾਂ ਸੰਕਲਪ ਲਓ';

  @override
  String get createSankalp => 'ਸੰਕਲਪ ਬਣਾਓ';

  @override
  String get chooseMantra => 'ਮੰਤਰ ਚੁਣੋ';

  @override
  String get dailyGoal => 'ਰੋਜ਼ਾਨਾ ਟੀਚਾ';

  @override
  String get duration => 'ਮਿਆਦ';

  @override
  String durationDays(int days) {
    return '$days ਦਿਨ';
  }

  @override
  String get reminder => 'ਯਾਦ-ਦਹਾਨੀ';

  @override
  String get beginSadhana => 'ਸਾਧਨਾ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get noSankalpTitle => 'ਸੰਕਲਪ ਲਓ';

  @override
  String get noSankalpBody =>
      'ਸੰਕਲਪ ਇੱਕ ਪ੍ਰਣ ਹੈ – ਚੁਣੇ ਹੋਏ ਦਿਨਾਂ ਤੱਕ ਹਰ ਰੋਜ਼ ਤੈਅ ਗਿਣਤੀ ਵਿੱਚ ਜਾਪ ਕਰਨ ਦਾ।';

  @override
  String get endSankalp => 'ਸੰਕਲਪ ਸਮਾਪਤ ਕਰੋ';

  @override
  String get endSankalpBody =>
      'ਤੁਹਾਡੀ ਤਰੱਕੀ ਸੰਭਾਲੀ ਰਹੇਗੀ, ਪਰ ਸੰਕਲਪ ਹੁਣ ਚਾਲੂ ਨਹੀਂ ਰਹੇਗਾ।';

  @override
  String jaapPerDay(int count) {
    return 'ਹਰ ਰੋਜ਼ $count ਜਾਪ';
  }

  @override
  String goalRemaining(int count) {
    return '$count ਬਾਕੀ';
  }

  @override
  String get goalReached => 'ਅੱਜ ਦਾ ਟੀਚਾ ਪੂਰਾ';

  @override
  String get goalReachedAutoBody =>
      'ਆਟੋ ਜਾਪ ਰੁਕਿਆ ਹੋਇਆ ਹੈ। ਜਾਰੀ ਰੱਖਣਾ ਹੈ ਜਾਂ ਇੱਥੇ ਰੋਕਣਾ ਹੈ?';

  @override
  String get keepGoing => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String get setDailyGoal => 'ਰੋਜ਼ਾਨਾ ਟੀਚਾ ਤੈਅ ਕਰੋ';

  @override
  String get sadhanaGoals => 'ਸਾਧਨਾ ਦੇ ਟੀਚੇ';

  @override
  String get progress => 'ਤਰੱਕੀ';

  @override
  String get filterDaily => 'ਰੋਜ਼ਾਨਾ';

  @override
  String get filterWeekly => 'ਹਫ਼ਤਾਵਾਰ';

  @override
  String get filterMonthly => 'ਮਹੀਨਾਵਾਰ';

  @override
  String get filterYearly => 'ਸਾਲਾਨਾ';

  @override
  String get totalJaap => 'ਕੁੱਲ ਜਾਪ';

  @override
  String get totalMalas => 'ਕੁੱਲ ਮਾਲਾਵਾਂ';

  @override
  String get weeklyJaap => 'ਹਫ਼ਤਾਵਾਰ ਜਾਪ';

  @override
  String get monthlyJaap => 'ਮਹੀਨਾਵਾਰ ਜਾਪ';

  @override
  String get yearlyJaap => 'ਸਾਲਾਨਾ ਜਾਪ';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString ਟੀਚਾ';
  }

  @override
  String get noJaapYet => 'ਅਜੇ ਕੋਈ ਜਾਪ ਦਰਜ ਨਹੀਂ';

  @override
  String get noJaapYetBody => 'ਪਹਿਲਾ ਮਣਕਾ ਹੀ ਸਫ਼ਰ ਦੀ ਸ਼ੁਰੂਆਤ ਹੈ।';

  @override
  String get dailyAverage => 'ਰੋਜ਼ਾਨਾ ਔਸਤ';

  @override
  String get activeDays => 'ਸਰਗਰਮ ਦਿਨ';

  @override
  String get perMantra => 'ਮੰਤਰ ਅਨੁਸਾਰ';

  @override
  String get stories => 'ਕਥਾਵਾਂ';

  @override
  String get storiesSubtitle => 'ਵਿਚਾਰਨ ਲਈ ਛੋਟੀਆਂ ਕਥਾਵਾਂ';

  @override
  String get popular => 'ਪ੍ਰਸਿੱਧ';

  @override
  String get read => 'ਪੜ੍ਹੋ';

  @override
  String get listen => 'ਸੁਣੋ';

  @override
  String get stopListening => 'ਰੋਕੋ';

  @override
  String get textSize => 'ਅੱਖਰਾਂ ਦਾ ਆਕਾਰ';

  @override
  String get favorite => 'ਪਸੰਦੀਦਾ';

  @override
  String get favorites => 'ਪਸੰਦੀਦਾ';

  @override
  String get share => 'ਸਾਂਝਾ ਕਰੋ';

  @override
  String get all => 'ਸਭ';

  @override
  String minRead(int minutes) {
    return '$minutes ਮਿੰਟ ਦਾ ਪਾਠ';
  }

  @override
  String get noFavoritesTitle => 'ਅਜੇ ਕੋਈ ਪਸੰਦੀਦਾ ਨਹੀਂ';

  @override
  String get noFavoritesBody =>
      'ਕਿਸੇ ਕਥਾ \'ਤੇ ਦਿਲ ਦੇ ਨਿਸ਼ਾਨ ਨੂੰ ਛੋਹ ਕੇ ਉਸ ਨੂੰ ਇੱਥੇ ਰੱਖੋ।';

  @override
  String get noStoriesFound => 'ਕੋਈ ਕਥਾ ਨਹੀਂ ਮਿਲੀ';

  @override
  String get settings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get sectionJaap => 'ਜਾਪ';

  @override
  String get sectionReminders => 'ਯਾਦ-ਦਹਾਨੀਆਂ';

  @override
  String get sectionAppearance => 'ਦਿੱਖ';

  @override
  String get sectionBackup => 'ਬੈਕਅੱਪ';

  @override
  String get sectionSupport => 'ਸਹਾਇਤਾ';

  @override
  String get sectionAbout => 'ਜਾਣ-ਪਛਾਣ';

  @override
  String get resetCounts => 'ਗਿਣਤੀ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get jaapReminders => 'ਜਾਪ ਦੀ ਯਾਦ-ਦਹਾਨੀ';

  @override
  String get streakReminder => 'ਲੜੀ ਦੀ ਯਾਦ-ਦਹਾਨੀ';

  @override
  String get goalReminder => 'ਟੀਚੇ ਦੀ ਯਾਦ-ਦਹਾਨੀ';

  @override
  String get theme => 'ਥੀਮ';

  @override
  String get haptics => 'ਵਾਈਬ੍ਰੇਸ਼ਨ';

  @override
  String get sound => 'ਆਵਾਜ਼';

  @override
  String get language => 'ਭਾਸ਼ਾ';

  @override
  String get languageSystem => 'ਸਿਸਟਮ ਅਨੁਸਾਰ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'ਬੈਕਅੱਪ ਅਤੇ ਬਹਾਲੀ';

  @override
  String get exportMyData => 'ਮੇਰਾ ਡਾਟਾ ਐਕਸਪੋਰਟ ਕਰੋ';

  @override
  String get rateApp => 'ਸਿਮਰਨ ਨੂੰ ਰੇਟ ਕਰੋ';

  @override
  String get shareApp => 'ਪਰਿਵਾਰ ਅਤੇ ਦੋਸਤਾਂ ਨੂੰ ਸੱਦਾ ਦਿਓ';

  @override
  String get feedback => 'ਸੁਝਾਅ';

  @override
  String get privacyPolicy => 'ਪਰਦੇਦਾਰੀ ਨੀਤੀ';

  @override
  String get terms => 'ਸ਼ਰਤਾਂ';

  @override
  String get aboutApp => 'ਸਿਮਰਨ ਬਾਰੇ';

  @override
  String version(String version) {
    return 'ਵਰਜਨ $version';
  }

  @override
  String get resetTodayTitle => 'ਅੱਜ ਦਾ ਜਾਪ ਰੀਸੈੱਟ ਕਰਨਾ ਹੈ?';

  @override
  String get resetTodayBody =>
      'ਅੱਜ ਦਰਜ ਹੋਇਆ ਸਾਰਾ ਜਾਪ ਹਟ ਜਾਵੇਗਾ। ਇਸ ਨੂੰ ਵਾਪਸ ਨਹੀਂ ਲਿਆ ਜਾ ਸਕਦਾ।';

  @override
  String get resetAllTitle => 'ਸਾਰਾ ਜਾਪ ਰੀਸੈੱਟ ਕਰਨਾ ਹੈ?';

  @override
  String get resetAllBody =>
      'ਤੁਹਾਡਾ ਪੂਰਾ ਜਾਪ ਇਤਿਹਾਸ, ਮਾਲਾਵਾਂ ਅਤੇ ਲੜੀਆਂ ਹਮੇਸ਼ਾ ਲਈ ਮਿਟ ਜਾਣਗੀਆਂ। ਇਸ ਨੂੰ ਵਾਪਸ ਨਹੀਂ ਲਿਆ ਜਾ ਸਕਦਾ।';

  @override
  String get resetToday => 'ਅੱਜ ਦਾ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get resetEverything => 'ਸਭ ਕੁਝ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get resetDone => 'ਗਿਣਤੀ ਰੀਸੈੱਟ ਹੋ ਗਈ';

  @override
  String get aboutBody =>
      'ਸਿਮਰਨ ਤੁਹਾਡੇ ਰੋਜ਼ਾਨਾ ਨਾਮ ਜਪ ਲਈ ਇੱਕ ਸ਼ਾਂਤ, ਨਿੱਜੀ ਥਾਂ ਹੈ। ਤੁਸੀਂ ਜੋ ਵੀ ਜਪਦੇ ਹੋ, ਉਹ ਸਿਰਫ਼ ਇਸੇ ਡਿਵਾਈਸ ਵਿੱਚ ਸੰਭਾਲਿਆ ਜਾਂਦਾ ਹੈ।';

  @override
  String get madeWith => 'ਸ਼ਰਧਾ ਨਾਲ ਬਣਾਇਆ';

  @override
  String get addReminder => 'ਯਾਦ-ਦਹਾਨੀ ਜੋੜੋ';

  @override
  String get reminderTime => 'ਸਮਾਂ';

  @override
  String get everyDay => 'ਹਰ ਰੋਜ਼';

  @override
  String get noRemindersTitle => 'ਅਜੇ ਕੋਈ ਯਾਦ-ਦਹਾਨੀ ਨਹੀਂ';

  @override
  String get noRemindersBody =>
      'ਹਰ ਰੋਜ਼ ਇੱਕੋ ਸਮੇਂ ਇੱਕ ਹਲਕੀ ਜਿਹੀ ਯਾਦ ਅਭਿਆਸ ਨੂੰ ਆਦਤ ਬਣਾ ਦਿੰਦੀ ਹੈ।';

  @override
  String get notificationsBlocked =>
      'ਸਿਮਰਨ ਲਈ ਸੂਚਨਾਵਾਂ ਬੰਦ ਹਨ। ਆਪਣੇ ਡਿਵਾਈਸ ਦੀਆਂ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਇਨ੍ਹਾਂ ਨੂੰ ਚਾਲੂ ਕਰੋ।';

  @override
  String get reminderNotificationTitle => 'ਜਾਪ ਦਾ ਸਮਾਂ';

  @override
  String get reminderNotificationBody => 'ਮਾਲਾ ਨਾਲ ਕੁਝ ਸ਼ਾਂਤ ਪਲ 🙏';

  @override
  String get streakNotificationTitle => 'ਆਪਣੀ ਲੜੀ ਨਾ ਟੁੱਟਣ ਦਿਓ';

  @override
  String get streakNotificationBody =>
      'ਤੁਸੀਂ ਅੱਜ ਜਾਪ ਨਹੀਂ ਕੀਤਾ। ਇੱਕ ਮਾਲਾ ਨਾਲ ਵੀ ਲੜੀ ਜਾਰੀ ਰਹੇਗੀ।';

  @override
  String get goalNotificationTitle => 'ਬੱਸ ਥੋੜ੍ਹਾ ਬਾਕੀ';

  @override
  String get goalNotificationBody =>
      'ਅੱਜ ਦਾ ਟੀਚਾ ਪੂਰਾ ਕਰਕੇ ਅੱਜ ਦੀ ਸਾਧਨਾ ਸੰਪੂਰਨ ਕਰੋ।';

  @override
  String get createBackup => 'ਬੈਕਅੱਪ ਬਣਾਓ';

  @override
  String get createBackupBody =>
      'ਆਪਣੇ ਸਾਰੇ ਮੰਤਰਾਂ, ਜਾਪ ਇਤਿਹਾਸ, ਟੀਚਿਆਂ ਅਤੇ ਸੈਟਿੰਗਾਂ ਵਾਲੀ JSON ਫ਼ਾਈਲ ਸੰਭਾਲੋ।';

  @override
  String get restoreBackup => 'ਬੈਕਅੱਪ ਤੋਂ ਬਹਾਲ ਕਰੋ';

  @override
  String get restoreBackupBody => 'ਬਹਾਲ ਕਰਨ ਲਈ ਸਿਮਰਨ ਦੀ ਬੈਕਅੱਪ ਫ਼ਾਈਲ ਚੁਣੋ।';

  @override
  String get backupCreated => 'ਬੈਕਅੱਪ ਬਣ ਗਿਆ';

  @override
  String get restoreWarningTitle => 'ਸਾਰਾ ਡਾਟਾ ਬਦਲਣਾ ਹੈ?';

  @override
  String get restoreWarningBody =>
      'ਬਹਾਲ ਕਰਨ ਨਾਲ ਸਿਮਰਨ ਵਿੱਚ ਹੁਣ ਮੌਜੂਦ ਸਭ ਕੁਝ ਬੈਕਅੱਪ ਫ਼ਾਈਲ ਦੀ ਸਮੱਗਰੀ ਨਾਲ ਬਦਲ ਜਾਵੇਗਾ।';

  @override
  String get restore => 'ਬਹਾਲ ਕਰੋ';

  @override
  String restoreSuccess(int count) {
    return '$count ਜਾਪ ਐਂਟਰੀਆਂ ਬਹਾਲ ਹੋਈਆਂ';
  }

  @override
  String get importInvalid => 'ਇਹ ਫ਼ਾਈਲ ਸਿਮਰਨ ਦਾ ਸਹੀ ਬੈਕਅੱਪ ਨਹੀਂ ਹੈ';

  @override
  String get exportShareText => 'ਮੇਰਾ ਸਿਮਰਨ ਬੈਕਅੱਪ';

  @override
  String get onb1Title => 'ਤੁਹਾਡੀ ਡਿਜੀਟਲ ਜਪ ਮਾਲਾ';

  @override
  String get onb1Body => 'ਹਰ ਨਾਮ ਜਪ ਨੂੰ ਗਿਣਨ ਦਾ ਇੱਕ ਸ਼ਾਂਤ ਤਰੀਕਾ।';

  @override
  String get onb2Title => 'ਸਾਧਨਾ ਨੂੰ ਆਦਤ ਬਣਾਓ';

  @override
  String get onb2Body => 'ਰੋਜ਼ਾਨਾ ਟੀਚਾ ਤੈਅ ਕਰੋ ਅਤੇ ਜਾਪ ਦੀ ਲੜੀ ਬਣਾਓ।';

  @override
  String get onb3Title => 'ਬਿਨਾਂ ਕਿਸੇ ਰੁਕਾਵਟ ਜਾਪ ਕਰੋ';

  @override
  String get onb3Body => 'ਸਾਫ਼, ਸ਼ਾਂਤ ਕਾਊਂਟਰ ਨਾਲ ਧਿਆਨ ਮੋਡ ਵਿੱਚ ਜਾਓ।';

  @override
  String get onbFeaturesTitle => 'ਸਭ ਕੁਝ ਤੁਹਾਡੇ ਹੱਥ ਵਿੱਚ';

  @override
  String get onbFeaturesBody => 'ਸ਼ੁਰੂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਜਾਣਨ ਯੋਗ ਕੁਝ ਗੱਲਾਂ।';

  @override
  String get soundsFeatureTitle => 'ਸ਼ਾਂਤ ਆਵਾਜ਼ਾਂ';

  @override
  String get soundsFeatureBody =>
      'ਧਿਆਨ ਦੌਰਾਨ, ਜਦੋਂ ਤੱਕ ਤੁਸੀਂ ਬੈਠੋ, ਹਲਕੀ ਪਿਛੋਕੜ ਧੁਨ ਚਲਾਓ।';

  @override
  String get startJap => 'ਜਪ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get blackout => 'ਹਨੇਰਾ';

  @override
  String get timer => 'ਟਾਈਮਰ';

  @override
  String get exitMeditation => 'ਧਿਆਨ ਮੋਡ ਤੋਂ ਬਾਹਰ ਆਓ';

  @override
  String get tapAnywhere => 'ਗਿਣਨ ਲਈ ਕਿਤੇ ਵੀ ਛੋਹੋ';

  @override
  String semanticCounter(int count, int total) {
    return 'ਜਾਪ ਕਾਊਂਟਰ। $total ਵਿੱਚੋਂ $count ਮਣਕੇ। ਇੱਕ ਗਿਣਨ ਲਈ ਦੋ ਵਾਰ ਛੋਹੋ।';
  }

  @override
  String get autoJaap => 'ਆਟੋ ਜਾਪ';

  @override
  String get autoJaapBody =>
      'ਐਪ ਇੱਕਸਾਰ ਰਫ਼ਤਾਰ ਨਾਲ ਤੁਹਾਡੇ ਲਈ ਗਿਣਦੀ ਹੈ, ਤਾਂ ਜੋ ਤੁਸੀਂ ਬਿਨਾਂ ਹੱਥ ਲਾਏ ਨਾਲ-ਨਾਲ ਜਾਪ ਕਰ ਸਕੋ।';

  @override
  String get autoJaapPace => 'ਰਫ਼ਤਾਰ';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds ਸਕਿੰਟ';
  }

  @override
  String get autoJaapStopAfter => 'ਕਦੋਂ ਰੁਕੇ';

  @override
  String get autoJaapStopMala => 'ਇੱਕ ਮਾਲਾ';

  @override
  String get autoJaapStopGoal => 'ਰੋਜ਼ਾਨਾ ਟੀਚਾ';

  @override
  String get autoJaapStopNever => 'ਨਾ ਰੁਕੇ';

  @override
  String get autoJaapStart => 'ਆਟੋ ਜਾਪ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get autoJaapStopAction => 'ਆਟੋ ਜਾਪ ਰੋਕੋ';

  @override
  String get chantPlay => 'ਚਲਾਓ';

  @override
  String get chantStop => 'ਰੋਕੋ';

  @override
  String get music => 'ਸੰਗੀਤ';

  @override
  String get chooseSound => 'ਆਵਾਜ਼ ਚੁਣੋ';

  @override
  String get musicRecord => 'ਰਿਕਾਰਡ ਕਰੋ';

  @override
  String get musicUpload => 'ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get musicYours => 'ਮੇਰਾ ਸੰਗੀਤ';

  @override
  String musicRecordingName(int n) {
    return 'ਰਿਕਾਰਡਿੰਗ $n';
  }

  @override
  String get musicNameTitle => 'ਰਿਕਾਰਡਿੰਗ ਨੂੰ ਨਾਮ ਦਿਓ';

  @override
  String get musicRemove => 'ਹਟਾਓ';

  @override
  String get musicAddFailed => 'ਇਹ ਫ਼ਾਈਲ ਨਹੀਂ ਜੋੜੀ ਜਾ ਸਕੀ';

  @override
  String get ownMusicTitle => 'ਆਪਣਾ ਸੰਗੀਤ ਲਿਆਓ';

  @override
  String get ownMusicBody =>
      'ਆਪਣਾ ਜਾਪ ਰਿਕਾਰਡ ਕਰੋ ਜਾਂ ਧਿਆਨ ਦੀ ਆਵਾਜ਼ ਅੱਪਲੋਡ ਕਰੋ; ਇਹ ਤੁਹਾਡੇ ਪੂਰੇ ਧਿਆਨ ਦੌਰਾਨ ਚੱਲੇਗੀ।';

  @override
  String counterCount(String count) {
    return 'ਗਿਣਤੀ: $count';
  }

  @override
  String counterMalas(String count) {
    return 'ਮਾਲਾਵਾਂ: $count';
  }

  @override
  String counterTotal(String count) {
    return 'ਕੁੱਲ: $count';
  }

  @override
  String get autoJaapTapToStop => 'ਆਟੋ ਜਾਪ ਚੱਲ ਰਿਹਾ ਹੈ · ਰੋਕਣ ਲਈ ਕਿਤੇ ਵੀ ਛੋਹੋ';

  @override
  String get hideMantra => 'ਮੰਤਰ ਲੁਕਾਓ';

  @override
  String get showMantra => 'ਮੰਤਰ ਵਿਖਾਓ';

  @override
  String get changeTheme => 'ਥੀਮ ਬਦਲੋ';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਦਿਨਾਂ ਦੀ ਲੜੀ',
      one: '1 ਦਿਨ ਦੀ ਲੜੀ',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'ਮੀਨੂ';

  @override
  String get chooseTheme => 'ਥੀਮ ਚੁਣੋ';

  @override
  String get themeAuto => 'ਆਟੋ';

  @override
  String get themeWhite => 'ਚਿੱਟਾ';

  @override
  String get themeBlack => 'ਕਾਲਾ';

  @override
  String get themePastelPink => 'ਹਲਕਾ ਗੁਲਾਬੀ';

  @override
  String get themeSpiritual => 'ਰੂਹਾਨੀ';

  @override
  String get themeSaffron => 'ਕੇਸਰੀ';

  @override
  String get themePeaceful => 'ਸ਼ਾਂਤ';

  @override
  String get themeTerracotta => 'ਟੈਰਾਕੋਟਾ';

  @override
  String get themeMeditative => 'ਧਿਆਨ';

  @override
  String get themeNature => 'ਕੁਦਰਤ';

  @override
  String get themeRoseGold => 'ਰੋਜ਼ ਗੋਲਡ';

  @override
  String get themeOcean => 'ਸਮੁੰਦਰ';

  @override
  String get themeLavender => 'ਲੈਵੈਂਡਰ';

  @override
  String get themeCharcoal => 'ਚਾਰਕੋਲ';

  @override
  String get counterBackground => 'ਕਾਊਂਟਰ ਦੀ ਪਿੱਠਭੂਮੀ';

  @override
  String get counterBackgroundBody =>
      'ਕਾਊਂਟਰ \'ਤੇ ਮੰਤਰ ਅਤੇ ਮਣਕਿਆਂ ਦੇ ਪਿੱਛੇ ਦਿਸਦੀ ਹੈ।';

  @override
  String get backgroundNone => 'ਕੋਈ ਨਹੀਂ';

  @override
  String get backgroundDawn => 'ਪ੍ਰਭਾਤ';

  @override
  String get backgroundDusk => 'ਸ਼ਾਮ';

  @override
  String get backgroundLotus => 'ਕਮਲ';

  @override
  String get backgroundForest => 'ਜੰਗਲ';

  @override
  String get backgroundOcean => 'ਸਮੁੰਦਰ';

  @override
  String get backgroundCosmos => 'ਬ੍ਰਹਿਮੰਡ';

  @override
  String get backgroundPhoto => 'ਮੇਰੀ ਫ਼ੋਟੋ';

  @override
  String get backgroundChoosePhoto => 'ਫ਼ੋਟੋ ਚੁਣੋ';

  @override
  String get backgroundChangePhoto => 'ਫ਼ੋਟੋ ਬਦਲੋ';

  @override
  String get backgroundRemovePhoto => 'ਫ਼ੋਟੋ ਹਟਾਓ';

  @override
  String get backgroundDim => 'ਪਿੱਠਭੂਮੀ ਮੱਧਮ ਕਰੋ';

  @override
  String get backgroundDimHint =>
      'ਜ਼ਿਆਦਾ ਮੱਧਮ ਕਰਨ ਨਾਲ ਮੰਤਰ ਪੜ੍ਹਨਾ ਸੌਖਾ ਰਹਿੰਦਾ ਹੈ।';

  @override
  String get addOwnMantra => 'ਆਪਣਾ ਮੰਤਰ ਜੋੜੋ';

  @override
  String get addOwnMantraHint =>
      'ਕੋਈ ਵੀ ਨਾਮ ਜਾਂ ਮੰਤਰ, ਕਿਸੇ ਵੀ ਲਿਪੀ ਵਿੱਚ, ਆਪਣੀ ਮਾਲਾ ਦੇ ਆਕਾਰ ਨਾਲ';

  @override
  String get legendLess => 'ਘੱਟ';

  @override
  String get legendMore => 'ਵੱਧ';

  @override
  String get allMantras => 'ਸਾਰੇ ਮੰਤਰ';

  @override
  String get previousPeriod => 'ਪਿਛਲਾ';

  @override
  String get nextPeriod => 'ਅਗਲਾ';

  @override
  String get showStatsFor => 'ਇਸ ਦੇ ਅੰਕੜੇ ਵਿਖਾਓ';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count ਜਾਪ · $malas ਮਾਲਾ';
  }

  @override
  String get dailyJaap => 'ਰੋਜ਼ਾਨਾ ਜਾਪ';

  @override
  String get mantraText => 'ਮੰਤਰ';

  @override
  String get mantraTextHint => 'ਜਿਵੇਂ राम ਜਾਂ ਓਮ ਨਮਃ ਸ਼ਿਵਾਯ';

  @override
  String get mantraRequired => 'ਕਿਰਪਾ ਕਰਕੇ ਮੰਤਰ ਲਿਖੋ';

  @override
  String get mantraDescription => 'ਵੇਰਵਾ';

  @override
  String get mantraDescriptionHint => 'ਅਰਥ, ਸਰੋਤ, ਜਾਂ ਆਪਣੇ ਲਈ ਕੋਈ ਨੋਟ';

  @override
  String get dictationStart => 'ਬੋਲ ਕੇ ਮੰਤਰ ਦਰਜ ਕਰੋ';

  @override
  String get dictationListening => 'ਸੁਣ ਰਹੇ ਹਾਂ… ਰੋਕਣ ਲਈ ਟੈਪ ਕਰੋ';

  @override
  String get dictationUnavailable =>
      'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਬੋਲ ਕੇ ਲਿਖਣ ਦੀ ਸਹੂਲਤ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get dictationOfflineUnavailable =>
      'ਇਸ ਫ਼ੋਨ \'ਤੇ ਇਸ ਭਾਸ਼ਾ ਲਈ ਔਫ਼ਲਾਈਨ ਆਵਾਜ਼ ਇਨਪੁੱਟ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਤੁਹਾਡੀ ਆਵਾਜ਼ ਕਦੇ ਡਿਵਾਈਸ ਤੋਂ ਬਾਹਰ ਨਹੀਂ ਜਾਂਦੀ, ਇਸ ਲਈ ਕਿਰਪਾ ਕਰਕੇ ਟਾਈਪ ਕਰੋ।';

  @override
  String get micPermissionDenied => 'ਇਸ ਲਈ ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਦੀ ਇਜਾਜ਼ਤ ਲੋੜੀਂਦੀ ਹੈ';

  @override
  String get fallingMantra => 'ਡਿੱਗਦਾ ਮੰਤਰ';

  @override
  String get stopFallingMantra => 'ਡਿੱਗਦਾ ਮੰਤਰ ਰੋਕੋ';

  @override
  String get malaStyle => 'ਮਾਲਾ ਦੀ ਸ਼ੈਲੀ';

  @override
  String get malaStyleBeads => 'ਮਣਕੇ';

  @override
  String get malaStyleRing => 'ਤਰੱਕੀ ਘੇਰਾ';

  @override
  String get sectionCounter => 'ਕਾਊਂਟਰ';

  @override
  String get showMantraOnCounter => 'ਕਾਊਂਟਰ \'ਤੇ ਮੰਤਰ ਵਿਖਾਓ';

  @override
  String get goalUnitMalas => 'ਮਾਲਾਵਾਂ';

  @override
  String get goalUnitJaap => 'ਜਾਪ';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਮਾਲਾਵਾਂ',
      one: '1 ਮਾਲਾ',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'ਰੋਜ਼ਾਨਾ ਮਾਲਾਵਾਂ';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas ਮਾਲਾਵਾਂ',
      one: '1 ਮਾਲਾ',
    );
    return 'ਹਰ ਰੋਜ਼ $_temp0 · $jaap ਜਾਪ';
  }

  @override
  String get onbMantraTitle => 'ਤੁਸੀਂ ਕਿਹੜਾ ਨਾਮ ਜਾਂ ਮੰਤਰ ਜਪਦੇ ਹੋ?';

  @override
  String get onbMantraBody =>
      'ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਇੱਕ ਚੁਣੋ। ਹੋਰ ਤੁਸੀਂ ਕਦੇ ਵੀ ਜੋੜ ਸਕਦੇ ਹੋ।';

  @override
  String get onbGoalTitle => 'ਤੁਹਾਡਾ ਰੋਜ਼ਾਨਾ ਟੀਚਾ';

  @override
  String get onbGoalBody =>
      'ਥੋੜ੍ਹੇ ਤੋਂ ਸ਼ੁਰੂ ਕਰੋ: ਵੱਡੀ ਗਿਣਤੀ ਨਾਲੋਂ ਰੋਜ਼ ਦਾ ਨੇਮ ਵੱਧ ਜ਼ਰੂਰੀ ਹੈ। ਤੁਸੀਂ ਇਸ ਨੂੰ ਕਦੇ ਵੀ ਬਦਲ ਸਕਦੇ ਹੋ।';

  @override
  String get shareProgress => 'ਮੇਰੀ ਤਰੱਕੀ ਸਾਂਝੀ ਕਰੋ';

  @override
  String get shareStreakLabel => 'ਦਿਨ ਲਗਾਤਾਰ';

  @override
  String shareCardText(int count) {
    return 'ਸਿਮਰਨ ਨਾਲ ਲਗਾਤਾਰ $count ਦਿਨ ਨਾਮ ਜਪ 🙏';
  }

  @override
  String get blackoutMode => 'ਹਨੇਰਾ ਮੋਡ';

  @override
  String get exitBlackout => 'ਹਨੇਰਾ ਮੋਡ ਤੋਂ ਬਾਹਰ';

  @override
  String get feedbackEmailSubject => 'ਸਿਮਰਨ ਬਾਰੇ ਸੁਝਾਅ';

  @override
  String get homeScreenWidget => 'ਹੋਮ ਸਕ੍ਰੀਨ ਵਿਜੇਟ';

  @override
  String get homeScreenWidgetBody =>
      'ਐਪ ਖੋਲ੍ਹੇ ਬਿਨਾਂ ਆਪਣੀ ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਅੱਜ ਦਾ ਜਾਪ ਅਤੇ ਆਪਣੀ ਲੜੀ ਵੇਖੋ।';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਕਿਸੇ ਖ਼ਾਲੀ ਥਾਂ ਨੂੰ ਦਬਾ ਕੇ ਰੱਖੋ, ਵਿਜੇਟ \'ਤੇ ਟੈਪ ਕਰੋ, ਫਿਰ ਸਿਮਰਨ ਲੱਭੋ।';

  @override
  String get homeScreenWidgetStepsIOS =>
      'ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਕਿਸੇ ਖ਼ਾਲੀ ਥਾਂ ਨੂੰ ਦਬਾ ਕੇ ਰੱਖੋ, ਕੋਨੇ ਵਿੱਚ + \'ਤੇ ਟੈਪ ਕਰੋ, ਸਿਮਰਨ ਲੱਭੋ, ਫਿਰ ਆਕਾਰ ਚੁਣ ਕੇ Add Widget \'ਤੇ ਟੈਪ ਕਰੋ।';

  @override
  String get addToHomeScreen => 'ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਜੋੜੋ';

  @override
  String get countWithButtons => 'ਬਟਨਾਂ ਨਾਲ ਗਿਣੋ';

  @override
  String get countWithButtonsHintAndroid =>
      'ਵਾਲੀਅਮ ਬਟਨ, ਹੈੱਡਸੈੱਟ ਬਟਨ ਜਾਂ Bluetooth ਕਲਿੱਕਰ ਨਾਲ ਇੱਕ ਮਣਕਾ ਗਿਣਿਆ ਜਾਂਦਾ ਹੈ';

  @override
  String get countWithButtonsHintIOS =>
      'Bluetooth ਕਲਿੱਕਰ ਜਾਂ ਕੀਬੋਰਡ ਨਾਲ ਇੱਕ ਮਣਕਾ ਗਿਣਿਆ ਜਾਂਦਾ ਹੈ। iPhone ਦੇ ਵਾਲੀਅਮ ਬਟਨ ਐਪਾਂ ਨਹੀਂ ਵਰਤ ਸਕਦੀਆਂ।';

  @override
  String get lockScreenCounter => 'ਲਾਕ ਸਕ੍ਰੀਨ ਕਾਊਂਟਰ';

  @override
  String get lockScreenCounterHint =>
      'ਤੁਹਾਡੀ ਲਾਕ ਸਕ੍ਰੀਨ ਅਤੇ Dynamic Island ਉੱਤੇ +1 ਬਟਨ। ਅਗਲੀ ਵਾਰ ਐਪ ਖੋਲ੍ਹਣ ਤੇ ਇਹ ਗਿਣਤੀ ਤੁਹਾਡੇ ਜਾਪ ਵਿੱਚ ਜੁੜ ਜਾਂਦੀ ਹੈ।';

  @override
  String get markerBead => 'ਨਿਸ਼ਾਨੀ ਮਣਕਾ';

  @override
  String get markerBeadHint =>
      'ਮਾਲਾ ਦੇ ਵਿਚਕਾਰ ਕਿਤੇ ਇੱਕ ਜ਼ੋਰਦਾਰ ਵਾਈਬ੍ਰੇਸ਼ਨ, ਤਾਂ ਜੋ ਅੱਖਾਂ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ ਪਤਾ ਰਹੇ ਕਿ ਤੁਸੀਂ ਕਿੱਥੇ ਹੋ';

  @override
  String markerBeadEvery(int count) {
    return 'ਹਰ $count \'ਤੇ';
  }

  @override
  String get markerBeadOff => 'ਬੰਦ';

  @override
  String get graceDays => 'ਛੋਟ ਦੇ ਦਿਨ';

  @override
  String get graceDaysHint =>
      'ਲਗਾਤਾਰ ਹਰ 7 ਦਿਨਾਂ \'ਤੇ ਇੱਕ ਛੋਟ ਦਾ ਦਿਨ ਮਿਲਦਾ ਹੈ (ਵੱਧ ਤੋਂ ਵੱਧ 2)। ਕੋਈ ਦਿਨ ਖੁੰਝਣ \'ਤੇ ਤੁਹਾਡੀ ਲੜੀ ਟੁੱਟਣ ਦੀ ਬਜਾਏ ਇੱਕ ਛੋਟ ਦਾ ਦਿਨ ਵਰਤਿਆ ਜਾਂਦਾ ਹੈ।';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਛੋਟ ਦੇ ਦਿਨ ਬਾਕੀ',
      one: '1 ਛੋਟ ਦਾ ਦਿਨ ਬਾਕੀ',
      zero: 'ਕੋਈ ਛੋਟ ਦਾ ਦਿਨ ਨਹੀਂ',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'ਛੋਟ ਦੇ ਦਿਨ ਨਾਲ ਪੂਰਾ ਹੋਇਆ';

  @override
  String milestoneLakh(int count) {
    return '$count ਲੱਖ ਜਾਪ';
  }

  @override
  String get milestoneSavaLakh => 'ਸਵਾ ਲੱਖ ਜਾਪ';

  @override
  String get milestoneCrore => '1 ਕਰੋੜ ਜਾਪ';

  @override
  String milestoneStreak(int days) {
    return '$days ਦਿਨਾਂ ਦੀ ਲੜੀ';
  }

  @override
  String milestoneReached(String milestone) {
    return 'ਤੁਸੀਂ $milestone ਤੱਕ ਪਹੁੰਚ ਗਏ ਹੋ। ਤੁਹਾਡੀ ਸਾਧਨਾ ਦਾ ਇੱਕ ਪੜਾਅ।';
  }

  @override
  String get milestones => 'ਪੜਾਅ';

  @override
  String milestoneNext(String milestone) {
    return 'ਅਗਲਾ: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ਬਾਕੀ';
  }

  @override
  String get milestoneAllReached => 'ਸਾਰੇ ਪੜਾਅ ਪੂਰੇ ਹੋਏ';

  @override
  String get yearInReview => 'ਸਾਲ ਦਾ ਲੇਖਾ-ਜੋਖਾ';

  @override
  String yearInReviewTitle(int year) {
    return 'ਜਾਪ ਵਿੱਚ ਤੁਹਾਡਾ $year';
  }

  @override
  String yearNoJaap(int year) {
    return '$year ਵਿੱਚ ਕੋਈ ਜਾਪ ਦਰਜ ਨਹੀਂ';
  }

  @override
  String get yearActiveDays => 'ਜਾਪ ਵਾਲੇ ਦਿਨ';

  @override
  String get yearLongestRun => 'ਸਭ ਤੋਂ ਲੰਬੀ ਲੜੀ';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਦਿਨ',
      one: '1 ਦਿਨ',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'ਸਭ ਤੋਂ ਵਧੀਆ ਦਿਨ';

  @override
  String get yearTopMantra => 'ਸਭ ਤੋਂ ਵੱਧ ਜਪਿਆ';

  @override
  String get yearByMonth => 'ਮਹੀਨੇਵਾਰ';

  @override
  String get yearMilestones => 'ਇਸ ਸਾਲ ਦੇ ਪੜਾਅ';

  @override
  String yearShareText(int year, String count) {
    return 'ਨਾਮ ਜਪ ਵਿੱਚ ਮੇਰਾ $year: $count ਜਾਪ';
  }

  @override
  String get previousYear => 'ਪਿਛਲਾ ਸਾਲ';

  @override
  String get nextYear => 'ਅਗਲਾ ਸਾਲ';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'ਇੰਦਰਾ ਏਕਾਦਸ਼ੀ',
      'papankusha': 'ਪਾਪਾਂਕੁਸ਼ਾ ਏਕਾਦਸ਼ੀ',
      'rama': 'ਰਮਾ ਏਕਾਦਸ਼ੀ',
      'devutthana': 'ਦੇਵਉਠਨੀ ਏਕਾਦਸ਼ੀ',
      'utpanna': 'ਉਤਪੰਨਾ ਏਕਾਦਸ਼ੀ',
      'mokshada': 'ਮੋਕਸ਼ਦਾ ਏਕਾਦਸ਼ੀ',
      'saphala': 'ਸਫਲਾ ਏਕਾਦਸ਼ੀ',
      'paushaPutrada': 'ਪੌਸ਼ ਪੁੱਤਰਦਾ ਏਕਾਦਸ਼ੀ',
      'shattila': 'ਸ਼ਟਤਿਲਾ ਏਕਾਦਸ਼ੀ',
      'jaya': 'ਜਯਾ ਏਕਾਦਸ਼ੀ',
      'vijaya': 'ਵਿਜਯਾ ਏਕਾਦਸ਼ੀ',
      'amalaki': 'ਆਮਲਕੀ ਏਕਾਦਸ਼ੀ',
      'papamochani': 'ਪਾਪਮੋਚਨੀ ਏਕਾਦਸ਼ੀ',
      'kamada': 'ਕਾਮਦਾ ਏਕਾਦਸ਼ੀ',
      'varuthini': 'ਵਰੂਥਿਨੀ ਏਕਾਦਸ਼ੀ',
      'mohini': 'ਮੋਹਿਨੀ ਏਕਾਦਸ਼ੀ',
      'apara': 'ਅਪਰਾ ਏਕਾਦਸ਼ੀ',
      'nirjala': 'ਨਿਰਜਲਾ ਏਕਾਦਸ਼ੀ',
      'yogini': 'ਯੋਗਿਨੀ ਏਕਾਦਸ਼ੀ',
      'devshayani': 'ਦੇਵਸ਼ਯਨੀ ਏਕਾਦਸ਼ੀ',
      'kamika': 'ਕਾਮਿਕਾ ਏਕਾਦਸ਼ੀ',
      'shravanaPutrada': 'ਸਾਵਣ ਪੁੱਤਰਦਾ ਏਕਾਦਸ਼ੀ',
      'aja': 'ਅਜਾ ਏਕਾਦਸ਼ੀ',
      'parsva': 'ਪਾਰਸ਼ਵ ਏਕਾਦਸ਼ੀ',
      'other': 'ਏਕਾਦਸ਼ੀ',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'ਸ਼ਾਰਦੀਯ ਨਵਰਾਤਰੀ',
      'chaitraNavratri': 'ਚੈਤਰ ਨਵਰਾਤਰੀ',
      'dussehra': 'ਦੁਸਹਿਰਾ',
      'diwali': 'ਦੀਵਾਲੀ',
      'kartikMonth': 'ਕੱਤਕ ਮਹੀਨਾ',
      'kartikPurnima': 'ਕੱਤਕ ਦੀ ਪੂਰਨਮਾਸ਼ੀ',
      'guruNanakJayanti': 'ਗੁਰੂ ਨਾਨਕ ਦੇਵ ਜੀ ਦਾ ਪ੍ਰਕਾਸ਼ ਪੁਰਬ',
      'makarSankranti': 'ਮਾਘੀ',
      'vasantPanchami': 'ਬਸੰਤ ਪੰਚਮੀ',
      'mahaShivaratri': 'ਮਹਾਸ਼ਿਵਰਾਤਰੀ',
      'holi': 'ਹੋਲੀ',
      'ramNavami': 'ਰਾਮ ਨੌਮੀ',
      'mahavirJayanti': 'ਮਹਾਵੀਰ ਜਯੰਤੀ',
      'hanumanJayanti': 'ਹਨੂਮਾਨ ਜਯੰਤੀ',
      'guruPurnima': 'ਗੁਰੂ ਪੂਰਨਿਮਾ',
      'shravanMonth': 'ਸਾਵਣ ਮਹੀਨਾ',
      'rakshaBandhan': 'ਰੱਖੜੀ',
      'krishnaJanmashtami': 'ਕ੍ਰਿਸ਼ਨ ਜਨਮ ਅਸ਼ਟਮੀ',
      'ganeshChaturthi': 'ਗਣੇਸ਼ ਚਤੁਰਥੀ',
      'other': 'ਤਿਉਹਾਰ',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return '$date ਤੋਂ ਸ਼ੁਰੂ';
  }

  @override
  String get upcomingObservances => 'ਏਕਾਦਸ਼ੀ ਅਤੇ ਤਿਉਹਾਰ';

  @override
  String get observanceToday => 'ਅੱਜ';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਦਿਨਾਂ ਵਿੱਚ',
      one: 'ਭਲਕੇ',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return '$name ਲਈ ਸੰਕਲਪ';
  }

  @override
  String get observanceTakeSankalp => 'ਸੰਕਲਪ ਲਓ';

  @override
  String observanceVaishnava(String date) {
    return 'ਵੈਸ਼ਣਵ (ISKCON) ਵਰਤ: $date';
  }

  @override
  String get observanceSourceNote =>
      'ਤਾਰੀਖ਼ਾਂ ਨਵੀਂ ਦਿੱਲੀ ਲਈ ਦ੍ਰਿਕ ਪੰਚਾਂਗ (Drik Panchang) ਅਨੁਸਾਰ ਹਨ। ਤੁਹਾਡੇ ਸਥਾਨਕ ਮੰਦਰ, ਗੁਰਦੁਆਰੇ ਜਾਂ ਪਰੰਪਰਾ ਵਿੱਚ ਇੱਕ ਦਿਨ ਦਾ ਫ਼ਰਕ ਹੋ ਸਕਦਾ ਹੈ।';

  @override
  String get observancesNone => 'ਅਗਲੇ ਕੁਝ ਹਫ਼ਤਿਆਂ ਵਿੱਚ ਕੁਝ ਨਹੀਂ';

  @override
  String get festivalReminders => 'ਏਕਾਦਸ਼ੀ ਅਤੇ ਤਿਉਹਾਰਾਂ ਦੀ ਯਾਦ-ਦਹਾਨੀ';

  @override
  String get festivalRemindersHint =>
      'ਏਕਾਦਸ਼ੀ ਅਤੇ ਤਿਉਹਾਰ ਵਾਲੇ ਦਿਨ ਸਵੇਰੇ 6 ਵਜੇ ਇੱਕ ਸੂਚਨਾ';

  @override
  String festivalNotificationBody(String name) {
    return 'ਅੱਜ $name ਹੈ। ਨਾਮ ਜਪਣ ਲਈ ਇੱਕ ਭਾਗਾਂ ਭਰਿਆ ਦਿਨ।';
  }

  @override
  String get sendDiagnostics => 'ਜਾਂਚ ਰਿਪੋਰਟ ਭੇਜੋ';

  @override
  String get diagnosticsExplain =>
      'ਇਹ ਰਿਪੋਰਟ ਕਿਸੇ ਸਮੱਸਿਆ ਨੂੰ ਠੀਕ ਕਰਨ ਵਿੱਚ ਮਦਦ ਕਰਦੀ ਹੈ। ਇਸ ਵਿੱਚ ਐਪ ਅਤੇ ਫ਼ੋਨ ਦੇ ਵਰਜਨ, ਤੁਹਾਡੀਆਂ ਸੈਟਿੰਗਾਂ ਅਤੇ ਐਪ ਦੀਆਂ ਗ਼ਲਤੀਆਂ ਦਾ ਰਿਕਾਰਡ ਹੁੰਦਾ ਹੈ। ਇਸ ਵਿੱਚ ਕੋਈ ਮੰਤਰ, ਗਿਣਤੀ ਜਾਂ ਨੋਟ ਨਹੀਂ ਹੁੰਦੇ। ਜਦੋਂ ਤੱਕ ਤੁਸੀਂ ਹੇਠਾਂ ਕੋਈ ਤਰੀਕਾ ਨਹੀਂ ਚੁਣਦੇ, ਕੁਝ ਵੀ ਨਹੀਂ ਭੇਜਿਆ ਜਾਂਦਾ।';

  @override
  String get diagnosticsEmail => 'ਈਮੇਲ ਕਰੋ';

  @override
  String get diagnosticsShare => 'ਫ਼ਾਈਲ ਵਜੋਂ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get diagnosticsEmailSubject => 'Smaran ਜਾਂਚ ਰਿਪੋਰਟ';

  @override
  String get diagnosticsNoMail =>
      'ਕੋਈ ਮੇਲ ਐਪ ਨਹੀਂ ਮਿਲੀ। ਇਸ ਨੂੰ ਫ਼ਾਈਲ ਵਜੋਂ ਸਾਂਝਾ ਕਰਕੇ ਵੇਖੋ।';
}
