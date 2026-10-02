// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppL10nTe extends AppL10n {
  AppL10nTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'నామ జప కౌంటర్ – స్మరణ';

  @override
  String get tagline => 'మీ రోజువారీ నామ జపానికి ప్రశాంతమైన డిజిటల్ జపమాల';

  @override
  String get navJaap => 'జపం';

  @override
  String get navProgress => 'పురోగతి';

  @override
  String get navStories => 'కథలు';

  @override
  String get navSettings => 'సెట్టింగ్‌లు';

  @override
  String get cancel => 'రద్దు';

  @override
  String get save => 'సేవ్ చేయి';

  @override
  String get delete => 'తొలగించు';

  @override
  String get edit => 'మార్చు';

  @override
  String get close => 'మూసివేయి';

  @override
  String get next => 'తదుపరి';

  @override
  String get skip => 'దాటవేయి';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించు';

  @override
  String get custom => 'మీ ఇష్టం';

  @override
  String get active => 'క్రియాశీలం';

  @override
  String get off => 'ఆఫ్';

  @override
  String get somethingWentWrong => 'ఏదో పొరపాటు జరిగింది';

  @override
  String get tapToCount => 'లెక్కించడానికి తాకండి';

  @override
  String get todaysJaap => 'నేటి జపం';

  @override
  String get undo => 'రద్దు చేయి';

  @override
  String get malaComplete => 'మాల పూర్తయింది';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మాలలు పూర్తయ్యాయి',
      one: '1 మాల పూర్తయింది',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString జపాలు';
  }

  @override
  String get nothingToUndo => 'రద్దు చేయడానికి ఏమీ లేదు';

  @override
  String get countRemoved => 'లెక్క తొలగించబడింది';

  @override
  String get resetCurrentMala => 'ప్రస్తుత మాలను రీసెట్ చేయండి';

  @override
  String get resetCurrentMalaBody =>
      'ఈ మాలలో లెక్కించిన పూసలు తొలగించబడతాయి. పూర్తయిన మాలలు భద్రంగా ఉంటాయి.';

  @override
  String get addCountManually => 'లెక్కను మీరే జోడించండి';

  @override
  String get addCount => 'లెక్క జోడించు';

  @override
  String get numberOfJaap => 'జపాల సంఖ్య';

  @override
  String get meditationMode => 'ధ్యాన మోడ్';

  @override
  String get startSession => 'సెషన్ ప్రారంభించు';

  @override
  String get endSession => 'సెషన్ ముగించు';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$minutes నిమిషాల్లో $jaap జపాలు';
  }

  @override
  String get myMantras => 'నా మంత్రాలు';

  @override
  String get addMantra => 'మంత్రం జోడించు';

  @override
  String get editMantra => 'మంత్రం మార్చు';

  @override
  String get malaSize => 'మాల పరిమాణం';

  @override
  String beads(int count) {
    return '$count పూసలు';
  }

  @override
  String get malaSizeInvalid => 'మాల పరిమాణం 1 నుండి 10,000 మధ్య ఉండాలి';

  @override
  String get deleteMantraTitle => 'మంత్రాన్ని తొలగించాలా?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" తొలగించబడుతుంది. మీ జప చరిత్ర భద్రంగా ఉంటుంది.';
  }

  @override
  String get optional => 'ఐచ్ఛికం';

  @override
  String get mySadhana => 'నా సాధన';

  @override
  String get todaysGoal => 'నేటి లక్ష్యం';

  @override
  String get complete => 'పూర్తయింది';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల వరుస',
      one: '1 రోజు వరుస',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'అత్యుత్తమ వరుస';

  @override
  String sankalpDays(int days) {
    return '$days రోజుల సంకల్పం';
  }

  @override
  String dayXofY(int current, int total) {
    return 'రోజు $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజులు పూర్తయ్యాయి',
      one: '1 రోజు పూర్తయింది',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return 'ప్రారంభం: $date';
  }

  @override
  String get createNewSankalp => 'కొత్త సంకల్పం తీసుకోండి';

  @override
  String get createSankalp => 'సంకల్పం తీసుకోండి';

  @override
  String get chooseMantra => 'మంత్రం ఎంచుకోండి';

  @override
  String get dailyGoal => 'రోజువారీ లక్ష్యం';

  @override
  String get duration => 'వ్యవధి';

  @override
  String durationDays(int days) {
    return '$days రోజులు';
  }

  @override
  String get reminder => 'రిమైండర్';

  @override
  String get beginSadhana => 'సాధన ప్రారంభించండి';

  @override
  String get noSankalpTitle => 'సంకల్పం ప్రారంభించండి';

  @override
  String get noSankalpBody =>
      'సంకల్పం అంటే ఒక వ్రతం – మీరు ఎంచుకున్న రోజుల పాటు ప్రతిరోజూ నిర్ణీత సంఖ్యలో జపం చేయడం.';

  @override
  String get endSankalp => 'సంకల్పం ముగించు';

  @override
  String get endSankalpBody =>
      'మీ పురోగతి భద్రంగా ఉంటుంది, కానీ సంకల్పం ఇకపై క్రియాశీలంగా ఉండదు.';

  @override
  String jaapPerDay(int count) {
    return 'రోజుకు $count జపాలు';
  }

  @override
  String goalRemaining(int count) {
    return 'ఇంకా $count';
  }

  @override
  String get goalReached => 'నేటి లక్ష్యం పూర్తయింది';

  @override
  String get setDailyGoal => 'రోజువారీ లక్ష్యం నిర్ణయించండి';

  @override
  String get sadhanaGoals => 'సాధన లక్ష్యాలు';

  @override
  String get progress => 'పురోగతి';

  @override
  String get filterDaily => 'రోజువారీ';

  @override
  String get filterWeekly => 'వారానికి';

  @override
  String get filterMonthly => 'నెలకు';

  @override
  String get filterYearly => 'సంవత్సరానికి';

  @override
  String get totalJaap => 'మొత్తం జపాలు';

  @override
  String get totalMalas => 'మొత్తం మాలలు';

  @override
  String get weeklyJaap => 'వారపు జపం';

  @override
  String get monthlyJaap => 'నెలవారీ జపం';

  @override
  String get yearlyJaap => 'సంవత్సరపు జపం';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ $countString లక్ష్యం';
  }

  @override
  String get noJaapYet => 'ఇంకా జపం నమోదు కాలేదు';

  @override
  String get noJaapYetBody => 'మొదటి పూసే ప్రయాణానికి ఆరంభం.';

  @override
  String get dailyAverage => 'రోజువారీ సగటు';

  @override
  String get activeDays => 'జపం చేసిన రోజులు';

  @override
  String get perMantra => 'మంత్రాల వారీగా';

  @override
  String get stories => 'కథలు';

  @override
  String get storiesSubtitle => 'మననం కోసం చిన్న కథలు';

  @override
  String get popular => 'ప్రసిద్ధమైనవి';

  @override
  String get read => 'చదవండి';

  @override
  String get listen => 'వినండి';

  @override
  String get stopListening => 'ఆపు';

  @override
  String get textSize => 'అక్షరాల పరిమాణం';

  @override
  String get favorite => 'ఇష్టమైనది';

  @override
  String get favorites => 'ఇష్టమైనవి';

  @override
  String get share => 'పంచుకోండి';

  @override
  String get all => 'అన్నీ';

  @override
  String minRead(int minutes) {
    return '$minutes నిమిషాల పఠనం';
  }

  @override
  String get noFavoritesTitle => 'ఇంకా ఇష్టమైనవి లేవు';

  @override
  String get noFavoritesBody =>
      'ఏదైనా కథపై హృదయ చిహ్నాన్ని తాకితే అది ఇక్కడ ఉంటుంది.';

  @override
  String get noStoriesFound => 'కథలు ఏవీ దొరకలేదు';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get sectionJaap => 'జపం';

  @override
  String get sectionReminders => 'రిమైండర్‌లు';

  @override
  String get sectionAppearance => 'రూపం';

  @override
  String get sectionBackup => 'బ్యాకప్';

  @override
  String get sectionSupport => 'సహాయం';

  @override
  String get sectionAbout => 'పరిచయం';

  @override
  String get resetCounts => 'లెక్కలు రీసెట్ చేయండి';

  @override
  String get jaapReminders => 'జప రిమైండర్‌లు';

  @override
  String get streakReminder => 'వరుస రిమైండర్';

  @override
  String get goalReminder => 'లక్ష్య రిమైండర్';

  @override
  String get theme => 'థీమ్';

  @override
  String get haptics => 'కంపనం';

  @override
  String get sound => 'శబ్దం';

  @override
  String get language => 'భాష';

  @override
  String get languageSystem => 'సిస్టమ్ ప్రకారం';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'బ్యాకప్ & పునరుద్ధరణ';

  @override
  String get exportMyData => 'నా డేటాను ఎగుమతి చేయండి';

  @override
  String get rateApp => 'స్మరణకు రేటింగ్ ఇవ్వండి';

  @override
  String get shareApp => 'కుటుంబాన్ని, స్నేహితులను ఆహ్వానించండి';

  @override
  String get feedback => 'అభిప్రాయం';

  @override
  String get privacyPolicy => 'గోప్యతా విధానం';

  @override
  String get terms => 'నిబంధనలు';

  @override
  String get aboutApp => 'స్మరణ గురించి';

  @override
  String version(String version) {
    return 'వెర్షన్ $version';
  }

  @override
  String get resetTodayTitle => 'నేటి జపాన్ని రీసెట్ చేయాలా?';

  @override
  String get resetTodayBody =>
      'ఈ రోజు నమోదైన జపం అంతా తొలగించబడుతుంది. దీన్ని తిరిగి పొందలేరు.';

  @override
  String get resetAllTitle => 'మొత్తం జపాన్ని రీసెట్ చేయాలా?';

  @override
  String get resetAllBody =>
      'మీ పూర్తి జప చరిత్ర, మాలలు, వరుసలు శాశ్వతంగా తొలగించబడతాయి. దీన్ని తిరిగి పొందలేరు.';

  @override
  String get resetToday => 'నేటిది రీసెట్ చేయి';

  @override
  String get resetEverything => 'అన్నీ రీసెట్ చేయి';

  @override
  String get resetDone => 'లెక్కలు రీసెట్ అయ్యాయి';

  @override
  String get aboutBody =>
      'స్మరణ మీ రోజువారీ నామ జపానికి ఒక ప్రశాంతమైన, వ్యక్తిగత స్థలం. మీరు చేసే జపం అంతా ఈ పరికరంలో మాత్రమే భద్రంగా ఉంటుంది.';

  @override
  String get madeWith => 'భక్తితో రూపొందించబడింది';

  @override
  String get addReminder => 'రిమైండర్ జోడించు';

  @override
  String get reminderTime => 'సమయం';

  @override
  String get everyDay => 'ప్రతిరోజూ';

  @override
  String get noRemindersTitle => 'ఇంకా రిమైండర్‌లు లేవు';

  @override
  String get noRemindersBody =>
      'ప్రతిరోజూ ఒకే సమయానికి ఒక చిన్న గుర్తు సాధనను అలవాటుగా మారుస్తుంది.';

  @override
  String get notificationsBlocked =>
      'స్మరణకు నోటిఫికేషన్‌లు ఆఫ్‌లో ఉన్నాయి. మీ పరికర సెట్టింగ్‌లలో వాటిని ఆన్ చేయండి.';

  @override
  String get reminderNotificationTitle => 'జపానికి సమయమైంది';

  @override
  String get reminderNotificationBody => 'మీ జపమాలతో కొన్ని ప్రశాంత క్షణాలు 🙏';

  @override
  String get streakNotificationTitle => 'మీ వరుసను కొనసాగించండి';

  @override
  String get streakNotificationBody =>
      'ఈ రోజు ఇంకా జపం చేయలేదు. ఒక్క మాల చేసినా వరుస కొనసాగుతుంది.';

  @override
  String get goalNotificationTitle => 'దాదాపు చేరుకున్నారు';

  @override
  String get goalNotificationBody =>
      'నేటి లక్ష్యాన్ని పూర్తి చేసి, ఈ రోజు సాధనను సంపూర్ణం చేసుకోండి.';

  @override
  String get createBackup => 'బ్యాకప్ సృష్టించు';

  @override
  String get createBackupBody =>
      'మీ మంత్రాలు, జప చరిత్ర, లక్ష్యాలు, సెట్టింగ్‌లు అన్నింటితో ఒక JSON ఫైల్‌ను సేవ్ చేయండి.';

  @override
  String get restoreBackup => 'బ్యాకప్ నుండి పునరుద్ధరించు';

  @override
  String get restoreBackupBody =>
      'పునరుద్ధరించడానికి స్మరణ బ్యాకప్ ఫైల్‌ను ఎంచుకోండి.';

  @override
  String get backupCreated => 'బ్యాకప్ సృష్టించబడింది';

  @override
  String get restoreWarningTitle => 'మొత్తం డేటాను మార్చాలా?';

  @override
  String get restoreWarningBody =>
      'పునరుద్ధరిస్తే, స్మరణలో ఇప్పుడు ఉన్న డేటా అంతా బ్యాకప్ ఫైల్‌లోని డేటాతో మారిపోతుంది.';

  @override
  String get restore => 'పునరుద్ధరించు';

  @override
  String restoreSuccess(int count) {
    return '$count జప నమోదులు పునరుద్ధరించబడ్డాయి';
  }

  @override
  String get importInvalid => 'ఈ ఫైల్ సరైన స్మరణ బ్యాకప్ కాదు';

  @override
  String get exportShareText => 'నా స్మరణ బ్యాకప్';

  @override
  String get onb1Title => 'మీ డిజిటల్ జపమాల';

  @override
  String get onb1Body => 'ప్రతి నామ జపాన్ని లెక్కించడానికి ఒక ప్రశాంత మార్గం.';

  @override
  String get onb2Title => 'సాధనను అలవాటుగా చేసుకోండి';

  @override
  String get onb2Body =>
      'రోజువారీ లక్ష్యం పెట్టుకుని, మీ జప వరుసను పెంచుకోండి.';

  @override
  String get onb3Title => 'ఏకాగ్రతతో జపం చేయండి';

  @override
  String get onb3Body =>
      'శుభ్రమైన, ప్రశాంతమైన కౌంటర్‌తో ధ్యాన మోడ్‌లోకి వెళ్లండి.';

  @override
  String get startJap => 'జపం ప్రారంభించండి';

  @override
  String get blackout => 'చీకటి';

  @override
  String get timer => 'టైమర్';

  @override
  String get exitMeditation => 'ధ్యాన మోడ్ నుండి బయటకు';

  @override
  String get tapAnywhere => 'లెక్కించడానికి ఎక్కడైనా తాకండి';

  @override
  String semanticCounter(int count, int total) {
    return 'జప కౌంటర్. $total పూసల్లో $count. ఒకటి లెక్కించడానికి రెండుసార్లు తాకండి.';
  }

  @override
  String get autoJaap => 'ఆటో జపం';

  @override
  String get autoJaapBody =>
      'యాప్ స్థిరమైన వేగంతో మీ కోసం లెక్కిస్తుంది, మీరు చేతులు ఉపయోగించకుండానే జపం చేయవచ్చు.';

  @override
  String get autoJaapPace => 'వేగం';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds సె.';
  }

  @override
  String get autoJaapStopAfter => 'ఎప్పుడు ఆపాలి';

  @override
  String get autoJaapStopMala => 'ఒక మాల';

  @override
  String get autoJaapStopGoal => 'రోజువారీ లక్ష్యం';

  @override
  String get autoJaapStopNever => 'ఆపవద్దు';

  @override
  String get autoJaapStart => 'ఆటో జపం ప్రారంభించు';

  @override
  String get autoJaapStopAction => 'ఆటో జపం ఆపు';

  @override
  String counterCount(String count) {
    return 'లెక్క: $count';
  }

  @override
  String counterMalas(String count) {
    return 'మాలలు: $count';
  }

  @override
  String counterTotal(String count) {
    return 'మొత్తం: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'ఆటో జపం నడుస్తోంది · ఆపడానికి ఎక్కడైనా తాకండి';

  @override
  String get hideMantra => 'మంత్రం దాచు';

  @override
  String get showMantra => 'మంత్రం చూపించు';

  @override
  String get changeTheme => 'థీమ్ మార్చు';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల వరుస',
      one: '1 రోజు వరుస',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'మెనూ';

  @override
  String get chooseTheme => 'థీమ్ ఎంచుకోండి';

  @override
  String get themeAuto => 'ఆటో';

  @override
  String get themeWhite => 'తెలుపు';

  @override
  String get themeBlack => 'నలుపు';

  @override
  String get themePastelPink => 'లేత గులాబీ';

  @override
  String get themeSpiritual => 'ఆధ్యాత్మికం';

  @override
  String get themeSaffron => 'కాషాయం';

  @override
  String get themePeaceful => 'ప్రశాంతం';

  @override
  String get themeTerracotta => 'టెర్రకోటా';

  @override
  String get themeMeditative => 'ధ్యానం';

  @override
  String get themeNature => 'ప్రకృతి';

  @override
  String get themeRoseGold => 'రోజ్ గోల్డ్';

  @override
  String get themeOcean => 'సముద్రం';

  @override
  String get themeLavender => 'లావెండర్';

  @override
  String get themeCharcoal => 'చార్‌కోల్';

  @override
  String get counterBackground => 'కౌంటర్ నేపథ్యం';

  @override
  String get counterBackgroundBody =>
      'కౌంటర్‌పై మంత్రం, పూసల వెనుక కనిపిస్తుంది.';

  @override
  String get backgroundNone => 'ఏదీ వద్దు';

  @override
  String get backgroundDawn => 'ఉషోదయం';

  @override
  String get backgroundDusk => 'సంధ్య';

  @override
  String get backgroundLotus => 'కమలం';

  @override
  String get backgroundForest => 'అడవి';

  @override
  String get backgroundOcean => 'సముద్రం';

  @override
  String get backgroundCosmos => 'బ్రహ్మాండం';

  @override
  String get backgroundPhoto => 'నా ఫోటో';

  @override
  String get backgroundChoosePhoto => 'ఫోటో ఎంచుకోండి';

  @override
  String get backgroundChangePhoto => 'ఫోటో మార్చు';

  @override
  String get backgroundRemovePhoto => 'ఫోటో తొలగించు';

  @override
  String get backgroundDim => 'నేపథ్యాన్ని మసకబార్చు';

  @override
  String get backgroundDimHint =>
      'ఎక్కువ మసకబారిస్తే మంత్రం చదవడం సులువుగా ఉంటుంది.';

  @override
  String get addOwnMantra => 'మీ సొంత మంత్రం జోడించండి';

  @override
  String get addOwnMantraHint =>
      'ఏ నామమైనా, మంత్రమైనా, ఏ లిపిలోనైనా, మీకు నచ్చిన మాల పరిమాణంతో';

  @override
  String get legendLess => 'తక్కువ';

  @override
  String get legendMore => 'ఎక్కువ';

  @override
  String get allMantras => 'అన్ని మంత్రాలు';

  @override
  String get previousPeriod => 'మునుపటి';

  @override
  String get nextPeriod => 'తదుపరి';

  @override
  String get showStatsFor => 'వీటి గణాంకాలు చూపించు';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count జపాలు · $malas మాలలు';
  }

  @override
  String get dailyJaap => 'రోజువారీ జపం';

  @override
  String get mantraText => 'మంత్రం';

  @override
  String get mantraTextHint => 'ఉదా. राम లేదా ఓం నమః శివాయ';

  @override
  String get mantraRequired => 'దయచేసి మంత్రాన్ని నమోదు చేయండి';

  @override
  String get mantraDescription => 'వివరణ';

  @override
  String get mantraDescriptionHint => 'అర్థం, మూలం లేదా మీ కోసం ఒక గమనిక';

  @override
  String get dictationStart => 'మాట్లాడి మంత్రాన్ని నమోదు చేయండి';

  @override
  String get dictationListening => 'వింటోంది… ఆపడానికి తాకండి';

  @override
  String get dictationUnavailable => 'ఈ పరికరంలో మాటతో టైప్ చేసే సౌకర్యం లేదు';

  @override
  String get dictationOfflineUnavailable =>
      'ఈ ఫోన్‌లో ఈ భాషకు ఆఫ్‌లైన్ వాయిస్ ఇన్‌పుట్ అందుబాటులో లేదు. మీ స్వరం పరికరం దాటి ఎక్కడికీ వెళ్లదు, కాబట్టి దయచేసి టైప్ చేయండి.';

  @override
  String get micPermissionDenied => 'దీనికి మైక్రోఫోన్ అనుమతి అవసరం';

  @override
  String get voiceNote => 'వాయిస్ నోట్';

  @override
  String get voiceNoteHint => 'మీరు జపిస్తుండగా రికార్డ్ చేసుకోండి';

  @override
  String get voiceNoteRecord => 'రికార్డ్ చేయి';

  @override
  String get voiceNoteRecording => 'రికార్డ్ అవుతోంది… ఆపడానికి తాకండి';

  @override
  String get voiceNotePlay => 'వాయిస్ నోట్ ప్లే చేయి';

  @override
  String get voiceNotePause => 'వాయిస్ నోట్ ఆపు';

  @override
  String get voiceNoteDelete => 'వాయిస్ నోట్ తొలగించు';

  @override
  String get voiceNoteMissing => 'ఈ వాయిస్ నోట్ ఇప్పుడు ఈ ఫోన్‌లో లేదు';

  @override
  String get fallingMantra => 'రాలే మంత్రం';

  @override
  String get stopFallingMantra => 'రాలే మంత్రం ఆపు';

  @override
  String get malaStyle => 'మాల శైలి';

  @override
  String get malaStyleBeads => 'పూసలు';

  @override
  String get malaStyleRing => 'పురోగతి వలయం';

  @override
  String get sectionCounter => 'కౌంటర్';

  @override
  String get showMantraOnCounter => 'కౌంటర్‌పై మంత్రం చూపించు';

  @override
  String get goalUnitMalas => 'మాలలు';

  @override
  String get goalUnitJaap => 'జపాలు';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మాలలు',
      one: '1 మాల',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'రోజుకు మాలలు';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: 'రోజుకు $malas మాలలు',
      one: 'రోజుకు 1 మాల',
    );
    return '$_temp0 · $jaap జపాలు';
  }

  @override
  String get onbMantraTitle => 'మీరు ఏ మంత్రం జపిస్తారు?';

  @override
  String get onbMantraBody =>
      'ప్రారంభించడానికి ఒకటి ఎంచుకోండి. మరిన్ని ఎప్పుడైనా జోడించవచ్చు.';

  @override
  String get onbGoalTitle => 'మీ రోజువారీ లక్ష్యం';

  @override
  String get onbGoalBody =>
      'చిన్నగా ప్రారంభించండి: పెద్ద సంఖ్య కంటే నిత్యం చేసే సాధనే ముఖ్యం. దీన్ని ఎప్పుడైనా మార్చుకోవచ్చు.';

  @override
  String get shareProgress => 'నా పురోగతిని పంచుకోండి';

  @override
  String get shareStreakLabel => 'రోజుల వరుస';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'స్మరణతో వరుసగా $count రోజులు నామ జపం 🙏',
      one: 'స్మరణతో 1 రోజు నామ జపం 🙏',
    );
    return '$_temp0';
  }

  @override
  String get blackoutMode => 'చీకటి మోడ్';

  @override
  String get exitBlackout => 'చీకటి మోడ్ నుండి బయటకు';

  @override
  String get feedbackEmailSubject => 'స్మరణపై అభిప్రాయం';

  @override
  String get homeScreenWidget => 'హోమ్ స్క్రీన్ విడ్జెట్';

  @override
  String get homeScreenWidgetBody =>
      'యాప్ తెరవకుండానే నేటి జపం, మీ వరుసను హోమ్ స్క్రీన్‌పై చూడండి.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'హోమ్ స్క్రీన్‌పై ఖాళీ చోట నొక్కి పట్టుకోండి, విడ్జెట్‌లు తాకండి, తర్వాత స్మరణను వెతకండి.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'హోమ్ స్క్రీన్‌పై ఖాళీ చోట నొక్కి పట్టుకోండి, మూలలో ఉన్న + తాకండి, స్మరణను వెతకండి, తర్వాత పరిమాణం ఎంచుకుని విడ్జెట్ జోడించు తాకండి.';

  @override
  String get addToHomeScreen => 'హోమ్ స్క్రీన్‌కు జోడించు';

  @override
  String get countWithButtons => 'బటన్‌లతో లెక్కించండి';

  @override
  String get countWithButtonsHintAndroid =>
      'వాల్యూమ్ బటన్‌లు, హెడ్‌సెట్ బటన్ లేదా Bluetooth క్లిక్కర్‌తో ఒక పూస లెక్కించబడుతుంది';

  @override
  String get countWithButtonsHintIOS =>
      'Bluetooth క్లిక్కర్ లేదా కీబోర్డ్‌తో ఒక పూస లెక్కించబడుతుంది. iPhone వాల్యూమ్ బటన్‌లను యాప్‌లు ఉపయోగించలేవు.';

  @override
  String get lockScreenCounter => 'లాక్ స్క్రీన్ కౌంటర్';

  @override
  String get lockScreenCounterHint =>
      'మీ లాక్ స్క్రీన్ మరియు Dynamic Island పై +1 బటన్. తదుపరిసారి యాప్ తెరిచినప్పుడు ఈ లెక్క మీ జపంలో చేరుతుంది.';

  @override
  String get markerBead => 'గుర్తు పూస';

  @override
  String get markerBeadHint =>
      'మాల మధ్యలో ఒక గట్టి కంపనం, కళ్లు మూసుకున్నా మీరు ఎక్కడ ఉన్నారో తెలుస్తుంది';

  @override
  String markerBeadEvery(int count) {
    return 'ప్రతి $countకి';
  }

  @override
  String get markerBeadOff => 'ఆఫ్';

  @override
  String get graceDays => 'మినహాయింపు రోజులు';

  @override
  String get graceDaysHint =>
      'వరుసగా ప్రతి 7 రోజులకు ఒక మినహాయింపు రోజు లభిస్తుంది (గరిష్ఠంగా 2). ఏదైనా రోజు తప్పిపోతే, మీ వరుస తెగకుండా ఒక మినహాయింపు రోజు వాడబడుతుంది.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మినహాయింపు రోజులు ఉన్నాయి',
      one: '1 మినహాయింపు రోజు ఉంది',
      zero: 'మినహాయింపు రోజులు లేవు',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'మినహాయింపు రోజుతో పూర్తయింది';

  @override
  String milestoneLakh(int count) {
    return '$count లక్షల జపాలు';
  }

  @override
  String get milestoneSavaLakh => 'సవా లక్ష జపాలు';

  @override
  String get milestoneCrore => '1 కోటి జపాలు';

  @override
  String milestoneStreak(int days) {
    return '$days రోజుల వరుస';
  }

  @override
  String milestoneReached(String milestone) {
    return '$milestone పూర్తయింది. మీ సాధనలో ఒక మైలురాయి.';
  }

  @override
  String get milestones => 'మైలురాళ్లు';

  @override
  String milestoneNext(String milestone) {
    return 'తదుపరి: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'ఇంకా $countString';
  }

  @override
  String get milestoneAllReached => 'అన్ని మైలురాళ్లు చేరుకున్నారు';

  @override
  String get yearInReview => 'సంవత్సర సారాంశం';

  @override
  String yearInReviewTitle(int year) {
    return 'జపంలో మీ $year';
  }

  @override
  String yearNoJaap(int year) {
    return '$yearలో జపం నమోదు కాలేదు';
  }

  @override
  String get yearActiveDays => 'జపం చేసిన రోజులు';

  @override
  String get yearLongestRun => 'అతి పొడవైన వరుస';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజులు',
      one: '1 రోజు',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'ఉత్తమ రోజు';

  @override
  String get yearTopMantra => 'ఎక్కువగా జపించినది';

  @override
  String get yearByMonth => 'నెలల వారీగా';

  @override
  String get yearMilestones => 'ఈ సంవత్సరపు మైలురాళ్లు';

  @override
  String yearShareText(int year, String count) {
    return 'నామ జపంలో నా $year: $count జపాలు';
  }

  @override
  String get previousYear => 'మునుపటి సంవత్సరం';

  @override
  String get nextYear => 'తదుపరి సంవత్సరం';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'ఇందిరా ఏకాదశి',
      'papankusha': 'పాపాంకుశ ఏకాదశి',
      'rama': 'రమా ఏకాదశి',
      'devutthana': 'ఉత్థాన ఏకాదశి',
      'utpanna': 'ఉత్పన్న ఏకాదశి',
      'mokshada': 'మోక్షద ఏకాదశి',
      'saphala': 'సఫల ఏకాదశి',
      'paushaPutrada': 'పుష్య పుత్రద ఏకాదశి',
      'shattila': 'షట్తిల ఏకాదశి',
      'jaya': 'జయ ఏకాదశి',
      'vijaya': 'విజయ ఏకాదశి',
      'amalaki': 'ఆమలకీ ఏకాదశి',
      'papamochani': 'పాపమోచని ఏకాదశి',
      'kamada': 'కామద ఏకాదశి',
      'varuthini': 'వరూథిని ఏకాదశి',
      'mohini': 'మోహినీ ఏకాదశి',
      'apara': 'అపర ఏకాదశి',
      'nirjala': 'నిర్జల ఏకాదశి',
      'yogini': 'యోగిని ఏకాదశి',
      'devshayani': 'తొలి ఏకాదశి',
      'kamika': 'కామిక ఏకాదశి',
      'shravanaPutrada': 'శ్రావణ పుత్రద ఏకాదశి',
      'aja': 'అజ ఏకాదశి',
      'parsva': 'పరివర్తన ఏకాదశి',
      'other': 'ఏకాదశి',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'దసరా నవరాత్రులు',
      'chaitraNavratri': 'వసంత నవరాత్రులు',
      'dussehra': 'విజయదశమి',
      'diwali': 'దీపావళి',
      'kartikMonth': 'కార్తీక మాసం',
      'kartikPurnima': 'కార్తీక పౌర్ణమి',
      'guruNanakJayanti': 'గురునానక్ జయంతి',
      'makarSankranti': 'సంక్రాంతి',
      'vasantPanchami': 'శ్రీ పంచమి',
      'mahaShivaratri': 'మహా శివరాత్రి',
      'holi': 'హోలీ',
      'ramNavami': 'శ్రీరామ నవమి',
      'mahavirJayanti': 'మహావీర్ జయంతి',
      'hanumanJayanti': 'హనుమాన్ జయంతి',
      'guruPurnima': 'గురు పౌర్ణమి',
      'shravanMonth': 'శ్రావణ మాసం',
      'rakshaBandhan': 'రాఖీ పౌర్ణమి',
      'krishnaJanmashtami': 'శ్రీకృష్ణ జన్మాష్టమి',
      'ganeshChaturthi': 'వినాయక చవితి',
      'other': 'పండుగ',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return 'ప్రారంభం: $date';
  }

  @override
  String get upcomingObservances => 'ఏకాదశులు, పండుగలు';

  @override
  String get observanceToday => 'ఈ రోజు';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల్లో',
      one: 'రేపు',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return '$name సంకల్పం';
  }

  @override
  String get observanceTakeSankalp => 'సంకల్పం తీసుకోండి';

  @override
  String observanceVaishnava(String date) {
    return 'వైష్ణవ (ISKCON) వ్రతం: $date';
  }

  @override
  String get observanceSourceNote =>
      'తేదీలు న్యూఢిల్లీకి దృక్ పంచాంగం (Drik Panchang) ప్రకారం ఉన్నాయి. మీ స్థానిక ఆలయం లేదా సంప్రదాయంలో ఒక రోజు తేడా ఉండవచ్చు.';

  @override
  String get observancesNone => 'రాబోయే కొన్ని వారాల్లో ఏమీ లేవు';

  @override
  String get festivalReminders => 'ఏకాదశి, పండుగ రిమైండర్‌లు';

  @override
  String get festivalRemindersHint =>
      'ఏకాదశి, పండుగ రోజుల్లో ఉదయం 6 గంటలకు ఒక సందేశం';

  @override
  String festivalNotificationBody(String name) {
    return 'ఈ రోజు $name. నామ జపానికి శుభ దినం.';
  }

  @override
  String get sendDiagnostics => 'డయాగ్నస్టిక్స్ పంపండి';

  @override
  String get diagnosticsExplain =>
      'ఈ నివేదిక ఒక సమస్యను సరిచేయడానికి సహాయపడుతుంది. ఇందులో యాప్, ఫోన్ వెర్షన్‌లు, మీ సెట్టింగ్‌లు, యాప్ లోపాల లాగ్ ఉంటాయి. మంత్రాలు, లెక్కలు, గమనికలు ఇందులో ఉండవు. కింద మీరు పద్ధతిని ఎంచుకునే వరకు ఏదీ పంపబడదు.';

  @override
  String get diagnosticsEmail => 'ఈమెయిల్ చేయి';

  @override
  String get diagnosticsShare => 'ఫైల్‌గా పంచుకోండి';

  @override
  String get diagnosticsEmailSubject => 'స్మరణ డయాగ్నస్టిక్స్';

  @override
  String get diagnosticsNoMail =>
      'మెయిల్ యాప్ కనిపించలేదు. ఫైల్‌గా పంచుకుని ప్రయత్నించండి.';
}
