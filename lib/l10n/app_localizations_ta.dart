// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppL10nTa extends AppL10n {
  AppL10nTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'நாம ஜப கவுன்ட்டர் – ஸ்மரண்';

  @override
  String get tagline =>
      'தினசரி நாம ஜபத்திற்கான உங்கள் அமைதியான டிஜிட்டல் ஜப மாலை';

  @override
  String get navJaap => 'ஜபம்';

  @override
  String get navProgress => 'முன்னேற்றம்';

  @override
  String get navStories => 'கதைகள்';

  @override
  String get navSettings => 'அமைப்புகள்';

  @override
  String get cancel => 'ரத்து';

  @override
  String get save => 'சேமி';

  @override
  String get delete => 'நீக்கு';

  @override
  String get edit => 'திருத்து';

  @override
  String get close => 'மூடு';

  @override
  String get next => 'அடுத்து';

  @override
  String get skip => 'தவிர்';

  @override
  String get retry => 'மீண்டும் முயல்க';

  @override
  String get custom => 'தனிப்பயன்';

  @override
  String get active => 'செயலில்';

  @override
  String get off => 'ஆஃப்';

  @override
  String get somethingWentWrong => 'ஏதோ தவறு நடந்துவிட்டது';

  @override
  String get tapToCount => 'எண்ணத் தொடவும்';

  @override
  String get todaysJaap => 'இன்றைய ஜபம்';

  @override
  String get undo => 'செயல்தவிர்';

  @override
  String get malaComplete => 'மாலை நிறைவு';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count மாலைகள் நிறைவு',
      one: '1 மாலை நிறைவு',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ஜபம்';
  }

  @override
  String get nothingToUndo => 'செயல்தவிர்க்க எதுவும் இல்லை';

  @override
  String get countRemoved => 'எண்ணிக்கை நீக்கப்பட்டது';

  @override
  String get resetCurrentMala => 'நடப்பு மாலையை மீட்டமை';

  @override
  String get resetCurrentMalaBody =>
      'இந்த மாலையில் எண்ணிய மணிகள் நீக்கப்படும். நிறைவான மாலைகள் அப்படியே இருக்கும்.';

  @override
  String get addCountManually => 'எண்ணிக்கையை நீங்களே சேர்க்கவும்';

  @override
  String get addCount => 'எண்ணிக்கை சேர்';

  @override
  String get numberOfJaap => 'ஜப எண்ணிக்கை';

  @override
  String get meditationMode => 'தியான முறை';

  @override
  String get startSession => 'அமர்வைத் தொடங்கு';

  @override
  String get endSession => 'அமர்வை முடி';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$minutes நிமிடத்தில் $jaap ஜபம்';
  }

  @override
  String get myMantras => 'என் மந்திரங்கள்';

  @override
  String get addMantra => 'மந்திரம் சேர்';

  @override
  String get editMantra => 'மந்திரத்தைத் திருத்து';

  @override
  String get malaSize => 'மாலை அளவு';

  @override
  String beads(int count) {
    return '$count மணிகள்';
  }

  @override
  String get malaSizeInvalid => 'மாலை அளவு 1 முதல் 10,000 வரை இருக்க வேண்டும்';

  @override
  String get deleteMantraTitle => 'மந்திரத்தை நீக்கவா?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" நீக்கப்படும். உங்கள் ஜப வரலாறு அப்படியே இருக்கும்.';
  }

  @override
  String get optional => 'விருப்பத்தேர்வு';

  @override
  String get mySadhana => 'என் சாதனை';

  @override
  String get todaysGoal => 'இன்றைய இலக்கு';

  @override
  String get complete => 'நிறைவு';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாள் தொடர்ச்சி',
      one: '1 நாள் தொடர்ச்சி',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'சிறந்த தொடர்ச்சி';

  @override
  String sankalpDays(int days) {
    return '$days நாள் சங்கல்பம்';
  }

  @override
  String dayXofY(int current, int total) {
    return 'நாள் $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள் நிறைவு',
      one: '1 நாள் நிறைவு',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return '$date அன்று தொடங்கியது';
  }

  @override
  String get createNewSankalp => 'புதிய சங்கல்பம் மேற்கொள்';

  @override
  String get createSankalp => 'சங்கல்பம் உருவாக்கு';

  @override
  String get chooseMantra => 'மந்திரத்தைத் தேர்ந்தெடு';

  @override
  String get dailyGoal => 'தினசரி இலக்கு';

  @override
  String get duration => 'காலம்';

  @override
  String durationDays(int days) {
    return '$days நாட்கள்';
  }

  @override
  String get reminder => 'நினைவூட்டல்';

  @override
  String get beginSadhana => 'சாதனையைத் தொடங்கு';

  @override
  String get noSankalpTitle => 'ஒரு சங்கல்பம் தொடங்குங்கள்';

  @override
  String get noSankalpBody =>
      'சங்கல்பம் என்பது, நீங்கள் தேர்ந்தெடுக்கும் நாட்கள் வரை தினமும் குறிப்பிட்ட எண்ணிக்கையில் ஜபம் செய்வதற்கான ஒரு விரதம்.';

  @override
  String get endSankalp => 'சங்கல்பத்தை முடி';

  @override
  String get endSankalpBody =>
      'உங்கள் முன்னேற்றம் சேமிக்கப்பட்டிருக்கும், ஆனால் சங்கல்பம் இனி செயலில் இருக்காது.';

  @override
  String jaapPerDay(int count) {
    return 'தினமும் $count ஜபம்';
  }

  @override
  String goalRemaining(int count) {
    return 'இன்னும் $count';
  }

  @override
  String get goalReached => 'தினசரி இலக்கு நிறைவு';

  @override
  String get setDailyGoal => 'தினசரி இலக்கை அமை';

  @override
  String get sadhanaGoals => 'சாதனை இலக்குகள்';

  @override
  String get progress => 'முன்னேற்றம்';

  @override
  String get filterDaily => 'நாள்';

  @override
  String get filterWeekly => 'வாரம்';

  @override
  String get filterMonthly => 'மாதம்';

  @override
  String get filterYearly => 'ஆண்டு';

  @override
  String get totalJaap => 'மொத்த ஜபம்';

  @override
  String get totalMalas => 'மொத்த மாலைகள்';

  @override
  String get weeklyJaap => 'வார ஜபம்';

  @override
  String get monthlyJaap => 'மாத ஜபம்';

  @override
  String get yearlyJaap => 'ஆண்டு ஜபம்';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString இலக்கு';
  }

  @override
  String get noJaapYet => 'இன்னும் ஜபம் எதுவும் பதிவாகவில்லை';

  @override
  String get noJaapYetBody => 'உங்கள் முதல் மணியே இந்தப் பயணத்தின் தொடக்கம்.';

  @override
  String get dailyAverage => 'தினசரி சராசரி';

  @override
  String get activeDays => 'செயலில் இருந்த நாட்கள்';

  @override
  String get perMantra => 'மந்திர வாரியாக';

  @override
  String get stories => 'கதைகள்';

  @override
  String get storiesSubtitle => 'சிந்தனைக்குச் சிறு கதைகள்';

  @override
  String get popular => 'பிரபலமானவை';

  @override
  String get read => 'படி';

  @override
  String get listen => 'கேள்';

  @override
  String get stopListening => 'நிறுத்து';

  @override
  String get textSize => 'எழுத்து அளவு';

  @override
  String get favorite => 'பிடித்தது';

  @override
  String get favorites => 'பிடித்தவை';

  @override
  String get share => 'பகிர்';

  @override
  String get all => 'அனைத்தும்';

  @override
  String minRead(int minutes) {
    return '$minutes நிமிட வாசிப்பு';
  }

  @override
  String get noFavoritesTitle => 'இன்னும் பிடித்தவை இல்லை';

  @override
  String get noFavoritesBody =>
      'ஒரு கதையில் உள்ள இதயக் குறியைத் தொட்டு அதை இங்கே வைத்துக்கொள்ளுங்கள்.';

  @override
  String get noStoriesFound => 'கதைகள் எதுவும் இல்லை';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get sectionJaap => 'ஜபம்';

  @override
  String get sectionReminders => 'நினைவூட்டல்கள்';

  @override
  String get sectionAppearance => 'தோற்றம்';

  @override
  String get sectionBackup => 'காப்புப் பிரதி';

  @override
  String get sectionSupport => 'உதவி';

  @override
  String get sectionAbout => 'அறிமுகம்';

  @override
  String get resetCounts => 'எண்ணிக்கையை மீட்டமை';

  @override
  String get jaapReminders => 'ஜப நினைவூட்டல்கள்';

  @override
  String get streakReminder => 'தொடர்ச்சி நினைவூட்டல்';

  @override
  String get goalReminder => 'இலக்கு நினைவூட்டல்';

  @override
  String get theme => 'தீம்';

  @override
  String get haptics => 'அதிர்வு';

  @override
  String get sound => 'ஒலி';

  @override
  String get language => 'மொழி';

  @override
  String get languageSystem => 'சாதன இயல்புநிலை';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'காப்புப் பிரதி & மீட்டெடுப்பு';

  @override
  String get exportMyData => 'என் தரவை ஏற்றுமதி செய்';

  @override
  String get rateApp => 'ஸ்மரண் செயலியை மதிப்பிடுங்கள்';

  @override
  String get shareApp => 'குடும்பத்தினரையும் நண்பர்களையும் அழையுங்கள்';

  @override
  String get feedback => 'கருத்து';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get terms => 'விதிமுறைகள்';

  @override
  String get aboutApp => 'ஸ்மரண் பற்றி';

  @override
  String version(String version) {
    return 'பதிப்பு $version';
  }

  @override
  String get resetTodayTitle => 'இன்றைய ஜபத்தை மீட்டமைக்கவா?';

  @override
  String get resetTodayBody =>
      'இன்று பதிவான ஜபம் அனைத்தும் நீக்கப்படும். இதைத் திரும்பப் பெற முடியாது.';

  @override
  String get resetAllTitle => 'அனைத்து ஜபத்தையும் மீட்டமைக்கவா?';

  @override
  String get resetAllBody =>
      'உங்கள் முழு ஜப வரலாறு, மாலைகள், தொடர்ச்சிகள் அனைத்தும் நிரந்தரமாக நீக்கப்படும். இதைத் திரும்பப் பெற முடியாது.';

  @override
  String get resetToday => 'இன்றையதை மீட்டமை';

  @override
  String get resetEverything => 'அனைத்தையும் மீட்டமை';

  @override
  String get resetDone => 'எண்ணிக்கை மீட்டமைக்கப்பட்டது';

  @override
  String get aboutBody =>
      'ஸ்மரண் உங்கள் தினசரி நாம ஜபத்திற்கான அமைதியான, தனிப்பட்ட இடம். நீங்கள் செய்யும் ஜபம் அனைத்தும் இந்தச் சாதனத்தில் மட்டுமே சேமிக்கப்படுகிறது.';

  @override
  String get madeWith => 'பக்தியுடன் உருவாக்கப்பட்டது';

  @override
  String get addReminder => 'நினைவூட்டல் சேர்';

  @override
  String get reminderTime => 'நேரம்';

  @override
  String get everyDay => 'தினமும்';

  @override
  String get noRemindersTitle => 'இன்னும் நினைவூட்டல்கள் இல்லை';

  @override
  String get noRemindersBody =>
      'தினமும் அதே நேரத்தில் ஒரு மென்மையான நினைவூட்டல், பயிற்சியைப் பழக்கமாக்கும்.';

  @override
  String get notificationsBlocked =>
      'ஸ்மரண் செயலிக்கு அறிவிப்புகள் முடக்கப்பட்டுள்ளன. சாதன அமைப்புகளில் அவற்றை இயக்கவும்.';

  @override
  String get reminderNotificationTitle => 'ஜபம் செய்யும் நேரம்';

  @override
  String get reminderNotificationBody =>
      'உங்கள் ஜப மாலையுடன் சில அமைதியான நிமிடங்கள் 🙏';

  @override
  String get streakNotificationTitle => 'உங்கள் தொடர்ச்சியைக் காத்திடுங்கள்';

  @override
  String get streakNotificationBody =>
      'இன்று நீங்கள் இன்னும் ஜபம் செய்யவில்லை. ஒரு மாலை போதும், தொடர்ச்சி தொடரும்.';

  @override
  String get goalNotificationTitle => 'இன்னும் கொஞ்சம்தான்';

  @override
  String get goalNotificationBody =>
      'இன்றைய இலக்கை முடித்து, இன்றைய சாதனையை நிறைவு செய்யுங்கள்.';

  @override
  String get createBackup => 'காப்புப் பிரதி உருவாக்கு';

  @override
  String get createBackupBody =>
      'உங்கள் மந்திரங்கள், ஜப வரலாறு, இலக்குகள், அமைப்புகள் அனைத்தையும் ஒரு JSON கோப்பாகச் சேமிக்கவும்.';

  @override
  String get restoreBackup => 'காப்புப் பிரதியிலிருந்து மீட்டெடு';

  @override
  String get restoreBackupBody =>
      'மீட்டெடுக்க ஒரு ஸ்மரண் காப்புப் பிரதிக் கோப்பைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get backupCreated => 'காப்புப் பிரதி உருவாக்கப்பட்டது';

  @override
  String get restoreWarningTitle => 'எல்லாத் தரவையும் மாற்றவா?';

  @override
  String get restoreWarningBody =>
      'மீட்டெடுத்தால், ஸ்மரணில் இப்போது உள்ள அனைத்தும் காப்புப் பிரதிக் கோப்பில் உள்ளவற்றால் மாற்றப்படும்.';

  @override
  String get restore => 'மீட்டெடு';

  @override
  String restoreSuccess(int count) {
    return '$count ஜபப் பதிவுகள் மீட்டெடுக்கப்பட்டன';
  }

  @override
  String get importInvalid => 'இது சரியான ஸ்மரண் காப்புப் பிரதிக் கோப்பு அல்ல';

  @override
  String get exportShareText => 'என் ஸ்மரண் காப்புப் பிரதி';

  @override
  String get onb1Title => 'உங்கள் டிஜிட்டல் ஜப மாலை';

  @override
  String get onb1Body => 'ஒவ்வொரு நாம ஜபத்தையும் எண்ண ஓர் அமைதியான வழி.';

  @override
  String get onb2Title => 'சாதனையைப் பழக்கமாக்குங்கள்';

  @override
  String get onb2Body =>
      'தினசரி இலக்கை அமைத்து, ஜபத் தொடர்ச்சியை வளர்த்திடுங்கள்.';

  @override
  String get onb3Title => 'கவனச்சிதறல் இல்லாமல் ஜபம் செய்யுங்கள்';

  @override
  String get onb3Body =>
      'தெளிவான, அமைதியான கவுன்ட்டருடன் தியான முறைக்குள் செல்லுங்கள்.';

  @override
  String get startJap => 'ஜபம் தொடங்கு';

  @override
  String get blackout => 'இருள்';

  @override
  String get timer => 'நேரம்';

  @override
  String get exitMeditation => 'தியான முறையிலிருந்து வெளியேறு';

  @override
  String get tapAnywhere => 'எண்ண எங்கு வேண்டுமானாலும் தொடவும்';

  @override
  String semanticCounter(int count, int total) {
    return 'ஜப கவுன்ட்டர். $total மணிகளில் $count. ஒன்றை எண்ண இருமுறை தட்டவும்.';
  }

  @override
  String get autoJaap => 'தானியங்கி ஜபம்';

  @override
  String get autoJaapBody =>
      'செயலி சீரான வேகத்தில் உங்களுக்காக எண்ணுகிறது; நீங்கள் கைகளைப் பயன்படுத்தாமலேயே உடன் ஜபிக்கலாம்.';

  @override
  String get autoJaapPace => 'வேகம்';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds வி.';
  }

  @override
  String get autoJaapStopAfter => 'எப்போது நிறுத்த';

  @override
  String get autoJaapStopMala => 'ஒரு மாலை';

  @override
  String get autoJaapStopGoal => 'தினசரி இலக்கு';

  @override
  String get autoJaapStopNever => 'நிறுத்த வேண்டாம்';

  @override
  String get autoJaapPlayChant => 'என் ஜபத்தை ஒலிக்கவும்';

  @override
  String get autoJaapPlayChantHint =>
      'ஒவ்வொரு மணியிலும் உங்கள் பதிவு ஒலிக்கும்';

  @override
  String get autoJaapStart => 'தானியங்கி ஜபம் தொடங்கு';

  @override
  String get autoJaapStopAction => 'தானியங்கி ஜபத்தை நிறுத்து';

  @override
  String get chantSound => 'இசை';

  @override
  String get chantPlay => 'இயக்கு';

  @override
  String get chantStop => 'நிறுத்து';

  @override
  String counterCount(String count) {
    return 'எண்ணிக்கை: $count';
  }

  @override
  String counterMalas(String count) {
    return 'மாலைகள்: $count';
  }

  @override
  String counterTotal(String count) {
    return 'மொத்தம்: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'தானியங்கி ஜபம் இயங்குகிறது · நிறுத்த எங்கு வேண்டுமானாலும் தொடவும்';

  @override
  String get hideMantra => 'மந்திரத்தை மறை';

  @override
  String get showMantra => 'மந்திரத்தைக் காட்டு';

  @override
  String get changeTheme => 'தீம் மாற்று';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாள் தொடர்ச்சி',
      one: '1 நாள் தொடர்ச்சி',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'மெனு';

  @override
  String get chooseTheme => 'தீம் தேர்ந்தெடு';

  @override
  String get themeAuto => 'தானியங்கு';

  @override
  String get themeWhite => 'வெள்ளை';

  @override
  String get themeBlack => 'கருப்பு';

  @override
  String get themePastelPink => 'மென் இளஞ்சிவப்பு';

  @override
  String get themeSpiritual => 'ஆன்மீகம்';

  @override
  String get themeSaffron => 'காவி';

  @override
  String get themePeaceful => 'அமைதி';

  @override
  String get themeTerracotta => 'சுடுமண்';

  @override
  String get themeMeditative => 'தியானம்';

  @override
  String get themeNature => 'இயற்கை';

  @override
  String get themeRoseGold => 'ரோஸ் கோல்ட்';

  @override
  String get themeOcean => 'கடல்';

  @override
  String get themeLavender => 'லாவெண்டர்';

  @override
  String get themeCharcoal => 'கரி';

  @override
  String get counterBackground => 'கவுன்ட்டர் பின்னணி';

  @override
  String get counterBackgroundBody =>
      'கவுன்ட்டரில் மந்திரத்திற்கும் மணிகளுக்கும் பின்னால் காட்டப்படும்.';

  @override
  String get backgroundNone => 'எதுவும் இல்லை';

  @override
  String get backgroundDawn => 'விடியல்';

  @override
  String get backgroundDusk => 'அந்தி';

  @override
  String get backgroundLotus => 'தாமரை';

  @override
  String get backgroundForest => 'காடு';

  @override
  String get backgroundOcean => 'கடல்';

  @override
  String get backgroundCosmos => 'பிரபஞ்சம்';

  @override
  String get backgroundPhoto => 'என் புகைப்படம்';

  @override
  String get backgroundChoosePhoto => 'புகைப்படம் தேர்ந்தெடு';

  @override
  String get backgroundChangePhoto => 'புகைப்படத்தை மாற்று';

  @override
  String get backgroundRemovePhoto => 'புகைப்படத்தை நீக்கு';

  @override
  String get backgroundDim => 'பின்னணியை மங்கலாக்கு';

  @override
  String get backgroundDimHint =>
      'அதிகம் மங்கலாக்கினால் மந்திரத்தைப் படிப்பது எளிது.';

  @override
  String get addOwnMantra => 'உங்கள் சொந்த மந்திரத்தைச் சேர்க்கவும்';

  @override
  String get addOwnMantraHint =>
      'எந்தப் பெயரும் மந்திரமும், எந்த எழுத்திலும், நீங்கள் விரும்பும் மாலை அளவுடன்';

  @override
  String get legendLess => 'குறைவு';

  @override
  String get legendMore => 'அதிகம்';

  @override
  String get allMantras => 'அனைத்து மந்திரங்கள்';

  @override
  String get previousPeriod => 'முந்தையது';

  @override
  String get nextPeriod => 'அடுத்தது';

  @override
  String get showStatsFor => 'இதற்கான புள்ளிவிவரங்கள்';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count ஜபம் · $malas மாலைகள்';
  }

  @override
  String get dailyJaap => 'தினசரி ஜபம்';

  @override
  String get mantraText => 'மந்திரம்';

  @override
  String get mantraTextHint => 'எ.கா. राम அல்லது ஓம் நமசிவாய';

  @override
  String get mantraRequired => 'மந்திரத்தை உள்ளிடவும்';

  @override
  String get mantraDescription => 'விளக்கம்';

  @override
  String get mantraDescriptionHint =>
      'பொருள், மூலம், அல்லது உங்களுக்கான ஒரு குறிப்பு';

  @override
  String get dictationStart => 'பேசி மந்திரத்தை உள்ளிடவும்';

  @override
  String get dictationListening => 'கேட்கிறது… நிறுத்தத் தட்டவும்';

  @override
  String get dictationUnavailable =>
      'இந்தச் சாதனத்தில் குரல் உள்ளீடு கிடைக்கவில்லை';

  @override
  String get dictationOfflineUnavailable =>
      'இந்த ஃபோனில் இந்த மொழிக்கு ஆஃப்லைன் குரல் உள்ளீடு கிடைக்கவில்லை. உங்கள் குரல் சாதனத்தை விட்டு வெளியே செல்லாது, எனவே தயவுசெய்து தட்டச்சு செய்யவும்.';

  @override
  String get micPermissionDenied => 'இதற்கு மைக்ரோஃபோன் அனுமதி தேவை';

  @override
  String get voiceNote => 'குரல் குறிப்பு';

  @override
  String get voiceNoteHint => 'நீங்கள் இதை ஜபிப்பதைப் பதிவு செய்யுங்கள்';

  @override
  String get voiceNoteRecord => 'பதிவு செய்';

  @override
  String get voiceNoteRecording => 'பதிவாகிறது… நிறுத்தத் தட்டவும்';

  @override
  String get voiceNotePlay => 'குரல் குறிப்பை இயக்கு';

  @override
  String get voiceNotePause => 'குரல் குறிப்பை இடைநிறுத்து';

  @override
  String get voiceNoteDelete => 'குரல் குறிப்பை நீக்கு';

  @override
  String get voiceNoteMissing =>
      'இந்தக் குரல் குறிப்பு இப்போது இந்த ஃபோனில் இல்லை';

  @override
  String get fallingMantra => 'பொழியும் மந்திரம்';

  @override
  String get stopFallingMantra => 'பொழியும் மந்திரத்தை நிறுத்து';

  @override
  String get malaStyle => 'மாலை வடிவம்';

  @override
  String get malaStyleBeads => 'மணிகள்';

  @override
  String get malaStyleRing => 'முன்னேற்ற வளையம்';

  @override
  String get sectionCounter => 'கவுன்ட்டர்';

  @override
  String get showMantraOnCounter => 'கவுன்ட்டரில் மந்திரத்தைக் காட்டு';

  @override
  String get goalUnitMalas => 'மாலைகள்';

  @override
  String get goalUnitJaap => 'ஜபம்';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count மாலைகள்',
      one: '1 மாலை',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'நாளொன்றுக்கு மாலைகள்';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas மாலைகள்',
      one: '1 மாலை',
    );
    return 'நாளொன்றுக்கு $_temp0 · $jaap ஜபம்';
  }

  @override
  String get onbMantraTitle => 'நீங்கள் எந்த மந்திரத்தை ஜபிக்கிறீர்கள்?';

  @override
  String get onbMantraBody =>
      'தொடங்க ஒன்றைத் தேர்ந்தெடுங்கள். எப்போது வேண்டுமானாலும் மேலும் சேர்க்கலாம்.';

  @override
  String get onbGoalTitle => 'உங்கள் தினசரி இலக்கு';

  @override
  String get onbGoalBody =>
      'சிறிதாகத் தொடங்குங்கள்: பெரிய எண்ணிக்கையை விட, தவறாத பயிற்சியே முக்கியம். இதை எப்போது வேண்டுமானாலும் மாற்றலாம்.';

  @override
  String get shareProgress => 'என் முன்னேற்றத்தைப் பகிர்';

  @override
  String get shareStreakLabel => 'நாள் தொடர்ச்சி';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள்',
      one: '1 நாள்',
    );
    return 'ஸ்மரணுடன் தொடர்ந்து $_temp0 நாம ஜபம் 🙏';
  }

  @override
  String get blackoutMode => 'இருள் முறை';

  @override
  String get exitBlackout => 'இருள் முறையிலிருந்து வெளியேறு';

  @override
  String get feedbackEmailSubject => 'ஸ்மரண் பற்றிய கருத்து';

  @override
  String get homeScreenWidget => 'முகப்புத் திரை விட்ஜெட்';

  @override
  String get homeScreenWidgetBody =>
      'செயலியைத் திறக்காமலேயே இன்றைய ஜபத்தையும் உங்கள் தொடர்ச்சியையும் முகப்புத் திரையில் பாருங்கள்.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'முகப்புத் திரையில் ஒரு காலி இடத்தை நீண்ட நேரம் அழுத்தி, விட்ஜெட்கள் என்பதைத் தட்டி, பிறகு ஸ்மரணைத் தேடுங்கள்.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'முகப்புத் திரையில் ஒரு காலி இடத்தை நீண்ட நேரம் அழுத்தி, மூலையில் உள்ள + ஐத் தட்டி, ஸ்மரணைத் தேடி, ஒரு அளவைத் தேர்ந்தெடுத்து, விட்ஜெட்டைச் சேர் என்பதைத் தட்டுங்கள்.';

  @override
  String get addToHomeScreen => 'முகப்புத் திரையில் சேர்';

  @override
  String get countWithButtons => 'பொத்தான்களால் எண்ணுதல்';

  @override
  String get countWithButtonsHintAndroid =>
      'ஒலியளவுப் பொத்தான்கள், ஹெட்செட் பொத்தான் அல்லது Bluetooth கிளிக்கர் மூலம் ஒரு மணி எண்ணப்படும்';

  @override
  String get countWithButtonsHintIOS =>
      'Bluetooth கிளிக்கர் அல்லது கீபோர்டு மூலம் ஒரு மணி எண்ணப்படும். iPhone ஒலியளவுப் பொத்தான்களைச் செயலிகள் பயன்படுத்த முடியாது.';

  @override
  String get lockScreenCounter => 'லாக் ஸ்கிரீன் கவுன்ட்டர்';

  @override
  String get lockScreenCounterHint =>
      'உங்கள் லாக் ஸ்கிரீன் மற்றும் Dynamic Island-இல் +1 பொத்தான். அடுத்த முறை செயலியைத் திறக்கும்போது இந்த எண்ணிக்கை உங்கள் ஜபத்தில் சேர்க்கப்படும்.';

  @override
  String get markerBead => 'அடையாள மணி';

  @override
  String get markerBeadHint =>
      'மாலையின் இடையில் ஒரு உறுதியான அதிர்வு; கண்களை மூடியிருந்தாலும் எங்கே இருக்கிறீர்கள் என்று உணரலாம்';

  @override
  String markerBeadEvery(int count) {
    return '$count மணிகளுக்கு ஒருமுறை';
  }

  @override
  String get markerBeadOff => 'ஆஃப்';

  @override
  String get graceDays => 'சலுகை நாட்கள்';

  @override
  String get graceDaysHint =>
      'தொடர்ந்து 7 நாட்கள் ஜபம் செய்யும் ஒவ்வொரு முறையும் ஒரு சலுகை நாள் கிடைக்கும் (அதிகபட்சம் 2). ஒரு நாள் தவறினால், உங்கள் தொடர்ச்சி முறியாமல் ஒரு சலுகை நாள் பயன்படுத்தப்படும்.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count சலுகை நாட்கள் கையிருப்பில்',
      one: '1 சலுகை நாள் கையிருப்பில்',
      zero: 'சலுகை நாட்கள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'சலுகை நாளால் ஈடுசெய்யப்பட்டது';

  @override
  String milestoneLakh(int count) {
    return '$count லட்சம் ஜபம்';
  }

  @override
  String get milestoneSavaLakh => 'ஒன்றே கால் லட்சம் ஜபம்';

  @override
  String get milestoneCrore => '1 கோடி ஜபம்';

  @override
  String milestoneStreak(int days) {
    return '$days நாள் தொடர்ச்சி';
  }

  @override
  String milestoneReached(String milestone) {
    return '$milestone எட்டப்பட்டது. உங்கள் சாதனையில் ஒரு மைல்கல்.';
  }

  @override
  String get milestones => 'மைல்கற்கள்';

  @override
  String milestoneNext(String milestone) {
    return 'அடுத்தது: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'இன்னும் $countString';
  }

  @override
  String get milestoneAllReached => 'எல்லா மைல்கற்களும் எட்டப்பட்டன';

  @override
  String get yearInReview => 'ஆண்டுச் சுருக்கம்';

  @override
  String yearInReviewTitle(int year) {
    return 'ஜபத்தில் உங்கள் $year';
  }

  @override
  String yearNoJaap(int year) {
    return '$year ஆம் ஆண்டில் ஜபம் எதுவும் பதிவாகவில்லை';
  }

  @override
  String get yearActiveDays => 'ஜபம் செய்த நாட்கள்';

  @override
  String get yearLongestRun => 'நீண்ட தொடர்ச்சி';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள்',
      one: '1 நாள்',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'சிறந்த நாள்';

  @override
  String get yearTopMantra => 'அதிகம் ஜபித்தது';

  @override
  String get yearByMonth => 'மாத வாரியாக';

  @override
  String get yearMilestones => 'இந்த ஆண்டின் மைல்கற்கள்';

  @override
  String yearShareText(int year, String count) {
    return 'நாம ஜபத்தில் என் $year: $count ஜபம்';
  }

  @override
  String get previousYear => 'முந்தைய ஆண்டு';

  @override
  String get nextYear => 'அடுத்த ஆண்டு';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'இந்திரா ஏகாதசி',
      'papankusha': 'பாபாங்குசா ஏகாதசி',
      'rama': 'ரமா ஏகாதசி',
      'devutthana': 'தேவ உத்தான ஏகாதசி',
      'utpanna': 'உத்பன்ன ஏகாதசி',
      'mokshada': 'மோக்ஷதா ஏகாதசி',
      'saphala': 'சபலா ஏகாதசி',
      'paushaPutrada': 'பௌஷ புத்ரதா ஏகாதசி',
      'shattila': 'ஷட்திலா ஏகாதசி',
      'jaya': 'ஜயா ஏகாதசி',
      'vijaya': 'விஜயா ஏகாதசி',
      'amalaki': 'ஆமலகி ஏகாதசி',
      'papamochani': 'பாபமோசனி ஏகாதசி',
      'kamada': 'காமதா ஏகாதசி',
      'varuthini': 'வரூதினி ஏகாதசி',
      'mohini': 'மோகினி ஏகாதசி',
      'apara': 'அபரா ஏகாதசி',
      'nirjala': 'நிர்ஜலா ஏகாதசி',
      'yogini': 'யோகினி ஏகாதசி',
      'devshayani': 'தேவசயனி ஏகாதசி',
      'kamika': 'காமிகா ஏகாதசி',
      'shravanaPutrada': 'ஸ்ராவண புத்ரதா ஏகாதசி',
      'aja': 'அஜா ஏகாதசி',
      'parsva': 'பார்ஸ்வ ஏகாதசி',
      'other': 'ஏகாதசி',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'சாரதா நவராத்திரி',
      'chaitraNavratri': 'வசந்த நவராத்திரி',
      'dussehra': 'விஜயதசமி',
      'diwali': 'தீபாவளி',
      'kartikMonth': 'கார்த்திக மாதம்',
      'kartikPurnima': 'கார்த்திக பௌர்ணமி',
      'guruNanakJayanti': 'குரு நானக் ஜெயந்தி',
      'makarSankranti': 'மகர சங்கராந்தி (பொங்கல்)',
      'vasantPanchami': 'வசந்த பஞ்சமி',
      'mahaShivaratri': 'மகா சிவராத்திரி',
      'holi': 'ஹோலி',
      'ramNavami': 'ஸ்ரீ ராம நவமி',
      'mahavirJayanti': 'மகாவீர் ஜெயந்தி',
      'hanumanJayanti': 'அனுமன் ஜெயந்தி',
      'guruPurnima': 'குரு பூர்ணிமா',
      'shravanMonth': 'ஸ்ராவண மாதம்',
      'rakshaBandhan': 'ரக்ஷா பந்தன்',
      'krishnaJanmashtami': 'கிருஷ்ண ஜெயந்தி',
      'ganeshChaturthi': 'விநாயகர் சதுர்த்தி',
      'other': 'பண்டிகை',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return '$date அன்று தொடங்கும்';
  }

  @override
  String get upcomingObservances => 'ஏகாதசியும் பண்டிகைகளும்';

  @override
  String get observanceToday => 'இன்று';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களில்',
      one: 'நாளை',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return '$name சங்கல்பம்';
  }

  @override
  String get observanceTakeSankalp => 'சங்கல்பம் மேற்கொள்';

  @override
  String observanceVaishnava(String date) {
    return 'வைஷ்ணவ (ISKCON) விரத நாள்: $date';
  }

  @override
  String get observanceSourceNote =>
      'தேதிகள் புது தில்லிக்கான Drik Panchang கணிப்பின்படி உள்ளன. உங்கள் உள்ளூர்க் கோயில் அல்லது சம்பிரதாயத்தில் ஒரு நாள் முன்பின் இருக்கலாம்.';

  @override
  String get observancesNone => 'அடுத்த சில வாரங்களில் எதுவும் இல்லை';

  @override
  String get festivalReminders => 'ஏகாதசி, பண்டிகை நினைவூட்டல்கள்';

  @override
  String get festivalRemindersHint =>
      'ஏகாதசி, பண்டிகை நாட்களில் காலை 6 மணிக்கு ஒரு குறிப்பு';

  @override
  String festivalNotificationBody(String name) {
    return 'இன்று $name. நாம ஜபத்திற்கு உகந்த புனித நாள்.';
  }

  @override
  String get sendDiagnostics => 'கண்டறிதல் அறிக்கையை அனுப்பு';

  @override
  String get diagnosticsExplain =>
      'இந்த அறிக்கை ஒரு சிக்கலைச் சரிசெய்ய உதவும். இதில் செயலி மற்றும் ஃபோன் பதிப்புகள், உங்கள் அமைப்புகள், செயலியின் பிழைப் பதிவு ஆகியவை உள்ளன. மந்திரங்கள், எண்ணிக்கைகள், குறிப்புகள் எதுவும் இதில் இல்லை. கீழே எப்படி அனுப்புவது என்று நீங்கள் தேர்வு செய்யும் வரை எதுவும் அனுப்பப்படாது.';

  @override
  String get diagnosticsEmail => 'மின்னஞ்சல் செய்';

  @override
  String get diagnosticsShare => 'கோப்பாகப் பகிர்';

  @override
  String get diagnosticsEmailSubject => 'Smaran கண்டறிதல் அறிக்கை';

  @override
  String get diagnosticsNoMail =>
      'மின்னஞ்சல் செயலி எதுவும் இல்லை. கோப்பாகப் பகிர்ந்து பாருங்கள்.';
}
