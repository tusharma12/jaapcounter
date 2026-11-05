// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Penghitung Japa: JaapMitra';

  @override
  String get tagline => 'Teman Bhakti, Setiap Hari';

  @override
  String get navJaap => 'Japa';

  @override
  String get navProgress => 'Kemajuan';

  @override
  String get navStories => 'Kisah';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get close => 'Tutup';

  @override
  String get next => 'Lanjut';

  @override
  String get skip => 'Lewati';

  @override
  String get back => 'Kembali';

  @override
  String get retry => 'Coba lagi';

  @override
  String get custom => 'Kustom';

  @override
  String get active => 'Aktif';

  @override
  String get off => 'MATI';

  @override
  String get somethingWentWrong => 'Terjadi kesalahan';

  @override
  String get tapToCount => 'KETUK UNTUK MENGHITUNG';

  @override
  String get todaysJaap => 'Japa Hari Ini';

  @override
  String get undo => 'Urungkan';

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
  String get resetCurrentMala => 'Ulangi mala ini';

  @override
  String get resetCurrentMalaBody =>
      'Butir yang sudah dihitung di mala ini akan dihapus. Mala yang sudah selesai tetap tersimpan.';

  @override
  String get addCountManually => 'Tambah hitungan manual';

  @override
  String get addCount => 'Tambah hitungan';

  @override
  String get numberOfJaap => 'Jumlah japa';

  @override
  String get meditationMode => 'Mode meditasi';

  @override
  String get startSession => 'Mulai sesi';

  @override
  String get endSession => 'Akhiri sesi';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$jaap japa dalam $minutes menit';
  }

  @override
  String get myMantras => 'Mantra Saya';

  @override
  String get addMantra => 'Tambah Mantra';

  @override
  String get editMantra => 'Ubah Mantra';

  @override
  String get malaSize => 'Ukuran Mala';

  @override
  String beads(int count) {
    return '$count butir';
  }

  @override
  String get malaSizeInvalid => 'Ukuran mala harus antara 1 dan 10.000';

  @override
  String get deleteMantraTitle => 'Hapus mantra?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" akan dihapus. Riwayat japa Anda tetap tersimpan.';
  }

  @override
  String get optional => 'opsional';

  @override
  String get mySadhana => 'Sadhana Saya';

  @override
  String get todaysGoal => 'Target Hari Ini';

  @override
  String get complete => 'Selesai';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Beruntun $count Hari',
      one: 'Beruntun 1 Hari',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'Rekor beruntun';

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
    return 'Dimulai $date';
  }

  @override
  String get createNewSankalp => 'Buat Sankalpa Baru';

  @override
  String get createSankalp => 'Buat Sankalpa';

  @override
  String get chooseMantra => 'Pilih Mantra';

  @override
  String get dailyGoal => 'Target Harian';

  @override
  String get duration => 'Durasi';

  @override
  String durationDays(int days) {
    return '$days hari';
  }

  @override
  String get reminder => 'Pengingat';

  @override
  String get beginSadhana => 'Mulai Sadhana';

  @override
  String get noSankalpTitle => 'Mulai Sankalpa';

  @override
  String get noSankalpBody =>
      'Sankalpa adalah tekad untuk melantunkan sejumlah japa setiap hari selama jumlah hari yang Anda pilih.';

  @override
  String get endSankalp => 'Akhiri Sankalpa';

  @override
  String get endSankalpBody =>
      'Kemajuan Anda tetap tersimpan, tetapi Sankalpa tidak lagi aktif.';

  @override
  String jaapPerDay(int count) {
    return '$count japa per hari';
  }

  @override
  String goalRemaining(int count) {
    return '$count lagi';
  }

  @override
  String get goalReached => 'Target harian tercapai';

  @override
  String get goalReachedAutoBody =>
      'Japa Otomatis dijeda. Lanjutkan atau berhenti di sini?';

  @override
  String get keepGoing => 'Lanjutkan';

  @override
  String get setDailyGoal => 'Atur target harian';

  @override
  String get sadhanaGoals => 'Target Sadhana';

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
  String get totalJaap => 'Total Japa';

  @override
  String get totalMalas => 'Total Mala';

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

    return '/ Target $countString';
  }

  @override
  String get noJaapYet => 'Belum ada japa yang tercatat';

  @override
  String get noJaapYetBody => 'Butir pertama Anda adalah awal perjalanan.';

  @override
  String get dailyAverage => 'Rata-rata harian';

  @override
  String get activeDays => 'Hari aktif';

  @override
  String get perMantra => 'Per mantra';

  @override
  String get stories => 'Kisah';

  @override
  String get storiesSubtitle => 'Kisah singkat untuk direnungkan';

  @override
  String get popular => 'Populer';

  @override
  String get read => 'Baca';

  @override
  String get listen => 'Dengarkan';

  @override
  String get stopListening => 'Berhenti';

  @override
  String get textSize => 'Ukuran Teks';

  @override
  String get favorite => 'Favorit';

  @override
  String get favorites => 'Favorit';

  @override
  String get share => 'Bagikan';

  @override
  String get all => 'Semua';

  @override
  String minRead(int minutes) {
    return '$minutes menit baca';
  }

  @override
  String get noFavoritesTitle => 'Belum ada favorit';

  @override
  String get noFavoritesBody =>
      'Ketuk ikon hati pada kisah untuk menyimpannya di sini.';

  @override
  String get noStoriesFound => 'Kisah tidak ditemukan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get sectionJaap => 'JAPA';

  @override
  String get sectionReminders => 'PENGINGAT';

  @override
  String get sectionAppearance => 'TAMPILAN';

  @override
  String get sectionBackup => 'CADANGAN';

  @override
  String get sectionSupport => 'BANTUAN';

  @override
  String get sectionAbout => 'TENTANG';

  @override
  String get resetCounts => 'Atur Ulang Hitungan';

  @override
  String get jaapReminders => 'Pengingat Japa';

  @override
  String get streakReminder => 'Pengingat Beruntun';

  @override
  String get goalReminder => 'Pengingat Target';

  @override
  String get theme => 'Tema';

  @override
  String get haptics => 'Getaran';

  @override
  String get sound => 'Suara';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Bawaan sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'Cadangkan & Pulihkan';

  @override
  String get exportMyData => 'Ekspor Data Saya';

  @override
  String get rateApp => 'Beri Nilai JaapMitra';

  @override
  String get shareApp => 'Ajak Keluarga dan Teman';

  @override
  String get feedback => 'Masukan';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get usageStats => 'Bagikan statistik penggunaan anonim';

  @override
  String get usageStatsHint =>
      'Layar dan fitur mana yang digunakan. Tidak pernah mantra atau hitungan Anda.';

  @override
  String get terms => 'Ketentuan';

  @override
  String get aboutApp => 'Tentang JaapMitra';

  @override
  String version(String version) {
    return 'Versi $version';
  }

  @override
  String get resetTodayTitle => 'Atur ulang japa hari ini?';

  @override
  String get resetTodayBody =>
      'Semua japa yang tercatat hari ini akan dihapus. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get resetAllTitle => 'Atur ulang semua japa?';

  @override
  String get resetAllBody =>
      'Seluruh riwayat japa, mala, dan rekor beruntun Anda akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get resetToday => 'Atur ulang hari ini';

  @override
  String get resetEverything => 'Atur ulang semuanya';

  @override
  String get resetDone => 'Hitungan diatur ulang';

  @override
  String get aboutBody =>
      'JaapMitra adalah ruang yang tenang dan pribadi untuk japa harian Anda. Semua yang Anda lantunkan hanya disimpan di perangkat ini.';

  @override
  String get madeWith => 'Dibuat dengan bhakti';

  @override
  String get addReminder => 'Tambah pengingat';

  @override
  String get reminderTime => 'Waktu';

  @override
  String get everyDay => 'Setiap hari';

  @override
  String get noRemindersTitle => 'Belum ada pengingat';

  @override
  String get noRemindersBody =>
      'Pengingat lembut di jam yang sama setiap hari menjadikan latihan sebagai kebiasaan.';

  @override
  String get notificationsBlocked =>
      'Notifikasi untuk JaapMitra dimatikan. Aktifkan di pengaturan perangkat Anda.';

  @override
  String get reminderNotificationTitle => 'Saatnya japa';

  @override
  String get reminderNotificationBody =>
      'Beberapa menit hening bersama mala Anda 🙏';

  @override
  String get streakNotificationTitle => 'Jaga rekor beruntun Anda';

  @override
  String get streakNotificationBody =>
      'Anda belum ber-japa hari ini. Satu mala sudah cukup untuk melanjutkannya.';

  @override
  String get goalNotificationTitle => 'Hampir sampai';

  @override
  String get goalNotificationBody =>
      'Selesaikan target hari ini untuk menuntaskan Sadhana Anda hari ini.';

  @override
  String get createBackup => 'Buat cadangan';

  @override
  String get createBackupBody =>
      'Simpan file JSON berisi semua mantra, riwayat japa, target, dan pengaturan Anda.';

  @override
  String get restoreBackup => 'Pulihkan dari cadangan';

  @override
  String get restoreBackupBody =>
      'Pilih file cadangan JaapMitra untuk dipulihkan.';

  @override
  String get backupCreated => 'Cadangan dibuat';

  @override
  String get restoreWarningTitle => 'Ganti semua data?';

  @override
  String get restoreWarningBody =>
      'Pemulihan akan mengganti semua data di JaapMitra saat ini dengan isi file cadangan.';

  @override
  String get restore => 'Pulihkan';

  @override
  String restoreSuccess(int count) {
    return '$count catatan japa dipulihkan';
  }

  @override
  String get importInvalid => 'File ini bukan cadangan JaapMitra yang valid';

  @override
  String get exportShareText => 'Cadangan JaapMitra saya';

  @override
  String get onb1Title => 'Genitri Digital Anda';

  @override
  String get onb1Body => 'Cara yang damai untuk menghitung setiap japa.';

  @override
  String get onb2Title => 'Jadikan Sadhana Kebiasaan';

  @override
  String get onb2Body =>
      'Tetapkan target harian dan bangun rekor beruntun japa Anda.';

  @override
  String get onb3Title => 'Japa Tanpa Gangguan';

  @override
  String get onb3Body =>
      'Masuk ke mode meditasi dengan penghitung yang bersih dan tenang.';

  @override
  String get onbLookTitle => 'Sesuaikan sesuka Anda';

  @override
  String get onbLookBody =>
      'Pilih tampilan dan suara penghitung. Tema, tampilan mantra, mantra jatuh, dan musik dapat diubah kapan saja di Pengaturan.';

  @override
  String get onbFeaturesTitle => 'Semua dalam genggaman Anda';

  @override
  String get onbFeaturesBody =>
      'Beberapa hal yang perlu diketahui sebelum memulai.';

  @override
  String get soundsFeatureTitle => 'Suara yang menenangkan';

  @override
  String get soundsFeatureBody =>
      'Putar lantunan latar yang lembut selama meditasi, selama Anda duduk.';

  @override
  String get startJap => 'Mulai Japa';

  @override
  String get blackout => 'Gelap';

  @override
  String get timer => 'Timer';

  @override
  String get exitMeditation => 'Keluar dari mode meditasi';

  @override
  String get tapAnywhere => 'Ketuk di mana saja untuk menghitung';

  @override
  String semanticCounter(int count, int total) {
    return 'Penghitung japa. $count dari $total butir. Ketuk dua kali untuk menghitung satu.';
  }

  @override
  String get autoJaap => 'Japa Otomatis';

  @override
  String get autoJaapBody =>
      'Aplikasi menghitung untuk Anda dengan tempo tetap, sehingga Anda bisa ber-japa tanpa menyentuh layar.';

  @override
  String get autoJaapPace => 'Tempo';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds dtk';
  }

  @override
  String get autoJaapStopAfter => 'Berhenti setelah';

  @override
  String get autoJaapStopMala => 'Satu mala';

  @override
  String get autoJaapStopGoal => 'Target harian';

  @override
  String get autoJaapStopNever => 'Jangan berhenti';

  @override
  String get autoJaapStart => 'Mulai Japa Otomatis';

  @override
  String get autoJaapStopAction => 'Hentikan Japa Otomatis';

  @override
  String get chantPlay => 'Putar';

  @override
  String get chantStop => 'Berhenti';

  @override
  String get music => 'Musik';

  @override
  String get playMusic => 'Putar musik';

  @override
  String get stopMusic => 'Hentikan musik';

  @override
  String get chooseSound => 'Pilih suara';

  @override
  String get musicRecord => 'Rekam';

  @override
  String get musicUpload => 'Unggah';

  @override
  String get musicYours => 'Musik saya';

  @override
  String musicRecordingName(int n) {
    return 'Rekaman $n';
  }

  @override
  String get musicNameTitle => 'Beri nama rekaman Anda';

  @override
  String get musicRemove => 'Hapus';

  @override
  String get musicAddFailed => 'File itu tidak dapat ditambahkan';

  @override
  String get ownMusicTitle => 'Gunakan musik Anda sendiri';

  @override
  String get ownMusicBody =>
      'Rekam lantunan Anda sendiri atau unggah suara meditasi, dan suara itu diputar sepanjang Anda duduk.';

  @override
  String counterCount(String count) {
    return 'Hitungan: $count';
  }

  @override
  String counterMalas(String count) {
    return 'Mala: $count';
  }

  @override
  String counterTotal(String count) {
    return 'Total: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'Japa Otomatis berjalan · ketuk di mana saja untuk berhenti';

  @override
  String get hideMantra => 'Sembunyikan mantra';

  @override
  String get showMantra => 'Tampilkan mantra';

  @override
  String get changeTheme => 'Ganti tema';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'beruntun $count hari',
      one: 'beruntun 1 hari',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Menu';

  @override
  String get chooseTheme => 'Pilih Tema';

  @override
  String get themeAuto => 'Otomatis';

  @override
  String get themeWhite => 'Putih';

  @override
  String get themeBlack => 'Hitam';

  @override
  String get themePastelPink => 'Merah Muda Pastel';

  @override
  String get themeSpiritual => 'Spiritual';

  @override
  String get themeSaffron => 'Kunyit';

  @override
  String get themePeaceful => 'Damai';

  @override
  String get themeTerracotta => 'Terakota';

  @override
  String get themeMeditative => 'Meditatif';

  @override
  String get themeNature => 'Alam';

  @override
  String get themeRoseGold => 'Rose Gold';

  @override
  String get themeOcean => 'Samudra';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeCharcoal => 'Arang';

  @override
  String get counterBackground => 'Latar penghitung';

  @override
  String get counterBackgroundBody =>
      'Ditampilkan di belakang mantra dan butir pada penghitung.';

  @override
  String get backgroundNone => 'Tidak ada';

  @override
  String get backgroundDawn => 'Fajar';

  @override
  String get backgroundDusk => 'Senja';

  @override
  String get backgroundLotus => 'Teratai';

  @override
  String get backgroundForest => 'Hutan';

  @override
  String get backgroundOcean => 'Samudra';

  @override
  String get backgroundCosmos => 'Kosmos';

  @override
  String get backgroundPhoto => 'Foto saya';

  @override
  String get backgroundChoosePhoto => 'Pilih foto';

  @override
  String get backgroundChangePhoto => 'Ganti foto';

  @override
  String get backgroundRemovePhoto => 'Hapus foto';

  @override
  String get backgroundDim => 'Redupkan latar';

  @override
  String get backgroundDimHint => 'Semakin redup, mantra semakin mudah dibaca.';

  @override
  String get addOwnMantra => 'Tambah mantra Anda sendiri';

  @override
  String get addOwnMantraHint =>
      'Nama atau mantra apa pun, dalam aksara apa pun, dengan ukuran mala Anda sendiri';

  @override
  String get legendLess => 'Sedikit';

  @override
  String get legendMore => 'Banyak';

  @override
  String get allMantras => 'Semua mantra';

  @override
  String get previousPeriod => 'Sebelumnya';

  @override
  String get nextPeriod => 'Berikutnya';

  @override
  String get showStatsFor => 'Tampilkan statistik untuk';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count japa · $malas mala';
  }

  @override
  String get dailyJaap => 'Japa Harian';

  @override
  String get mantraText => 'Mantra';

  @override
  String get mantraTextHint => 'mis. Om Namah Shivaya atau राम';

  @override
  String get mantraRequired => 'Silakan masukkan mantra';

  @override
  String get mantraDescription => 'Deskripsi';

  @override
  String get mantraDescriptionHint =>
      'Makna, sumber, atau catatan untuk diri sendiri';

  @override
  String get dictationStart => 'Masukkan mantra dengan mengucapkannya';

  @override
  String get dictationListening => 'Mendengarkan… ketuk untuk berhenti';

  @override
  String get dictationUnavailable =>
      'Input suara tidak tersedia di perangkat ini';

  @override
  String get dictationOfflineUnavailable =>
      'Input suara offline tidak tersedia untuk bahasa ini di ponsel ini. Suara Anda tidak pernah keluar dari perangkat, jadi silakan ketik saja.';

  @override
  String get micPermissionDenied => 'Akses mikrofon diperlukan untuk ini';

  @override
  String get fallingMantra => 'Mantra jatuh';

  @override
  String get stopFallingMantra => 'Hentikan mantra jatuh';

  @override
  String get malaStyle => 'Gaya mala';

  @override
  String get malaStyleBeads => 'Butir';

  @override
  String get malaStyleRing => 'Cincin kemajuan';

  @override
  String get sectionCounter => 'PENGHITUNG';

  @override
  String get showMantraOnCounter => 'Tampilkan mantra di penghitung';

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
  String get malasPerDay => 'Mala per hari';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas mala',
      one: '1 mala',
    );
    return '$_temp0 per hari · $jaap japa';
  }

  @override
  String get onbMantraTitle => 'Mantra apa yang Anda lantunkan?';

  @override
  String get onbMantraBody =>
      'Pilih satu untuk memulai. Anda bisa menambah lebih banyak kapan saja.';

  @override
  String get onbGoalTitle => 'Target harian Anda';

  @override
  String get onbGoalBody =>
      'Mulailah dari yang kecil: latihan yang konsisten lebih penting daripada angka besar. Anda bisa mengubahnya kapan saja.';

  @override
  String get shareProgress => 'Bagikan kemajuan saya';

  @override
  String get shareStreakLabel => 'hari beruntun';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari',
      one: '1 hari',
    );
    return '$_temp0 japa berturut-turut bersama JaapMitra 🙏';
  }

  @override
  String get blackoutMode => 'Mode gelap total';

  @override
  String get exitBlackout => 'Keluar dari mode gelap';

  @override
  String get feedbackEmailSubject => 'Masukan JaapMitra';

  @override
  String get homeScreenWidget => 'Widget layar utama';

  @override
  String get homeScreenWidgetBody =>
      'Lihat japa hari ini dan rekor beruntun Anda di Layar Utama, tanpa membuka aplikasi.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'Tekan lama area kosong di Layar Utama, ketuk Widget, lalu cari JaapMitra.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'Tekan lama area kosong di Layar Utama, ketuk + di pojok, cari JaapMitra, lalu pilih ukuran dan ketuk Tambah Widget.';

  @override
  String get addToHomeScreen => 'Tambah ke Layar Utama';

  @override
  String get countWithButtons => 'Hitung dengan tombol';

  @override
  String get countWithButtonsHintAndroid =>
      'Tombol volume, tombol headset, atau klik Bluetooth menghitung satu butir';

  @override
  String get countWithButtonsHintIOS =>
      'Klik Bluetooth atau keyboard menghitung satu butir. Tombol volume iPhone tidak dapat digunakan oleh aplikasi.';

  @override
  String get lockScreenCounter => 'Penghitung layar kunci';

  @override
  String get lockScreenCounterHint =>
      'Tombol +1 di layar kunci dan Dynamic Island. Ketukan ditambahkan ke japa Anda saat aplikasi dibuka berikutnya.';

  @override
  String get markerBead => 'Butir penanda';

  @override
  String get markerBeadHint =>
      'Satu getaran tegas di tengah mala, agar Anda tahu posisi Anda meski mata terpejam';

  @override
  String markerBeadEvery(int count) {
    return 'Setiap $count';
  }

  @override
  String get markerBeadOff => 'Mati';

  @override
  String get graceDays => 'Hari keringanan';

  @override
  String get graceDaysHint =>
      'Setiap 7 hari berturut-turut memberi satu hari keringanan (maksimal 2). Hari yang terlewat memakainya alih-alih memutus rekor beruntun Anda.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari keringanan tersimpan',
      one: '1 hari keringanan tersimpan',
      zero: 'Tidak ada hari keringanan',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'Ditutup oleh hari keringanan';

  @override
  String milestoneLakh(int count) {
    return '$count lakh japa';
  }

  @override
  String get milestoneSavaLakh => 'Sava lakh japa (125.000)';

  @override
  String get milestoneCrore => '1 crore japa (10 juta)';

  @override
  String milestoneStreak(int days) {
    return 'Beruntun $days hari';
  }

  @override
  String milestoneReached(String milestone) {
    return '$milestone tercapai. Sebuah tonggak dalam latihan Anda.';
  }

  @override
  String get milestones => 'Tonggak';

  @override
  String milestoneNext(String milestone) {
    return 'Berikutnya: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString lagi';
  }

  @override
  String get milestoneAllReached => 'Semua tonggak tercapai';

  @override
  String get yearInReview => 'Kilas balik tahunan';

  @override
  String yearInReviewTitle(int year) {
    return 'Japa Anda di $year';
  }

  @override
  String yearNoJaap(int year) {
    return 'Tidak ada japa tercatat di $year';
  }

  @override
  String get yearActiveDays => 'Hari ber-japa';

  @override
  String get yearLongestRun => 'Beruntun terpanjang';

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
  String get yearTopMantra => 'Paling sering dilantunkan';

  @override
  String get yearByMonth => 'Per bulan';

  @override
  String get yearMilestones => 'Tonggak tahun ini';

  @override
  String yearShareText(int year, String count) {
    return 'Japa saya di $year: $count japa';
  }

  @override
  String get previousYear => 'Tahun sebelumnya';

  @override
  String get nextYear => 'Tahun berikutnya';

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
      'dussehra': 'Dussehra',
      'diwali': 'Diwali (Deepavali)',
      'kartikMonth': 'Bulan Kartika',
      'kartikPurnima': 'Purnama Kartika',
      'guruNanakJayanti': 'Guru Nanak Jayanti',
      'makarSankranti': 'Makar Sankranti',
      'vasantPanchami': 'Vasant Panchami',
      'mahaShivaratri': 'Maha Shivaratri',
      'holi': 'Holi',
      'ramNavami': 'Rama Navami',
      'mahavirJayanti': 'Mahavir Jayanti',
      'hanumanJayanti': 'Hanuman Jayanti',
      'guruPurnima': 'Guru Purnima',
      'shravanMonth': 'Bulan Shravana',
      'rakshaBandhan': 'Raksha Bandhan',
      'krishnaJanmashtami': 'Krishna Janmashtami',
      'ganeshChaturthi': 'Ganesh Chaturthi',
      'other': 'Hari raya',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return 'Dimulai $date';
  }

  @override
  String get upcomingObservances => 'Ekadashi dan hari raya';

  @override
  String get observanceToday => 'Hari ini';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dalam $count hari',
      one: 'Besok',
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
    return 'Perayaan Waisnawa (ISKCON): $date';
  }

  @override
  String get observanceSourceNote =>
      'Tanggal mengikuti Drik Panchang untuk New Delhi. Pura atau tradisi setempat Anda mungkin merayakannya selisih satu hari.';

  @override
  String get observancesNone => 'Tidak ada dalam beberapa minggu ke depan';

  @override
  String get festivalReminders => 'Pengingat Ekadashi dan hari raya';

  @override
  String get festivalRemindersHint =>
      'Pemberitahuan pukul 06.00 pada hari Ekadashi dan hari raya';

  @override
  String festivalNotificationBody(String name) {
    return 'Hari ini $name. Hari yang suci untuk japa.';
  }

  @override
  String get sendDiagnostics => 'Kirim diagnostik';

  @override
  String get diagnosticsExplain =>
      'Laporan ini membantu memperbaiki masalah. Isinya versi aplikasi dan ponsel, pengaturan Anda, dan log kesalahan aplikasi. Tidak ada mantra, hitungan, atau catatan. Tidak ada yang dikirim sampai Anda memilih caranya di bawah.';

  @override
  String get diagnosticsEmail => 'Kirim lewat email';

  @override
  String get diagnosticsShare => 'Bagikan sebagai file';

  @override
  String get diagnosticsEmailSubject => 'Diagnostik JaapMitra';

  @override
  String get diagnosticsNoMail =>
      'Aplikasi email tidak ditemukan. Coba bagikan sebagai file.';
}
