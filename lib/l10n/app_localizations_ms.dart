// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppL10nMs extends AppL10n {
  AppL10nMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'Pengira Japa: JaapMitra';

  @override
  String get tagline => 'Teman Bhakti, Setiap Hari';

  @override
  String get navJaap => 'Japa';

  @override
  String get navProgress => 'Kemajuan';

  @override
  String get navStories => 'Kisah';

  @override
  String get navSettings => 'Tetapan';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Padam';

  @override
  String get edit => 'Sunting';

  @override
  String get close => 'Tutup';

  @override
  String get next => 'Seterusnya';

  @override
  String get skip => 'Langkau';

  @override
  String get back => 'Kembali';

  @override
  String get retry => 'Cuba lagi';

  @override
  String get custom => 'Tersuai';

  @override
  String get active => 'Aktif';

  @override
  String get off => 'TUTUP';

  @override
  String get somethingWentWrong => 'Ada sesuatu yang tidak kena';

  @override
  String get tapToCount => 'KETIK UNTUK MENGIRA';

  @override
  String get todaysJaap => 'Japa Hari Ini';

  @override
  String get undo => 'Buat asal';

  @override
  String get malaComplete => 'Satu Mala Selesai';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mala selesai',
      one: '1 mala selesai',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString Japa';
  }

  @override
  String get resetCurrentMala => 'Set semula mala ini';

  @override
  String get resetCurrentMalaBody =>
      'Manik yang telah dikira dalam mala ini akan dibuang. Mala yang telah selesai tetap disimpan.';

  @override
  String get addCountManually => 'Tambah kiraan secara manual';

  @override
  String get addCount => 'Tambah kiraan';

  @override
  String get numberOfJaap => 'Bilangan japa';

  @override
  String get meditationMode => 'Mod meditasi';

  @override
  String get startSession => 'Mula sesi';

  @override
  String get endSession => 'Tamatkan sesi';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$jaap japa dalam $minutes minit';
  }

  @override
  String get myMantras => 'Mantra Saya';

  @override
  String get addMantra => 'Tambah Mantra';

  @override
  String get editMantra => 'Sunting Mantra';

  @override
  String get malaSize => 'Saiz Mala';

  @override
  String beads(int count) {
    return '$count manik';
  }

  @override
  String get malaSizeInvalid => 'Saiz mala mestilah antara 1 hingga 10,000';

  @override
  String get deleteMantraTitle => 'Padam mantra?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" akan dibuang. Sejarah japa anda tetap disimpan.';
  }

  @override
  String get optional => 'pilihan';

  @override
  String get mySadhana => 'Sadhana Saya';

  @override
  String get todaysGoal => 'Sasaran Hari Ini';

  @override
  String get complete => 'Selesai';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rentetan $count Hari',
      one: 'Rentetan 1 Hari',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'Rentetan terbaik';

  @override
  String sankalpDays(int days) {
    return 'SANKALPA $days HARI';
  }

  @override
  String dayXofY(int current, int total) {
    return 'Hari $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari selesai',
      one: '1 hari selesai',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return 'Bermula $date';
  }

  @override
  String get createNewSankalp => 'Cipta Sankalpa Baharu';

  @override
  String get createSankalp => 'Cipta Sankalpa';

  @override
  String get chooseMantra => 'Pilih Mantra';

  @override
  String get dailyGoal => 'Sasaran Harian';

  @override
  String get duration => 'Tempoh';

  @override
  String durationDays(int days) {
    return '$days hari';
  }

  @override
  String get reminder => 'Peringatan';

  @override
  String get beginSadhana => 'Mulakan Sadhana';

  @override
  String get noSankalpTitle => 'Mulakan Sankalpa';

  @override
  String get noSankalpBody =>
      'Sankalpa ialah ikrar untuk melafazkan sejumlah japa setiap hari selama bilangan hari yang anda pilih.';

  @override
  String get endSankalp => 'Tamatkan Sankalpa';

  @override
  String get endSankalpBody =>
      'Kemajuan anda tetap disimpan, tetapi Sankalpa tidak lagi aktif.';

  @override
  String jaapPerDay(int count) {
    return '$count japa sehari';
  }

  @override
  String goalRemaining(int count) {
    return '$count lagi';
  }

  @override
  String get goalReached => 'Sasaran harian tercapai';

  @override
  String get goalReachedAutoBody =>
      'Japa Automatik dijeda. Teruskan atau berhenti di sini?';

  @override
  String get keepGoing => 'Teruskan';

  @override
  String get setDailyGoal => 'Tetapkan sasaran harian';

  @override
  String get sadhanaGoals => 'Sasaran Sadhana';

  @override
  String get progress => 'Kemajuan';

  @override
  String get filterDaily => 'Harian';

  @override
  String get filterWeekly => 'Mingguan';

  @override
  String get filterMonthly => 'Bulanan';

  @override
  String get filterYearly => 'Tahunan';

  @override
  String get totalJaap => 'Jumlah Japa';

  @override
  String get totalMalas => 'Jumlah Mala';

  @override
  String get weeklyJaap => 'Japa Mingguan';

  @override
  String get monthlyJaap => 'Japa Bulanan';

  @override
  String get yearlyJaap => 'Japa Tahunan';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ Sasaran $countString';
  }

  @override
  String get noJaapYet => 'Belum ada japa direkodkan';

  @override
  String get noJaapYetBody => 'Manik pertama anda ialah permulaan perjalanan.';

  @override
  String get dailyAverage => 'Purata harian';

  @override
  String get activeDays => 'Hari aktif';

  @override
  String get perMantra => 'Mengikut mantra';

  @override
  String get stories => 'Kisah';

  @override
  String get storiesSubtitle => 'Kisah pendek untuk renungan';

  @override
  String get popular => 'Popular';

  @override
  String get read => 'Baca';

  @override
  String get listen => 'Dengar';

  @override
  String get stopListening => 'Berhenti';

  @override
  String get textSize => 'Saiz Teks';

  @override
  String get favorite => 'Kegemaran';

  @override
  String get favorites => 'Kegemaran';

  @override
  String get share => 'Kongsi';

  @override
  String get all => 'Semua';

  @override
  String minRead(int minutes) {
    return '$minutes minit bacaan';
  }

  @override
  String get noFavoritesTitle => 'Belum ada kegemaran';

  @override
  String get noFavoritesBody =>
      'Ketik ikon hati pada kisah untuk menyimpannya di sini.';

  @override
  String get noStoriesFound => 'Tiada kisah ditemui';

  @override
  String get settings => 'Tetapan';

  @override
  String get sectionJaap => 'JAPA';

  @override
  String get sectionReminders => 'PERINGATAN';

  @override
  String get sectionAppearance => 'PAPARAN';

  @override
  String get sectionBackup => 'SANDARAN';

  @override
  String get sectionSupport => 'SOKONGAN';

  @override
  String get sectionAbout => 'PERIHAL';

  @override
  String get resetCounts => 'Set Semula Kiraan';

  @override
  String get jaapReminders => 'Peringatan Japa';

  @override
  String get streakReminder => 'Peringatan Rentetan';

  @override
  String get goalReminder => 'Peringatan Sasaran';

  @override
  String get theme => 'Tema';

  @override
  String get haptics => 'Getaran';

  @override
  String get sound => 'Bunyi';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Lalai sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'Sandaran & Pemulihan';

  @override
  String get exportMyData => 'Eksport Data Saya';

  @override
  String get rateApp => 'Nilai JaapMitra';

  @override
  String get shareApp => 'Jemput Keluarga dan Rakan';

  @override
  String get feedback => 'Maklum balas';

  @override
  String get privacyPolicy => 'Dasar Privasi';

  @override
  String get usageStats => 'Kongsi statistik penggunaan tanpa nama';

  @override
  String get usageStatsHint =>
      'Skrin dan ciri mana yang digunakan. Tidak sekali-kali mantra atau kiraan anda.';

  @override
  String get terms => 'Terma';

  @override
  String get aboutApp => 'Perihal JaapMitra';

  @override
  String version(String version) {
    return 'Versi $version';
  }

  @override
  String get resetTodayTitle => 'Set semula japa hari ini?';

  @override
  String get resetTodayBody =>
      'Semua japa yang direkodkan hari ini akan dibuang. Tindakan ini tidak boleh dibuat asal.';

  @override
  String get resetAllTitle => 'Set semula semua japa?';

  @override
  String get resetAllBody =>
      'Seluruh sejarah japa, mala dan rentetan anda akan dipadam secara kekal. Tindakan ini tidak boleh dibuat asal.';

  @override
  String get resetToday => 'Set semula hari ini';

  @override
  String get resetEverything => 'Set semula semuanya';

  @override
  String get resetDone => 'Kiraan telah diset semula';

  @override
  String get aboutBody =>
      'JaapMitra ialah ruang yang tenang dan peribadi untuk japa harian anda. Semua yang anda lafazkan disimpan hanya pada peranti ini.';

  @override
  String get madeWith => 'Dibina dengan penuh bhakti';

  @override
  String get addReminder => 'Tambah peringatan';

  @override
  String get reminderTime => 'Masa';

  @override
  String get everyDay => 'Setiap hari';

  @override
  String get noRemindersTitle => 'Belum ada peringatan';

  @override
  String get noRemindersBody =>
      'Peringatan lembut pada waktu yang sama setiap hari menjadikan amalan ini satu kebiasaan.';

  @override
  String get notificationsBlocked =>
      'Pemberitahuan untuk JaapMitra dimatikan. Hidupkannya dalam tetapan peranti anda.';

  @override
  String get reminderNotificationTitle => 'Masa untuk japa anda';

  @override
  String get reminderNotificationBody =>
      'Beberapa minit yang tenang bersama mala anda 🙏';

  @override
  String get streakNotificationTitle => 'Kekalkan rentetan anda';

  @override
  String get streakNotificationBody =>
      'Anda belum berjapa hari ini. Satu mala sudah cukup untuk meneruskannya.';

  @override
  String get goalNotificationTitle => 'Hampir sampai';

  @override
  String get goalNotificationBody =>
      'Capai sasaran hari ini untuk melengkapkan Sadhana anda untuk hari ini.';

  @override
  String get createBackup => 'Buat sandaran';

  @override
  String get createBackupBody =>
      'Simpan fail JSON yang mengandungi semua mantra, sejarah japa, sasaran dan tetapan anda.';

  @override
  String get restoreBackup => 'Pulihkan daripada sandaran';

  @override
  String get restoreBackupBody =>
      'Pilih fail sandaran JaapMitra untuk dipulihkan.';

  @override
  String get backupCreated => 'Sandaran telah dibuat';

  @override
  String get restoreWarningTitle => 'Gantikan semua data?';

  @override
  String get restoreWarningBody =>
      'Pemulihan akan menggantikan semua data dalam JaapMitra sekarang dengan kandungan fail sandaran.';

  @override
  String get restore => 'Pulihkan';

  @override
  String restoreSuccess(int count) {
    return '$count catatan japa dipulihkan';
  }

  @override
  String get importInvalid => 'Fail ini bukan sandaran JaapMitra yang sah';

  @override
  String get exportShareText => 'Sandaran JaapMitra saya';

  @override
  String get onb1Title => 'Japa Mala Digital Anda';

  @override
  String get onb1Body => 'Cara yang tenang untuk mengira setiap japa.';

  @override
  String get onb2Title => 'Jadikan Sadhana Satu Kebiasaan';

  @override
  String get onb2Body => 'Tetapkan sasaran harian dan bina rentetan japa anda.';

  @override
  String get onb3Title => 'Berjapa Tanpa Gangguan';

  @override
  String get onb3Body =>
      'Masuk ke mod meditasi dengan pengira yang ringkas dan tenang.';

  @override
  String get onbLookTitle => 'Ikut citarasa anda';

  @override
  String get onbLookBody =>
      'Pilih rupa dan bunyi pengira. Tema, paparan mantra, mantra jatuh dan muzik boleh ditukar bila-bila masa dalam Tetapan.';

  @override
  String get onbFeaturesTitle => 'Semuanya di hujung jari anda';

  @override
  String get onbFeaturesBody =>
      'Beberapa perkara yang perlu diketahui sebelum anda bermula.';

  @override
  String get soundsFeatureTitle => 'Bunyi yang menenangkan';

  @override
  String get soundsFeatureBody =>
      'Mainkan alunan latar yang lembut semasa meditasi, selama mana anda duduk.';

  @override
  String get startJap => 'Mula Japa';

  @override
  String get blackout => 'Gelap';

  @override
  String get timer => 'Pemasa';

  @override
  String get exitMeditation => 'Keluar dari mod meditasi';

  @override
  String get tapAnywhere => 'Ketik di mana-mana untuk mengira';

  @override
  String semanticCounter(int count, int total) {
    return 'Pengira japa. $count daripada $total manik. Ketik dua kali untuk mengira satu.';
  }

  @override
  String get autoJaap => 'Japa Automatik';

  @override
  String get autoJaapBody =>
      'Aplikasi mengira untuk anda pada rentak yang tetap, supaya anda boleh berjapa tanpa menyentuh skrin.';

  @override
  String get autoJaapPace => 'Rentak';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds saat';
  }

  @override
  String get autoJaapStopAfter => 'Berhenti selepas';

  @override
  String get autoJaapStopMala => 'Satu mala';

  @override
  String get autoJaapStopGoal => 'Sasaran harian';

  @override
  String get autoJaapStopNever => 'Jangan berhenti';

  @override
  String get autoJaapStart => 'Mula Japa Automatik';

  @override
  String get autoJaapStopAction => 'Hentikan Japa Automatik';

  @override
  String get chantPlay => 'Main';

  @override
  String get chantStop => 'Berhenti';

  @override
  String get music => 'Muzik';

  @override
  String get playMusic => 'Mainkan muzik';

  @override
  String get stopMusic => 'Hentikan muzik';

  @override
  String get chooseSound => 'Pilih bunyi';

  @override
  String get musicRecord => 'Rakam';

  @override
  String get musicUpload => 'Muat naik';

  @override
  String get musicYours => 'Muzik saya';

  @override
  String musicRecordingName(int n) {
    return 'Rakaman $n';
  }

  @override
  String get musicNameTitle => 'Namakan rakaman anda';

  @override
  String get musicRemove => 'Buang';

  @override
  String get musicAddFailed => 'Fail itu tidak dapat ditambah';

  @override
  String get ownMusicTitle => 'Gunakan muzik anda sendiri';

  @override
  String get ownMusicBody =>
      'Rakam alunan anda sendiri atau muat naik bunyi meditasi, dan ia dimainkan sepanjang anda duduk.';

  @override
  String counterCount(String count) {
    return 'Kiraan: $count';
  }

  @override
  String counterMalas(String count) {
    return 'Mala: $count';
  }

  @override
  String counterTotal(String count) {
    return 'Jumlah: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'Japa Automatik sedang berjalan · ketik di mana-mana untuk berhenti';

  @override
  String get hideMantra => 'Sembunyikan mantra';

  @override
  String get showMantra => 'Tunjukkan mantra';

  @override
  String get changeTheme => 'Tukar tema';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rentetan $count hari',
      one: 'rentetan 1 hari',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Menu';

  @override
  String get chooseTheme => 'Pilih Tema';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeWhite => 'Putih';

  @override
  String get themeBlack => 'Hitam';

  @override
  String get themePastelPink => 'Merah Jambu Pastel';

  @override
  String get themeSpiritual => 'Spiritual';

  @override
  String get themeSaffron => 'Safron';

  @override
  String get themePeaceful => 'Tenang';

  @override
  String get themeTerracotta => 'Terakota';

  @override
  String get themeMeditative => 'Meditatif';

  @override
  String get themeNature => 'Alam';

  @override
  String get themeRoseGold => 'Rose Gold';

  @override
  String get themeOcean => 'Lautan';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeCharcoal => 'Arang';

  @override
  String get counterBackground => 'Latar pengira';

  @override
  String get counterBackgroundBody =>
      'Dipaparkan di belakang mantra dan manik pada pengira.';

  @override
  String get backgroundNone => 'Tiada';

  @override
  String get backgroundDawn => 'Fajar';

  @override
  String get backgroundDusk => 'Senja';

  @override
  String get backgroundLotus => 'Teratai';

  @override
  String get backgroundForest => 'Hutan';

  @override
  String get backgroundOcean => 'Lautan';

  @override
  String get backgroundCosmos => 'Kosmos';

  @override
  String get backgroundPhoto => 'Foto saya';

  @override
  String get backgroundChoosePhoto => 'Pilih foto';

  @override
  String get backgroundChangePhoto => 'Tukar foto';

  @override
  String get backgroundRemovePhoto => 'Buang foto';

  @override
  String get backgroundDim => 'Malapkan latar';

  @override
  String get backgroundDimHint => 'Lebih malap, lebih mudah mantra dibaca.';

  @override
  String get addOwnMantra => 'Tambah mantra anda sendiri';

  @override
  String get addOwnMantraHint =>
      'Apa-apa nama atau mantra, dalam apa-apa tulisan, dengan saiz mala anda sendiri';

  @override
  String get legendLess => 'Kurang';

  @override
  String get legendMore => 'Lebih';

  @override
  String get allMantras => 'Semua mantra';

  @override
  String get previousPeriod => 'Sebelumnya';

  @override
  String get nextPeriod => 'Seterusnya';

  @override
  String get showStatsFor => 'Tunjukkan statistik untuk';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count japa · $malas mala';
  }

  @override
  String get dailyJaap => 'Japa Harian';

  @override
  String get mantraText => 'Mantra';

  @override
  String get mantraTextHint => 'cth. Om Namah Shivaya atau राम';

  @override
  String get mantraRequired => 'Sila masukkan mantra';

  @override
  String get mantraDescription => 'Keterangan';

  @override
  String get mantraDescriptionHint =>
      'Makna, sumber, atau catatan untuk diri sendiri';

  @override
  String get dictationStart => 'Masukkan mantra dengan menyebutnya';

  @override
  String get dictationListening => 'Sedang mendengar… ketik untuk berhenti';

  @override
  String get dictationUnavailable =>
      'Input suara tidak tersedia pada peranti ini';

  @override
  String get dictationOfflineUnavailable =>
      'Input suara luar talian tidak tersedia untuk bahasa ini pada telefon ini. Suara anda tidak pernah keluar dari peranti, jadi sila taip sahaja.';

  @override
  String get micPermissionDenied => 'Akses mikrofon diperlukan untuk ini';

  @override
  String get fallingMantra => 'Mantra jatuh';

  @override
  String get stopFallingMantra => 'Hentikan mantra jatuh';

  @override
  String get malaStyle => 'Gaya mala';

  @override
  String get malaStyleBeads => 'Manik';

  @override
  String get malaStyleRing => 'Cincin kemajuan';

  @override
  String get sectionCounter => 'PENGIRA';

  @override
  String get showMantraOnCounter => 'Tunjukkan mantra pada pengira';

  @override
  String get goalUnitMalas => 'Mala';

  @override
  String get goalUnitJaap => 'Japa';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mala',
      one: '1 mala',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'Mala sehari';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas mala',
      one: '1 mala',
    );
    return '$_temp0 sehari · $jaap japa';
  }

  @override
  String get onbMantraTitle => 'Mantra apakah yang anda lafazkan?';

  @override
  String get onbMantraBody =>
      'Pilih satu untuk bermula. Anda boleh menambah lagi bila-bila masa.';

  @override
  String get onbGoalTitle => 'Sasaran harian anda';

  @override
  String get onbGoalBody =>
      'Mulakan secara kecil: amalan yang konsisten lebih penting daripada angka yang besar. Anda boleh menukarnya bila-bila masa.';

  @override
  String get shareProgress => 'Kongsi kemajuan saya';

  @override
  String get shareStreakLabel => 'hari berturut-turut';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari',
      one: '1 hari',
    );
    return '$_temp0 berjapa berturut-turut bersama JaapMitra 🙏';
  }

  @override
  String get blackoutMode => 'Mod gelap penuh';

  @override
  String get exitBlackout => 'Keluar dari mod gelap';

  @override
  String get feedbackEmailSubject => 'Maklum balas JaapMitra';

  @override
  String get homeScreenWidget => 'Widget skrin utama';

  @override
  String get homeScreenWidgetBody =>
      'Lihat japa hari ini dan rentetan anda di Skrin Utama, tanpa membuka aplikasi.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'Tekan lama ruang kosong di Skrin Utama, ketik Widget, kemudian cari JaapMitra.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'Tekan lama ruang kosong di Skrin Utama, ketik + di penjuru, cari JaapMitra, kemudian pilih saiz dan ketik Tambah Widget.';

  @override
  String get addToHomeScreen => 'Tambah ke Skrin Utama';

  @override
  String get countWithButtons => 'Kira dengan butang';

  @override
  String get countWithButtonsHintAndroid =>
      'Butang kelantangan, butang set kepala atau pengklik Bluetooth mengira satu manik';

  @override
  String get countWithButtonsHintIOS =>
      'Pengklik Bluetooth atau papan kekunci mengira satu manik. Butang kelantangan iPhone tidak boleh digunakan oleh aplikasi.';

  @override
  String get lockScreenCounter => 'Pengira skrin kunci';

  @override
  String get lockScreenCounterHint =>
      'Butang +1 pada skrin kunci dan Dynamic Island. Ketikan ditambah pada japa anda apabila anda membuka aplikasi seterusnya.';

  @override
  String get markerBead => 'Manik penanda';

  @override
  String get markerBeadHint =>
      'Satu getaran tegas di pertengahan mala, supaya anda tahu kedudukan anda walaupun mata terpejam';

  @override
  String markerBeadEvery(int count) {
    return 'Setiap $count';
  }

  @override
  String get markerBeadOff => 'Tutup';

  @override
  String get graceDays => 'Hari kelonggaran';

  @override
  String get graceDaysHint =>
      'Setiap 7 hari berturut-turut memberi satu hari kelonggaran (maksimum 2). Hari yang terlepas akan menggunakannya dan rentetan anda tidak terputus.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari kelonggaran disimpan',
      one: '1 hari kelonggaran disimpan',
      zero: 'Tiada hari kelonggaran',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'Dilindungi oleh hari kelonggaran';

  @override
  String milestoneLakh(int count) {
    return '$count lakh japa';
  }

  @override
  String get milestoneSavaLakh => 'Sava lakh japa (125,000)';

  @override
  String get milestoneCrore => '1 crore japa (10 juta)';

  @override
  String milestoneStreak(int days) {
    return 'Rentetan $days hari';
  }

  @override
  String milestoneReached(String milestone) {
    return '$milestone tercapai. Satu pencapaian dalam amalan anda.';
  }

  @override
  String get milestones => 'Pencapaian';

  @override
  String milestoneNext(String milestone) {
    return 'Seterusnya: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString lagi';
  }

  @override
  String get milestoneAllReached => 'Semua pencapaian telah dicapai';

  @override
  String get yearInReview => 'Imbasan tahunan';

  @override
  String yearInReviewTitle(int year) {
    return 'Japa anda pada $year';
  }

  @override
  String yearNoJaap(int year) {
    return 'Tiada japa direkodkan pada $year';
  }

  @override
  String get yearActiveDays => 'Hari berjapa';

  @override
  String get yearLongestRun => 'Rentetan terpanjang';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari',
      one: '1 hari',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'Hari terbaik';

  @override
  String get yearTopMantra => 'Paling kerap dilafazkan';

  @override
  String get yearByMonth => 'Mengikut bulan';

  @override
  String get yearMilestones => 'Pencapaian tahun ini';

  @override
  String yearShareText(int year, String count) {
    return 'Japa saya pada $year: $count japa';
  }

  @override
  String get previousYear => 'Tahun sebelumnya';

  @override
  String get nextYear => 'Tahun seterusnya';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'Indira Ekadashi',
      'papankusha': 'Papankusha Ekadashi',
      'rama': 'Rama Ekadashi',
      'devutthana': 'Devutthana Ekadashi',
      'utpanna': 'Utpanna Ekadashi',
      'mokshada': 'Mokshada Ekadashi',
      'saphala': 'Saphala Ekadashi',
      'paushaPutrada': 'Pausha Putrada Ekadashi',
      'shattila': 'Shattila Ekadashi',
      'jaya': 'Jaya Ekadashi',
      'vijaya': 'Vijaya Ekadashi',
      'amalaki': 'Amalaki Ekadashi',
      'papamochani': 'Papamochani Ekadashi',
      'kamada': 'Kamada Ekadashi',
      'varuthini': 'Varuthini Ekadashi',
      'mohini': 'Mohini Ekadashi',
      'apara': 'Apara Ekadashi',
      'nirjala': 'Nirjala Ekadashi',
      'yogini': 'Yogini Ekadashi',
      'devshayani': 'Devshayani Ekadashi',
      'kamika': 'Kamika Ekadashi',
      'shravanaPutrada': 'Shravana Putrada Ekadashi',
      'aja': 'Aja Ekadashi',
      'parsva': 'Parsva Ekadashi',
      'other': 'Ekadashi',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'Sharad Navaratri',
      'chaitraNavratri': 'Chaitra Navaratri',
      'dussehra': 'Dussehra (Vijayadasami)',
      'diwali': 'Deepavali',
      'kartikMonth': 'Bulan Kartik',
      'kartikPurnima': 'Kartik Purnima',
      'guruNanakJayanti': 'Guru Nanak Jayanti',
      'makarSankranti': 'Makar Sankranti (Ponggal)',
      'vasantPanchami': 'Vasant Panchami',
      'mahaShivaratri': 'Maha Shivaratri',
      'holi': 'Holi',
      'ramNavami': 'Rama Navami',
      'mahavirJayanti': 'Mahavir Jayanti',
      'hanumanJayanti': 'Hanuman Jayanti',
      'guruPurnima': 'Guru Purnima',
      'shravanMonth': 'Bulan Shravan',
      'rakshaBandhan': 'Raksha Bandhan',
      'krishnaJanmashtami': 'Krishna Janmashtami',
      'ganeshChaturthi': 'Ganesh Chaturthi',
      'other': 'Perayaan',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return 'Bermula $date';
  }

  @override
  String get upcomingObservances => 'Ekadashi dan perayaan';

  @override
  String get observanceToday => 'Hari ini';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dalam $count hari',
      one: 'Esok',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return 'Sankalpa untuk $name';
  }

  @override
  String get observanceTakeSankalp => 'Ambil Sankalpa';

  @override
  String observanceVaishnava(String date) {
    return 'Sambutan Vaishnava (ISKCON): $date';
  }

  @override
  String get observanceSourceNote =>
      'Tarikh mengikut Drik Panchang untuk New Delhi. Kuil atau tradisi setempat anda mungkin menyambutnya sehari lebih awal atau lewat.';

  @override
  String get observancesNone =>
      'Tiada apa-apa dalam beberapa minggu akan datang';

  @override
  String get festivalReminders => 'Peringatan Ekadashi dan perayaan';

  @override
  String get festivalRemindersHint =>
      'Pemberitahuan pada pukul 6 pagi pada hari Ekadashi dan perayaan';

  @override
  String festivalNotificationBody(String name) {
    return 'Hari ini $name. Hari yang mulia untuk japa.';
  }

  @override
  String get sendDiagnostics => 'Hantar diagnostik';

  @override
  String get diagnosticsExplain =>
      'Laporan ini membantu membaiki masalah. Ia mengandungi versi aplikasi dan telefon, tetapan anda dan log ralat aplikasi. Tiada mantra, kiraan atau catatan. Tiada apa-apa dihantar sehingga anda memilih caranya di bawah.';

  @override
  String get diagnosticsEmail => 'Hantar melalui e-mel';

  @override
  String get diagnosticsShare => 'Kongsi sebagai fail';

  @override
  String get diagnosticsEmailSubject => 'Diagnostik JaapMitra';

  @override
  String get diagnosticsNoMail =>
      'Tiada aplikasi e-mel ditemui. Cuba kongsi sebagai fail.';
}
