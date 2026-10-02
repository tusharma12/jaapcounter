// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppL10nMr extends AppL10n {
  AppL10nMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'नाम जप काउंटर – स्मरण';

  @override
  String get tagline => 'तुमच्या दैनंदिन नाम जपासाठी शांत डिजिटल माळ';

  @override
  String get navJaap => 'जप';

  @override
  String get navProgress => 'प्रगती';

  @override
  String get navStories => 'कथा';

  @override
  String get navSettings => 'सेटिंग्ज';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'जतन करा';

  @override
  String get delete => 'हटवा';

  @override
  String get edit => 'बदला';

  @override
  String get close => 'बंद करा';

  @override
  String get next => 'पुढे';

  @override
  String get skip => 'वगळा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get custom => 'स्वतःचे';

  @override
  String get active => 'सक्रिय';

  @override
  String get off => 'बंद';

  @override
  String get somethingWentWrong => 'काहीतरी चुकले';

  @override
  String get tapToCount => 'मोजण्यासाठी स्पर्श करा';

  @override
  String get todaysJaap => 'आजचा जप';

  @override
  String get undo => 'पूर्ववत';

  @override
  String get malaComplete => 'माळ पूर्ण';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count माळा पूर्ण',
      one: '1 माळ पूर्ण',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString जप';
  }

  @override
  String get nothingToUndo => 'पूर्ववत करण्यासारखे काही नाही';

  @override
  String get countRemoved => 'मोजणी काढली';

  @override
  String get resetCurrentMala => 'चालू माळ रीसेट करा';

  @override
  String get resetCurrentMalaBody =>
      'या माळेत मोजलेले मणी काढले जातील. पूर्ण झालेल्या माळा तशाच राहतील.';

  @override
  String get addCountManually => 'मोजणी स्वतः जोडा';

  @override
  String get addCount => 'मोजणी जोडा';

  @override
  String get numberOfJaap => 'जपांची संख्या';

  @override
  String get meditationMode => 'ध्यान मोड';

  @override
  String get startSession => 'सत्र सुरू करा';

  @override
  String get endSession => 'सत्र संपवा';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$minutes मिनिटांत $jaap जप';
  }

  @override
  String get myMantras => 'माझे मंत्र';

  @override
  String get addMantra => 'मंत्र जोडा';

  @override
  String get editMantra => 'मंत्र बदला';

  @override
  String get malaSize => 'माळेचा आकार';

  @override
  String beads(int count) {
    return '$count मणी';
  }

  @override
  String get malaSizeInvalid => 'माळेचा आकार 1 ते 10,000 च्या दरम्यान असावा';

  @override
  String get deleteMantraTitle => 'मंत्र हटवायचा?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" हटवला जाईल. तुमचा नोंदवलेला जपाचा इतिहास सुरक्षित राहील.';
  }

  @override
  String get optional => 'ऐच्छिक';

  @override
  String get mySadhana => 'माझी साधना';

  @override
  String get todaysGoal => 'आजचे लक्ष्य';

  @override
  String get complete => 'पूर्ण';

  @override
  String dayStreak(int count) {
    return 'सलग $count दिवस';
  }

  @override
  String get bestStreak => 'सर्वोत्तम सातत्य';

  @override
  String sankalpDays(int days) {
    return '$days दिवसांचा संकल्प';
  }

  @override
  String dayXofY(int current, int total) {
    return 'दिवस $current / $total';
  }

  @override
  String daysCompleted(int count) {
    return '$count दिवस पूर्ण';
  }

  @override
  String startedOn(String date) {
    return '$date पासून सुरू';
  }

  @override
  String get createNewSankalp => 'नवा संकल्प घ्या';

  @override
  String get createSankalp => 'संकल्प करा';

  @override
  String get chooseMantra => 'मंत्र निवडा';

  @override
  String get dailyGoal => 'दैनंदिन लक्ष्य';

  @override
  String get duration => 'कालावधी';

  @override
  String durationDays(int days) {
    return '$days दिवस';
  }

  @override
  String get reminder => 'आठवण';

  @override
  String get beginSadhana => 'साधना सुरू करा';

  @override
  String get noSankalpTitle => 'संकल्प घ्या';

  @override
  String get noSankalpBody =>
      'संकल्प म्हणजे ठरवलेल्या दिवसांपर्यंत रोज ठरावीक संख्येने जप करण्याचे व्रत.';

  @override
  String get endSankalp => 'संकल्प समाप्त करा';

  @override
  String get endSankalpBody =>
      'तुमची प्रगती जतन राहील, पण संकल्प यापुढे सक्रिय राहणार नाही.';

  @override
  String jaapPerDay(int count) {
    return 'दररोज $count जप';
  }

  @override
  String goalRemaining(int count) {
    return '$count बाकी';
  }

  @override
  String get goalReached => 'आजचे लक्ष्य पूर्ण';

  @override
  String get setDailyGoal => 'दैनंदिन लक्ष्य ठरवा';

  @override
  String get sadhanaGoals => 'साधनेची लक्ष्ये';

  @override
  String get progress => 'प्रगती';

  @override
  String get filterDaily => 'दैनंदिन';

  @override
  String get filterWeekly => 'साप्ताहिक';

  @override
  String get filterMonthly => 'मासिक';

  @override
  String get filterYearly => 'वार्षिक';

  @override
  String get totalJaap => 'एकूण जप';

  @override
  String get totalMalas => 'एकूण माळा';

  @override
  String get weeklyJaap => 'साप्ताहिक जप';

  @override
  String get monthlyJaap => 'मासिक जप';

  @override
  String get yearlyJaap => 'वार्षिक जप';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString लक्ष्य';
  }

  @override
  String get noJaapYet => 'अजून कोणताही जप नोंदवलेला नाही';

  @override
  String get noJaapYetBody => 'तुमचा पहिला मणी हीच प्रवासाची सुरुवात आहे.';

  @override
  String get dailyAverage => 'दैनंदिन सरासरी';

  @override
  String get activeDays => 'सक्रिय दिवस';

  @override
  String get perMantra => 'मंत्रानुसार';

  @override
  String get stories => 'कथा';

  @override
  String get storiesSubtitle => 'चिंतनासाठी छोट्या कथा';

  @override
  String get popular => 'लोकप्रिय';

  @override
  String get read => 'वाचा';

  @override
  String get listen => 'ऐका';

  @override
  String get stopListening => 'थांबवा';

  @override
  String get textSize => 'अक्षरांचा आकार';

  @override
  String get favorite => 'आवडते';

  @override
  String get favorites => 'आवडते';

  @override
  String get share => 'शेअर करा';

  @override
  String get all => 'सर्व';

  @override
  String minRead(int minutes) {
    return '$minutes मिनिटांचे वाचन';
  }

  @override
  String get noFavoritesTitle => 'अजून काहीही आवडते नाही';

  @override
  String get noFavoritesBody =>
      'एखादी कथा इथे ठेवण्यासाठी तिच्यावरील हृदयाच्या चिन्हाला स्पर्श करा.';

  @override
  String get noStoriesFound => 'कोणतीही कथा सापडली नाही';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get sectionJaap => 'जप';

  @override
  String get sectionReminders => 'आठवण';

  @override
  String get sectionAppearance => 'रूप';

  @override
  String get sectionBackup => 'बॅकअप';

  @override
  String get sectionSupport => 'मदत';

  @override
  String get sectionAbout => 'माहिती';

  @override
  String get resetCounts => 'मोजणी रीसेट करा';

  @override
  String get jaapReminders => 'जपाची आठवण';

  @override
  String get streakReminder => 'सातत्याची आठवण';

  @override
  String get goalReminder => 'लक्ष्याची आठवण';

  @override
  String get theme => 'थीम';

  @override
  String get haptics => 'कंपन';

  @override
  String get sound => 'आवाज';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टमनुसार';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'बॅकअप आणि पुनर्संचयन';

  @override
  String get exportMyData => 'माझा डेटा निर्यात करा';

  @override
  String get rateApp => 'स्मरणला रेटिंग द्या';

  @override
  String get shareApp => 'कुटुंबीय आणि मित्रांना आमंत्रित करा';

  @override
  String get feedback => 'अभिप्राय';

  @override
  String get privacyPolicy => 'गोपनीयता धोरण';

  @override
  String get terms => 'अटी';

  @override
  String get aboutApp => 'स्मरणबद्दल';

  @override
  String version(String version) {
    return 'आवृत्ती $version';
  }

  @override
  String get resetTodayTitle => 'आजचा जप रीसेट करायचा?';

  @override
  String get resetTodayBody =>
      'आज नोंदवलेला सर्व जप काढून टाकला जाईल. हे पूर्ववत करता येणार नाही.';

  @override
  String get resetAllTitle => 'सर्व जप रीसेट करायचा?';

  @override
  String get resetAllBody =>
      'तुमचा संपूर्ण जप इतिहास, माळा आणि सातत्य कायमचे हटवले जाईल. हे पूर्ववत करता येणार नाही.';

  @override
  String get resetToday => 'आजचे रीसेट करा';

  @override
  String get resetEverything => 'सर्व काही रीसेट करा';

  @override
  String get resetDone => 'मोजणी रीसेट झाली';

  @override
  String get aboutBody =>
      'स्मरण हे तुमच्या दैनंदिन नाम जपासाठी एक शांत, खाजगी स्थान आहे. तुम्ही केलेला सर्व जप फक्त याच डिव्हाइसवर साठवला जातो.';

  @override
  String get madeWith => 'श्रद्धेने बनवलेले';

  @override
  String get addReminder => 'आठवण जोडा';

  @override
  String get reminderTime => 'वेळ';

  @override
  String get everyDay => 'दररोज';

  @override
  String get noRemindersTitle => 'अजून कोणतीही आठवण नाही';

  @override
  String get noRemindersBody =>
      'रोज एकाच वेळी मिळणारी हलकीशी आठवण साधनेला सवय बनवते.';

  @override
  String get notificationsBlocked =>
      'स्मरणसाठी सूचना बंद आहेत. डिव्हाइसच्या सेटिंग्जमध्ये त्या सुरू करा.';

  @override
  String get reminderNotificationTitle => 'जपाची वेळ झाली';

  @override
  String get reminderNotificationBody => 'माळेसोबत काही शांत क्षण 🙏';

  @override
  String get streakNotificationTitle => 'तुमचे सातत्य टिकवा';

  @override
  String get streakNotificationBody =>
      'आज तुम्ही अजून जप केलेला नाही. एक माळ केली तरी सातत्य टिकून राहील.';

  @override
  String get goalNotificationTitle => 'थोडेच बाकी';

  @override
  String get goalNotificationBody => 'आजचे लक्ष्य गाठून आजची साधना पूर्ण करा.';

  @override
  String get createBackup => 'बॅकअप तयार करा';

  @override
  String get createBackupBody =>
      'तुमचे सर्व मंत्र, जप इतिहास, लक्ष्ये आणि सेटिंग्ज असलेली JSON फाइल जतन करा.';

  @override
  String get restoreBackup => 'बॅकअपमधून पुनर्संचयित करा';

  @override
  String get restoreBackupBody =>
      'पुनर्संचयित करण्यासाठी स्मरणची बॅकअप फाइल निवडा.';

  @override
  String get backupCreated => 'बॅकअप तयार झाला';

  @override
  String get restoreWarningTitle => 'सर्व डेटा बदलायचा?';

  @override
  String get restoreWarningBody =>
      'पुनर्संचयित केल्यावर स्मरणमधील सध्याचा सर्व डेटा बॅकअप फाइलमधील डेटाने बदलला जाईल.';

  @override
  String get restore => 'पुनर्संचयित करा';

  @override
  String restoreSuccess(int count) {
    return 'पुनर्संचयित जप नोंदी: $count';
  }

  @override
  String get importInvalid => 'ही फाइल स्मरणचा वैध बॅकअप नाही';

  @override
  String get exportShareText => 'माझा स्मरण बॅकअप';

  @override
  String get onb1Title => 'तुमची डिजिटल जपमाळ';

  @override
  String get onb1Body => 'प्रत्येक नाम जप मोजण्याचा एक शांत मार्ग.';

  @override
  String get onb2Title => 'साधनेला सवय बनवा';

  @override
  String get onb2Body => 'दैनंदिन लक्ष्य ठरवा आणि जपात सातत्य राखा.';

  @override
  String get onb3Title => 'व्यत्ययाशिवाय जप करा';

  @override
  String get onb3Body => 'स्वच्छ, शांत काउंटरसह ध्यान मोडमध्ये जा.';

  @override
  String get startJap => 'जप सुरू करा';

  @override
  String get blackout => 'अंधार';

  @override
  String get timer => 'टायमर';

  @override
  String get exitMeditation => 'ध्यान मोडमधून बाहेर पडा';

  @override
  String get tapAnywhere => 'मोजण्यासाठी कुठेही स्पर्श करा';

  @override
  String semanticCounter(int count, int total) {
    return 'जप काउंटर. $total पैकी $count मणी. एक मोजण्यासाठी दोनदा स्पर्श करा.';
  }

  @override
  String get autoJaap => 'स्वयं जप';

  @override
  String get autoJaapBody =>
      'ॲप स्थिर गतीने तुमच्यासाठी मोजणी करते, त्यामुळे तुम्ही हात न लावता सोबत जप करू शकता.';

  @override
  String get autoJaapPace => 'गती';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds से.';
  }

  @override
  String get autoJaapStopAfter => 'कधी थांबावे';

  @override
  String get autoJaapStopMala => 'एक माळ';

  @override
  String get autoJaapStopGoal => 'दैनंदिन लक्ष्य';

  @override
  String get autoJaapStopNever => 'थांबू नका';

  @override
  String get autoJaapStart => 'स्वयं जप सुरू करा';

  @override
  String get autoJaapStopAction => 'स्वयं जप थांबवा';

  @override
  String counterCount(String count) {
    return 'मोजणी: $count';
  }

  @override
  String counterMalas(String count) {
    return 'माळा: $count';
  }

  @override
  String counterTotal(String count) {
    return 'एकूण: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'स्वयं जप सुरू आहे · थांबवण्यासाठी कुठेही स्पर्श करा';

  @override
  String get hideMantra => 'मंत्र लपवा';

  @override
  String get showMantra => 'मंत्र दाखवा';

  @override
  String get changeTheme => 'थीम बदला';

  @override
  String streakDays(int count) {
    return 'सलग $count दिवस';
  }

  @override
  String get menu => 'मेनू';

  @override
  String get chooseTheme => 'थीम निवडा';

  @override
  String get themeAuto => 'स्वयंचलित';

  @override
  String get themeWhite => 'पांढरा';

  @override
  String get themeBlack => 'काळा';

  @override
  String get themePastelPink => 'फिकट गुलाबी';

  @override
  String get themeSpiritual => 'आध्यात्मिक';

  @override
  String get themeSaffron => 'भगवा';

  @override
  String get themePeaceful => 'शांत';

  @override
  String get themeTerracotta => 'टेराकोटा';

  @override
  String get themeMeditative => 'ध्यानमग्न';

  @override
  String get themeNature => 'निसर्ग';

  @override
  String get themeRoseGold => 'रोझ गोल्ड';

  @override
  String get themeOcean => 'सागर';

  @override
  String get themeLavender => 'लॅव्हेंडर';

  @override
  String get themeCharcoal => 'चारकोल';

  @override
  String get counterBackground => 'काउंटरची पार्श्वभूमी';

  @override
  String get counterBackgroundBody =>
      'काउंटरवर मंत्र आणि मण्यांच्या मागे दिसते.';

  @override
  String get backgroundNone => 'काहीही नाही';

  @override
  String get backgroundDawn => 'पहाट';

  @override
  String get backgroundDusk => 'सांजवेळ';

  @override
  String get backgroundLotus => 'कमळ';

  @override
  String get backgroundForest => 'वन';

  @override
  String get backgroundOcean => 'सागर';

  @override
  String get backgroundCosmos => 'ब्रह्मांड';

  @override
  String get backgroundPhoto => 'माझा फोटो';

  @override
  String get backgroundChoosePhoto => 'फोटो निवडा';

  @override
  String get backgroundChangePhoto => 'फोटो बदला';

  @override
  String get backgroundRemovePhoto => 'फोटो काढा';

  @override
  String get backgroundDim => 'पार्श्वभूमी मंद करा';

  @override
  String get backgroundDimHint => 'जास्त मंद केल्यास मंत्र वाचायला सोपा राहतो.';

  @override
  String get addOwnMantra => 'तुमचा स्वतःचा मंत्र जोडा';

  @override
  String get addOwnMantraHint =>
      'कोणतेही नाम किंवा मंत्र, कोणत्याही लिपीत, तुमच्या माळेच्या आकारासह';

  @override
  String get legendLess => 'कमी';

  @override
  String get legendMore => 'जास्त';

  @override
  String get allMantras => 'सर्व मंत्र';

  @override
  String get previousPeriod => 'मागील';

  @override
  String get nextPeriod => 'पुढील';

  @override
  String get showStatsFor => 'आकडेवारी दाखवा';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count जप · $malas माळा';
  }

  @override
  String get dailyJaap => 'दैनंदिन जप';

  @override
  String get mantraText => 'मंत्र';

  @override
  String get mantraTextHint => 'उदा. राम किंवा ॐ नमः शिवाय';

  @override
  String get mantraRequired => 'कृपया मंत्र लिहा';

  @override
  String get mantraDescription => 'वर्णन';

  @override
  String get mantraDescriptionHint => 'अर्थ, स्रोत किंवा स्वतःसाठी एखादी टीप';

  @override
  String get dictationStart => 'बोलून मंत्र नोंदवा';

  @override
  String get dictationListening => 'ऐकत आहे… थांबवण्यासाठी टॅप करा';

  @override
  String get dictationUnavailable =>
      'या डिव्हाइसवर बोलून लिहिण्याची सुविधा उपलब्ध नाही';

  @override
  String get dictationOfflineUnavailable =>
      'या फोनवर या भाषेसाठी ऑफलाइन आवाज इनपुट उपलब्ध नाही. तुमचा आवाज डिव्हाइसबाहेर कधीच जात नाही, म्हणून कृपया टाइप करा.';

  @override
  String get micPermissionDenied => 'यासाठी मायक्रोफोनची परवानगी आवश्यक आहे';

  @override
  String get voiceNote => 'व्हॉइस नोट';

  @override
  String get voiceNoteHint => 'तो जपताना स्वतःचा आवाज रेकॉर्ड करा';

  @override
  String get voiceNoteRecord => 'रेकॉर्ड करा';

  @override
  String get voiceNoteRecording => 'रेकॉर्डिंग सुरू आहे… थांबवण्यासाठी टॅप करा';

  @override
  String get voiceNotePlay => 'व्हॉइस नोट ऐका';

  @override
  String get voiceNotePause => 'व्हॉइस नोट थांबवा';

  @override
  String get voiceNoteDelete => 'व्हॉइस नोट हटवा';

  @override
  String get voiceNoteMissing => 'ही व्हॉइस नोट आता या फोनवर नाही';

  @override
  String get fallingMantra => 'बरसणारा मंत्र';

  @override
  String get stopFallingMantra => 'बरसणारा मंत्र थांबवा';

  @override
  String get malaStyle => 'माळेची शैली';

  @override
  String get malaStyleBeads => 'मणी';

  @override
  String get malaStyleRing => 'प्रगती वलय';

  @override
  String get sectionCounter => 'काउंटर';

  @override
  String get showMantraOnCounter => 'काउंटरवर मंत्र दाखवा';

  @override
  String get goalUnitMalas => 'माळा';

  @override
  String get goalUnitJaap => 'जप';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count माळा',
      one: '1 माळ',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'दररोज माळा';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas माळा',
      one: '1 माळ',
    );
    return 'दररोज $_temp0 · $jaap जप';
  }

  @override
  String get onbMantraTitle => 'तुम्ही कोणता मंत्र जपता?';

  @override
  String get onbMantraBody =>
      'सुरुवातीसाठी एक निवडा. आणखी मंत्र कधीही जोडता येतील.';

  @override
  String get onbGoalTitle => 'तुमचे दैनंदिन लक्ष्य';

  @override
  String get onbGoalBody =>
      'लहान सुरुवात करा: मोठ्या संख्येपेक्षा रोजचा नियम जास्त महत्त्वाचा. हे कधीही बदलता येईल.';

  @override
  String get shareProgress => 'माझी प्रगती शेअर करा';

  @override
  String get shareStreakLabel => 'सलग दिवस';

  @override
  String shareCardText(int count) {
    return 'स्मरणसोबत सलग $count दिवस नाम जप 🙏';
  }

  @override
  String get blackoutMode => 'अंधार मोड';

  @override
  String get exitBlackout => 'अंधार मोडमधून बाहेर पडा';

  @override
  String get feedbackEmailSubject => 'स्मरणबद्दल अभिप्राय';

  @override
  String get homeScreenWidget => 'होम स्क्रीन विजेट';

  @override
  String get homeScreenWidgetBody =>
      'ॲप न उघडता तुमच्या होम स्क्रीनवर आजचा जप आणि तुमचे सातत्य पाहा.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'होम स्क्रीनवरील रिकाम्या जागेवर दाबून धरा, विजेट्सवर टॅप करा, मग स्मरण शोधा.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'होम स्क्रीनवरील रिकाम्या जागेवर दाबून धरा, कोपऱ्यातील + वर टॅप करा, स्मरण शोधा, मग आकार निवडून विजेट जोडा वर टॅप करा.';

  @override
  String get addToHomeScreen => 'होम स्क्रीनवर जोडा';

  @override
  String get countWithButtons => 'बटणांनी मोजा';

  @override
  String get countWithButtonsHintAndroid =>
      'व्हॉल्यूम बटणे, हेडसेटचे बटण किंवा ब्लूटूथ क्लिकरने एक मणी मोजला जातो';

  @override
  String get countWithButtonsHintIOS =>
      'ब्लूटूथ क्लिकर किंवा कीबोर्डने एक मणी मोजला जातो. iPhone ची व्हॉल्यूम बटणे ॲप्सना वापरता येत नाहीत.';

  @override
  String get lockScreenCounter => 'लॉक स्क्रीन काउंटर';

  @override
  String get lockScreenCounterHint =>
      'तुमच्या लॉक स्क्रीन आणि Dynamic Island वर +1 बटण. पुढच्या वेळी ॲप उघडल्यावर ही मोजणी तुमच्या जपात जोडली जाते.';

  @override
  String get markerBead => 'खुणेचा मणी';

  @override
  String get markerBeadHint =>
      'माळेत ठरावीक ठिकाणी एक ठळक कंपन, ज्यामुळे डोळे मिटलेले असतानाही आपण कुठवर आलो ते जाणवते';

  @override
  String markerBeadEvery(int count) {
    return 'दर $count नंतर';
  }

  @override
  String get markerBeadOff => 'बंद';

  @override
  String get graceDays => 'सवलतीचे दिवस';

  @override
  String get graceDaysHint =>
      'सलग प्रत्येक 7 दिवसांनंतर एक सवलतीचा दिवस मिळतो (जास्तीत जास्त 2). एखादा दिवस चुकला तर तुमचे सातत्य तुटण्याऐवजी एक सवलतीचा दिवस वापरला जातो.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सवलतीचे दिवस शिल्लक',
      one: '1 सवलतीचा दिवस शिल्लक',
      zero: 'एकही सवलतीचा दिवस नाही',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'सवलतीच्या दिवसाने भरून काढला';

  @override
  String milestoneLakh(int count) {
    return '$count लाख जप';
  }

  @override
  String get milestoneSavaLakh => 'सव्वा लाख जप';

  @override
  String get milestoneCrore => '1 कोटी जप';

  @override
  String milestoneStreak(int days) {
    return 'सलग $days दिवस';
  }

  @override
  String milestoneReached(String milestone) {
    return '$milestone पूर्ण झाले. तुमच्या साधनेतील एक महत्त्वाचा टप्पा.';
  }

  @override
  String get milestones => 'टप्पे';

  @override
  String milestoneNext(String milestone) {
    return 'पुढील टप्पा: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString बाकी';
  }

  @override
  String get milestoneAllReached => 'सर्व टप्पे पूर्ण झाले';

  @override
  String get yearInReview => 'वर्षाचा आढावा';

  @override
  String yearInReviewTitle(int year) {
    return '$year मधील तुमचा जप';
  }

  @override
  String yearNoJaap(int year) {
    return '$year मध्ये कोणताही जप नोंदवलेला नाही';
  }

  @override
  String get yearActiveDays => 'जपाचे दिवस';

  @override
  String get yearLongestRun => 'सर्वात मोठे सातत्य';

  @override
  String yearLongestRunValue(int count) {
    return '$count दिवस';
  }

  @override
  String get yearBestDay => 'सर्वोत्तम दिवस';

  @override
  String get yearTopMantra => 'सर्वाधिक जपलेला';

  @override
  String get yearByMonth => 'महिन्यानुसार';

  @override
  String get yearMilestones => 'या वर्षीचे टप्पे';

  @override
  String yearShareText(int year, String count) {
    return '$year मधील माझा नाम जप: $count जप';
  }

  @override
  String get previousYear => 'मागील वर्ष';

  @override
  String get nextYear => 'पुढील वर्ष';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'इंदिरा एकादशी',
      'papankusha': 'पाशांकुशा एकादशी',
      'rama': 'रमा एकादशी',
      'devutthana': 'कार्तिकी (प्रबोधिनी) एकादशी',
      'utpanna': 'उत्पत्ती एकादशी',
      'mokshada': 'मोक्षदा एकादशी',
      'saphala': 'सफला एकादशी',
      'paushaPutrada': 'पौष पुत्रदा एकादशी',
      'shattila': 'षट्तिला एकादशी',
      'jaya': 'जया एकादशी',
      'vijaya': 'विजया एकादशी',
      'amalaki': 'आमलकी एकादशी',
      'papamochani': 'पापमोचनी एकादशी',
      'kamada': 'कामदा एकादशी',
      'varuthini': 'वरूथिनी एकादशी',
      'mohini': 'मोहिनी एकादशी',
      'apara': 'अपरा एकादशी',
      'nirjala': 'निर्जला एकादशी',
      'yogini': 'योगिनी एकादशी',
      'devshayani': 'आषाढी (देवशयनी) एकादशी',
      'kamika': 'कामिका एकादशी',
      'shravanaPutrada': 'श्रावण पुत्रदा एकादशी',
      'aja': 'अजा एकादशी',
      'parsva': 'परिवर्तिनी एकादशी',
      'other': 'एकादशी',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'शारदीय नवरात्र',
      'chaitraNavratri': 'चैत्र नवरात्र',
      'dussehra': 'दसरा',
      'diwali': 'दिवाळी',
      'kartikMonth': 'कार्तिक मास',
      'kartikPurnima': 'त्रिपुरारी पौर्णिमा',
      'guruNanakJayanti': 'गुरु नानक जयंती',
      'makarSankranti': 'मकर संक्रांत',
      'vasantPanchami': 'वसंत पंचमी',
      'mahaShivaratri': 'महाशिवरात्री',
      'holi': 'होळी',
      'ramNavami': 'रामनवमी',
      'mahavirJayanti': 'महावीर जयंती',
      'hanumanJayanti': 'हनुमान जयंती',
      'guruPurnima': 'गुरुपौर्णिमा',
      'shravanMonth': 'श्रावण मास',
      'rakshaBandhan': 'रक्षाबंधन',
      'krishnaJanmashtami': 'गोकुळाष्टमी',
      'ganeshChaturthi': 'गणेश चतुर्थी',
      'other': 'सण',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return '$date पासून सुरू';
  }

  @override
  String get upcomingObservances => 'एकादशी आणि सण';

  @override
  String get observanceToday => 'आज';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिवसांनी',
      one: 'उद्या',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return '$name निमित्त संकल्प';
  }

  @override
  String get observanceTakeSankalp => 'संकल्प घ्या';

  @override
  String observanceVaishnava(String date) {
    return 'वैष्णव (इस्कॉन) व्रत: $date';
  }

  @override
  String get observanceSourceNote =>
      'तारखा नवी दिल्लीसाठीच्या द्रिक पंचांगानुसार आहेत. तुमच्या स्थानिक मंदिरात किंवा परंपरेत एका दिवसाचा फरक असू शकतो.';

  @override
  String get observancesNone => 'पुढील काही आठवड्यांत काहीही नाही';

  @override
  String get festivalReminders => 'एकादशी आणि सणांची आठवण';

  @override
  String get festivalRemindersHint =>
      'एकादशी आणि सणांच्या दिवशी सकाळी 6 वाजता एक सूचना';

  @override
  String festivalNotificationBody(String name) {
    return 'आज $name आहे. नाम जपासाठी एक शुभ दिवस.';
  }

  @override
  String get sendDiagnostics => 'निदान अहवाल पाठवा';

  @override
  String get diagnosticsExplain =>
      'हा अहवाल एखादी अडचण दूर करण्यास मदत करतो. त्यात ॲप आणि फोनच्या आवृत्त्या, तुमच्या सेटिंग्ज आणि ॲपमधील त्रुटींची नोंद असते. त्यात कोणतेही मंत्र, मोजणी किंवा टिपा नसतात. तुम्ही खाली एखादा मार्ग निवडेपर्यंत काहीही पाठवले जात नाही.';

  @override
  String get diagnosticsEmail => 'ईमेल करा';

  @override
  String get diagnosticsShare => 'फाइल म्हणून शेअर करा';

  @override
  String get diagnosticsEmailSubject => 'Smaran निदान';

  @override
  String get diagnosticsNoMail =>
      'कोणतेही मेल ॲप सापडले नाही. फाइल म्हणून शेअर करून पाहा.';
}
