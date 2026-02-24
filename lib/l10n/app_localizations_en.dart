// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get focusTimer => 'FOCUS TIMER';

  @override
  String level(int level) {
    return 'LEVEL $level';
  }

  @override
  String get accountInfo => 'Account Info';

  @override
  String get cannotGoToAccount =>
      'You cannot go to account while timer is running!';

  @override
  String get ready => 'READY';

  @override
  String get focus => 'FOCUS';

  @override
  String get paused => 'PAUSED';

  @override
  String get failed => 'FAILED';

  @override
  String get success => 'SUCCESS';

  @override
  String get breakLabel => 'BREAK';

  @override
  String get secondsFocusTest => '30 Seconds Focus Test';

  @override
  String get beginnerLevel => 'Beginner Level';

  @override
  String minuteFocus(int minutes) {
    return '$minutes Minute Focus';
  }

  @override
  String get selectCategory => 'SELECT CATEGORY';

  @override
  String get start => 'START';

  @override
  String get breakTimeTitle => 'BREAK TIME';

  @override
  String minBreak(int minutes) {
    return '$minutes min Break';
  }

  @override
  String get dontTakeBreak => 'Don\'t take a break, continue';

  @override
  String get endBreak => 'END BREAK';

  @override
  String get cancel => 'CANCEL';

  @override
  String get statusIdleLvl1 =>
      'Complete the 30-second test and\nstart real focus!';

  @override
  String get statusIdle => 'Set duration, select category and focus!';

  @override
  String get statusRunning => 'Deep focus starts...\nTurn your phone over!';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusFailure => 'FOCUS BROKEN!\nYou lifted the phone.';

  @override
  String get statusSuccessFirst =>
      'CONGRATULATIONS! First stage complete.\n1 hour focus unlocked!';

  @override
  String get statusSuccess => 'Congratulations! Session completed.';

  @override
  String get statusBreak => 'Rest time...\nHave a good break!';

  @override
  String get catWork => 'Work';

  @override
  String get catStudy => 'Study';

  @override
  String get catReading => 'Reading';

  @override
  String get catMeditation => 'Meditation';

  @override
  String get catExercise => 'Exercise';

  @override
  String get catCreative => 'Creative';

  @override
  String get catBreak => 'Break';

  @override
  String get catOther => 'Other';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get enterEmailPassword => 'Please enter email and password';

  @override
  String get welcome => 'Welcome';

  @override
  String get startFocusingToday => 'Start focusing and being productive today.';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get forgotPasswordDialog =>
      'You will need to create a new account since you forgot your password. Are you sure?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get nameSurname => 'Name Surname';

  @override
  String get enterNameSurname => 'Enter your name and surname';

  @override
  String get agreeTerms =>
      'By registering, you agree to the Terms of Service and Privacy Policy.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get accountInfoTitle => 'ACCOUNT INFO';

  @override
  String get focusSummary => 'FOCUS SUMMARY';

  @override
  String get total => 'Total';

  @override
  String get successful => 'Successful';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get totalTime => 'Total Time';

  @override
  String session(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sessions',
      one: 'Session',
    );
    return '$_temp0';
  }

  @override
  String get earnedBadges => 'EARNED BADGES';

  @override
  String get successAnalysis => 'SUCCESS ANALYSIS';

  @override
  String get sessionHistory => 'SESSION HISTORY';

  @override
  String get detailedCharts => 'DETAILED CHARTS';

  @override
  String get logout => 'LOGOUT';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get delete => 'DELETE';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get successRate => 'Success Rate';

  @override
  String get dailyStreak => 'DAILY STREAK';

  @override
  String day(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'DAYS',
      one: 'DAY',
    );
    return '$_temp0';
  }

  @override
  String get badgeEarlyBird => 'Early Bird';

  @override
  String get badgeMarathoner => 'Marathoner';

  @override
  String get badgeMaster => 'Master Focuser';

  @override
  String get user => 'User';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get sectionVoiceNotification => 'VOICE AND NOTIFICATION';

  @override
  String get alarmSound => 'Alarm Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get sectionFocusSettings => 'FOCUS SETTINGS';

  @override
  String get defaultDuration => 'Default Duration';

  @override
  String mins(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get sectionAccountSettings => 'ACCOUNT SETTINGS';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updatePasswordSubtitle => 'Update your account password';

  @override
  String get passwordSecureNote => 'Note: Your password is stored securely.';

  @override
  String get sectionDataManagement => 'DATA MANAGEMENT';

  @override
  String get backupData => 'Backup Data';

  @override
  String get exportDataSubtitle => 'Export your data';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get importDataSubtitle => 'Load data from backup';

  @override
  String get resetStatistics => 'Reset Statistics';

  @override
  String get resetStatsSubtitle => 'Clear all session data';

  @override
  String get sectionApplication => 'APPLICATION';

  @override
  String get shareWithFriends => 'Share with Friends';

  @override
  String get shareSubtitle => 'Share via WhatsApp or other apps';

  @override
  String version(Object version) {
    return 'Version $version';
  }

  @override
  String get historyTitle => 'SESSION HISTORY';

  @override
  String get noHistoryYet => 'No session history yet';

  @override
  String get startFocusNow =>
      'Start focusing now and create your first record!';

  @override
  String get startFocusingBtn => 'Start Focusing';

  @override
  String get weeklyGoalSuccess => 'WEEKLY GOAL REACHED!';

  @override
  String get weeklyGoalFailed => 'GOAL NOT REACHED';

  @override
  String weeklyMinutesNote(Object hours, Object minutes) {
    return 'You focused for a total of $hours hours $minutes minutes this week.';
  }

  @override
  String moreMinutesRequired(Object minutes) {
    return '$minutes more minutes required!';
  }

  @override
  String get today => 'TODAY';

  @override
  String get yesterday => 'YESTERDAY';

  @override
  String get successLabel => 'SUCCESSFUL';

  @override
  String get failedLabel => 'FAILED';

  @override
  String get timeAgoJustNow => 'Just now';

  @override
  String timeAgoMinutes(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(Object hours) {
    return '$hours hours ago';
  }

  @override
  String timeAgoDays(Object days) {
    return '$days days ago';
  }

  @override
  String get statisticsTitle => 'STATISTICS';

  @override
  String get categoryDistribution => 'CATEGORY DISTRIBUTION';

  @override
  String get weeklyActivity => 'LAST 7 DAYS ACTIVITY';

  @override
  String get timeDistribution => 'TIME DISTRIBUTION';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get successfulSessions => 'Completed';

  @override
  String get cancelledSessionsCount => 'Cancelled';

  @override
  String get activeDaysCount => 'Active Days';

  @override
  String get hoursShort => 'h';

  @override
  String get minutesShort => 'm';

  @override
  String hoursLong(Object hours) {
    return '$hours hours';
  }

  @override
  String minutesLong(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifSuccessTitle => 'Congratulations!';

  @override
  String get notifSuccessBody =>
      'Focus session completed successfully. You\'re awesome!';

  @override
  String get notifBreakEndTitle => 'Break Over!';

  @override
  String get notifBreakEndBody => 'You are ready for a new focus session.';

  @override
  String get onboardingWelcome => 'Welcome to Focus Flow';

  @override
  String get onboardingWelcomeDesc =>
      'Let\'s set up your focus environment for the best experience.';

  @override
  String get onboardingSensorTitle => 'Sensor Access';

  @override
  String get onboardingSensorDesc =>
      'Focus Flow uses the accelerometer to detect if your phone is face down. This helps you stay focused!';

  @override
  String get onboardingDndTitle => 'Do Not Disturb';

  @override
  String get onboardingDndDesc =>
      'To block distracting notifications, we need permission to manage Do Not Disturb mode.';

  @override
  String get onboardingPhoneTitle => 'Call Detection';

  @override
  String get onboardingPhoneDesc =>
      'If you receive a call during focus, we\'ll automatically pause to let you decide.';

  @override
  String get btnGrant => 'Grant Permission';

  @override
  String get btnNext => 'NEXT';

  @override
  String get btnBack => 'BACK';

  @override
  String get btnStart => 'GET STARTED';

  @override
  String get permissionGranted => 'Permission Granted';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get tutorialTitle => 'App Tutorial';

  @override
  String get tutorialSubtitle => 'Show onboarding guide again';
}
