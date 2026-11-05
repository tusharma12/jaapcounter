// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Чётки для джапы: JaapMitra';

  @override
  String get tagline => 'Спутник в бхакти — каждый день';

  @override
  String get navJaap => 'Джапа';

  @override
  String get navProgress => 'Прогресс';

  @override
  String get navStories => 'Истории';

  @override
  String get navSettings => 'Настройки';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get close => 'Закрыть';

  @override
  String get next => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get back => 'Назад';

  @override
  String get retry => 'Повторить';

  @override
  String get custom => 'Свой вариант';

  @override
  String get active => 'Активна';

  @override
  String get off => 'ВЫКЛ';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get tapToCount => 'КОСНИТЕСЬ, ЧТОБЫ СЧИТАТЬ';

  @override
  String get todaysJaap => 'Джапа сегодня';

  @override
  String get undo => 'Отменить';

  @override
  String get malaComplete => 'Круг завершён';

  @override
  String malasCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Завершено $count круга',
      many: 'Завершено $count кругов',
      few: 'Завершено $count круга',
      one: 'Завершён $count круг',
    );
    return '$_temp0';
  }

  @override
  String jaapCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString повторения',
      many: '$countString повторений',
      few: '$countString повторения',
      one: '$countString повторение',
    );
    return '$_temp0';
  }

  @override
  String get resetCurrentMala => 'Сбросить текущий круг';

  @override
  String get resetCurrentMalaBody =>
      'Бусины, отсчитанные в этом круге, будут удалены. Завершённые круги сохранятся.';

  @override
  String get addCountManually => 'Добавить вручную';

  @override
  String get addCount => 'Добавить';

  @override
  String get numberOfJaap => 'Количество повторений';

  @override
  String get meditationMode => 'Режим медитации';

  @override
  String get startSession => 'Начать сессию';

  @override
  String get endSession => 'Завершить сессию';

  @override
  String sessionSummary(int jaap, int minutes) {
    return '$jaap повт. за $minutes мин';
  }

  @override
  String get myMantras => 'Мои мантры';

  @override
  String get addMantra => 'Добавить мантру';

  @override
  String get editMantra => 'Изменить мантру';

  @override
  String get malaSize => 'Размер чёток';

  @override
  String beads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бусины',
      many: '$count бусин',
      few: '$count бусины',
      one: '$count бусина',
    );
    return '$_temp0';
  }

  @override
  String get malaSizeInvalid => 'Размер чёток должен быть от 1 до 10 000';

  @override
  String get deleteMantraTitle => 'Удалить мантру?';

  @override
  String deleteMantraBody(String name) {
    return 'Мантра «$name» будет удалена. История вашей джапы сохранится.';
  }

  @override
  String get optional => 'необязательно';

  @override
  String get mySadhana => 'Моя садхана';

  @override
  String get todaysGoal => 'Цель на сегодня';

  @override
  String get complete => 'Выполнено';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня подряд',
      many: '$count дней подряд',
      few: '$count дня подряд',
      one: '$count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get bestStreak => 'Лучшая серия';

  @override
  String sankalpDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'САНКАЛЬПА НА $days ДНЯ',
      many: 'САНКАЛЬПА НА $days ДНЕЙ',
      few: 'САНКАЛЬПА НА $days ДНЯ',
      one: 'САНКАЛЬПА НА $days ДЕНЬ',
    );
    return '$_temp0';
  }

  @override
  String dayXofY(int current, int total) {
    return 'День $current из $total';
  }

  @override
  String daysCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выполнено $count дня',
      many: 'Выполнено $count дней',
      few: 'Выполнено $count дня',
      one: 'Выполнен $count день',
    );
    return '$_temp0';
  }

  @override
  String startedOn(String date) {
    return 'Начато $date';
  }

  @override
  String get createNewSankalp => 'Новая санкальпа';

  @override
  String get createSankalp => 'Принять санкальпу';

  @override
  String get chooseMantra => 'Выберите мантру';

  @override
  String get dailyGoal => 'Цель на день';

  @override
  String get duration => 'Длительность';

  @override
  String durationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0';
  }

  @override
  String get reminder => 'Напоминание';

  @override
  String get beginSadhana => 'Начать садхану';

  @override
  String get noSankalpTitle => 'Примите санкальпу';

  @override
  String get noSankalpBody =>
      'Санкальпа — это обет повторять мантру определённое число раз каждый день в течение выбранного количества дней.';

  @override
  String get endSankalp => 'Завершить санкальпу';

  @override
  String get endSankalpBody =>
      'Ваш прогресс сохранится, но санкальпа больше не будет активной.';

  @override
  String jaapPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count повторения в день',
      many: '$count повторений в день',
      few: '$count повторения в день',
      one: '$count повторение в день',
    );
    return '$_temp0';
  }

  @override
  String goalRemaining(int count) {
    return 'Осталось: $count';
  }

  @override
  String get goalReached => 'Цель на день достигнута';

  @override
  String get goalReachedAutoBody =>
      'Автоджапа приостановлена. Продолжить или остановиться?';

  @override
  String get keepGoing => 'Продолжить';

  @override
  String get setDailyGoal => 'Задать цель на день';

  @override
  String get sadhanaGoals => 'Цели садханы';

  @override
  String get progress => 'Прогресс';

  @override
  String get filterDaily => 'День';

  @override
  String get filterWeekly => 'Неделя';

  @override
  String get filterMonthly => 'Месяц';

  @override
  String get filterYearly => 'Год';

  @override
  String get totalJaap => 'Всего повторений';

  @override
  String get totalMalas => 'Всего кругов';

  @override
  String get weeklyJaap => 'Джапа за неделю';

  @override
  String get monthlyJaap => 'Джапа за месяц';

  @override
  String get yearlyJaap => 'Джапа за год';

  @override
  String ofGoal(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '/ цель $countString';
  }

  @override
  String get noJaapYet => 'Джапа ещё не записана';

  @override
  String get noJaapYetBody => 'Первая бусина — начало пути.';

  @override
  String get dailyAverage => 'В среднем за день';

  @override
  String get activeDays => 'Активные дни';

  @override
  String get perMantra => 'По мантрам';

  @override
  String get stories => 'Истории';

  @override
  String get storiesSubtitle => 'Короткие истории для размышления';

  @override
  String get popular => 'Популярное';

  @override
  String get read => 'Читать';

  @override
  String get listen => 'Слушать';

  @override
  String get stopListening => 'Стоп';

  @override
  String get textSize => 'Размер текста';

  @override
  String get favorite => 'В избранное';

  @override
  String get favorites => 'Избранное';

  @override
  String get share => 'Поделиться';

  @override
  String get all => 'Все';

  @override
  String minRead(int minutes) {
    return '$minutes мин чтения';
  }

  @override
  String get noFavoritesTitle => 'Пока нет избранного';

  @override
  String get noFavoritesBody =>
      'Нажмите на сердечко у истории, чтобы сохранить её здесь.';

  @override
  String get noStoriesFound => 'Истории не найдены';

  @override
  String get settings => 'Настройки';

  @override
  String get sectionJaap => 'ДЖАПА';

  @override
  String get sectionReminders => 'НАПОМИНАНИЯ';

  @override
  String get sectionAppearance => 'ОФОРМЛЕНИЕ';

  @override
  String get sectionBackup => 'РЕЗЕРВНАЯ КОПИЯ';

  @override
  String get sectionSupport => 'ПОДДЕРЖКА';

  @override
  String get sectionAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get resetCounts => 'Сбросить счёт';

  @override
  String get jaapReminders => 'Напоминания о джапе';

  @override
  String get streakReminder => 'Напоминание о серии';

  @override
  String get goalReminder => 'Напоминание о цели';

  @override
  String get theme => 'Тема';

  @override
  String get haptics => 'Вибрация';

  @override
  String get sound => 'Звук';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get backupRestore => 'Резервное копирование';

  @override
  String get exportMyData => 'Экспорт моих данных';

  @override
  String get rateApp => 'Оценить JaapMitra';

  @override
  String get shareApp => 'Пригласить родных и друзей';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get usageStats => 'Отправлять анонимную статистику';

  @override
  String get usageStatsHint =>
      'Какие экраны и функции используются. Никогда — ваши мантры или счёт.';

  @override
  String get terms => 'Условия';

  @override
  String get aboutApp => 'О JaapMitra';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get resetTodayTitle => 'Сбросить сегодняшнюю джапу?';

  @override
  String get resetTodayBody =>
      'Вся джапа, записанная сегодня, будет удалена. Это действие нельзя отменить.';

  @override
  String get resetAllTitle => 'Сбросить всю джапу?';

  @override
  String get resetAllBody =>
      'Вся история джапы, круги и серии будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get resetToday => 'Сбросить сегодня';

  @override
  String get resetEverything => 'Сбросить всё';

  @override
  String get resetDone => 'Счёт сброшен';

  @override
  String get aboutBody =>
      'JaapMitra — тихое, личное пространство для вашей ежедневной нама-джапы. Всё, что вы повторяете, хранится только на этом устройстве.';

  @override
  String get madeWith => 'Сделано с преданностью';

  @override
  String get addReminder => 'Добавить напоминание';

  @override
  String get reminderTime => 'Время';

  @override
  String get everyDay => 'Каждый день';

  @override
  String get noRemindersTitle => 'Напоминаний пока нет';

  @override
  String get noRemindersBody =>
      'Мягкое напоминание в одно и то же время каждый день превращает практику в привычку.';

  @override
  String get notificationsBlocked =>
      'Уведомления для JaapMitra отключены. Включите их в настройках устройства.';

  @override
  String get reminderNotificationTitle => 'Время для джапы';

  @override
  String get reminderNotificationBody => 'Несколько тихих минут с чётками 🙏';

  @override
  String get streakNotificationTitle => 'Сохраните свою серию';

  @override
  String get streakNotificationBody =>
      'Сегодня вы ещё не повторяли мантру. Одного круга достаточно, чтобы продолжить серию.';

  @override
  String get goalNotificationTitle => 'Почти у цели';

  @override
  String get goalNotificationBody =>
      'Выполните цель на сегодня, чтобы завершить дневную садхану.';

  @override
  String get createBackup => 'Создать резервную копию';

  @override
  String get createBackupBody =>
      'Сохранить JSON-файл со всеми мантрами, историей джапы, целями и настройками.';

  @override
  String get restoreBackup => 'Восстановить из копии';

  @override
  String get restoreBackupBody =>
      'Выберите файл резервной копии JaapMitra для восстановления.';

  @override
  String get backupCreated => 'Резервная копия создана';

  @override
  String get restoreWarningTitle => 'Заменить все данные?';

  @override
  String get restoreWarningBody =>
      'При восстановлении все текущие данные в JaapMitra будут заменены содержимым файла резервной копии.';

  @override
  String get restore => 'Восстановить';

  @override
  String restoreSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Восстановлено $count записи джапы',
      many: 'Восстановлено $count записей джапы',
      few: 'Восстановлено $count записи джапы',
      one: 'Восстановлена $count запись джапы',
    );
    return '$_temp0';
  }

  @override
  String get importInvalid =>
      'Этот файл не является резервной копией JaapMitra';

  @override
  String get exportShareText => 'Моя резервная копия JaapMitra';

  @override
  String get onb1Title => 'Ваши цифровые чётки';

  @override
  String get onb1Body => 'Спокойный способ считать каждое повторение мантры.';

  @override
  String get onb2Title => 'Сделайте садхану привычкой';

  @override
  String get onb2Body => 'Поставьте цель на день и наращивайте серию дней.';

  @override
  String get onb3Title => 'Джапа без отвлечений';

  @override
  String get onb3Body =>
      'Включите режим медитации с чистым, спокойным счётчиком.';

  @override
  String get onbLookTitle => 'Настройте под себя';

  @override
  String get onbLookBody =>
      'Выберите, как выглядит и звучит счётчик. Тему, отображение мантры, падающую мантру и музыку можно изменить в любой момент в настройках.';

  @override
  String get onbFeaturesTitle => 'Всё в ваших руках';

  @override
  String get onbFeaturesBody => 'Несколько полезных вещей перед началом.';

  @override
  String get soundsFeatureTitle => 'Успокаивающие звуки';

  @override
  String get soundsFeatureBody =>
      'Включите мягкое фоновое пение на время медитации — сколько бы вы ни сидели.';

  @override
  String get startJap => 'Начать джапу';

  @override
  String get blackout => 'Темнота';

  @override
  String get timer => 'Таймер';

  @override
  String get exitMeditation => 'Выйти из режима медитации';

  @override
  String get tapAnywhere => 'Коснитесь где угодно, чтобы считать';

  @override
  String semanticCounter(int count, int total) {
    return 'Счётчик джапы. $count из $total бусин. Коснитесь дважды, чтобы добавить одну.';
  }

  @override
  String get autoJaap => 'Автоджапа';

  @override
  String get autoJaapBody =>
      'Приложение считает за вас в ровном темпе, а вы повторяете мантру, не касаясь экрана.';

  @override
  String get autoJaapPace => 'Темп';

  @override
  String autoJaapSeconds(int seconds) {
    return '$seconds с';
  }

  @override
  String get autoJaapStopAfter => 'Остановить после';

  @override
  String get autoJaapStopMala => 'Одного круга';

  @override
  String get autoJaapStopGoal => 'Цели на день';

  @override
  String get autoJaapStopNever => 'Не останавливать';

  @override
  String get autoJaapStart => 'Запустить автоджапу';

  @override
  String get autoJaapStopAction => 'Остановить автоджапу';

  @override
  String get chantPlay => 'Играть';

  @override
  String get chantStop => 'Стоп';

  @override
  String get music => 'Музыка';

  @override
  String get playMusic => 'Включить музыку';

  @override
  String get stopMusic => 'Выключить музыку';

  @override
  String get chooseSound => 'Выберите звук';

  @override
  String get musicRecord => 'Записать';

  @override
  String get musicUpload => 'Загрузить';

  @override
  String get musicYours => 'Моя музыка';

  @override
  String musicRecordingName(int n) {
    return 'Запись $n';
  }

  @override
  String get musicNameTitle => 'Назовите запись';

  @override
  String get musicRemove => 'Удалить';

  @override
  String get musicAddFailed => 'Не удалось добавить этот файл';

  @override
  String get ownMusicTitle => 'Своя музыка';

  @override
  String get ownMusicBody =>
      'Запишите своё пение или загрузите звук для медитации — он будет играть всё время вашей практики.';

  @override
  String counterCount(String count) {
    return 'Счёт: $count';
  }

  @override
  String counterMalas(String count) {
    return 'Круги: $count';
  }

  @override
  String counterTotal(String count) {
    return 'Всего: $count';
  }

  @override
  String get autoJaapTapToStop =>
      'Идёт автоджапа · коснитесь, чтобы остановить';

  @override
  String get hideMantra => 'Скрыть мантру';

  @override
  String get showMantra => 'Показать мантру';

  @override
  String get changeTheme => 'Сменить тему';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня подряд',
      many: '$count дней подряд',
      few: '$count дня подряд',
      one: '$count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Меню';

  @override
  String get chooseTheme => 'Выберите тему';

  @override
  String get themeAuto => 'Авто';

  @override
  String get themeWhite => 'Белая';

  @override
  String get themeBlack => 'Чёрная';

  @override
  String get themePastelPink => 'Пастельно-розовая';

  @override
  String get themeSpiritual => 'Духовная';

  @override
  String get themeSaffron => 'Шафрановая';

  @override
  String get themePeaceful => 'Умиротворённая';

  @override
  String get themeTerracotta => 'Терракотовая';

  @override
  String get themeMeditative => 'Медитативная';

  @override
  String get themeNature => 'Природа';

  @override
  String get themeRoseGold => 'Розовое золото';

  @override
  String get themeOcean => 'Океан';

  @override
  String get themeLavender => 'Лаванда';

  @override
  String get themeCharcoal => 'Графит';

  @override
  String get counterBackground => 'Фон счётчика';

  @override
  String get counterBackgroundBody =>
      'Отображается за мантрой и бусинами на счётчике.';

  @override
  String get backgroundNone => 'Нет';

  @override
  String get backgroundDawn => 'Рассвет';

  @override
  String get backgroundDusk => 'Сумерки';

  @override
  String get backgroundLotus => 'Лотос';

  @override
  String get backgroundForest => 'Лес';

  @override
  String get backgroundOcean => 'Океан';

  @override
  String get backgroundCosmos => 'Космос';

  @override
  String get backgroundPhoto => 'Моё фото';

  @override
  String get backgroundChoosePhoto => 'Выбрать фото';

  @override
  String get backgroundChangePhoto => 'Сменить фото';

  @override
  String get backgroundRemovePhoto => 'Удалить фото';

  @override
  String get backgroundDim => 'Затемнение фона';

  @override
  String get backgroundDimHint =>
      'Чем сильнее затемнение, тем легче читать мантру.';

  @override
  String get addOwnMantra => 'Добавить свою мантру';

  @override
  String get addOwnMantraHint =>
      'Любое имя или мантра, на любом языке, со своим размером чёток';

  @override
  String get legendLess => 'Меньше';

  @override
  String get legendMore => 'Больше';

  @override
  String get allMantras => 'Все мантры';

  @override
  String get previousPeriod => 'Назад';

  @override
  String get nextPeriod => 'Вперёд';

  @override
  String get showStatsFor => 'Показать статистику за';

  @override
  String selectionSummary(String label, String count, String malas) {
    return '$label · повторений: $count · кругов: $malas';
  }

  @override
  String get dailyJaap => 'Джапа за день';

  @override
  String get mantraText => 'Мантра';

  @override
  String get mantraTextHint => 'например, Харе Кришна или Ом Намах Шивая';

  @override
  String get mantraRequired => 'Введите мантру';

  @override
  String get mantraDescription => 'Описание';

  @override
  String get mantraDescriptionHint => 'Значение, источник или заметка для себя';

  @override
  String get dictationStart => 'Продиктовать мантру голосом';

  @override
  String get dictationListening => 'Слушаю… коснитесь, чтобы остановить';

  @override
  String get dictationUnavailable =>
      'Голосовой ввод недоступен на этом устройстве';

  @override
  String get dictationOfflineUnavailable =>
      'Офлайн-распознавание речи для этого языка недоступно на этом телефоне. Ваш голос никогда не покидает устройство, поэтому введите мантру вручную.';

  @override
  String get micPermissionDenied => 'Для этого нужен доступ к микрофону';

  @override
  String get fallingMantra => 'Падающая мантра';

  @override
  String get stopFallingMantra => 'Остановить падающую мантру';

  @override
  String get malaStyle => 'Вид чёток';

  @override
  String get malaStyleBeads => 'Бусины';

  @override
  String get malaStyleRing => 'Кольцо прогресса';

  @override
  String get sectionCounter => 'СЧЁТЧИК';

  @override
  String get showMantraOnCounter => 'Показывать мантру на счётчике';

  @override
  String get goalUnitMalas => 'Круги';

  @override
  String get goalUnitJaap => 'Повторения';

  @override
  String malaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count круга',
      many: '$count кругов',
      few: '$count круга',
      one: '$count круг',
    );
    return '$_temp0';
  }

  @override
  String get malasPerDay => 'Кругов в день';

  @override
  String goalMalasPerDay(int malas, String jaap) {
    String _temp0 = intl.Intl.pluralLogic(
      malas,
      locale: localeName,
      other: '$malas круга',
      many: '$malas кругов',
      few: '$malas круга',
      one: '$malas круг',
    );
    return '$_temp0 в день · $jaap повт.';
  }

  @override
  String get onbMantraTitle => 'Какую мантру вы повторяете?';

  @override
  String get onbMantraBody =>
      'Выберите одну, чтобы начать. Другие можно добавить в любой момент.';

  @override
  String get onbGoalTitle => 'Ваша цель на день';

  @override
  String get onbGoalBody =>
      'Начните с малого: регулярность важнее большого числа. Цель можно изменить в любой момент.';

  @override
  String get shareProgress => 'Поделиться прогрессом';

  @override
  String get shareStreakLabel => 'дней подряд';

  @override
  String shareCardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0 нама-джапы подряд с JaapMitra 🙏';
  }

  @override
  String get blackoutMode => 'Режим темноты';

  @override
  String get exitBlackout => 'Выйти из темноты';

  @override
  String get feedbackEmailSubject => 'Отзыв о JaapMitra';

  @override
  String get homeScreenWidget => 'Виджет на экране «Домой»';

  @override
  String get homeScreenWidgetBody =>
      'Сегодняшняя джапа и ваша серия прямо на главном экране — без открытия приложения.';

  @override
  String get homeScreenWidgetStepsAndroid =>
      'Нажмите и удерживайте пустое место на главном экране, выберите «Виджеты» и найдите JaapMitra.';

  @override
  String get homeScreenWidgetStepsIOS =>
      'Нажмите и удерживайте пустое место на экране «Домой», коснитесь «+» в углу, найдите JaapMitra, выберите размер и нажмите «Добавить виджет».';

  @override
  String get addToHomeScreen => 'Добавить на главный экран';

  @override
  String get countWithButtons => 'Счёт кнопками';

  @override
  String get countWithButtonsHintAndroid =>
      'Кнопки громкости, кнопка гарнитуры или Bluetooth-кликер отсчитывают бусину';

  @override
  String get countWithButtonsHintIOS =>
      'Bluetooth-кликер или клавиатура отсчитывают бусину. Кнопки громкости iPhone приложениям недоступны.';

  @override
  String get lockScreenCounter => 'Счётчик на экране блокировки';

  @override
  String get lockScreenCounterHint =>
      'Кнопка +1 на экране блокировки и в Dynamic Island. Нажатия добавятся к вашей джапе при следующем открытии приложения.';

  @override
  String get markerBead => 'Бусина-метка';

  @override
  String get markerBeadHint =>
      'Один ощутимый толчок посреди круга, чтобы с закрытыми глазами чувствовать, где вы находитесь';

  @override
  String markerBeadEvery(int count) {
    return 'Каждые $count';
  }

  @override
  String get markerBeadOff => 'Выкл';

  @override
  String get graceDays => 'Запасные дни';

  @override
  String get graceDaysHint =>
      'Каждые 7 дней подряд дают запасной день (до 2). Пропущенный день расходует его, а не прерывает серию.';

  @override
  String graceDaysHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запасных дня',
      many: '$count запасных дней',
      few: '$count запасных дня',
      one: '$count запасной день',
      zero: 'Нет запасных дней',
    );
    return '$_temp0';
  }

  @override
  String get graceDayUsed => 'Покрыт запасным днём';

  @override
  String milestoneLakh(int count) {
    return '$count × 100 000 повторений';
  }

  @override
  String get milestoneSavaLakh => '125 000 повторений (сава лакх)';

  @override
  String get milestoneCrore => '10 000 000 повторений';

  @override
  String milestoneStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня подряд',
      many: '$days дней подряд',
      few: '$days дня подряд',
      one: '$days день подряд',
    );
    return '$_temp0';
  }

  @override
  String milestoneReached(String milestone) {
    return 'Достигнуто: $milestone. Важная веха в вашей практике.';
  }

  @override
  String get milestones => 'Вехи';

  @override
  String milestoneNext(String milestone) {
    return 'Следующая: $milestone';
  }

  @override
  String milestoneToGo(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Осталось: $countString';
  }

  @override
  String get milestoneAllReached => 'Все вехи достигнуты';

  @override
  String get yearInReview => 'Итоги года';

  @override
  String yearInReviewTitle(int year) {
    return 'Ваш $year год в джапе';
  }

  @override
  String yearNoJaap(int year) {
    return 'В $year году джапа не записана';
  }

  @override
  String get yearActiveDays => 'Дней практики';

  @override
  String get yearLongestRun => 'Самая долгая серия';

  @override
  String yearLongestRunValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get yearBestDay => 'Лучший день';

  @override
  String get yearTopMantra => 'Чаще всего';

  @override
  String get yearByMonth => 'По месяцам';

  @override
  String get yearMilestones => 'Вехи этого года';

  @override
  String yearShareText(int year, String count) {
    return 'Мой $year год в нама-джапе: $count повт.';
  }

  @override
  String get previousYear => 'Предыдущий год';

  @override
  String get nextYear => 'Следующий год';

  @override
  String ekadashiName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'indira': 'Индира Экадаши',
      'papankusha': 'Папанкуша Экадаши',
      'rama': 'Рама Экадаши',
      'devutthana': 'Девоттхана Экадаши',
      'utpanna': 'Утпанна Экадаши',
      'mokshada': 'Мокшада Экадаши',
      'saphala': 'Сапхала Экадаши',
      'paushaPutrada': 'Пауша Путрада Экадаши',
      'shattila': 'Шаттила Экадаши',
      'jaya': 'Джая Экадаши',
      'vijaya': 'Виджая Экадаши',
      'amalaki': 'Амалаки Экадаши',
      'papamochani': 'Папамочани Экадаши',
      'kamada': 'Камада Экадаши',
      'varuthini': 'Варутхини Экадаши',
      'mohini': 'Мохини Экадаши',
      'apara': 'Апара Экадаши',
      'nirjala': 'Нирджала Экадаши',
      'yogini': 'Йогини Экадаши',
      'devshayani': 'Девашаяни Экадаши',
      'kamika': 'Камика Экадаши',
      'shravanaPutrada': 'Шравана Путрада Экадаши',
      'aja': 'Аджа Экадаши',
      'parsva': 'Паршва Экадаши',
      'other': 'Экадаши',
    });
    return '$_temp0';
  }

  @override
  String festivalName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'sharadNavratri': 'Шарад Наваратри',
      'chaitraNavratri': 'Чайтра Наваратри',
      'dussehra': 'Дасара',
      'diwali': 'Дивали',
      'kartikMonth': 'Месяц Картика',
      'kartikPurnima': 'Картика Пурнима',
      'guruNanakJayanti': 'Гуру Нанак Джаянти',
      'makarSankranti': 'Макара Санкранти',
      'vasantPanchami': 'Васанта Панчами',
      'mahaShivaratri': 'Маха Шиваратри',
      'holi': 'Холи',
      'ramNavami': 'Рама Навами',
      'mahavirJayanti': 'Махавира Джаянти',
      'hanumanJayanti': 'Хануман Джаянти',
      'guruPurnima': 'Гуру Пурнима',
      'shravanMonth': 'Месяц Шравана',
      'rakshaBandhan': 'Ракша Бандхан',
      'krishnaJanmashtami': 'Кришна Джанмаштами',
      'ganeshChaturthi': 'Ганеша Чатуртхи',
      'other': 'Праздник',
    });
    return '$_temp0';
  }

  @override
  String sankalpBegins(String date) {
    return 'Начало $date';
  }

  @override
  String get upcomingObservances => 'Экадаши и праздники';

  @override
  String get observanceToday => 'Сегодня';

  @override
  String observanceInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Через $count дня',
      many: 'Через $count дней',
      few: 'Через $count дня',
      one: 'Через $count день',
    );
    return '$_temp0';
  }

  @override
  String observanceDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String observanceSankalpTitle(String name) {
    return 'Санкальпа: $name';
  }

  @override
  String get observanceTakeSankalp => 'Принять санкальпу';

  @override
  String observanceVaishnava(String date) {
    return 'По вайшнавскому календарю (ИСККОН): $date';
  }

  @override
  String get observanceSourceNote =>
      'Даты указаны по Drik Panchang для Нью-Дели. В вашем храме или традиции день может отличаться на сутки.';

  @override
  String get observancesNone => 'В ближайшие недели ничего нет';

  @override
  String get festivalReminders => 'Напоминания об Экадаши и праздниках';

  @override
  String get festivalRemindersHint =>
      'Уведомление в 6 утра в дни Экадаши и праздников';

  @override
  String festivalNotificationBody(String name) {
    return 'Сегодня $name. Благоприятный день для нама-джапы.';
  }

  @override
  String get sendDiagnostics => 'Отправить диагностику';

  @override
  String get diagnosticsExplain =>
      'Этот отчёт помогает исправить проблему. В нём версии приложения и телефона, ваши настройки и журнал ошибок приложения. В нём нет мантр, счёта и заметок. Ничего не отправляется, пока вы не выберете способ ниже.';

  @override
  String get diagnosticsEmail => 'Отправить по почте';

  @override
  String get diagnosticsShare => 'Поделиться файлом';

  @override
  String get diagnosticsEmailSubject => 'Диагностика JaapMitra';

  @override
  String get diagnosticsNoMail =>
      'Почтовое приложение не найдено. Попробуйте поделиться файлом.';
}
