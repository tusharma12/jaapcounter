// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppL10nGu extends AppL10n {
  AppL10nGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'નામ જાપ કાઉન્ટર – સ્મરણ';

  @override
  String get tagline => 'તમારા રોજના નામ જાપ માટે શાંત ડિજિટલ માળા';

  @override
  String get navJaap => 'જાપ';

  @override
  String get navProgress => 'પ્રગતિ';

  @override
  String get navStories => 'કથાઓ';

  @override
  String get navSettings => 'સેટિંગ્સ';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get save => 'સાચવો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get edit => 'ફેરફાર કરો';

  @override
  String get close => 'બંધ કરો';

  @override
  String get next => 'આગળ';

  @override
  String get skip => 'છોડો';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get custom => 'પોતાની પસંદ';

  @override
  String get active => 'સક્રિય';

  @override
  String get off => 'બંધ';

  @override
  String get somethingWentWrong => 'કંઈક ખોટું થયું';

  @override
  String get tapToCount => 'ગણવા માટે સ્પર્શ કરો';

  @override
  String get todaysJaap => 'આજના જાપ';

  @override
  String get undo => 'પાછું લો';

  @override
  String get malaComplete => 'માળા પૂર્ણ';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count માળા પૂર્ણ',
      one: '1 માળા પૂર્ણ',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString જાપ';
  }

  @override
  String get resetCurrentMala => 'ચાલુ માળા રીસેટ કરો';

  @override
  String get resetCurrentMalaBody =>
      'આ માળામાં ગણેલા મણકા દૂર થશે. પૂર્ણ થયેલી માળાઓ સચવાયેલી રહેશે.';

  @override
  String get addCountManually => 'ગણતરી જાતે ઉમેરો';

  @override
  String get addCount => 'ગણતરી ઉમેરો';

  @override
  String get numberOfJaap => 'જાપની સંખ્યા';

  @override
  String get meditationMode => 'ધ્યાન મોડ';

  @override
  String get startSession => 'સત્ર શરૂ કરો';

  @override
  String get endSession => 'સત્ર પૂરું કરો';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$minutes મિનિટમાં $jaap જાપ';
  }

  @override
  String get myMantras => 'મારા મંત્રો';

  @override
  String get addMantra => 'મંત્ર ઉમેરો';

  @override
  String get editMantra => 'મંત્રમાં ફેરફાર કરો';

  @override
  String get malaSize => 'માળાનું માપ';

  @override
  String beads(int count) {
    return '$count મણકા';
  }

  @override
  String get malaSizeInvalid => 'માળાનું માપ 1 થી 10,000 ની વચ્ચે હોવું જોઈએ';

  @override
  String get deleteMantraTitle => 'મંત્ર કાઢી નાખવો છે?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" દૂર થશે. તમારો જાપનો ઇતિહાસ સચવાયેલો રહેશે.';
  }

  @override
  String get optional => 'વૈકલ્પિક';

  @override
  String get mySadhana => 'મારી સાધના';

  @override
  String get todaysGoal => 'આજનું લક્ષ્ય';

  @override
  String get complete => 'પૂર્ણ';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'સળંગ $count દિવસ',
      one: 'સળંગ 1 દિવસ',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'સૌથી લાંબું સાતત્ય';

  @override
  String sankalpDays(int days) {
    return '$days દિવસનો સંકલ્પ';
  }

  @override
  String dayXofY(int current, int total) {
    return 'દિવસ $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ પૂર્ણ',
      one: '1 દિવસ પૂર્ણ',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return '$date થી શરૂ';
  }

  @override
  String get createNewSankalp => 'નવો સંકલ્પ લો';

  @override
  String get createSankalp => 'સંકલ્પ લો';

  @override
  String get chooseMantra => 'મંત્ર પસંદ કરો';

  @override
  String get dailyGoal => 'રોજનું લક્ષ્ય';

  @override
  String get duration => 'સમયગાળો';

  @override
  String durationDays(int days) {
    return '$days દિવસ';
  }

  @override
  String get reminder => 'રિમાઇન્ડર';

  @override
  String get beginSadhana => 'સાધના શરૂ કરો';

  @override
  String get noSankalpTitle => 'સંકલ્પ લો';

  @override
  String get noSankalpBody =>
      'સંકલ્પ એ એક વ્રત છે - પસંદ કરેલા દિવસો સુધી રોજ નક્કી કરેલી સંખ્યામાં જાપ કરવાનું.';

  @override
  String get endSankalp => 'સંકલ્પ પૂરો કરો';

  @override
  String get endSankalpBody =>
      'તમારી પ્રગતિ સચવાયેલી રહેશે, પણ સંકલ્પ સક્રિય નહીં રહે.';

  @override
  String jaapPerDay(int count) {
    return 'રોજ $count જાપ';
  }

  @override
  String goalRemaining(int count) {
    return '$count બાકી';
  }

  @override
  String get goalReached => 'આજનું લક્ષ્ય પૂર્ણ';

  @override
  String get goalReachedAutoBody =>
      'ઓટો જાપ થોભેલો છે. ચાલુ રાખવો કે અહીં રોકવો?';

  @override
  String get keepGoing => 'ચાલુ રાખો';

  @override
  String get setDailyGoal => 'રોજનું લક્ષ્ય નક્કી કરો';

  @override
  String get sadhanaGoals => 'સાધનાનાં લક્ષ્યો';

  @override
  String get progress => 'પ્રગતિ';

  @override
  String get filterDaily => 'દૈનિક';

  @override
  String get filterWeekly => 'સાપ્તાહિક';

  @override
  String get filterMonthly => 'માસિક';

  @override
  String get filterYearly => 'વાર્ષિક';

  @override
  String get totalJaap => 'કુલ જાપ';

  @override
  String get totalMalas => 'કુલ માળા';

  @override
  String get weeklyJaap => 'સાપ્તાહિક જાપ';

  @override
  String get monthlyJaap => 'માસિક જાપ';

  @override
  String get yearlyJaap => 'વાર્ષિક જાપ';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString લક્ષ્ય';
  }

  @override
  String get noJaapYet => 'હજુ કોઈ જાપ નોંધાયા નથી';

  @override
  String get noJaapYetBody => 'પહેલો મણકો જ યાત્રાની શરૂઆત છે.';

  @override
  String get dailyAverage => 'દૈનિક સરેરાશ';

  @override
  String get activeDays => 'સક્રિય દિવસો';

  @override
  String get perMantra => 'મંત્ર પ્રમાણે';

  @override
  String get stories => 'કથાઓ';

  @override
  String get storiesSubtitle => 'મનન માટે ટૂંકી કથાઓ';

  @override
  String get popular => 'લોકપ્રિય';

  @override
  String get read => 'વાંચો';

  @override
  String get listen => 'સાંભળો';

  @override
  String get stopListening => 'રોકો';

  @override
  String get textSize => 'અક્ષરનું કદ';

  @override
  String get favorite => 'મનપસંદ';

  @override
  String get favorites => 'મનપસંદ';

  @override
  String get share => 'શેર કરો';

  @override
  String get all => 'બધા';

  @override
  String minRead(int minutes) {
    return '$minutes મિનિટનું વાંચન';
  }

  @override
  String get noFavoritesTitle => 'હજુ કોઈ મનપસંદ નથી';

  @override
  String get noFavoritesBody =>
      'કોઈ કથા પર હૃદયના ચિહ્નને સ્પર્શ કરીને તેને અહીં રાખો.';

  @override
  String get noStoriesFound => 'કોઈ કથા મળી નથી';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get sectionJaap => 'જાપ';

  @override
  String get sectionReminders => 'રિમાઇન્ડર';

  @override
  String get sectionAppearance => 'દેખાવ';

  @override
  String get sectionBackup => 'બેકઅપ';

  @override
  String get sectionSupport => 'સહાય';

  @override
  String get sectionAbout => 'પરિચય';

  @override
  String get resetCounts => 'ગણતરી રીસેટ કરો';

  @override
  String get jaapReminders => 'જાપ રિમાઇન્ડર';

  @override
  String get streakReminder => 'સાતત્ય રિમાઇન્ડર';

  @override
  String get goalReminder => 'લક્ષ્ય રિમાઇન્ડર';

  @override
  String get theme => 'થીમ';

  @override
  String get haptics => 'કંપન';

  @override
  String get sound => 'અવાજ';

  @override
  String get language => 'ભાષા';

  @override
  String get languageSystem => 'સિસ્ટમ મુજબ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'બેકઅપ અને પુનઃસ્થાપન';

  @override
  String get exportMyData => 'મારો ડેટા નિકાસ કરો';

  @override
  String get rateApp => 'સ્મરણને રેટ કરો';

  @override
  String get shareApp => 'પરિવાર અને મિત્રોને આમંત્રણ આપો';

  @override
  String get feedback => 'પ્રતિભાવ';

  @override
  String get privacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get terms => 'શરતો';

  @override
  String get aboutApp => 'સ્મરણ વિશે';

  @override
  String version(String version) {
    return 'સંસ્કરણ $version';
  }

  @override
  String get resetTodayTitle => 'આજના જાપ રીસેટ કરવા છે?';

  @override
  String get resetTodayBody =>
      'આજે નોંધાયેલા બધા જાપ દૂર થશે. આ પાછું લઈ શકાશે નહીં.';

  @override
  String get resetAllTitle => 'બધા જાપ રીસેટ કરવા છે?';

  @override
  String get resetAllBody =>
      'તમારો આખો જાપ ઇતિહાસ, માળાઓ અને સાતત્ય કાયમ માટે ભૂંસાઈ જશે. આ પાછું લઈ શકાશે નહીં.';

  @override
  String get resetToday => 'આજનું રીસેટ કરો';

  @override
  String get resetEverything => 'બધું રીસેટ કરો';

  @override
  String get resetDone => 'ગણતરી રીસેટ થઈ ગઈ';

  @override
  String get aboutBody =>
      'સ્મરણ તમારા રોજના નામ જાપ માટે એક શાંત, ખાનગી સ્થાન છે. તમે જે પણ જાપ કરો છો તે ફક્ત આ ઉપકરણમાં જ સચવાય છે.';

  @override
  String get madeWith => 'શ્રદ્ધાથી બનાવેલું';

  @override
  String get addReminder => 'રિમાઇન્ડર ઉમેરો';

  @override
  String get reminderTime => 'સમય';

  @override
  String get everyDay => 'દરરોજ';

  @override
  String get noRemindersTitle => 'હજુ કોઈ રિમાઇન્ડર નથી';

  @override
  String get noRemindersBody =>
      'રોજ એક જ સમયે મળતી હળવી યાદ સાધનાને ટેવ બનાવી દે છે.';

  @override
  String get notificationsBlocked =>
      'સ્મરણ માટે સૂચનાઓ બંધ છે. તમારા ઉપકરણની સેટિંગ્સમાં તેને ચાલુ કરો.';

  @override
  String get reminderNotificationTitle => 'જાપનો સમય થયો';

  @override
  String get reminderNotificationBody => 'માળા સાથે થોડી શાંત પળો 🙏';

  @override
  String get streakNotificationTitle => 'તમારું સાતત્ય જાળવી રાખો';

  @override
  String get streakNotificationBody =>
      'આજે તમે હજુ જાપ નથી કર્યા. એક માળા પણ સાતત્ય જાળવી રાખશે.';

  @override
  String get goalNotificationTitle => 'બસ થોડું બાકી';

  @override
  String get goalNotificationBody =>
      'આજનું લક્ષ્ય પૂરું કરો અને આજની સાધના પૂર્ણ કરો.';

  @override
  String get createBackup => 'બેકઅપ બનાવો';

  @override
  String get createBackupBody =>
      'તમારા બધા મંત્રો, જાપ ઇતિહાસ, લક્ષ્યો અને સેટિંગ્સની JSON ફાઇલ સાચવો.';

  @override
  String get restoreBackup => 'બેકઅપમાંથી પુનઃસ્થાપિત કરો';

  @override
  String get restoreBackupBody =>
      'પુનઃસ્થાપિત કરવા માટે સ્મરણની બેકઅપ ફાઇલ પસંદ કરો.';

  @override
  String get backupCreated => 'બેકઅપ બની ગયો';

  @override
  String get restoreWarningTitle => 'બધો ડેટા બદલવો છે?';

  @override
  String get restoreWarningBody =>
      'પુનઃસ્થાપન કરવાથી સ્મરણમાં હાલનો બધો ડેટા બેકઅપ ફાઇલના ડેટાથી બદલાઈ જશે.';

  @override
  String get restore => 'પુનઃસ્થાપિત કરો';

  @override
  String restoreSuccess(int count) {
    return '$count જાપ નોંધો પુનઃસ્થાપિત થઈ';
  }

  @override
  String get importInvalid => 'આ ફાઇલ સ્મરણનો માન્ય બેકઅપ નથી';

  @override
  String get exportShareText => 'મારો સ્મરણ બેકઅપ';

  @override
  String get onb1Title => 'તમારી ડિજિટલ જાપ માળા';

  @override
  String get onb1Body => 'દરેક નામ જાપ ગણવાની એક શાંત રીત.';

  @override
  String get onb2Title => 'સાધનાને ટેવ બનાવો';

  @override
  String get onb2Body => 'રોજનું લક્ષ્ય નક્કી કરો અને જાપનું સાતત્ય કેળવો.';

  @override
  String get onb3Title => 'વિક્ષેપ વિના જાપ કરો';

  @override
  String get onb3Body => 'સ્વચ્છ, શાંત કાઉન્ટર સાથે ધ્યાન મોડમાં પ્રવેશ કરો.';

  @override
  String get onbLookTitle => 'તેને તમારું બનાવો';

  @override
  String get onbLookBody =>
      'કાઉન્ટર કેવું દેખાય અને કેવું સંભળાય તે પસંદ કરો. આ ગમે ત્યારે સેટિંગ્સમાં બદલી શકાય છે.';

  @override
  String get onbFeaturesTitle => 'બધું તમારા હાથમાં';

  @override
  String get onbFeaturesBody => 'શરૂ કરતા પહેલાં જાણવા જેવી કેટલીક વાતો.';

  @override
  String get soundsFeatureTitle => 'શાંત અવાજો';

  @override
  String get soundsFeatureBody =>
      'ધ્યાન દરમિયાન, તમે બેસો ત્યાં સુધી હળવી પૃષ્ઠભૂમિ ધૂન વગાડો.';

  @override
  String get startJap => 'જાપ શરૂ કરો';

  @override
  String get blackout => 'અંધકાર';

  @override
  String get timer => 'ટાઇમર';

  @override
  String get exitMeditation => 'ધ્યાન મોડમાંથી બહાર આવો';

  @override
  String get tapAnywhere => 'ગણવા માટે ગમે ત્યાં સ્પર્શ કરો';

  @override
  String semanticCounter(int count, int total) {
    return 'જાપ કાઉન્ટર. $total માંથી $count મણકા. એક ગણવા માટે બે વાર સ્પર્શ કરો.';
  }

  @override
  String get autoJaap => 'ઓટો જાપ';

  @override
  String get autoJaapBody =>
      'એપ સ્થિર ગતિએ તમારા માટે ગણતરી કરે છે, જેથી તમે હાથ લગાડ્યા વિના સાથે જાપ કરી શકો.';

  @override
  String get autoJaapPace => 'ગતિ';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds સે.';
  }

  @override
  String get autoJaapStopAfter => 'ક્યારે રોકાવું';

  @override
  String get autoJaapStopMala => 'એક માળા';

  @override
  String get autoJaapStopGoal => 'રોજનું લક્ષ્ય';

  @override
  String get autoJaapStopNever => 'રોકાવું નહીં';

  @override
  String get autoJaapStart => 'ઓટો જાપ શરૂ કરો';

  @override
  String get autoJaapStopAction => 'ઓટો જાપ રોકો';

  @override
  String get chantPlay => 'ચલાવો';

  @override
  String get chantStop => 'રોકો';

  @override
  String get music => 'સંગીત';

  @override
  String get playMusic => 'સંગીત ચલાવો';

  @override
  String get stopMusic => 'સંગીત રોકો';

  @override
  String get chooseSound => 'અવાજ પસંદ કરો';

  @override
  String get musicRecord => 'રેકોર્ડ કરો';

  @override
  String get musicUpload => 'અપલોડ કરો';

  @override
  String get musicYours => 'મારું સંગીત';

  @override
  String musicRecordingName(int n) {
    return 'રેકોર્ડિંગ $n';
  }

  @override
  String get musicNameTitle => 'રેકોર્ડિંગને નામ આપો';

  @override
  String get musicRemove => 'દૂર કરો';

  @override
  String get musicAddFailed => 'આ ફાઇલ ઉમેરી શકાઈ નથી';

  @override
  String get ownMusicTitle => 'તમારું પોતાનું સંગીત લાવો';

  @override
  String get ownMusicBody =>
      'તમારો જાપ રેકોર્ડ કરો અથવા ધ્યાનનો અવાજ અપલોડ કરો; તે તમારા આખા ધ્યાન દરમિયાન વાગશે.';

  @override
  String counterCount(String count) {
    return 'ગણતરી: $count';
  }

  @override
  String counterMalas(String count) {
    return 'માળા: $count';
  }

  @override
  String counterTotal(String count) {
    return 'કુલ: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'ઓટો જાપ ચાલુ · રોકવા માટે ગમે ત્યાં સ્પર્શ કરો';

  @override
  String get hideMantra => 'મંત્ર છુપાવો';

  @override
  String get showMantra => 'મંત્ર બતાવો';

  @override
  String get changeTheme => 'થીમ બદલો';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'સળંગ $count દિવસ',
      one: 'સળંગ 1 દિવસ',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'મેનુ';

  @override
  String get chooseTheme => 'થીમ પસંદ કરો';

  @override
  String get themeAuto => 'ઓટો';

  @override
  String get themeWhite => 'સફેદ';

  @override
  String get themeBlack => 'કાળો';

  @override
  String get themePastelPink => 'આછો ગુલાબી';

  @override
  String get themeSpiritual => 'આધ્યાત્મિક';

  @override
  String get themeSaffron => 'કેસરી';

  @override
  String get themePeaceful => 'શાંત';

  @override
  String get themeTerracotta => 'ટેરાકોટા';

  @override
  String get themeMeditative => 'ધ્યાન';

  @override
  String get themeNature => 'પ્રકૃતિ';

  @override
  String get themeRoseGold => 'રોઝ ગોલ્ડ';

  @override
  String get themeOcean => 'સાગર';

  @override
  String get themeLavender => 'લવેન્ડર';

  @override
  String get themeCharcoal => 'ચારકોલ';

  @override
  String get counterBackground => 'કાઉન્ટરની પૃષ્ઠભૂમિ';

  @override
  String get counterBackgroundBody =>
      'કાઉન્ટર પર મંત્ર અને મણકાની પાછળ દેખાય છે.';

  @override
  String get backgroundNone => 'કોઈ નહીં';

  @override
  String get backgroundDawn => 'પરોઢ';

  @override
  String get backgroundDusk => 'સંધ્યા';

  @override
  String get backgroundLotus => 'કમળ';

  @override
  String get backgroundForest => 'વન';

  @override
  String get backgroundOcean => 'સાગર';

  @override
  String get backgroundCosmos => 'બ્રહ્માંડ';

  @override
  String get backgroundPhoto => 'મારો ફોટો';

  @override
  String get backgroundChoosePhoto => 'ફોટો પસંદ કરો';

  @override
  String get backgroundChangePhoto => 'ફોટો બદલો';

  @override
  String get backgroundRemovePhoto => 'ફોટો દૂર કરો';

  @override
  String get backgroundDim => 'પૃષ્ઠભૂમિ ઝાંખી કરો';

  @override
  String get backgroundDimHint => 'વધુ ઝાંખું કરવાથી મંત્ર વાંચવો સરળ રહે છે.';

  @override
  String get addOwnMantra => 'તમારો પોતાનો મંત્ર ઉમેરો';

  @override
  String get addOwnMantraHint =>
      'કોઈ પણ નામ કે મંત્ર, કોઈ પણ લિપિમાં, તમારી પોતાની માળાના માપ સાથે';

  @override
  String get legendLess => 'ઓછું';

  @override
  String get legendMore => 'વધુ';

  @override
  String get allMantras => 'બધા મંત્રો';

  @override
  String get previousPeriod => 'પાછલું';

  @override
  String get nextPeriod => 'આગલું';

  @override
  String get showStatsFor => 'આના આંકડા બતાવો';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count જાપ · $malas માળા';
  }

  @override
  String get dailyJaap => 'દૈનિક જાપ';

  @override
  String get mantraText => 'મંત્ર';

  @override
  String get mantraTextHint => 'દા.ત. राम અથવા ૐ નમઃ શિવાય';

  @override
  String get mantraRequired => 'કૃપા કરીને મંત્ર લખો';

  @override
  String get mantraDescription => 'વર્ણન';

  @override
  String get mantraDescriptionHint => 'અર્થ, સ્રોત, અથવા તમારા માટે કોઈ નોંધ';

  @override
  String get dictationStart => 'બોલીને મંત્ર દાખલ કરો';

  @override
  String get dictationListening => 'સાંભળી રહ્યા છીએ… રોકવા માટે ટૅપ કરો';

  @override
  String get dictationUnavailable =>
      'આ ઉપકરણ પર બોલીને લખવાની સુવિધા ઉપલબ્ધ નથી';

  @override
  String get dictationOfflineUnavailable =>
      'આ ફોન પર આ ભાષા માટે ઑફલાઇન વૉઇસ ઇનપુટ ઉપલબ્ધ નથી. તમારો અવાજ ક્યારેય ઉપકરણની બહાર જતો નથી, તેથી કૃપા કરીને ટાઇપ કરો.';

  @override
  String get micPermissionDenied => 'આ માટે માઇક્રોફોનની પરવાનગી જરૂરી છે';

  @override
  String get fallingMantra => 'વરસતો મંત્ર';

  @override
  String get stopFallingMantra => 'વરસતો મંત્ર બંધ કરો';

  @override
  String get malaStyle => 'માળાની શૈલી';

  @override
  String get malaStyleBeads => 'મણકા';

  @override
  String get malaStyleRing => 'પ્રગતિ વર્તુળ';

  @override
  String get sectionCounter => 'કાઉન્ટર';

  @override
  String get showMantraOnCounter => 'કાઉન્ટર પર મંત્ર બતાવો';

  @override
  String get goalUnitMalas => 'માળા';

  @override
  String get goalUnitJaap => 'જાપ';

  @override
  String malaCount(int count) {
    return '$count માળા';
  }

  @override
  String get malasPerDay => 'રોજની માળા';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    return 'રોજ $malas માળા · $jaap જાપ';
  }

  @override
  String get onbMantraTitle => 'તમે કયો મંત્ર જપો છો?';

  @override
  String get onbMantraBody =>
      'શરૂ કરવા માટે એક પસંદ કરો. વધુ મંત્રો ગમે ત્યારે ઉમેરી શકો છો.';

  @override
  String get onbGoalTitle => 'તમારું રોજનું લક્ષ્ય';

  @override
  String get onbGoalBody =>
      'નાનાથી શરૂઆત કરો: મોટી સંખ્યા કરતાં રોજનો નિયમ વધુ મહત્ત્વનો છે. તેને ગમે ત્યારે બદલી શકો છો.';

  @override
  String get shareProgress => 'મારી પ્રગતિ શેર કરો';

  @override
  String get shareStreakLabel => 'દિવસ સળંગ';

  @override
  String shareCardText(int count) {
    return 'સ્મરણ સાથે સળંગ $count દિવસ નામ જાપ 🙏';
  }

  @override
  String get blackoutMode => 'અંધકાર મોડ';

  @override
  String get exitBlackout => 'અંધકાર મોડમાંથી બહાર આવો';

  @override
  String get feedbackEmailSubject => 'સ્મરણ વિશે પ્રતિભાવ';

  @override
  String get homeScreenWidget => 'હોમ સ્ક્રીન વિજેટ';

  @override
  String get homeScreenWidgetBody =>
      'એપ ખોલ્યા વિના તમારી હોમ સ્ક્રીન પર આજના જાપ અને તમારું સાતત્ય જુઓ.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'હોમ સ્ક્રીન પર કોઈ ખાલી જગ્યાને દબાવી રાખો, વિજેટ્સ પર ટૅપ કરો, પછી સ્મરણ શોધો.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'હોમ સ્ક્રીન પર કોઈ ખાલી જગ્યાને દબાવી રાખો, ખૂણામાં + પર ટૅપ કરો, સ્મરણ શોધો, પછી કદ પસંદ કરીને વિજેટ ઉમેરો પર ટૅપ કરો.';

  @override
  String get addToHomeScreen => 'હોમ સ્ક્રીન પર ઉમેરો';

  @override
  String get countWithButtons => 'બટનથી ગણો';

  @override
  String get countWithButtonsHintAndroid =>
      'વૉલ્યૂમ બટન, હેડસેટ બટન અથવા Bluetooth ક્લિકરથી એક મણકો ગણાય છે';

  @override
  String get countWithButtonsHintIOS =>
      'Bluetooth ક્લિકર અથવા કીબોર્ડથી એક મણકો ગણાય છે. iPhone ના વૉલ્યૂમ બટન એપ્સ વાપરી શકતી નથી.';

  @override
  String get lockScreenCounter => 'લૉક સ્ક્રીન કાઉન્ટર';

  @override
  String get lockScreenCounterHint =>
      'તમારી લૉક સ્ક્રીન અને Dynamic Island પર +1 બટન. હવે પછી એપ ખોલશો ત્યારે આ ગણતરી તમારા જાપમાં ઉમેરાઈ જશે.';

  @override
  String get markerBead => 'નિશાનીનો મણકો';

  @override
  String get markerBeadHint =>
      'માળાની વચ્ચે એક જોરદાર કંપન, જેથી આંખો બંધ હોય ત્યારે પણ ખબર પડે કે તમે ક્યાં છો';

  @override
  String markerBeadEvery(int count) {
    return 'દર $count પર';
  }

  @override
  String get markerBeadOff => 'બંધ';

  @override
  String get graceDays => 'છૂટના દિવસો';

  @override
  String get graceDaysHint =>
      'સળંગ દર 7 દિવસે એક છૂટનો દિવસ મળે છે (વધુમાં વધુ 2). કોઈ દિવસ ચૂકી જાઓ તો તમારું સાતત્ય તૂટવાને બદલે એક છૂટનો દિવસ વપરાય છે.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count છૂટના દિવસ બાકી',
      one: '1 છૂટનો દિવસ બાકી',
      zero: 'કોઈ છૂટનો દિવસ બાકી નથી',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'છૂટના દિવસથી સચવાયું';

  @override
  String milestoneLakh(int count) {
    return '$count લાખ જાપ';
  }

  @override
  String get milestoneSavaLakh => 'સવા લાખ જાપ';

  @override
  String get milestoneCrore => '1 કરોડ જાપ';

  @override
  String milestoneStreak(int days) {
    return 'સળંગ $days દિવસ';
  }

  @override
  String milestoneReached(String milestone) {
    return '$milestone પૂર્ણ. તમારી સાધનાનું એક સીમાચિહ્ન.';
  }

  @override
  String get milestones => 'સીમાચિહ્નો';

  @override
  String milestoneNext(String milestone) {
    return 'હવે પછી: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString બાકી';
  }

  @override
  String get milestoneAllReached => 'બધાં સીમાચિહ્નો પૂર્ણ';

  @override
  String get yearInReview => 'વર્ષનો સાર';

  @override
  String yearInReviewTitle(int year) {
    return 'જાપમાં તમારું $year';
  }

  @override
  String yearNoJaap(int year) {
    return '$year માં કોઈ જાપ નોંધાયા નથી';
  }

  @override
  String get yearActiveDays => 'જાપના દિવસો';

  @override
  String get yearLongestRun => 'સૌથી લાંબું સાતત્ય';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ',
      one: '1 દિવસ',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'શ્રેષ્ઠ દિવસ';

  @override
  String get yearTopMantra => 'સૌથી વધુ જપાયેલો';

  @override
  String get yearByMonth => 'મહિના પ્રમાણે';

  @override
  String get yearMilestones => 'આ વર્ષનાં સીમાચિહ્નો';

  @override
  String yearShareText(int year, String count) {
    return 'નામ જાપમાં મારું $year: $count જાપ';
  }

  @override
  String get previousYear => 'પાછલું વર્ષ';

  @override
  String get nextYear => 'આગલું વર્ષ';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'ઇન્દિરા એકાદશી',
      'papankusha': 'પાપાંકુશા એકાદશી',
      'rama': 'રમા એકાદશી',
      'devutthana': 'દેવઉઠી એકાદશી',
      'utpanna': 'ઉત્પન્ના એકાદશી',
      'mokshada': 'મોક્ષદા એકાદશી',
      'saphala': 'સફલા એકાદશી',
      'paushaPutrada': 'પોષ પુત્રદા એકાદશી',
      'shattila': 'ષટ્તિલા એકાદશી',
      'jaya': 'જયા એકાદશી',
      'vijaya': 'વિજયા એકાદશી',
      'amalaki': 'આમલકી એકાદશી',
      'papamochani': 'પાપમોચની એકાદશી',
      'kamada': 'કામદા એકાદશી',
      'varuthini': 'વરૂથિની એકાદશી',
      'mohini': 'મોહિની એકાદશી',
      'apara': 'અપરા એકાદશી',
      'nirjala': 'નિર્જળા એકાદશી',
      'yogini': 'યોગિની એકાદશી',
      'devshayani': 'દેવશયની એકાદશી',
      'kamika': 'કામિકા એકાદશી',
      'shravanaPutrada': 'શ્રાવણ પુત્રદા એકાદશી',
      'aja': 'અજા એકાદશી',
      'parsva': 'પરિવર્તિની એકાદશી',
      'other': 'એકાદશી',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'નવરાત્રી',
      'chaitraNavratri': 'ચૈત્રી નવરાત્રી',
      'dussehra': 'દશેરા',
      'diwali': 'દિવાળી',
      'kartikMonth': 'કારતક માસ',
      'kartikPurnima': 'કારતકી પૂનમ',
      'guruNanakJayanti': 'ગુરુ નાનક જયંતી',
      'makarSankranti': 'ઉત્તરાયણ',
      'vasantPanchami': 'વસંત પંચમી',
      'mahaShivaratri': 'મહાશિવરાત્રી',
      'holi': 'હોળી',
      'ramNavami': 'રામ નવમી',
      'mahavirJayanti': 'મહાવીર જયંતી',
      'hanumanJayanti': 'હનુમાન જયંતી',
      'guruPurnima': 'ગુરુ પૂર્ણિમા',
      'shravanMonth': 'શ્રાવણ માસ',
      'rakshaBandhan': 'રક્ષાબંધન',
      'krishnaJanmashtami': 'જન્માષ્ટમી',
      'ganeshChaturthi': 'ગણેશ ચતુર્થી',
      'other': 'તહેવાર',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return '$date થી શરૂ';
  }

  @override
  String get upcomingObservances => 'એકાદશી અને તહેવારો';

  @override
  String get observanceToday => 'આજે';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસમાં',
      one: 'આવતીકાલે',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return '$name નિમિત્તે સંકલ્પ';
  }

  @override
  String get observanceTakeSankalp => 'સંકલ્પ લો';

  @override
  String observanceVaishnava(String date) {
    return 'વૈષ્ણવ (ISKCON) વ્રત: $date';
  }

  @override
  String get observanceSourceNote =>
      'તિથિઓ નવી દિલ્હી માટેના દ્રિક પંચાંગ (Drik Panchang) મુજબ છે. તમારા સ્થાનિક મંદિર કે પરંપરામાં એક દિવસનો ફેર હોઈ શકે છે.';

  @override
  String get observancesNone => 'આવનારાં થોડાં અઠવાડિયાંમાં કંઈ નથી';

  @override
  String get festivalReminders => 'એકાદશી અને તહેવારના રિમાઇન્ડર';

  @override
  String get festivalRemindersHint =>
      'એકાદશી અને તહેવારના દિવસે સવારે 6 વાગ્યે એક સૂચના';

  @override
  String festivalNotificationBody(String name) {
    return 'આજે $name છે. નામ જાપ માટે શુભ દિવસ.';
  }

  @override
  String get sendDiagnostics => 'નિદાન રિપોર્ટ મોકલો';

  @override
  String get diagnosticsExplain =>
      'આ રિપોર્ટ કોઈ સમસ્યા ઉકેલવામાં મદદ કરે છે. તેમાં એપ અને ફોનનાં સંસ્કરણ, તમારી સેટિંગ્સ અને એપની ભૂલોની નોંધ છે. તેમાં કોઈ મંત્ર, ગણતરી કે નોંધ નથી. તમે નીચે કોઈ રીત પસંદ ન કરો ત્યાં સુધી કંઈ મોકલાતું નથી.';

  @override
  String get diagnosticsEmail => 'ઇમેઇલ કરો';

  @override
  String get diagnosticsShare => 'ફાઇલ તરીકે શેર કરો';

  @override
  String get diagnosticsEmailSubject => 'Smaran નિદાન';

  @override
  String get diagnosticsNoMail =>
      'કોઈ મેઇલ એપ મળી નથી. ફાઇલ તરીકે શેર કરી જુઓ.';
}
