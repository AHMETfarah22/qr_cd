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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('tr'),
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
