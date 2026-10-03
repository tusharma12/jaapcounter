import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Naam Jaap Counter: JaapMitra'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Bhakti Ka Sathi, Har Din'**
  String get tagline;

  /// No description provided for @navJaap.
  ///
  /// In en, this message translates to:
  /// **'Jaap'**
  String get navJaap;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navStories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get navStories;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'TAP TO COUNT'**
  String get tapToCount;

  /// No description provided for @todaysJaap.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Jaap'**
  String get todaysJaap;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @malaComplete.
  ///
  /// In en, this message translates to:
  /// **'Mala Complete'**
  String get malaComplete;

  /// No description provided for @malasCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Mala completed} other{{count} Malas completed}}'**
  String malasCompleted(int count);

  /// No description provided for @jaapCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Jaap'**
  String jaapCount(int count);

  /// No description provided for @resetCurrentMala.
  ///
  /// In en, this message translates to:
  /// **'Reset current mala'**
  String get resetCurrentMala;

  /// No description provided for @resetCurrentMalaBody.
  ///
  /// In en, this message translates to:
  /// **'The beads counted in this mala will be removed. Completed malas are kept.'**
  String get resetCurrentMalaBody;

  /// No description provided for @addCountManually.
  ///
  /// In en, this message translates to:
  /// **'Add count manually'**
  String get addCountManually;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'Add count'**
  String get addCount;

  /// No description provided for @numberOfJaap.
  ///
  /// In en, this message translates to:
  /// **'Number of Jaap'**
  String get numberOfJaap;

  /// No description provided for @meditationMode.
  ///
  /// In en, this message translates to:
  /// **'Meditation mode'**
  String get meditationMode;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get startSession;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @sessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{jaap} Jaap in {minutes} min'**
  String sessionSummary(int jaap, int minutes);

  /// No description provided for @myMantras.
  ///
  /// In en, this message translates to:
  /// **'My Mantras'**
  String get myMantras;

  /// No description provided for @addMantra.
  ///
  /// In en, this message translates to:
  /// **'Add Mantra'**
  String get addMantra;

  /// No description provided for @editMantra.
  ///
  /// In en, this message translates to:
  /// **'Edit Mantra'**
  String get editMantra;

  /// No description provided for @malaSize.
  ///
  /// In en, this message translates to:
  /// **'Mala Size'**
  String get malaSize;

  /// No description provided for @beads.
  ///
  /// In en, this message translates to:
  /// **'{count} beads'**
  String beads(int count);

  /// No description provided for @malaSizeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Mala size must be between 1 and 10,000'**
  String get malaSizeInvalid;

  /// No description provided for @deleteMantraTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mantra?'**
  String get deleteMantraTitle;

  /// No description provided for @deleteMantraBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed. Your recorded Jaap history is kept.'**
  String deleteMantraBody(String name);

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @mySadhana.
  ///
  /// In en, this message translates to:
  /// **'My Sadhana'**
  String get mySadhana;

  /// No description provided for @todaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goal'**
  String get todaysGoal;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Day Streak} other{{count} Day Streak}}'**
  String dayStreak(int count);

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @sankalpDays.
  ///
  /// In en, this message translates to:
  /// **'{days} DAY SANKALP'**
  String sankalpDays(int days);

  /// No description provided for @dayXofY.
  ///
  /// In en, this message translates to:
  /// **'Day {current} / {total}'**
  String dayXofY(int current, int total);

  /// No description provided for @daysCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day completed} other{{count} days completed}}'**
  String daysCompleted(int count);

  /// No description provided for @startedOn.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String startedOn(String date);

  /// No description provided for @createNewSankalp.
  ///
  /// In en, this message translates to:
  /// **'Create New Sankalp'**
  String get createNewSankalp;

  /// No description provided for @createSankalp.
  ///
  /// In en, this message translates to:
  /// **'Create Sankalp'**
  String get createSankalp;

  /// No description provided for @chooseMantra.
  ///
  /// In en, this message translates to:
  /// **'Choose Mantra'**
  String get chooseMantra;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String durationDays(int days);

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @beginSadhana.
  ///
  /// In en, this message translates to:
  /// **'Begin Sadhana'**
  String get beginSadhana;

  /// No description provided for @noSankalpTitle.
  ///
  /// In en, this message translates to:
  /// **'Begin a Sankalp'**
  String get noSankalpTitle;

  /// No description provided for @noSankalpBody.
  ///
  /// In en, this message translates to:
  /// **'A Sankalp is a vow to chant a set number of Jaap every day for a chosen number of days.'**
  String get noSankalpBody;

  /// No description provided for @endSankalp.
  ///
  /// In en, this message translates to:
  /// **'End Sankalp'**
  String get endSankalp;

  /// No description provided for @endSankalpBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be kept, but the Sankalp will no longer be active.'**
  String get endSankalpBody;

  /// No description provided for @jaapPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} Jaap per day'**
  String jaapPerDay(int count);

  /// No description provided for @goalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} to go'**
  String goalRemaining(int count);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached'**
  String get goalReached;

  /// No description provided for @goalReachedAutoBody.
  ///
  /// In en, this message translates to:
  /// **'Auto Jaap is paused. Keep going or stop here?'**
  String get goalReachedAutoBody;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get keepGoing;

  /// No description provided for @setDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set daily goal'**
  String get setDailyGoal;

  /// No description provided for @sadhanaGoals.
  ///
  /// In en, this message translates to:
  /// **'Sadhana Goals'**
  String get sadhanaGoals;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @filterDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get filterDaily;

  /// No description provided for @filterWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get filterWeekly;

  /// No description provided for @filterMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get filterMonthly;

  /// No description provided for @filterYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get filterYearly;

  /// No description provided for @totalJaap.
  ///
  /// In en, this message translates to:
  /// **'Total Jaap'**
  String get totalJaap;

  /// No description provided for @totalMalas.
  ///
  /// In en, this message translates to:
  /// **'Total Malas'**
  String get totalMalas;

  /// No description provided for @weeklyJaap.
  ///
  /// In en, this message translates to:
  /// **'Weekly Jaap'**
  String get weeklyJaap;

  /// No description provided for @monthlyJaap.
  ///
  /// In en, this message translates to:
  /// **'Monthly Jaap'**
  String get monthlyJaap;

  /// No description provided for @yearlyJaap.
  ///
  /// In en, this message translates to:
  /// **'Yearly Jaap'**
  String get yearlyJaap;

  /// No description provided for @ofGoal.
  ///
  /// In en, this message translates to:
  /// **'/ {count} Goal'**
  String ofGoal(int count);

  /// No description provided for @noJaapYet.
  ///
  /// In en, this message translates to:
  /// **'No Jaap recorded yet'**
  String get noJaapYet;

  /// No description provided for @noJaapYetBody.
  ///
  /// In en, this message translates to:
  /// **'Your first bead is the beginning of the journey.'**
  String get noJaapYetBody;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @perMantra.
  ///
  /// In en, this message translates to:
  /// **'By mantra'**
  String get perMantra;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @storiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short stories for reflection'**
  String get storiesSubtitle;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopListening;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @minRead.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String minRead(int minutes);

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a story to keep it here.'**
  String get noFavoritesBody;

  /// No description provided for @noStoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No stories found'**
  String get noStoriesFound;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sectionJaap.
  ///
  /// In en, this message translates to:
  /// **'JAAP'**
  String get sectionJaap;

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'REMINDERS'**
  String get sectionReminders;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get sectionAppearance;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'BACKUP'**
  String get sectionBackup;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get sectionSupport;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get sectionAbout;

  /// No description provided for @resetCounts.
  ///
  /// In en, this message translates to:
  /// **'Reset Counts'**
  String get resetCounts;

  /// No description provided for @jaapReminders.
  ///
  /// In en, this message translates to:
  /// **'Jaap Reminders'**
  String get jaapReminders;

  /// No description provided for @streakReminder.
  ///
  /// In en, this message translates to:
  /// **'Streak Reminder'**
  String get streakReminder;

  /// No description provided for @goalReminder.
  ///
  /// In en, this message translates to:
  /// **'Goal Reminder'**
  String get goalReminder;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @exportMyData.
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get exportMyData;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate JaapMitra'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Invite Family and Friends'**
  String get shareApp;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About JaapMitra'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @resetTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset today\'s Jaap?'**
  String get resetTodayTitle;

  /// No description provided for @resetTodayBody.
  ///
  /// In en, this message translates to:
  /// **'All Jaap recorded today will be removed. This cannot be undone.'**
  String get resetTodayBody;

  /// No description provided for @resetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all Jaap?'**
  String get resetAllTitle;

  /// No description provided for @resetAllBody.
  ///
  /// In en, this message translates to:
  /// **'Your entire Jaap history, malas and streaks will be permanently deleted. This cannot be undone.'**
  String get resetAllBody;

  /// No description provided for @resetToday.
  ///
  /// In en, this message translates to:
  /// **'Reset today'**
  String get resetToday;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset everything'**
  String get resetEverything;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Counts reset'**
  String get resetDone;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'JaapMitra is a quiet, private space for your daily Naam Jap. Everything you chant is stored only on this device.'**
  String get aboutBody;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with devotion'**
  String get madeWith;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @noRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersTitle;

  /// No description provided for @noRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'A gentle nudge at the same time each day makes the practice a habit.'**
  String get noRemindersBody;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for JaapMitra. Enable them in your device settings.'**
  String get notificationsBlocked;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for your Jaap'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'A few quiet minutes with your mala 🙏'**
  String get reminderNotificationBody;

  /// No description provided for @streakNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive'**
  String get streakNotificationTitle;

  /// No description provided for @streakNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t chanted today. One mala keeps it going.'**
  String get streakNotificationBody;

  /// No description provided for @goalNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get goalNotificationTitle;

  /// No description provided for @goalNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Finish today\'s goal to complete your Sadhana for the day.'**
  String get goalNotificationBody;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @createBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Save a JSON file with all your mantras, Jaap history, goals and settings.'**
  String get createBackupBody;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a JaapMitra backup file to restore.'**
  String get restoreBackupBody;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupCreated;

  /// No description provided for @restoreWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get restoreWarningTitle;

  /// No description provided for @restoreWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Restoring will replace everything currently in JaapMitra with the contents of the backup file.'**
  String get restoreWarningBody;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {count} Jaap entries'**
  String restoreSuccess(int count);

  /// No description provided for @importInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid JaapMitra backup'**
  String get importInvalid;

  /// No description provided for @exportShareText.
  ///
  /// In en, this message translates to:
  /// **'My JaapMitra backup'**
  String get exportShareText;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Your Digital Jap Mala'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'A peaceful way to count every Naam Jap.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Make Your Sadhana a Habit'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Set a daily goal and build your chanting streak.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Chant Without Distractions'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Enter meditation mode with a clean, peaceful counter.'**
  String get onb3Body;

  /// No description provided for @onbLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get onbLookTitle;

  /// No description provided for @onbLookBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how the counter looks and sounds. Theme, mantra display, falling mantra and music can all be changed any time in Settings.'**
  String get onbLookBody;

  /// No description provided for @onbFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything in your hands'**
  String get onbFeaturesTitle;

  /// No description provided for @onbFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'A few things worth knowing before you begin.'**
  String get onbFeaturesBody;

  /// No description provided for @soundsFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Calming sounds'**
  String get soundsFeatureTitle;

  /// No description provided for @soundsFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'Play a soft background chant during meditation, for as long as you sit.'**
  String get soundsFeatureBody;

  /// No description provided for @startJap.
  ///
  /// In en, this message translates to:
  /// **'Start Jap'**
  String get startJap;

  /// No description provided for @blackout.
  ///
  /// In en, this message translates to:
  /// **'Blackout'**
  String get blackout;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @exitMeditation.
  ///
  /// In en, this message translates to:
  /// **'Exit meditation mode'**
  String get exitMeditation;

  /// No description provided for @tapAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get tapAnywhere;

  /// No description provided for @semanticCounter.
  ///
  /// In en, this message translates to:
  /// **'Jaap counter. {count} of {total} beads. Double tap to count one.'**
  String semanticCounter(int count, int total);

  /// No description provided for @autoJaap.
  ///
  /// In en, this message translates to:
  /// **'Auto Jaap'**
  String get autoJaap;

  /// No description provided for @autoJaapBody.
  ///
  /// In en, this message translates to:
  /// **'The app counts for you at a steady pace, so you can chant along hands-free.'**
  String get autoJaapBody;

  /// No description provided for @autoJaapPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get autoJaapPace;

  /// No description provided for @autoJaapSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String autoJaapSeconds(int seconds);

  /// No description provided for @autoJaapStopAfter.
  ///
  /// In en, this message translates to:
  /// **'Stop after'**
  String get autoJaapStopAfter;

  /// No description provided for @autoJaapStopMala.
  ///
  /// In en, this message translates to:
  /// **'One mala'**
  String get autoJaapStopMala;

  /// No description provided for @autoJaapStopGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get autoJaapStopGoal;

  /// No description provided for @autoJaapStopNever.
  ///
  /// In en, this message translates to:
  /// **'Don\'t stop'**
  String get autoJaapStopNever;

  /// No description provided for @autoJaapStart.
  ///
  /// In en, this message translates to:
  /// **'Start Auto Jaap'**
  String get autoJaapStart;

  /// No description provided for @autoJaapStopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Jaap'**
  String get autoJaapStopAction;

  /// No description provided for @chantPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get chantPlay;

  /// No description provided for @chantStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chantStop;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @playMusic.
  ///
  /// In en, this message translates to:
  /// **'Play music'**
  String get playMusic;

  /// No description provided for @stopMusic.
  ///
  /// In en, this message translates to:
  /// **'Stop music'**
  String get stopMusic;

  /// No description provided for @chooseSound.
  ///
  /// In en, this message translates to:
  /// **'Choose sound'**
  String get chooseSound;

  /// No description provided for @musicRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get musicRecord;

  /// No description provided for @musicUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get musicUpload;

  /// No description provided for @musicYours.
  ///
  /// In en, this message translates to:
  /// **'My music'**
  String get musicYours;

  /// No description provided for @musicRecordingName.
  ///
  /// In en, this message translates to:
  /// **'Recording {n}'**
  String musicRecordingName(int n);

  /// No description provided for @musicNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your recording'**
  String get musicNameTitle;

  /// No description provided for @musicRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get musicRemove;

  /// No description provided for @musicAddFailed.
  ///
  /// In en, this message translates to:
  /// **'That file couldn\'t be added'**
  String get musicAddFailed;

  /// No description provided for @ownMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your own music'**
  String get ownMusicTitle;

  /// No description provided for @ownMusicBody.
  ///
  /// In en, this message translates to:
  /// **'Record your own chant or upload a meditation sound, and it plays for your whole sitting.'**
  String get ownMusicBody;

  /// No description provided for @counterCount.
  ///
  /// In en, this message translates to:
  /// **'Count: {count}'**
  String counterCount(String count);

  /// No description provided for @counterMalas.
  ///
  /// In en, this message translates to:
  /// **'Malas: {count}'**
  String counterMalas(String count);

  /// No description provided for @counterTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String counterTotal(String count);

  /// No description provided for @autoJaapTapToStop.
  ///
  /// In en, this message translates to:
  /// **'Auto Jaap running · tap anywhere to stop'**
  String get autoJaapTapToStop;

  /// No description provided for @hideMantra.
  ///
  /// In en, this message translates to:
  /// **'Hide mantra'**
  String get hideMantra;

  /// No description provided for @showMantra.
  ///
  /// In en, this message translates to:
  /// **'Show mantra'**
  String get showMantra;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String streakDays(int count);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get themeWhite;

  /// No description provided for @themeBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get themeBlack;

  /// No description provided for @themePastelPink.
  ///
  /// In en, this message translates to:
  /// **'Pastel Pink'**
  String get themePastelPink;

  /// No description provided for @themeSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get themeSpiritual;

  /// No description provided for @themeSaffron.
  ///
  /// In en, this message translates to:
  /// **'Saffron'**
  String get themeSaffron;

  /// No description provided for @themePeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get themePeaceful;

  /// No description provided for @themeTerracotta.
  ///
  /// In en, this message translates to:
  /// **'Terracotta'**
  String get themeTerracotta;

  /// No description provided for @themeMeditative.
  ///
  /// In en, this message translates to:
  /// **'Meditative'**
  String get themeMeditative;

  /// No description provided for @themeNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get themeNature;

  /// No description provided for @themeRoseGold.
  ///
  /// In en, this message translates to:
  /// **'Rose Gold'**
  String get themeRoseGold;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get themeLavender;

  /// No description provided for @themeCharcoal.
  ///
  /// In en, this message translates to:
  /// **'Charcoal'**
  String get themeCharcoal;

  /// No description provided for @counterBackground.
  ///
  /// In en, this message translates to:
  /// **'Counter background'**
  String get counterBackground;

  /// No description provided for @counterBackgroundBody.
  ///
  /// In en, this message translates to:
  /// **'Shown behind the mantra and beads on the counter.'**
  String get counterBackgroundBody;

  /// No description provided for @backgroundNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get backgroundNone;

  /// No description provided for @backgroundDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get backgroundDawn;

  /// No description provided for @backgroundDusk.
  ///
  /// In en, this message translates to:
  /// **'Dusk'**
  String get backgroundDusk;

  /// No description provided for @backgroundLotus.
  ///
  /// In en, this message translates to:
  /// **'Lotus'**
  String get backgroundLotus;

  /// No description provided for @backgroundForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get backgroundForest;

  /// No description provided for @backgroundOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get backgroundOcean;

  /// No description provided for @backgroundCosmos.
  ///
  /// In en, this message translates to:
  /// **'Cosmos'**
  String get backgroundCosmos;

  /// No description provided for @backgroundPhoto.
  ///
  /// In en, this message translates to:
  /// **'My photo'**
  String get backgroundPhoto;

  /// No description provided for @backgroundChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get backgroundChoosePhoto;

  /// No description provided for @backgroundChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get backgroundChangePhoto;

  /// No description provided for @backgroundRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get backgroundRemovePhoto;

  /// No description provided for @backgroundDim.
  ///
  /// In en, this message translates to:
  /// **'Dim background'**
  String get backgroundDim;

  /// No description provided for @backgroundDimHint.
  ///
  /// In en, this message translates to:
  /// **'More dimming keeps the mantra easy to read.'**
  String get backgroundDimHint;

  /// No description provided for @addOwnMantra.
  ///
  /// In en, this message translates to:
  /// **'Add your own mantra'**
  String get addOwnMantra;

  /// No description provided for @addOwnMantraHint.
  ///
  /// In en, this message translates to:
  /// **'Any name or mantra, in any script, with your own mala size'**
  String get addOwnMantraHint;

  /// No description provided for @legendLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get legendLess;

  /// No description provided for @legendMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get legendMore;

  /// No description provided for @allMantras.
  ///
  /// In en, this message translates to:
  /// **'All mantras'**
  String get allMantras;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPeriod;

  /// No description provided for @showStatsFor.
  ///
  /// In en, this message translates to:
  /// **'Show statistics for'**
  String get showStatsFor;

  /// No description provided for @selectionSummary.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count} Jaap · {malas} malas'**
  String selectionSummary(String label, String count, String malas);

  /// No description provided for @dailyJaap.
  ///
  /// In en, this message translates to:
  /// **'Daily Jaap'**
  String get dailyJaap;

  /// No description provided for @mantraText.
  ///
  /// In en, this message translates to:
  /// **'Mantra'**
  String get mantraText;

  /// No description provided for @mantraTextHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. राम or Om Namah Shivaya'**
  String get mantraTextHint;

  /// No description provided for @mantraRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the mantra'**
  String get mantraRequired;

  /// No description provided for @mantraDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mantraDescription;

  /// No description provided for @mantraDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'A meaning, a source, or a note to yourself'**
  String get mantraDescriptionHint;

  /// No description provided for @dictationStart.
  ///
  /// In en, this message translates to:
  /// **'Enter the mantra by speaking it'**
  String get dictationStart;

  /// No description provided for @dictationListening.
  ///
  /// In en, this message translates to:
  /// **'Listening… tap to stop'**
  String get dictationListening;

  /// No description provided for @dictationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech input isn\'t available on this device'**
  String get dictationUnavailable;

  /// No description provided for @dictationOfflineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Offline speech input isn\'t available for this language on this phone. Your voice never leaves the device, so please type it instead.'**
  String get dictationOfflineUnavailable;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed for this'**
  String get micPermissionDenied;

  /// No description provided for @fallingMantra.
  ///
  /// In en, this message translates to:
  /// **'Falling mantra'**
  String get fallingMantra;

  /// No description provided for @stopFallingMantra.
  ///
  /// In en, this message translates to:
  /// **'Stop falling mantra'**
  String get stopFallingMantra;

  /// No description provided for @malaStyle.
  ///
  /// In en, this message translates to:
  /// **'Mala style'**
  String get malaStyle;

  /// No description provided for @malaStyleBeads.
  ///
  /// In en, this message translates to:
  /// **'Beads'**
  String get malaStyleBeads;

  /// No description provided for @malaStyleRing.
  ///
  /// In en, this message translates to:
  /// **'Progress ring'**
  String get malaStyleRing;

  /// No description provided for @sectionCounter.
  ///
  /// In en, this message translates to:
  /// **'COUNTER'**
  String get sectionCounter;

  /// No description provided for @showMantraOnCounter.
  ///
  /// In en, this message translates to:
  /// **'Show mantra on counter'**
  String get showMantraOnCounter;

  /// No description provided for @goalUnitMalas.
  ///
  /// In en, this message translates to:
  /// **'Malas'**
  String get goalUnitMalas;

  /// No description provided for @goalUnitJaap.
  ///
  /// In en, this message translates to:
  /// **'Jaap'**
  String get goalUnitJaap;

  /// No description provided for @malaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mala} other{{count} malas}}'**
  String malaCount(int count);

  /// No description provided for @malasPerDay.
  ///
  /// In en, this message translates to:
  /// **'Malas a day'**
  String get malasPerDay;

  /// No description provided for @goalMalasPerDay.
  ///
  /// In en, this message translates to:
  /// **'{malas, plural, =1{1 mala} other{{malas} malas}} a day · {jaap} Jaap'**
  String goalMalasPerDay(int malas, String jaap);

  /// No description provided for @onbMantraTitle.
  ///
  /// In en, this message translates to:
  /// **'Which mantra do you chant?'**
  String get onbMantraTitle;

  /// No description provided for @onbMantraBody.
  ///
  /// In en, this message translates to:
  /// **'Pick one to begin. You can add more at any time.'**
  String get onbMantraBody;

  /// No description provided for @onbGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily goal'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Start small: a steady practice matters more than a big number. You can change it any time.'**
  String get onbGoalBody;

  /// No description provided for @shareProgress.
  ///
  /// In en, this message translates to:
  /// **'Share my progress'**
  String get shareProgress;

  /// No description provided for @shareStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get shareStreakLabel;

  /// No description provided for @shareCardText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}} of Naam Jap in a row, with JaapMitra 🙏'**
  String shareCardText(int count);

  /// No description provided for @blackoutMode.
  ///
  /// In en, this message translates to:
  /// **'Blackout mode'**
  String get blackoutMode;

  /// No description provided for @exitBlackout.
  ///
  /// In en, this message translates to:
  /// **'Exit blackout'**
  String get exitBlackout;

  /// No description provided for @feedbackEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'JaapMitra feedback'**
  String get feedbackEmailSubject;

  /// No description provided for @homeScreenWidget.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget'**
  String get homeScreenWidget;

  /// No description provided for @homeScreenWidgetBody.
  ///
  /// In en, this message translates to:
  /// **'See today\'s Jaap and your streak on your Home Screen, without opening the app.'**
  String get homeScreenWidgetBody;

  /// No description provided for @homeScreenWidgetStepsAndroid.
  ///
  /// In en, this message translates to:
  /// **'Long-press an empty spot on your Home Screen, tap Widgets, then find JaapMitra.'**
  String get homeScreenWidgetStepsAndroid;

  /// No description provided for @homeScreenWidgetStepsIOS.
  ///
  /// In en, this message translates to:
  /// **'Long-press an empty spot on your Home Screen, tap the + in the corner, search for JaapMitra, then choose a size and tap Add Widget.'**
  String get homeScreenWidgetStepsIOS;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get addToHomeScreen;

  /// No description provided for @countWithButtons.
  ///
  /// In en, this message translates to:
  /// **'Count with buttons'**
  String get countWithButtons;

  /// No description provided for @countWithButtonsHintAndroid.
  ///
  /// In en, this message translates to:
  /// **'Volume buttons, a headset button or a Bluetooth clicker count a bead'**
  String get countWithButtonsHintAndroid;

  /// No description provided for @countWithButtonsHintIOS.
  ///
  /// In en, this message translates to:
  /// **'A Bluetooth clicker or keyboard counts a bead. iPhone volume buttons can\'t be used by apps.'**
  String get countWithButtonsHintIOS;

  /// No description provided for @lockScreenCounter.
  ///
  /// In en, this message translates to:
  /// **'Lock screen counter'**
  String get lockScreenCounter;

  /// No description provided for @lockScreenCounterHint.
  ///
  /// In en, this message translates to:
  /// **'A +1 button on your lock screen and Dynamic Island. Taps are added to your Jaap when you next open the app.'**
  String get lockScreenCounterHint;

  /// No description provided for @markerBead.
  ///
  /// In en, this message translates to:
  /// **'Marker bead'**
  String get markerBead;

  /// No description provided for @markerBeadHint.
  ///
  /// In en, this message translates to:
  /// **'One firm knock partway through the mala, so you can feel where you are with eyes closed'**
  String get markerBeadHint;

  /// No description provided for @markerBeadEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {count}'**
  String markerBeadEvery(int count);

  /// No description provided for @markerBeadOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get markerBeadOff;

  /// No description provided for @graceDays.
  ///
  /// In en, this message translates to:
  /// **'Grace days'**
  String get graceDays;

  /// No description provided for @graceDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Every 7 days in a row earns a grace day (up to 2). A missed day uses one instead of breaking your streak.'**
  String get graceDaysHint;

  /// No description provided for @graceDaysHeld.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No grace days held} =1{1 grace day held} other{{count} grace days held}}'**
  String graceDaysHeld(int count);

  /// No description provided for @graceDayUsed.
  ///
  /// In en, this message translates to:
  /// **'Covered by a grace day'**
  String get graceDayUsed;

  /// No description provided for @milestoneLakh.
  ///
  /// In en, this message translates to:
  /// **'{count} lakh Jaap'**
  String milestoneLakh(int count);

  /// No description provided for @milestoneSavaLakh.
  ///
  /// In en, this message translates to:
  /// **'Sava lakh Jaap'**
  String get milestoneSavaLakh;

  /// No description provided for @milestoneCrore.
  ///
  /// In en, this message translates to:
  /// **'1 crore Jaap'**
  String get milestoneCrore;

  /// No description provided for @milestoneStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String milestoneStreak(int days);

  /// No description provided for @milestoneReached.
  ///
  /// In en, this message translates to:
  /// **'{milestone} reached. A milestone in your practice.'**
  String milestoneReached(String milestone);

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @milestoneNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {milestone}'**
  String milestoneNext(String milestone);

  /// No description provided for @milestoneToGo.
  ///
  /// In en, this message translates to:
  /// **'{count} to go'**
  String milestoneToGo(int count);

  /// No description provided for @milestoneAllReached.
  ///
  /// In en, this message translates to:
  /// **'Every milestone reached'**
  String get milestoneAllReached;

  /// No description provided for @yearInReview.
  ///
  /// In en, this message translates to:
  /// **'Year in review'**
  String get yearInReview;

  /// No description provided for @yearInReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {year} in Jaap'**
  String yearInReviewTitle(int year);

  /// No description provided for @yearNoJaap.
  ///
  /// In en, this message translates to:
  /// **'No Jaap recorded in {year}'**
  String yearNoJaap(int year);

  /// No description provided for @yearActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Days chanted'**
  String get yearActiveDays;

  /// No description provided for @yearLongestRun.
  ///
  /// In en, this message translates to:
  /// **'Longest run'**
  String get yearLongestRun;

  /// No description provided for @yearLongestRunValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String yearLongestRunValue(int count);

  /// No description provided for @yearBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get yearBestDay;

  /// No description provided for @yearTopMantra.
  ///
  /// In en, this message translates to:
  /// **'Most chanted'**
  String get yearTopMantra;

  /// No description provided for @yearByMonth.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get yearByMonth;

  /// No description provided for @yearMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones this year'**
  String get yearMilestones;

  /// No description provided for @yearShareText.
  ///
  /// In en, this message translates to:
  /// **'My {year} in Naam Jap: {count} Jaap'**
  String yearShareText(int year, String count);

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @ekadashiName.
  ///
  /// In en, this message translates to:
  /// **'{name, select, indira{Indira Ekadashi} papankusha{Papankusha Ekadashi} rama{Rama Ekadashi} devutthana{Devutthana Ekadashi} utpanna{Utpanna Ekadashi} mokshada{Mokshada Ekadashi} saphala{Saphala Ekadashi} paushaPutrada{Pausha Putrada Ekadashi} shattila{Shattila Ekadashi} jaya{Jaya Ekadashi} vijaya{Vijaya Ekadashi} amalaki{Amalaki Ekadashi} papamochani{Papamochani Ekadashi} kamada{Kamada Ekadashi} varuthini{Varuthini Ekadashi} mohini{Mohini Ekadashi} apara{Apara Ekadashi} nirjala{Nirjala Ekadashi} yogini{Yogini Ekadashi} devshayani{Devshayani Ekadashi} kamika{Kamika Ekadashi} shravanaPutrada{Shravana Putrada Ekadashi} aja{Aja Ekadashi} parsva{Parsva Ekadashi} other{Ekadashi}}'**
  String ekadashiName(String name);

  /// No description provided for @festivalName.
  ///
  /// In en, this message translates to:
  /// **'{name, select, sharadNavratri{Sharad Navratri} chaitraNavratri{Chaitra Navratri} dussehra{Dussehra} diwali{Diwali} kartikMonth{Kartik month} kartikPurnima{Kartik Purnima} guruNanakJayanti{Guru Nanak Jayanti} makarSankranti{Makar Sankranti} vasantPanchami{Vasant Panchami} mahaShivaratri{Maha Shivaratri} holi{Holi} ramNavami{Ram Navami} mahavirJayanti{Mahavir Jayanti} hanumanJayanti{Hanuman Jayanti} guruPurnima{Guru Purnima} shravanMonth{Shravan month} rakshaBandhan{Raksha Bandhan} krishnaJanmashtami{Krishna Janmashtami} ganeshChaturthi{Ganesh Chaturthi} other{Festival}}'**
  String festivalName(String name);

  /// No description provided for @sankalpBegins.
  ///
  /// In en, this message translates to:
  /// **'Begins {date}'**
  String sankalpBegins(String date);

  /// No description provided for @upcomingObservances.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi and festivals'**
  String get upcomingObservances;

  /// No description provided for @observanceToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get observanceToday;

  /// No description provided for @observanceInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tomorrow} other{In {count} days}}'**
  String observanceInDays(int count);

  /// No description provided for @observanceDateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String observanceDateRange(String start, String end);

  /// No description provided for @observanceSankalpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sankalp for {name}'**
  String observanceSankalpTitle(String name);

  /// No description provided for @observanceTakeSankalp.
  ///
  /// In en, this message translates to:
  /// **'Take a Sankalp'**
  String get observanceTakeSankalp;

  /// No description provided for @observanceVaishnava.
  ///
  /// In en, this message translates to:
  /// **'Vaishnava (ISKCON) observance: {date}'**
  String observanceVaishnava(String date);

  /// No description provided for @observanceSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Dates follow Drik Panchang for New Delhi. Your local temple or tradition may observe a day apart.'**
  String get observanceSourceNote;

  /// No description provided for @observancesNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the next few weeks'**
  String get observancesNone;

  /// No description provided for @festivalReminders.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi and festival reminders'**
  String get festivalReminders;

  /// No description provided for @festivalRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'A note at 6 am on Ekadashi and festival days'**
  String get festivalRemindersHint;

  /// No description provided for @festivalNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Today is {name}. A blessed day for Naam Jap.'**
  String festivalNotificationBody(String name);

  /// No description provided for @sendDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Send diagnostics'**
  String get sendDiagnostics;

  /// No description provided for @diagnosticsExplain.
  ///
  /// In en, this message translates to:
  /// **'This report helps fix a problem. It has the app and phone versions, your settings and the app\'s error log. It has no mantras, counts or notes. Nothing is sent until you choose how below.'**
  String get diagnosticsExplain;

  /// No description provided for @diagnosticsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email it'**
  String get diagnosticsEmail;

  /// No description provided for @diagnosticsShare.
  ///
  /// In en, this message translates to:
  /// **'Share as a file'**
  String get diagnosticsShare;

  /// No description provided for @diagnosticsEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'JaapMitra diagnostics'**
  String get diagnosticsEmailSubject;

  /// No description provided for @diagnosticsNoMail.
  ///
  /// In en, this message translates to:
  /// **'No mail app found. Try sharing it as a file.'**
  String get diagnosticsNoMail;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'gu',
    'hi',
    'mr',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'gu':
      return AppL10nGu();
    case 'hi':
      return AppL10nHi();
    case 'mr':
      return AppL10nMr();
    case 'pa':
      return AppL10nPa();
    case 'ta':
      return AppL10nTa();
    case 'te':
      return AppL10nTe();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
