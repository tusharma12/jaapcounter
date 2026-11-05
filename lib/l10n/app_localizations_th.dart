// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppL10nTh extends AppL10n {
  AppL10nTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'นับสวดมนต์ ลูกประคำ: JaapMitra';

  @override
  String get tagline => 'เพื่อนคู่ศรัทธา ทุกวัน';

  @override
  String get navJaap => 'สวดมนต์';

  @override
  String get navProgress => 'ความก้าวหน้า';

  @override
  String get navStories => 'เรื่องเล่า';

  @override
  String get navSettings => 'ตั้งค่า';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get save => 'บันทึก';

  @override
  String get delete => 'ลบ';

  @override
  String get edit => 'แก้ไข';

  @override
  String get close => 'ปิด';

  @override
  String get next => 'ถัดไป';

  @override
  String get skip => 'ข้าม';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get custom => 'กำหนดเอง';

  @override
  String get active => 'ใช้งานอยู่';

  @override
  String get off => 'ปิด';

  @override
  String get somethingWentWrong => 'เกิดข้อผิดพลาดบางอย่าง';

  @override
  String get tapToCount => 'แตะเพื่อนับ';

  @override
  String get todaysJaap => 'การสวดวันนี้';

  @override
  String get undo => 'เลิกทำ';

  @override
  String get malaComplete => 'ครบหนึ่งรอบประคำ';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'สวดครบ $count รอบ',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString จบ';
  }

  @override
  String get resetCurrentMala => 'เริ่มรอบปัจจุบันใหม่';

  @override
  String get resetCurrentMalaBody =>
      'จำนวนเม็ดที่นับในรอบนี้จะถูกลบ ส่วนรอบที่สวดครบแล้วยังคงอยู่';

  @override
  String get addCountManually => 'เพิ่มจำนวนเอง';

  @override
  String get addCount => 'เพิ่มจำนวน';

  @override
  String get numberOfJaap => 'จำนวนจบ';

  @override
  String get meditationMode => 'โหมดสมาธิ';

  @override
  String get startSession => 'เริ่มภาวนา';

  @override
  String get endSession => 'จบการภาวนา';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$jaap จบ ใน $minutes นาที';
  }

  @override
  String get myMantras => 'บทสวดของฉัน';

  @override
  String get addMantra => 'เพิ่มบทสวด';

  @override
  String get editMantra => 'แก้ไขบทสวด';

  @override
  String get malaSize => 'จำนวนเม็ดประคำ';

  @override
  String beads(int count) {
    return '$count เม็ด';
  }

  @override
  String get malaSizeInvalid => 'จำนวนเม็ดประคำต้องอยู่ระหว่าง 1 ถึง 10,000';

  @override
  String get deleteMantraTitle => 'ลบบทสวดนี้?';

  @override
  String deleteMantraBody(String name) {
    return '\"$name\" จะถูกลบ แต่ประวัติการสวดของคุณยังคงอยู่';
  }

  @override
  String get optional => 'ไม่บังคับ';

  @override
  String get mySadhana => 'การปฏิบัติของฉัน';

  @override
  String get todaysGoal => 'เป้าหมายวันนี้';

  @override
  String get complete => 'สำเร็จ';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ต่อเนื่อง $count วัน',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'ต่อเนื่องนานที่สุด';

  @override
  String sankalpDays(int days) {
    return 'ตั้งสัจจะ $days วัน';
  }

  @override
  String dayXofY(int current, int total) {
    return 'วันที่ $current / $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'สำเร็จแล้ว $count วัน',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return 'เริ่มเมื่อ $date';
  }

  @override
  String get createNewSankalp => 'ตั้งสัจจะใหม่';

  @override
  String get createSankalp => 'ตั้งสัจจะ';

  @override
  String get chooseMantra => 'เลือกบทสวด';

  @override
  String get dailyGoal => 'เป้าหมายรายวัน';

  @override
  String get duration => 'ระยะเวลา';

  @override
  String durationDays(int days) {
    return '$days วัน';
  }

  @override
  String get reminder => 'การแจ้งเตือน';

  @override
  String get beginSadhana => 'เริ่มปฏิบัติ';

  @override
  String get noSankalpTitle => 'ตั้งสัจจะอธิษฐาน';

  @override
  String get noSankalpBody =>
      'การตั้งสัจจะคือคำมั่นว่าจะสวดให้ครบจำนวนที่กำหนดทุกวัน ตลอดจำนวนวันที่เลือกไว้';

  @override
  String get endSankalp => 'ยุติสัจจะ';

  @override
  String get endSankalpBody =>
      'ความก้าวหน้าของคุณจะยังคงอยู่ แต่สัจจะนี้จะไม่ทำงานอีกต่อไป';

  @override
  String jaapPerDay(int count) {
    return 'วันละ $count จบ';
  }

  @override
  String goalRemaining(int count) {
    return 'เหลืออีก $count';
  }

  @override
  String get goalReached => 'ถึงเป้าหมายวันนี้แล้ว';

  @override
  String get goalReachedAutoBody =>
      'หยุดการนับอัตโนมัติไว้ชั่วคราว จะสวดต่อหรือหยุดเพียงเท่านี้?';

  @override
  String get keepGoing => 'สวดต่อ';

  @override
  String get setDailyGoal => 'ตั้งเป้าหมายรายวัน';

  @override
  String get sadhanaGoals => 'เป้าหมายการปฏิบัติ';

  @override
  String get progress => 'ความก้าวหน้า';

  @override
  String get filterDaily => 'รายวัน';

  @override
  String get filterWeekly => 'รายสัปดาห์';

  @override
  String get filterMonthly => 'รายเดือน';

  @override
  String get filterYearly => 'รายปี';

  @override
  String get totalJaap => 'จำนวนจบทั้งหมด';

  @override
  String get totalMalas => 'จำนวนรอบทั้งหมด';

  @override
  String get weeklyJaap => 'การสวดรายสัปดาห์';

  @override
  String get monthlyJaap => 'การสวดรายเดือน';

  @override
  String get yearlyJaap => 'การสวดรายปี';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ เป้าหมาย $countString';
  }

  @override
  String get noJaapYet => 'ยังไม่มีการสวดที่บันทึกไว้';

  @override
  String get noJaapYetBody => 'ลูกประคำเม็ดแรกคือจุดเริ่มต้นของการเดินทาง';

  @override
  String get dailyAverage => 'เฉลี่ยต่อวัน';

  @override
  String get activeDays => 'วันที่สวด';

  @override
  String get perMantra => 'แยกตามบทสวด';

  @override
  String get stories => 'เรื่องเล่า';

  @override
  String get storiesSubtitle => 'เรื่องสั้นสำหรับใคร่ครวญ';

  @override
  String get popular => 'ยอดนิยม';

  @override
  String get read => 'อ่าน';

  @override
  String get listen => 'ฟัง';

  @override
  String get stopListening => 'หยุด';

  @override
  String get textSize => 'ขนาดตัวอักษร';

  @override
  String get favorite => 'รายการโปรด';

  @override
  String get favorites => 'รายการโปรด';

  @override
  String get share => 'แชร์';

  @override
  String get all => 'ทั้งหมด';

  @override
  String minRead(int minutes) {
    return 'อ่าน $minutes นาที';
  }

  @override
  String get noFavoritesTitle => 'ยังไม่มีรายการโปรด';

  @override
  String get noFavoritesBody => 'แตะรูปหัวใจบนเรื่องเล่าเพื่อเก็บไว้ที่นี่';

  @override
  String get noStoriesFound => 'ไม่พบเรื่องเล่า';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get sectionJaap => 'การสวด';

  @override
  String get sectionReminders => 'การแจ้งเตือน';

  @override
  String get sectionAppearance => 'รูปลักษณ์';

  @override
  String get sectionBackup => 'สำรองข้อมูล';

  @override
  String get sectionSupport => 'ช่วยเหลือ';

  @override
  String get sectionAbout => 'เกี่ยวกับ';

  @override
  String get resetCounts => 'รีเซ็ตจำนวน';

  @override
  String get jaapReminders => 'เตือนให้สวดมนต์';

  @override
  String get streakReminder => 'เตือนรักษาความต่อเนื่อง';

  @override
  String get goalReminder => 'เตือนเป้าหมาย';

  @override
  String get theme => 'ธีม';

  @override
  String get haptics => 'การสั่น';

  @override
  String get sound => 'เสียง';

  @override
  String get language => 'ภาษา';

  @override
  String get languageSystem => 'ตามค่าเริ่มต้นของระบบ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'สำรองและกู้คืน';

  @override
  String get exportMyData => 'ส่งออกข้อมูลของฉัน';

  @override
  String get rateApp => 'ให้คะแนน JaapMitra';

  @override
  String get shareApp => 'ชวนครอบครัวและเพื่อน';

  @override
  String get feedback => 'ความคิดเห็น';

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get usageStats => 'แชร์สถิติการใช้งานแบบไม่ระบุตัวตน';

  @override
  String get usageStatsHint =>
      'เฉพาะหน้าจอและฟีเจอร์ที่ถูกใช้ ไม่มีบทสวดหรือจำนวนการสวดของคุณ';

  @override
  String get terms => 'ข้อกำหนด';

  @override
  String get aboutApp => 'เกี่ยวกับ JaapMitra';

  @override
  String version(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get resetTodayTitle => 'รีเซ็ตการสวดวันนี้?';

  @override
  String get resetTodayBody =>
      'การสวดทั้งหมดที่บันทึกวันนี้จะถูกลบ และไม่สามารถย้อนกลับได้';

  @override
  String get resetAllTitle => 'รีเซ็ตการสวดทั้งหมด?';

  @override
  String get resetAllBody =>
      'ประวัติการสวด จำนวนรอบ และความต่อเนื่องทั้งหมดจะถูกลบถาวร และไม่สามารถย้อนกลับได้';

  @override
  String get resetToday => 'รีเซ็ตวันนี้';

  @override
  String get resetEverything => 'รีเซ็ตทั้งหมด';

  @override
  String get resetDone => 'รีเซ็ตจำนวนแล้ว';

  @override
  String get aboutBody =>
      'JaapMitra คือพื้นที่สงบและเป็นส่วนตัวสำหรับการสวดมนต์ประจำวันของคุณ ทุกบทที่คุณสวดจะถูกเก็บไว้ในอุปกรณ์เครื่องนี้เท่านั้น';

  @override
  String get madeWith => 'สร้างด้วยศรัทธา';

  @override
  String get addReminder => 'เพิ่มการแจ้งเตือน';

  @override
  String get reminderTime => 'เวลา';

  @override
  String get everyDay => 'ทุกวัน';

  @override
  String get noRemindersTitle => 'ยังไม่มีการแจ้งเตือน';

  @override
  String get noRemindersBody =>
      'การเตือนเบาๆ ในเวลาเดิมทุกวันช่วยให้การสวดมนต์กลายเป็นนิสัย';

  @override
  String get notificationsBlocked =>
      'การแจ้งเตือนของ JaapMitra ถูกปิดอยู่ เปิดได้ในการตั้งค่าของอุปกรณ์';

  @override
  String get reminderNotificationTitle => 'ถึงเวลาสวดมนต์แล้ว';

  @override
  String get reminderNotificationBody =>
      'ใช้เวลาสงบสักครู่กับลูกประคำของคุณ 🙏';

  @override
  String get streakNotificationTitle => 'รักษาความต่อเนื่องไว้';

  @override
  String get streakNotificationBody =>
      'วันนี้คุณยังไม่ได้สวด เพียงหนึ่งรอบก็รักษาความต่อเนื่องไว้ได้';

  @override
  String get goalNotificationTitle => 'ใกล้ถึงแล้ว';

  @override
  String get goalNotificationBody =>
      'สวดให้ครบเป้าหมายวันนี้ เพื่อให้การปฏิบัติประจำวันสมบูรณ์';

  @override
  String get createBackup => 'สร้างข้อมูลสำรอง';

  @override
  String get createBackupBody =>
      'บันทึกไฟล์ JSON ที่มีบทสวด ประวัติการสวด เป้าหมาย และการตั้งค่าทั้งหมดของคุณ';

  @override
  String get restoreBackup => 'กู้คืนจากข้อมูลสำรอง';

  @override
  String get restoreBackupBody => 'เลือกไฟล์สำรองของ JaapMitra เพื่อกู้คืน';

  @override
  String get backupCreated => 'สร้างข้อมูลสำรองแล้ว';

  @override
  String get restoreWarningTitle => 'แทนที่ข้อมูลทั้งหมด?';

  @override
  String get restoreWarningBody =>
      'การกู้คืนจะแทนที่ข้อมูลทั้งหมดใน JaapMitra ตอนนี้ด้วยเนื้อหาจากไฟล์สำรอง';

  @override
  String get restore => 'กู้คืน';

  @override
  String restoreSuccess(int count) {
    return 'กู้คืนรายการสวด $count รายการแล้ว';
  }

  @override
  String get importInvalid => 'ไฟล์นี้ไม่ใช่ไฟล์สำรองของ JaapMitra ที่ถูกต้อง';

  @override
  String get exportShareText => 'ข้อมูลสำรอง JaapMitra ของฉัน';

  @override
  String get onb1Title => 'ลูกประคำดิจิทัลของคุณ';

  @override
  String get onb1Body => 'วิธีนับทุกบทสวดอย่างสงบ';

  @override
  String get onb2Title => 'สวดมนต์ให้เป็นนิสัย';

  @override
  String get onb2Body => 'ตั้งเป้าหมายรายวันและสร้างความต่อเนื่องในการสวด';

  @override
  String get onb3Title => 'สวดโดยไม่มีสิ่งรบกวน';

  @override
  String get onb3Body => 'เข้าสู่โหมดสมาธิด้วยตัวนับที่เรียบง่ายและสงบ';

  @override
  String get onbLookTitle => 'ปรับให้เป็นแบบของคุณ';

  @override
  String get onbLookBody =>
      'เลือกหน้าตาและเสียงของตัวนับ ธีม การแสดงบทสวด บทสวดร่วงลงมา และเพลง เปลี่ยนได้ทุกเมื่อในการตั้งค่า';

  @override
  String get onbFeaturesTitle => 'ทุกอย่างอยู่ในมือคุณ';

  @override
  String get onbFeaturesBody => 'สิ่งที่ควรรู้ก่อนเริ่มต้น';

  @override
  String get soundsFeatureTitle => 'เสียงที่ผ่อนคลาย';

  @override
  String get soundsFeatureBody =>
      'เปิดเสียงสวดเบาๆ เป็นพื้นหลังระหว่างทำสมาธิ ได้นานเท่าที่คุณนั่ง';

  @override
  String get startJap => 'เริ่มสวด';

  @override
  String get blackout => 'จอมืด';

  @override
  String get timer => 'ตัวจับเวลา';

  @override
  String get exitMeditation => 'ออกจากโหมดสมาธิ';

  @override
  String get tapAnywhere => 'แตะตรงไหนก็ได้เพื่อนับ';

  @override
  String semanticCounter(int count, int total) {
    return 'ตัวนับการสวด $count จาก $total เม็ด แตะสองครั้งเพื่อนับหนึ่ง';
  }

  @override
  String get autoJaap => 'นับอัตโนมัติ';

  @override
  String get autoJaapBody =>
      'แอปจะนับให้คุณด้วยจังหวะสม่ำเสมอ คุณจึงสวดตามได้โดยไม่ต้องใช้มือ';

  @override
  String get autoJaapPace => 'จังหวะ';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds วิ';
  }

  @override
  String get autoJaapStopAfter => 'หยุดเมื่อ';

  @override
  String get autoJaapStopMala => 'ครบหนึ่งรอบ';

  @override
  String get autoJaapStopGoal => 'ถึงเป้าหมายรายวัน';

  @override
  String get autoJaapStopNever => 'ไม่หยุด';

  @override
  String get autoJaapStart => 'เริ่มนับอัตโนมัติ';

  @override
  String get autoJaapStopAction => 'หยุดนับอัตโนมัติ';

  @override
  String get chantPlay => 'เล่น';

  @override
  String get chantStop => 'หยุด';

  @override
  String get music => 'เพลง';

  @override
  String get playMusic => 'เล่นเพลง';

  @override
  String get stopMusic => 'หยุดเพลง';

  @override
  String get chooseSound => 'เลือกเสียง';

  @override
  String get musicRecord => 'อัดเสียง';

  @override
  String get musicUpload => 'อัปโหลด';

  @override
  String get musicYours => 'เพลงของฉัน';

  @override
  String musicRecordingName(int n) {
    return 'เสียงที่อัด $n';
  }

  @override
  String get musicNameTitle => 'ตั้งชื่อเสียงที่อัด';

  @override
  String get musicRemove => 'ลบออก';

  @override
  String get musicAddFailed => 'ไม่สามารถเพิ่มไฟล์นั้นได้';

  @override
  String get ownMusicTitle => 'ใช้เพลงของคุณเอง';

  @override
  String get ownMusicBody =>
      'อัดเสียงสวดของคุณเอง หรืออัปโหลดเสียงสำหรับทำสมาธิ แล้วจะเล่นตลอดการนั่งของคุณ';

  @override
  String counterCount(String count) {
    return 'นับ: $count';
  }

  @override
  String counterMalas(String count) {
    return 'รอบ: $count';
  }

  @override
  String counterTotal(String count) {
    return 'รวม: $count';
  }

  @override
  String get autoJaapTapToStop => 'กำลังนับอัตโนมัติ · แตะตรงไหนก็ได้เพื่อหยุด';

  @override
  String get hideMantra => 'ซ่อนบทสวด';

  @override
  String get showMantra => 'แสดงบทสวด';

  @override
  String get changeTheme => 'เปลี่ยนธีม';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ต่อเนื่อง $count วัน',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'เมนู';

  @override
  String get chooseTheme => 'เลือกธีม';

  @override
  String get themeAuto => 'อัตโนมัติ';

  @override
  String get themeWhite => 'ขาว';

  @override
  String get themeBlack => 'ดำ';

  @override
  String get themePastelPink => 'ชมพูพาสเทล';

  @override
  String get themeSpiritual => 'จิตวิญญาณ';

  @override
  String get themeSaffron => 'หญ้าฝรั่น';

  @override
  String get themePeaceful => 'สงบ';

  @override
  String get themeTerracotta => 'ดินเผา';

  @override
  String get themeMeditative => 'สมาธิ';

  @override
  String get themeNature => 'ธรรมชาติ';

  @override
  String get themeRoseGold => 'โรสโกลด์';

  @override
  String get themeOcean => 'มหาสมุทร';

  @override
  String get themeLavender => 'ลาเวนเดอร์';

  @override
  String get themeCharcoal => 'ถ่าน';

  @override
  String get counterBackground => 'พื้นหลังตัวนับ';

  @override
  String get counterBackgroundBody =>
      'แสดงอยู่ด้านหลังบทสวดและเม็ดประคำบนตัวนับ';

  @override
  String get backgroundNone => 'ไม่มี';

  @override
  String get backgroundDawn => 'รุ่งอรุณ';

  @override
  String get backgroundDusk => 'สนธยา';

  @override
  String get backgroundLotus => 'ดอกบัว';

  @override
  String get backgroundForest => 'ป่า';

  @override
  String get backgroundOcean => 'มหาสมุทร';

  @override
  String get backgroundCosmos => 'จักรวาล';

  @override
  String get backgroundPhoto => 'รูปของฉัน';

  @override
  String get backgroundChoosePhoto => 'เลือกรูปภาพ';

  @override
  String get backgroundChangePhoto => 'เปลี่ยนรูปภาพ';

  @override
  String get backgroundRemovePhoto => 'ลบรูปภาพ';

  @override
  String get backgroundDim => 'หรี่พื้นหลัง';

  @override
  String get backgroundDimHint => 'ยิ่งหรี่มาก บทสวดก็ยิ่งอ่านง่าย';

  @override
  String get addOwnMantra => 'เพิ่มบทสวดของคุณเอง';

  @override
  String get addOwnMantraHint =>
      'ชื่อหรือบทสวดใดก็ได้ ในอักษรใดก็ได้ พร้อมจำนวนเม็ดประคำที่คุณกำหนด';

  @override
  String get legendLess => 'น้อย';

  @override
  String get legendMore => 'มาก';

  @override
  String get allMantras => 'ทุกบทสวด';

  @override
  String get previousPeriod => 'ก่อนหน้า';

  @override
  String get nextPeriod => 'ถัดไป';

  @override
  String get showStatsFor => 'แสดงสถิติของ';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · $count จบ · $malas รอบ';
  }

  @override
  String get dailyJaap => 'การสวดรายวัน';

  @override
  String get mantraText => 'บทสวด';

  @override
  String get mantraTextHint => 'เช่น โอม นมัส ศิวายะ หรือ राम';

  @override
  String get mantraRequired => 'กรุณาใส่บทสวด';

  @override
  String get mantraDescription => 'คำอธิบาย';

  @override
  String get mantraDescriptionHint => 'ความหมาย ที่มา หรือบันทึกถึงตัวคุณเอง';

  @override
  String get dictationStart => 'ใส่บทสวดด้วยการพูด';

  @override
  String get dictationListening => 'กำลังฟัง… แตะเพื่อหยุด';

  @override
  String get dictationUnavailable =>
      'อุปกรณ์นี้ไม่รองรับการป้อนข้อมูลด้วยเสียง';

  @override
  String get dictationOfflineUnavailable =>
      'โทรศัพท์เครื่องนี้ไม่รองรับการป้อนเสียงแบบออฟไลน์สำหรับภาษานี้ เสียงของคุณจะไม่ออกไปจากอุปกรณ์ จึงขอให้พิมพ์แทน';

  @override
  String get micPermissionDenied => 'ต้องอนุญาตให้ใช้ไมโครโฟนสำหรับการนี้';

  @override
  String get fallingMantra => 'บทสวดร่วงลงมา';

  @override
  String get stopFallingMantra => 'หยุดบทสวดร่วงลงมา';

  @override
  String get malaStyle => 'รูปแบบลูกประคำ';

  @override
  String get malaStyleBeads => 'เม็ดประคำ';

  @override
  String get malaStyleRing => 'วงแหวนความคืบหน้า';

  @override
  String get sectionCounter => 'ตัวนับ';

  @override
  String get showMantraOnCounter => 'แสดงบทสวดบนตัวนับ';

  @override
  String get goalUnitMalas => 'รอบ';

  @override
  String get goalUnitJaap => 'จบ';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count รอบ',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'จำนวนรอบต่อวัน';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas รอบ',
    );
    return 'วันละ $_temp0 · $jaap จบ';
  }

  @override
  String get onbMantraTitle => 'คุณสวดบทใด?';

  @override
  String get onbMantraBody =>
      'เลือกหนึ่งบทเพื่อเริ่มต้น เพิ่มบทอื่นได้ทุกเมื่อ';

  @override
  String get onbGoalTitle => 'เป้าหมายรายวันของคุณ';

  @override
  String get onbGoalBody =>
      'เริ่มจากน้อยๆ การสวดอย่างสม่ำเสมอสำคัญกว่าตัวเลขที่สูง เปลี่ยนได้ทุกเมื่อ';

  @override
  String get shareProgress => 'แชร์ความก้าวหน้าของฉัน';

  @override
  String get shareStreakLabel => 'วันต่อเนื่อง';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count วัน',
    );
    return 'สวดมนต์ต่อเนื่อง $_temp0 ด้วย JaapMitra 🙏';
  }

  @override
  String get blackoutMode => 'โหมดจอมืด';

  @override
  String get exitBlackout => 'ออกจากจอมืด';

  @override
  String get feedbackEmailSubject => 'ความคิดเห็นเกี่ยวกับ JaapMitra';

  @override
  String get homeScreenWidget => 'วิดเจ็ตหน้าจอหลัก';

  @override
  String get homeScreenWidgetBody =>
      'ดูการสวดวันนี้และความต่อเนื่องของคุณบนหน้าจอหลัก โดยไม่ต้องเปิดแอป';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'แตะค้างที่พื้นที่ว่างบนหน้าจอหลัก แตะวิดเจ็ต แล้วหา JaapMitra';

  @override
  String get homeScreenWidgetStepsIOS =>
      'แตะค้างที่พื้นที่ว่างบนหน้าจอหลัก แตะ + ที่มุมจอ ค้นหา JaapMitra แล้วเลือกขนาดและแตะเพิ่มวิดเจ็ต';

  @override
  String get addToHomeScreen => 'เพิ่มไปยังหน้าจอหลัก';

  @override
  String get countWithButtons => 'นับด้วยปุ่ม';

  @override
  String get countWithButtonsHintAndroid =>
      'ปุ่มปรับเสียง ปุ่มบนหูฟัง หรือรีโมตบลูทูธ นับได้ครั้งละหนึ่งเม็ด';

  @override
  String get countWithButtonsHintIOS =>
      'รีโมตบลูทูธหรือคีย์บอร์ดนับได้ครั้งละหนึ่งเม็ด แอปไม่สามารถใช้ปุ่มปรับเสียงของ iPhone ได้';

  @override
  String get lockScreenCounter => 'ตัวนับบนหน้าจอล็อก';

  @override
  String get lockScreenCounterHint =>
      'ปุ่ม +1 บนหน้าจอล็อกและ Dynamic Island การแตะจะถูกเพิ่มเข้าการสวดของคุณเมื่อเปิดแอปครั้งถัดไป';

  @override
  String get markerBead => 'เม็ดคั่น';

  @override
  String get markerBeadHint =>
      'การสั่นหนักหนึ่งครั้งระหว่างรอบ เพื่อให้รู้ว่าสวดถึงไหนแล้วแม้หลับตา';

  @override
  String markerBeadEvery(int count) {
    return 'ทุก $count';
  }

  @override
  String get markerBeadOff => 'ปิด';

  @override
  String get graceDays => 'วันผ่อนผัน';

  @override
  String get graceDaysHint =>
      'ทุก 7 วันติดต่อกันจะได้รับวันผ่อนผันหนึ่งวัน (สูงสุด 2 วัน) วันที่พลาดจะใช้วันผ่อนผันแทนการทำให้ความต่อเนื่องขาด';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มีวันผ่อนผัน $count วัน',
      zero: 'ไม่มีวันผ่อนผัน',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'ใช้วันผ่อนผันแทนแล้ว';

  @override
  String milestoneLakh(int count) {
    return '$count แสนจบ';
  }

  @override
  String get milestoneSavaLakh => '125,000 จบ';

  @override
  String get milestoneCrore => '10,000,000 จบ';

  @override
  String milestoneStreak(int days) {
    return 'ต่อเนื่อง $days วัน';
  }

  @override
  String milestoneReached(String milestone) {
    return 'ถึง $milestone แล้ว หนึ่งหมุดหมายในการปฏิบัติของคุณ';
  }

  @override
  String get milestones => 'หมุดหมาย';

  @override
  String milestoneNext(String milestone) {
    return 'ถัดไป: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'เหลืออีก $countString';
  }

  @override
  String get milestoneAllReached => 'ถึงทุกหมุดหมายแล้ว';

  @override
  String get yearInReview => 'สรุปทั้งปี';

  @override
  String yearInReviewTitle(int year) {
    return 'การสวดของคุณในปี $year';
  }

  @override
  String yearNoJaap(int year) {
    return 'ไม่มีการสวดที่บันทึกไว้ในปี $year';
  }

  @override
  String get yearActiveDays => 'วันที่สวด';

  @override
  String get yearLongestRun => 'ต่อเนื่องนานที่สุด';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count วัน',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'วันที่ดีที่สุด';

  @override
  String get yearTopMantra => 'สวดมากที่สุด';

  @override
  String get yearByMonth => 'แยกตามเดือน';

  @override
  String get yearMilestones => 'หมุดหมายในปีนี้';

  @override
  String yearShareText(int year, String count) {
    return 'การสวดมนต์ของฉันในปี $year: $count จบ';
  }

  @override
  String get previousYear => 'ปีก่อนหน้า';

  @override
  String get nextYear => 'ปีถัดไป';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'อินทิราเอกาทศี',
      'papankusha': 'ปาปางกุศาเอกาทศี',
      'rama': 'รามาเอกาทศี',
      'devutthana': 'เทวุตถานะเอกาทศี',
      'utpanna': 'อุตปันนาเอกาทศี',
      'mokshada': 'โมกษทาเอกาทศี',
      'saphala': 'สผลาเอกาทศี',
      'paushaPutrada': 'เปาษะปุตรทาเอกาทศี',
      'shattila': 'ษัฏติลาเอกาทศี',
      'jaya': 'ชยาเอกาทศี',
      'vijaya': 'วิชยาเอกาทศี',
      'amalaki': 'อามลกีเอกาทศี',
      'papamochani': 'ปาปโมจนีเอกาทศี',
      'kamada': 'กามทาเอกาทศี',
      'varuthini': 'วรูถินีเอกาทศี',
      'mohini': 'โมหินีเอกาทศี',
      'apara': 'อปราเอกาทศี',
      'nirjala': 'นิรชลาเอกาทศี',
      'yogini': 'โยคินีเอกาทศี',
      'devshayani': 'เทวศยนีเอกาทศี',
      'kamika': 'กามิกาเอกาทศี',
      'shravanaPutrada': 'ศราวณะปุตรทาเอกาทศี',
      'aja': 'อชาเอกาทศี',
      'parsva': 'ปารศวะเอกาทศี',
      'other': 'เอกาทศี',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'ศารทนวราตรี',
      'chaitraNavratri': 'ไจตรนวราตรี',
      'dussehra': 'ทศหรา',
      'diwali': 'ดิวาลี',
      'kartikMonth': 'เดือนการติก',
      'kartikPurnima': 'การติกปูรณิมา',
      'guruNanakJayanti': 'คุรุนานักชยันตี',
      'makarSankranti': 'มกรสังกรานติ',
      'vasantPanchami': 'วสันตปัญจมี',
      'mahaShivaratri': 'มหาศิวราตรี',
      'holi': 'โฮลี',
      'ramNavami': 'รามนวมี',
      'mahavirJayanti': 'มหาวีรชยันตี',
      'hanumanJayanti': 'หนุมานชยันตี',
      'guruPurnima': 'คุรุปูรณิมา',
      'shravanMonth': 'เดือนศราวณะ',
      'rakshaBandhan': 'รักษาพันธัน',
      'krishnaJanmashtami': 'กฤษณะชนมาษฏมี',
      'ganeshChaturthi': 'คเณศจตุรถี',
      'other': 'เทศกาล',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return 'เริ่ม $date';
  }

  @override
  String get upcomingObservances => 'เอกาทศีและเทศกาล';

  @override
  String get observanceToday => 'วันนี้';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count วัน',
      one: 'พรุ่งนี้',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return 'สัจจะสำหรับ$name';
  }

  @override
  String get observanceTakeSankalp => 'ตั้งสัจจะ';

  @override
  String observanceVaishnava(String date) {
    return 'วันตามธรรมเนียมไวษณพ (ISKCON): $date';
  }

  @override
  String get observanceSourceNote =>
      'วันที่อ้างอิงปฏิทิน Drik Panchang ของนิวเดลี เทวาลัยหรือธรรมเนียมในพื้นที่ของคุณอาจถือต่างกันหนึ่งวัน';

  @override
  String get observancesNone => 'ไม่มีในอีกไม่กี่สัปดาห์ข้างหน้า';

  @override
  String get festivalReminders => 'เตือนวันเอกาทศีและเทศกาล';

  @override
  String get festivalRemindersHint =>
      'แจ้งเตือนเวลา 6 โมงเช้าในวันเอกาทศีและวันเทศกาล';

  @override
  String festivalNotificationBody(String name) {
    return 'วันนี้คือวัน$name วันมงคลสำหรับการสวดมนต์';
  }

  @override
  String get sendDiagnostics => 'ส่งข้อมูลวินิจฉัย';

  @override
  String get diagnosticsExplain =>
      'รายงานนี้ช่วยแก้ไขปัญหา ประกอบด้วยเวอร์ชันของแอปและโทรศัพท์ การตั้งค่าของคุณ และบันทึกข้อผิดพลาดของแอป ไม่มีบทสวด จำนวนการสวด หรือบันทึกใดๆ จะไม่มีการส่งสิ่งใดจนกว่าคุณจะเลือกวิธีด้านล่าง';

  @override
  String get diagnosticsEmail => 'ส่งทางอีเมล';

  @override
  String get diagnosticsShare => 'แชร์เป็นไฟล์';

  @override
  String get diagnosticsEmailSubject => 'ข้อมูลวินิจฉัย JaapMitra';

  @override
  String get diagnosticsNoMail => 'ไม่พบแอปอีเมล ลองแชร์เป็นไฟล์แทน';
}
