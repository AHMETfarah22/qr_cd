import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @focusTimer.
  ///
  /// In en, this message translates to:
  /// **'FOCUS TIMER'**
  String get focusTimer;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String level(int level);

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @cannotGoToAccount.
  ///
  /// In en, this message translates to:
  /// **'You cannot go to account while timer is running!'**
  String get cannotGoToAccount;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get focus;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get failed;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS'**
  String get success;

  /// No description provided for @breakLabel.
  ///
  /// In en, this message translates to:
  /// **'BREAK'**
  String get breakLabel;

  /// No description provided for @secondsFocusTest.
  ///
  /// In en, this message translates to:
  /// **'30 Seconds Focus Test'**
  String get secondsFocusTest;

  /// No description provided for @beginnerLevel.
  ///
  /// In en, this message translates to:
  /// **'Beginner Level'**
  String get beginnerLevel;

  /// No description provided for @minuteFocus.
  ///
  /// In en, this message translates to:
  /// **'{minutes} Minute Focus'**
  String minuteFocus(int minutes);

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'SELECT CATEGORY'**
  String get selectCategory;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @breakTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'BREAK TIME'**
  String get breakTimeTitle;

  /// No description provided for @minBreak.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min Break'**
  String minBreak(int minutes);

  /// No description provided for @dontTakeBreak.
  ///
  /// In en, this message translates to:
  /// **'Don\'t take a break, continue'**
  String get dontTakeBreak;

  /// No description provided for @endBreak.
  ///
  /// In en, this message translates to:
  /// **'END BREAK'**
  String get endBreak;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @statusIdleLvl1.
  ///
  /// In en, this message translates to:
  /// **'Complete the 30-second test and\nstart real focus!'**
  String get statusIdleLvl1;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'Set duration, select category and focus!'**
  String get statusIdle;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Deep focus starts...\nTurn your phone over!'**
  String get statusRunning;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusFailure.
  ///
  /// In en, this message translates to:
  /// **'FOCUS BROKEN!\nYou lifted the phone.'**
  String get statusFailure;

  /// No description provided for @statusSuccessFirst.
  ///
  /// In en, this message translates to:
  /// **'CONGRATULATIONS! First stage complete.\n1 hour focus unlocked!'**
  String get statusSuccessFirst;

  /// No description provided for @statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Session completed.'**
  String get statusSuccess;

  /// No description provided for @statusBreak.
  ///
  /// In en, this message translates to:
  /// **'Rest time...\nHave a good break!'**
  String get statusBreak;

  /// No description provided for @catWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get catWork;

  /// No description provided for @catStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get catStudy;

  /// No description provided for @catReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get catReading;

  /// No description provided for @catMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get catMeditation;

  /// No description provided for @catExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get catExercise;

  /// No description provided for @catCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get catCreative;

  /// No description provided for @catBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get catBreak;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @startFocusingToday.
  ///
  /// In en, this message translates to:
  /// **'Start focusing and being productive today.'**
  String get startFocusingToday;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @forgotPasswordDialog.
  ///
  /// In en, this message translates to:
  /// **'You will need to create a new account since you forgot your password. Are you sure?'**
  String get forgotPasswordDialog;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @nameSurname.
  ///
  /// In en, this message translates to:
  /// **'Name Surname'**
  String get nameSurname;

  /// No description provided for @enterNameSurname.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and surname'**
  String get enterNameSurname;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to the Terms of Service and Privacy Policy.'**
  String get agreeTerms;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @accountInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT INFO'**
  String get accountInfoTitle;

  /// No description provided for @focusSummary.
  ///
  /// In en, this message translates to:
  /// **'FOCUS SUMMARY'**
  String get focusSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Session} other{Sessions}}'**
  String session(num count);

  /// No description provided for @earnedBadges.
  ///
  /// In en, this message translates to:
  /// **'EARNED BADGES'**
  String get earnedBadges;

  /// No description provided for @successAnalysis.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS ANALYSIS'**
  String get successAnalysis;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'SESSION HISTORY'**
  String get sessionHistory;

  /// No description provided for @detailedCharts.
  ///
  /// In en, this message translates to:
  /// **'DETAILED CHARTS'**
  String get detailedCharts;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'DAILY STREAK'**
  String get dailyStreak;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{DAY} other{DAYS}}'**
  String day(num count);

  /// No description provided for @badgeEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get badgeEarlyBird;

  /// No description provided for @badgeMarathoner.
  ///
  /// In en, this message translates to:
  /// **'Marathoner'**
  String get badgeMarathoner;

  /// No description provided for @badgeMaster.
  ///
  /// In en, this message translates to:
  /// **'Master Focuser'**
  String get badgeMaster;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @sectionVoiceNotification.
  ///
  /// In en, this message translates to:
  /// **'VOICE AND NOTIFICATION'**
  String get sectionVoiceNotification;

  /// No description provided for @alarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get alarmSound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @sectionFocusSettings.
  ///
  /// In en, this message translates to:
  /// **'FOCUS SETTINGS'**
  String get sectionFocusSettings;

  /// No description provided for @defaultDuration.
  ///
  /// In en, this message translates to:
  /// **'Default Duration'**
  String get defaultDuration;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String mins(Object minutes);

  /// No description provided for @sectionAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get sectionAccountSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updatePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updatePasswordSubtitle;

  /// No description provided for @passwordSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Your password is stored securely.'**
  String get passwordSecureNote;

  /// No description provided for @sectionDataManagement.
  ///
  /// In en, this message translates to:
  /// **'DATA MANAGEMENT'**
  String get sectionDataManagement;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get exportDataSubtitle;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load data from backup'**
  String get importDataSubtitle;

  /// No description provided for @resetStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reset Statistics'**
  String get resetStatistics;

  /// No description provided for @resetStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all session data'**
  String get resetStatsSubtitle;

  /// No description provided for @sectionApplication.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION'**
  String get sectionApplication;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// No description provided for @shareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp or other apps'**
  String get shareSubtitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(Object version);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'SESSION HISTORY'**
  String get historyTitle;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No session history yet'**
  String get noHistoryYet;

  /// No description provided for @startFocusNow.
  ///
  /// In en, this message translates to:
  /// **'Start focusing now and create your first record!'**
  String get startFocusNow;

  /// No description provided for @startFocusingBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Focusing'**
  String get startFocusingBtn;

  /// No description provided for @weeklyGoalSuccess.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY GOAL REACHED!'**
  String get weeklyGoalSuccess;

  /// No description provided for @weeklyGoalFailed.
  ///
  /// In en, this message translates to:
  /// **'GOAL NOT REACHED'**
  String get weeklyGoalFailed;

  /// No description provided for @weeklyMinutesNote.
  ///
  /// In en, this message translates to:
  /// **'You focused for a total of {hours} hours {minutes} minutes this week.'**
  String weeklyMinutesNote(Object hours, Object minutes);

  /// No description provided for @moreMinutesRequired.
  ///
  /// In en, this message translates to:
  /// **'{minutes} more minutes required!'**
  String moreMinutesRequired(Object minutes);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterday;

  /// No description provided for @successLabel.
  ///
  /// In en, this message translates to:
  /// **'SUCCESSFUL'**
  String get successLabel;

  /// No description provided for @failedLabel.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get failedLabel;

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeAgoJustNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String timeAgoMinutes(Object minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String timeAgoHours(Object hours);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String timeAgoDays(Object days);

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statisticsTitle;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY DISTRIBUTION'**
  String get categoryDistribution;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'LAST 7 DAYS ACTIVITY'**
  String get weeklyActivity;

  /// No description provided for @timeDistribution.
  ///
  /// In en, this message translates to:
  /// **'TIME DISTRIBUTION'**
  String get timeDistribution;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @successfulSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get successfulSessions;

  /// No description provided for @cancelledSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledSessionsCount;

  /// No description provided for @activeDaysCount.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDaysCount;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutesShort;

  /// No description provided for @hoursLong.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hoursLong(Object hours);

  /// No description provided for @minutesLong.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesLong(Object minutes);

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get sectionAppearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get notifSuccessTitle;

  /// No description provided for @notifSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Focus session completed successfully. You\'re awesome!'**
  String get notifSuccessBody;

  /// No description provided for @notifBreakEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Break Over!'**
  String get notifBreakEndTitle;

  /// No description provided for @notifBreakEndBody.
  ///
  /// In en, this message translates to:
  /// **'You are ready for a new focus session.'**
  String get notifBreakEndBody;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TScan'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your focus environment for the best experience.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingSensorTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensor Access'**
  String get onboardingSensorTitle;

  /// No description provided for @onboardingSensorDesc.
  ///
  /// In en, this message translates to:
  /// **'TScan uses the accelerometer to detect if your phone is face down. This helps you stay focused!'**
  String get onboardingSensorDesc;

  /// No description provided for @onboardingDndTitle.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get onboardingDndTitle;

  /// No description provided for @onboardingDndDesc.
  ///
  /// In en, this message translates to:
  /// **'To block distracting notifications, we need permission to manage Do Not Disturb mode.'**
  String get onboardingDndDesc;

  /// No description provided for @onboardingPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Detection'**
  String get onboardingPhoneTitle;

  /// No description provided for @onboardingPhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'If you receive a call during focus, we\'ll automatically pause to let you decide.'**
  String get onboardingPhoneDesc;

  /// No description provided for @btnGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get btnGrant;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get btnNext;

  /// No description provided for @btnBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get btnBack;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get btnStart;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission Granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'App Tutorial'**
  String get tutorialTitle;

  /// No description provided for @tutorialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show onboarding guide again'**
  String get tutorialSubtitle;

  /// No description provided for @addSessionNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'What did you focus on?'**
  String get addSessionNoteTitle;

  /// No description provided for @sessionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., studying math, coding'**
  String get sessionNoteHint;

  /// No description provided for @sessionNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Session Note'**
  String get sessionNoteLabel;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @dailyGoalSetting.
  ///
  /// In en, this message translates to:
  /// **'Daily Focus Goal'**
  String get dailyGoalSetting;

  /// No description provided for @dailyGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Target minutes of focus per day'**
  String get dailyGoalSubtitle;

  /// No description provided for @dailyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'DAILY FOCUS GOAL REACHED! 🎉'**
  String get dailyGoalReached;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal Progress'**
  String get dailyGoalProgress;

  /// No description provided for @dailyMinutesFocused.
  ///
  /// In en, this message translates to:
  /// **'{minutes} / {goal} minutes'**
  String dailyMinutesFocused(int minutes, int goal);

  /// No description provided for @dailyGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} more minutes to reach your goal!'**
  String dailyGoalRemaining(Object minutes);

  /// No description provided for @pdfStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Study'**
  String get pdfStudyTitle;

  /// No description provided for @pdfDestekliCalisma.
  ///
  /// In en, this message translates to:
  /// **'AI Powered PDF Study'**
  String get pdfDestekliCalisma;

  /// No description provided for @pdfYukleAciklama.
  ///
  /// In en, this message translates to:
  /// **'Upload study notes, let AI estimate reading time.\nThen it tests you when done! 🚀'**
  String get pdfYukleAciklama;

  /// No description provided for @pdfStep1.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get pdfStep1;

  /// No description provided for @pdfStep2.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get pdfStep2;

  /// No description provided for @pdfStep3.
  ///
  /// In en, this message translates to:
  /// **'Focus & Read'**
  String get pdfStep3;

  /// No description provided for @pdfStep4.
  ///
  /// In en, this message translates to:
  /// **'Test with Quiz'**
  String get pdfStep4;

  /// No description provided for @pdfDosyaSec.
  ///
  /// In en, this message translates to:
  /// **'Select PDF File'**
  String get pdfDosyaSec;

  /// No description provided for @sonCalisilanBelgeler.
  ///
  /// In en, this message translates to:
  /// **'Recent Documents'**
  String get sonCalisilanBelgeler;

  /// No description provided for @temizle.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get temizle;

  /// No description provided for @tekrarCalis.
  ///
  /// In en, this message translates to:
  /// **'Study Again'**
  String get tekrarCalis;

  /// No description provided for @sil.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sil;

  /// No description provided for @premiumOzellik.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumOzellik;

  /// No description provided for @premiumCalismaAsistani.
  ///
  /// In en, this message translates to:
  /// **'You must be a Premium member to use advanced study assistant features such as AI time estimation and quiz generation.'**
  String get premiumCalismaAsistani;

  /// No description provided for @premiumYukselt.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium 🚀'**
  String get premiumYukselt;

  /// No description provided for @pdfSeciliyor.
  ///
  /// In en, this message translates to:
  /// **'Selecting PDF file...'**
  String get pdfSeciliyor;

  /// No description provided for @pdfOkunuyor.
  ///
  /// In en, this message translates to:
  /// **'📄 Reading PDF...'**
  String get pdfOkunuyor;

  /// No description provided for @aiAnalizEdiyor.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI analyzing text...'**
  String get aiAnalizEdiyor;

  /// No description provided for @onboardingPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'AI & PDF Study Mode'**
  String get onboardingPdfTitle;

  /// No description provided for @onboardingPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your study notes; TScan\'s AI will auto-calculate your study duration, keep you focused, and generate interactive quizzes right after your session!'**
  String get onboardingPdfDesc;

  /// No description provided for @onboardingPdfExtra.
  ///
  /// In en, this message translates to:
  /// **'Smart Reading & AI Quizzes'**
  String get onboardingPdfExtra;

  /// No description provided for @aiAnalizSonuclari.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Results'**
  String get aiAnalizSonuclari;

  /// No description provided for @dersAdi.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get dersAdi;

  /// No description provided for @zorlukDerecesi.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get zorlukDerecesi;

  /// No description provided for @tahminiOkumaSuresi.
  ///
  /// In en, this message translates to:
  /// **'Estimated Reading Time'**
  String get tahminiOkumaSuresi;

  /// No description provided for @tahminiSureDk.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String tahminiSureDk(int minutes);

  /// No description provided for @tscanOnerisi.
  ///
  /// In en, this message translates to:
  /// **'TScan Recommendation'**
  String get tscanOnerisi;

  /// No description provided for @calismayiBaslat.
  ///
  /// In en, this message translates to:
  /// **'Start Study ⏱️'**
  String get calismayiBaslat;

  /// No description provided for @pdfGizlilikOnayiTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Cloud Analysis Consent'**
  String get pdfGizlilikOnayiTitle;

  /// No description provided for @pdfGizlilikOnayiBody.
  ///
  /// In en, this message translates to:
  /// **'The text content of your uploaded PDF will be sent to the AI service (Google Gemini) over a secure connection for duration estimation and quiz generation. Do you consent to sending your data to the cloud?'**
  String get pdfGizlilikOnayiBody;

  /// No description provided for @onayla.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get onayla;

  /// No description provided for @reddet.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get reddet;

  /// No description provided for @aiQuizBaslat.
  ///
  /// In en, this message translates to:
  /// **'Start AI Quiz'**
  String get aiQuizBaslat;

  /// No description provided for @akilliSoruModu.
  ///
  /// In en, this message translates to:
  /// **'Session ended! Ready to solve AI questions?'**
  String get akilliSoruModu;

  /// No description provided for @quizBasligi.
  ///
  /// In en, this message translates to:
  /// **'AI Evaluation Test'**
  String get quizBasligi;

  /// No description provided for @soruSayisi.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String soruSayisi(int current, int total);

  /// No description provided for @quiziBitir.
  ///
  /// In en, this message translates to:
  /// **'Finish Test'**
  String get quiziBitir;

  /// No description provided for @quizSonuclari.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get quizSonuclari;

  /// No description provided for @basariSkoru.
  ///
  /// In en, this message translates to:
  /// **'Success Score: %{score}'**
  String basariSkoru(int score);

  /// No description provided for @dogruSoruSayisi.
  ///
  /// In en, this message translates to:
  /// **'Correct: {correct} / {total}'**
  String dogruSoruSayisi(int correct, int total);

  /// No description provided for @odaklanmayaDon.
  ///
  /// In en, this message translates to:
  /// **'Back to Focus'**
  String get odaklanmayaDon;

  /// No description provided for @farkliSureSec.
  ///
  /// In en, this message translates to:
  /// **'Select custom duration'**
  String get farkliSureSec;

  /// No description provided for @sureSec.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get sureSec;

  /// No description provided for @dakika.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get dakika;

  /// No description provided for @aiSorulariHazirliyor.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI preparing questions...'**
  String get aiSorulariHazirliyor;

  /// No description provided for @buBirkacSaniyeSurebilir.
  ///
  /// In en, this message translates to:
  /// **'This may take a few seconds'**
  String get buBirkacSaniyeSurebilir;

  /// No description provided for @quizYuklenemedi.
  ///
  /// In en, this message translates to:
  /// **'Quiz could not be loaded'**
  String get quizYuklenemedi;

  /// No description provided for @tekrarDene.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tekrarDene;

  /// No description provided for @sonrakiSoru.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get sonrakiSoru;

  /// No description provided for @sonuclariGor.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get sonuclariGor;

  /// No description provided for @aiYanlisAnalizi.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI analyzing wrong answers...'**
  String get aiYanlisAnalizi;

  /// No description provided for @aiKocAnalizi.
  ///
  /// In en, this message translates to:
  /// **'AI Coach Analysis'**
  String get aiKocAnalizi;

  /// No description provided for @soruDetaylari.
  ///
  /// In en, this message translates to:
  /// **'Question Details'**
  String get soruDetaylari;

  /// No description provided for @anaSayfayaDon.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get anaSayfayaDon;

  /// No description provided for @soruNo.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String soruNo(int number);

  /// No description provided for @seninCevabin.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String seninCevabin(String answer);

  /// No description provided for @dogruCevap.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String dogruCevap(String answer);

  /// No description provided for @muhtesemKonuyaHakimsin.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You mastered the subject!'**
  String get muhtesemKonuyaHakimsin;

  /// No description provided for @iyiGidiyorsunTekrar.
  ///
  /// In en, this message translates to:
  /// **'Doing good, practice a bit more!'**
  String get iyiGidiyorsunTekrar;

  /// No description provided for @gelismeAlaninVar.
  ///
  /// In en, this message translates to:
  /// **'Room for improvement, read again'**
  String get gelismeAlaninVar;

  /// No description provided for @tekrarCalismalisin.
  ///
  /// In en, this message translates to:
  /// **'You should study the text again'**
  String get tekrarCalismalisin;

  /// No description provided for @pdfCalismasi.
  ///
  /// In en, this message translates to:
  /// **'PDF Study'**
  String get pdfCalismasi;

  /// No description provided for @tamamlananQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get tamamlananQuiz;

  /// No description provided for @ortalamaQuizBasarisi.
  ///
  /// In en, this message translates to:
  /// **'Average Quiz Score'**
  String get ortalamaQuizBasarisi;

  /// No description provided for @oturum.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get oturum;

  /// No description provided for @sinav.
  ///
  /// In en, this message translates to:
  /// **'quizzes'**
  String get sinav;

  /// No description provided for @basariOrani.
  ///
  /// In en, this message translates to:
  /// **'success rate'**
  String get basariOrani;

  /// No description provided for @okumaHizi.
  ///
  /// In en, this message translates to:
  /// **'Personalized Reading Speed'**
  String get okumaHizi;

  /// No description provided for @okumaHiziAciklama.
  ///
  /// In en, this message translates to:
  /// **'Tailor AI time estimates to your reading speed with Premium.'**
  String get okumaHiziAciklama;

  /// No description provided for @hizYavas.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get hizYavas;

  /// No description provided for @hizNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get hizNormal;

  /// No description provided for @hizHizli.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get hizHizli;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAiQuest.
  ///
  /// In en, this message translates to:
  /// **'AI Quest'**
  String get navAiQuest;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @aiQuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a PDF, solve AI quizzes'**
  String get aiQuestSubtitle;

  /// No description provided for @aiQuestUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'📄 Upload PDF & Study'**
  String get aiQuestUploadTitle;

  /// No description provided for @aiQuestUploadDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload a document, let AI analyze it and build a quiz'**
  String get aiQuestUploadDesc;

  /// No description provided for @aiQuestNoDocs.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get aiQuestNoDocs;

  /// No description provided for @aiQuestNoDocsDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your first PDF to start\nAI-assisted studying!'**
  String get aiQuestNoDocsDesc;

  /// No description provided for @aiQuestRecentDocs.
  ///
  /// In en, this message translates to:
  /// **'📚 Recently Studied Documents'**
  String get aiQuestRecentDocs;

  /// No description provided for @aiQuestClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get aiQuestClear;

  /// No description provided for @aiQuestClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all documents from history?'**
  String get aiQuestClearConfirm;

  /// No description provided for @aiQuestDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from history?'**
  String aiQuestDeleteConfirm(String name);

  /// No description provided for @aiQuestDocMeta.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min • {pages} pages'**
  String aiQuestDocMeta(int minutes, int pages);

  /// No description provided for @gizlilikKontrol.
  ///
  /// In en, this message translates to:
  /// **'Checking privacy consent...'**
  String get gizlilikKontrol;

  /// No description provided for @apiKey401Hata.
  ///
  /// In en, this message translates to:
  /// **'The API key was rejected. Please enter a valid Gemini API key; the saved key was cleared.'**
  String get apiKey401Hata;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @activityIntensity.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY INTENSITY'**
  String get activityIntensity;

  /// No description provided for @timeAgoWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String timeAgoWeeks(int weeks);

  /// No description provided for @timeAgoMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String timeAgoMonths(int months);

  /// No description provided for @timeAgoYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years ago'**
  String timeAgoYears(int years);

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(int minutes);

  /// No description provided for @aiQuestAllDocs.
  ///
  /// In en, this message translates to:
  /// **'All Documents ({count})'**
  String aiQuestAllDocs(int count);

  /// No description provided for @allDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'ALL DOCUMENTS'**
  String get allDocsTitle;

  /// No description provided for @freePdfRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} free PDF uploads left'**
  String freePdfRemaining(int count);

  /// No description provided for @freeLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your free uploads are used up'**
  String get freeLimitReachedTitle;

  /// No description provided for @freeLimitReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You have used your 2 free PDF uploads. Go Premium for unlimited PDFs and AI quizzes.'**
  String get freeLimitReachedBody;

  /// No description provided for @statsTotalStudy.
  ///
  /// In en, this message translates to:
  /// **'Total study'**
  String get statsTotalStudy;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsWeeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal: {hours} h'**
  String statsWeeklyGoal(int hours);

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get statsStreak;

  /// No description provided for @statsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions done'**
  String get statsSessions;

  /// No description provided for @statsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get statsSuccess;

  /// No description provided for @statsQuizAvg.
  ///
  /// In en, this message translates to:
  /// **'Quiz average'**
  String get statsQuizAvg;

  /// No description provided for @statsDailyMinutes.
  ///
  /// In en, this message translates to:
  /// **'LAST 7 DAYS (MINUTES)'**
  String get statsDailyMinutes;

  /// No description provided for @statsBySubject.
  ///
  /// In en, this message translates to:
  /// **'TIME BY SUBJECT'**
  String get statsBySubject;

  /// No description provided for @hoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutesShort(int hours, int minutes);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'TScan Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Study smarter with unlimited PDFs and your AI study coach'**
  String get paywallSubtitle;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get planPerMonth;

  /// No description provided for @planPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get planPerYear;

  /// No description provided for @planMonthlyNote.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get planMonthlyNote;

  /// No description provided for @planYearlyNote.
  ///
  /// In en, this message translates to:
  /// **'Only 50 TL a month — save 83%'**
  String get planYearlyNote;

  /// No description provided for @planBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get planBestValue;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @premiumActiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Premium is active until {date}'**
  String premiumActiveUntil(String date);

  /// No description provided for @premiumActivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Premium Activated!'**
  String get premiumActivatedTitle;

  /// No description provided for @premiumActivatedBody.
  ///
  /// In en, this message translates to:
  /// **'You now have unlimited access to every feature. Happy studying!'**
  String get premiumActivatedBody;

  /// No description provided for @greatBtn.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get greatBtn;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'You can cancel your subscription at any time from Play Store settings.'**
  String get paywallTerms;

  /// No description provided for @benefitUnlimitedPdf.
  ///
  /// In en, this message translates to:
  /// **'Unlimited PDFs'**
  String get benefitUnlimitedPdf;

  /// No description provided for @benefitUnlimitedPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload as many notes and books as you like.'**
  String get benefitUnlimitedPdfDesc;

  /// No description provided for @benefitAiQuiz.
  ///
  /// In en, this message translates to:
  /// **'AI quiz & study time'**
  String get benefitAiQuiz;

  /// No description provided for @benefitAiQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated quizzes and reading time for every PDF.'**
  String get benefitAiQuizDesc;

  /// No description provided for @benefitWrongAnswers.
  ///
  /// In en, this message translates to:
  /// **'Wrong answer analysis'**
  String get benefitWrongAnswers;

  /// No description provided for @benefitWrongAnswersDesc.
  ///
  /// In en, this message translates to:
  /// **'See which topics to review after each quiz.'**
  String get benefitWrongAnswersDesc;

  /// No description provided for @benefitSounds.
  ///
  /// In en, this message translates to:
  /// **'All focus sounds'**
  String get benefitSounds;

  /// No description provided for @benefitSoundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Rain, forest, café and more.'**
  String get benefitSoundsDesc;

  /// No description provided for @apiKeyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key'**
  String get apiKeyDialogTitle;

  /// No description provided for @apiKeyDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your Google Gemini API key to use AI features. You can get a free key from Google AI Studio.'**
  String get apiKeyDialogBody;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your key'**
  String get apiKeyRequired;

  /// No description provided for @apiKeyInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a Gemini API key'**
  String get apiKeyInvalidFormat;

  /// No description provided for @flipPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Turn your phone face down'**
  String get flipPhoneHint;

  /// No description provided for @autoQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Well done!'**
  String get autoQuizTitle;

  /// No description provided for @autoQuizDone.
  ///
  /// In en, this message translates to:
  /// **'Your PDF focus session is complete.'**
  String get autoQuizDone;

  /// No description provided for @autoQuizStarting.
  ///
  /// In en, this message translates to:
  /// **'The AI quiz is starting so you can test what you learned...'**
  String get autoQuizStarting;

  /// No description provided for @aiErrMissingKey.
  ///
  /// In en, this message translates to:
  /// **'Add your Gemini API key to use AI features.'**
  String get aiErrMissingKey;

  /// No description provided for @aiErrBusy.
  ///
  /// In en, this message translates to:
  /// **'The AI service is busy right now. Please try again in a few minutes.'**
  String get aiErrBusy;

  /// No description provided for @aiErrRateLimit.
  ///
  /// In en, this message translates to:
  /// **'The AI usage limit was reached. Please try again later.'**
  String get aiErrRateLimit;

  /// No description provided for @aiErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get aiErrNetwork;

  /// No description provided for @aiErrFileMissing.
  ///
  /// In en, this message translates to:
  /// **'The PDF file could not be found on this device.'**
  String get aiErrFileMissing;

  /// No description provided for @aiErrBadResponse.
  ///
  /// In en, this message translates to:
  /// **'The AI couldn\'t prepare the questions. Please try again.'**
  String get aiErrBadResponse;

  /// No description provided for @aiErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with the AI service. Please try again.'**
  String get aiErrGeneric;

  /// No description provided for @enterApiKeyBtn.
  ///
  /// In en, this message translates to:
  /// **'Enter API key'**
  String get enterApiKeyBtn;

  /// No description provided for @apiKeyWhere.
  ///
  /// In en, this message translates to:
  /// **'Get a free key at aistudio.google.com/apikey'**
  String get apiKeyWhere;

  /// No description provided for @pagesWords.
  ///
  /// In en, this message translates to:
  /// **'{pages} pages • {words} words'**
  String pagesWords(int pages, int words);

  /// No description provided for @aiErrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI is temporarily unavailable. Please try again later.'**
  String get aiErrUnavailable;

  /// No description provided for @olderSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'OLDER SESSIONS'**
  String get olderSessionsTitle;

  /// No description provided for @olderSessionsBtn.
  ///
  /// In en, this message translates to:
  /// **'Older sessions ({count})'**
  String olderSessionsBtn(int count);

  /// No description provided for @noRecentSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions in the last 7 days'**
  String get noRecentSessions;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Purchases checked'**
  String get restoreDone;

  /// No description provided for @billingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store isn\'t available on this device. Install TScan from Google Play to subscribe.'**
  String get billingUnavailable;

  /// No description provided for @billingProductMissing.
  ///
  /// In en, this message translates to:
  /// **'This subscription isn\'t available right now. Please try again later.'**
  String get billingProductMissing;

  /// No description provided for @billingFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed.'**
  String get billingFailed;

  /// No description provided for @billingPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation...'**
  String get billingPending;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
