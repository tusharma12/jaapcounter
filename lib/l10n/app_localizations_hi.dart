// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppL10nHi extends AppL10n {
  AppL10nHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'नाम जप काउंटर – स्मरण';

  @override
  String get tagline => 'आपके दैनिक नाम जप के लिए शांत डिजिटल माला';

  @override
  String get navJaap => 'जाप';

  @override
  String get navProgress => 'प्रगति';

  @override
  String get navStories => 'कथाएँ';

  @override
  String get navSettings => 'सेटिंग';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get edit => 'बदलें';

  @override
  String get close => 'बंद करें';

  @override
  String get next => 'आगे';

  @override
  String get skip => 'छोड़ें';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get custom => 'अपनी पसंद';

  @override
  String get active => 'सक्रिय';

  @override
  String get off => 'बंद';

  @override
  String get somethingWentWrong => 'कुछ गड़बड़ हो गई';

  @override
  String get tapToCount => 'गिनने के लिए स्पर्श करें';

  @override
  String get todaysJaap => 'आज का जाप';

  @override
  String get undo => 'पूर्ववत';

  @override
  String get malaComplete => 'माला पूर्ण';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मालाएँ पूर्ण',
      one: '1 माला पूर्ण',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    return '$count जाप';
  }

  @override
  String get nothingToUndo => 'पूर्ववत करने के लिए कुछ नहीं';

  @override
  String get countRemoved => 'गिनती हटाई गई';

  @override
  String get resetCurrentMala => 'वर्तमान माला रीसेट करें';

  @override
  String get resetCurrentMalaBody =>
      'इस माला में गिने गए मनके हटा दिए जाएँगे। पूर्ण मालाएँ सुरक्षित रहेंगी।';

  @override
  String get addCountManually => 'गिनती स्वयं जोड़ें';

  @override
  String get addCount => 'गिनती जोड़ें';

  @override
  String get numberOfJaap => 'जाप की संख्या';

  @override
  String get meditationMode => 'ध्यान मोड';

  @override
  String get startSession => 'सत्र शुरू करें';

  @override
  String get endSession => 'सत्र समाप्त करें';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$minutes मिनट में $jaap जाप';
  }

  @override
  String get myMantras => 'मेरे मंत्र';

  @override
  String get addMantra => 'मंत्र जोड़ें';

  @override
  String get editMantra => 'मंत्र बदलें';

  @override
  String get malaSize => 'माला का आकार';

  @override
  String beads(int count) {
    return '$count मनके';
  }

  @override
  String get malaSizeInvalid => 'माला का आकार 1 से 10,000 के बीच होना चाहिए';

  @override
  String get deleteMantraTitle => 'मंत्र हटाएँ?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" हटा दिया जाएगा। आपका जाप इतिहास सुरक्षित रहेगा।';
  }

  @override
  String get optional => 'वैकल्पिक';

  @override
  String get mySadhana => 'मेरी साधना';

  @override
  String get todaysGoal => 'आज का लक्ष्य';

  @override
  String get complete => 'पूर्ण';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन की लय',
      one: '1 दिन की लय',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'सर्वश्रेष्ठ लय';

  @override
  String sankalpDays(int days) {
    return '$days दिन का संकल्प';
  }

  @override
  String dayXofY(int current, int total) {
    return 'दिन $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पूर्ण',
      one: '1 दिन पूर्ण',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return '$date से आरंभ';
  }

  @override
  String get createNewSankalp => 'नया संकल्प लें';

  @override
  String get createSankalp => 'संकल्प बनाएँ';

  @override
  String get chooseMantra => 'मंत्र चुनें';

  @override
  String get dailyGoal => 'दैनिक लक्ष्य';

  @override
  String get duration => 'अवधि';

  @override
  String durationDays(int days) {
    return '$days दिन';
  }

  @override
  String get reminder => 'स्मरण';

  @override
  String get beginSadhana => 'साधना आरंभ करें';

  @override
  String get noSankalpTitle => 'संकल्प आरंभ करें';

  @override
  String get noSankalpBody =>
      'संकल्प एक व्रत है — चुने हुए दिनों तक प्रतिदिन निश्चित संख्या में जाप करने का।';

  @override
  String get endSankalp => 'संकल्प समाप्त करें';

  @override
  String get endSankalpBody =>
      'आपकी प्रगति सुरक्षित रहेगी, पर संकल्प सक्रिय नहीं रहेगा।';

  @override
  String jaapPerDay(int count) {
    return 'प्रतिदिन $count जाप';
  }

  @override
  String goalRemaining(int count) {
    return '$count शेष';
  }

  @override
  String get goalReached => 'आज का लक्ष्य पूर्ण';

  @override
  String get setDailyGoal => 'दैनिक लक्ष्य तय करें';

  @override
  String get sadhanaGoals => 'साधना लक्ष्य';

  @override
  String get progress => 'प्रगति';

  @override
  String get filterDaily => 'दैनिक';

  @override
  String get filterWeekly => 'साप्ताहिक';

  @override
  String get filterMonthly => 'मासिक';

  @override
  String get filterYearly => 'वार्षिक';

  @override
  String get totalJaap => 'कुल जाप';

  @override
  String get totalMalas => 'कुल मालाएँ';

  @override
  String get weeklyJaap => 'साप्ताहिक जाप';

  @override
  String get monthlyJaap => 'मासिक जाप';

  @override
  String get yearlyJaap => 'वार्षिक जाप';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString लक्ष्य';
  }

  @override
  String get noJaapYet => 'अभी कोई जाप दर्ज नहीं';

  @override
  String get noJaapYetBody => 'पहला मनका ही यात्रा का आरंभ है।';

  @override
  String get dailyAverage => 'दैनिक औसत';

  @override
  String get activeDays => 'सक्रिय दिन';

  @override
  String get perMantra => 'मंत्र अनुसार';

  @override
  String get stories => 'कथाएँ';

  @override
  String get storiesSubtitle => 'मनन के लिए छोटी कथाएँ';

  @override
  String get popular => 'लोकप्रिय';

  @override
  String get read => 'पढ़ें';

  @override
  String get listen => 'सुनें';

  @override
  String get stopListening => 'रोकें';

  @override
  String get textSize => 'अक्षर का आकार';

  @override
  String get favorite => 'पसंदीदा';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get share => 'साझा करें';

  @override
  String get all => 'सभी';

  @override
  String minRead(int minutes) {
    return '$minutes मिनट का पाठ';
  }

  @override
  String get noFavoritesTitle => 'अभी कोई पसंदीदा नहीं';

  @override
  String get noFavoritesBody => 'किसी कथा पर हृदय चिह्न दबाकर उसे यहाँ रखें।';

  @override
  String get noStoriesFound => 'कोई कथा नहीं मिली';

  @override
  String get settings => 'सेटिंग';

  @override
  String get sectionJaap => 'जाप';

  @override
  String get sectionReminders => 'स्मरण';

  @override
  String get sectionAppearance => 'रूप';

  @override
  String get sectionBackup => 'बैकअप';

  @override
  String get sectionSupport => 'सहायता';

  @override
  String get sectionAbout => 'परिचय';

  @override
  String get resetCounts => 'गिनती रीसेट करें';

  @override
  String get jaapReminders => 'जाप स्मरण';

  @override
  String get streakReminder => 'लय स्मरण';

  @override
  String get goalReminder => 'लक्ष्य स्मरण';

  @override
  String get theme => 'थीम';

  @override
  String get haptics => 'कंपन';

  @override
  String get sound => 'ध्वनि';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम अनुसार';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get backupRestore => 'बैकअप और पुनर्स्थापना';

  @override
  String get exportMyData => 'मेरा डेटा निर्यात करें';

  @override
  String get rateApp => 'स्मरण को रेट करें';

  @override
  String get shareApp => 'स्मरण साझा करें';

  @override
  String get feedback => 'प्रतिक्रिया';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get terms => 'शर्तें';

  @override
  String get aboutApp => 'स्मरण के बारे में';

  @override
  String version(String version) {
    return 'संस्करण $version';
  }

  @override
  String get resetTodayTitle => 'आज का जाप रीसेट करें?';

  @override
  String get resetTodayBody =>
      'आज दर्ज सारा जाप हट जाएगा। यह पूर्ववत नहीं हो सकता।';

  @override
  String get resetAllTitle => 'सारा जाप रीसेट करें?';

  @override
  String get resetAllBody =>
      'आपका पूरा जाप इतिहास, मालाएँ और लय सदा के लिए मिट जाएँगी। यह पूर्ववत नहीं हो सकता।';

  @override
  String get resetToday => 'आज का रीसेट करें';

  @override
  String get resetEverything => 'सब कुछ रीसेट करें';

  @override
  String get resetDone => 'गिनती रीसेट हो गई';

  @override
  String get aboutBody =>
      'स्मरण आपके दैनिक नाम जप के लिए एक शांत, निजी स्थान है। आपका सारा जाप केवल इसी उपकरण में सुरक्षित रहता है।';

  @override
  String get madeWith => 'श्रद्धा से निर्मित';

  @override
  String get addReminder => 'स्मरण जोड़ें';

  @override
  String get reminderTime => 'समय';

  @override
  String get everyDay => 'प्रतिदिन';

  @override
  String get noRemindersTitle => 'अभी कोई स्मरण नहीं';

  @override
  String get noRemindersBody =>
      'प्रतिदिन एक ही समय पर कोमल स्मरण अभ्यास को आदत बना देता है।';

  @override
  String get notificationsBlocked =>
      'स्मरण के लिए सूचनाएँ बंद हैं। उपकरण की सेटिंग में इन्हें चालू करें।';

  @override
  String get reminderNotificationTitle => 'जाप का समय';

  @override
  String get reminderNotificationBody => 'माला के संग कुछ शांत क्षण 🙏';

  @override
  String get streakNotificationTitle => 'अपनी लय बनाए रखें';

  @override
  String get streakNotificationBody =>
      'आपने आज जाप नहीं किया। एक माला भी लय बनाए रखेगी।';

  @override
  String get goalNotificationTitle => 'बस थोड़ा शेष';

  @override
  String get goalNotificationBody =>
      'आज का लक्ष्य पूरा करें और साधना पूर्ण करें।';

  @override
  String get createBackup => 'बैकअप बनाएँ';

  @override
  String get createBackupBody =>
      'अपने सभी मंत्र, जाप इतिहास, लक्ष्य और सेटिंग की JSON फ़ाइल सहेजें।';

  @override
  String get restoreBackup => 'बैकअप से पुनर्स्थापित करें';

  @override
  String get restoreBackupBody =>
      'पुनर्स्थापित करने के लिए स्मरण बैकअप फ़ाइल चुनें।';

  @override
  String get backupCreated => 'बैकअप बन गया';

  @override
  String get restoreWarningTitle => 'सारा डेटा बदलें?';

  @override
  String get restoreWarningBody =>
      'पुनर्स्थापना स्मरण के वर्तमान सारे डेटा को बैकअप फ़ाइल के डेटा से बदल देगी।';

  @override
  String get restore => 'पुनर्स्थापित करें';

  @override
  String restoreSuccess(int count) {
    return '$count जाप प्रविष्टियाँ पुनर्स्थापित हुईं';
  }

  @override
  String get importInvalid => 'यह फ़ाइल मान्य स्मरण बैकअप नहीं है';

  @override
  String get exportShareText => 'मेरा स्मरण बैकअप';

  @override
  String get onb1Title => 'आपकी डिजिटल जप माला';

  @override
  String get onb1Body => 'हर नाम जप गिनने का एक शांत तरीका।';

  @override
  String get onb2Title => 'साधना को आदत बनाएँ';

  @override
  String get onb2Body => 'दैनिक लक्ष्य तय करें और जाप की लय बनाएँ।';

  @override
  String get onb3Title => 'बिना विघ्न जाप करें';

  @override
  String get onb3Body => 'स्वच्छ, शांत काउंटर के साथ ध्यान मोड में जाएँ।';

  @override
  String get startJap => 'जप आरंभ करें';

  @override
  String get blackout => 'अंधकार';

  @override
  String get timer => 'समय';

  @override
  String get exitMeditation => 'ध्यान मोड से बाहर आएँ';

  @override
  String get tapAnywhere => 'गिनने के लिए कहीं भी स्पर्श करें';

  @override
  String semanticCounter(int count, int total) {
    return 'जाप काउंटर। $total में से $count मनके। एक गिनने के लिए दो बार स्पर्श करें।';
  }

  @override
  String get autoJaap => 'स्वतः जाप';

  @override
  String get autoJaapBody =>
      'ऐप एक स्थिर गति से आपके लिए गिनती करता है, ताकि आप बिना हाथ लगाए साथ में जाप कर सकें।';

  @override
  String get autoJaapPace => 'गति';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds से.';
  }

  @override
  String get autoJaapStopAfter => 'कब रुकें';

  @override
  String get autoJaapStopMala => 'एक माला';

  @override
  String get autoJaapStopGoal => 'दैनिक लक्ष्य';

  @override
  String get autoJaapStopNever => 'न रुकें';

  @override
  String get autoJaapStart => 'स्वतः जाप शुरू करें';

  @override
  String get autoJaapStopAction => 'स्वतः जाप रोकें';

  @override
  String counterCount(String count) {
    return 'गिनती: $count';
  }

  @override
  String counterMalas(String count) {
    return 'मालाएँ: $count';
  }

  @override
  String counterTotal(String count) {
    return 'कुल: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'स्वतः जाप चालू · रोकने के लिए कहीं भी स्पर्श करें';

  @override
  String get hideMantra => 'मंत्र छिपाएँ';

  @override
  String get showMantra => 'मंत्र दिखाएँ';

  @override
  String get changeTheme => 'थीम बदलें';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन का क्रम',
      one: '1 दिन का क्रम',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'मेनू';

  @override
  String get chooseTheme => 'थीम चुनें';

  @override
  String get themeAuto => 'स्वचालित';

  @override
  String get themeWhite => 'सफ़ेद';

  @override
  String get themeBlack => 'काला';

  @override
  String get themePastelPink => 'हल्का गुलाबी';

  @override
  String get themeSpiritual => 'आध्यात्मिक';

  @override
  String get themeSaffron => 'केसरिया';

  @override
  String get themePeaceful => 'शांत';

  @override
  String get themeTerracotta => 'टेराकोटा';

  @override
  String get themeMeditative => 'ध्यान';

  @override
  String get themeNature => 'प्रकृति';

  @override
  String get themeRoseGold => 'रोज़ गोल्ड';

  @override
  String get themeOcean => 'सागर';

  @override
  String get themeLavender => 'लैवेंडर';

  @override
  String get themeCharcoal => 'चारकोल';

  @override
  String get counterBackground => 'काउंटर पृष्ठभूमि';

  @override
  String get counterBackgroundBody =>
      'काउंटर पर मंत्र और मनकों के पीछे दिखती है।';

  @override
  String get backgroundNone => 'कोई नहीं';

  @override
  String get backgroundDawn => 'भोर';

  @override
  String get backgroundDusk => 'संध्या';

  @override
  String get backgroundLotus => 'कमल';

  @override
  String get backgroundForest => 'वन';

  @override
  String get backgroundOcean => 'सागर';

  @override
  String get backgroundCosmos => 'ब्रह्मांड';

  @override
  String get backgroundPhoto => 'मेरी फ़ोटो';

  @override
  String get backgroundChoosePhoto => 'फ़ोटो चुनें';

  @override
  String get backgroundChangePhoto => 'फ़ोटो बदलें';

  @override
  String get backgroundRemovePhoto => 'फ़ोटो हटाएँ';

  @override
  String get backgroundDim => 'पृष्ठभूमि मंद करें';

  @override
  String get backgroundDimHint => 'अधिक मंद करने से मंत्र पढ़ना आसान रहता है।';

  @override
  String get addOwnMantra => 'अपना मंत्र जोड़ें';

  @override
  String get addOwnMantraHint =>
      'कोई भी नाम या मंत्र, किसी भी लिपि में, अपनी माला के आकार के साथ';

  @override
  String get legendLess => 'कम';

  @override
  String get legendMore => 'अधिक';

  @override
  String get allMantras => 'सभी मंत्र';

  @override
  String get previousPeriod => 'पिछला';

  @override
  String get nextPeriod => 'अगला';

  @override
  String get showStatsFor => 'इसके आँकड़े दिखाएँ';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count जाप · $malas माला';
  }

  @override
  String get dailyJaap => 'दैनिक जाप';

  @override
  String get mantraText => 'मंत्र';

  @override
  String get mantraTextHint => 'जैसे राम या ॐ नमः शिवाय';

  @override
  String get mantraRequired => 'कृपया मंत्र लिखें';

  @override
  String get mantraDescription => 'विवरण';

  @override
  String get mantraDescriptionHint => 'अर्थ, स्रोत, या अपने लिए कोई नोट';

  @override
  String get fallingMantra => 'गिरता मंत्र';

  @override
  String get malaStyle => 'माला की शैली';

  @override
  String get malaStyleBeads => 'मनके';

  @override
  String get malaStyleRing => 'प्रगति वलय';

  @override
  String get sectionCounter => 'काउंटर';

  @override
  String get showMantraOnCounter => 'काउंटर पर मंत्र दिखाएँ';

  @override
  String get goalUnitMalas => 'माला';

  @override
  String get goalUnitJaap => 'जाप';

  @override
  String malaCount(int count) {
    return '$count माला';
  }

  @override
  String get malasPerDay => 'प्रतिदिन माला';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    return 'प्रतिदिन $malas माला · $jaap जाप';
  }

  @override
  String get onbMantraTitle => 'आप कौन सा मंत्र जपते हैं?';

  @override
  String get onbMantraBody =>
      'शुरू करने के लिए एक चुनें। और मंत्र कभी भी जोड़ सकते हैं।';

  @override
  String get onbGoalTitle => 'आपका दैनिक लक्ष्य';

  @override
  String get onbGoalBody =>
      'छोटे से शुरू करें: बड़ी संख्या से ज़्यादा ज़रूरी रोज़ का नियम है। इसे कभी भी बदल सकते हैं।';

  @override
  String get shareProgress => 'मेरी प्रगति साझा करें';

  @override
  String get shareStreakLabel => 'दिन लगातार';

  @override
  String shareCardText(int count) {
    return 'स्मरण के साथ लगातार $count दिन नाम जाप 🙏';
  }

  @override
  String get blackoutMode => 'अंधकार मोड';

  @override
  String get exitBlackout => 'अंधकार मोड से बाहर';
}
