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
  String get cannotGoToAccount => 'You cannot go to account while timer is running!';

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
  String get statusIdleLvl1 => 'Complete the 30-second test and\nstart real focus!';

  @override
  String get statusIdle => 'Set duration, select category and focus!';

  @override
  String get statusRunning => 'Deep focus starts...\nTurn your phone over!';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusFailure => 'FOCUS BROKEN!\nYou lifted the phone.';

  @override
  String get statusSuccessFirst => 'CONGRATULATIONS! First stage complete.\n1 hour focus unlocked!';

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
  String get forgotPasswordDialog => 'You will need to create a new account since you forgot your password. Are you sure?';

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
  String get agreeTerms => 'By registering, you agree to the Terms of Service and Privacy Policy.';

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
  String get deleteAccountConfirm => 'Are you sure you want to delete your account? This action cannot be undone.';

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
  String get startFocusNow => 'Start focusing now and create your first record!';

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
  String get notifSuccessBody => 'Focus session completed successfully. You\'re awesome!';

  @override
  String get notifBreakEndTitle => 'Break Over!';

  @override
  String get notifBreakEndBody => 'You are ready for a new focus session.';

  @override
  String get onboardingWelcome => 'Welcome to TScan';

  @override
  String get onboardingWelcomeDesc => 'Let\'s set up your focus environment for the best experience.';

  @override
  String get onboardingSensorTitle => 'Sensor Access';

  @override
  String get onboardingSensorDesc => 'TScan uses the accelerometer to detect if your phone is face down. This helps you stay focused!';

  @override
  String get onboardingDndTitle => 'Do Not Disturb';

  @override
  String get onboardingDndDesc => 'To block distracting notifications, we need permission to manage Do Not Disturb mode.';

  @override
  String get onboardingPhoneTitle => 'Call Detection';

  @override
  String get onboardingPhoneDesc => 'If you receive a call during focus, we\'ll automatically pause to let you decide.';

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

  @override
  String get addSessionNoteTitle => 'What did you focus on?';

  @override
  String get sessionNoteHint => 'e.g., studying math, coding';

  @override
  String get sessionNoteLabel => 'Session Note';

  @override
  String get saveBtn => 'Save';

  @override
  String get dailyGoalSetting => 'Daily Focus Goal';

  @override
  String get dailyGoalSubtitle => 'Target minutes of focus per day';

  @override
  String get dailyGoalReached => 'DAILY FOCUS GOAL REACHED! 🎉';

  @override
  String get dailyGoalProgress => 'Daily Goal Progress';

  @override
  String dailyMinutesFocused(int minutes, int goal) {
    return '$minutes / $goal minutes';
  }

  @override
  String dailyGoalRemaining(Object minutes) {
    return '$minutes more minutes to reach your goal!';
  }

  @override
  String get pdfStudyTitle => 'PDF Study';

  @override
  String get pdfDestekliCalisma => 'AI Powered PDF Study';

  @override
  String get pdfYukleAciklama => 'Upload study notes, let AI estimate reading time.\nThen it tests you when done! 🚀';

  @override
  String get pdfStep1 => 'Upload PDF';

  @override
  String get pdfStep2 => 'AI Analysis';

  @override
  String get pdfStep3 => 'Focus & Read';

  @override
  String get pdfStep4 => 'Test with Quiz';

  @override
  String get pdfDosyaSec => 'Select PDF File';

  @override
  String get sonCalisilanBelgeler => 'Recent Documents';

  @override
  String get temizle => 'Clear';

  @override
  String get tekrarCalis => 'Study Again';

  @override
  String get sil => 'Delete';

  @override
  String get premiumOzellik => 'Premium Feature';

  @override
  String get premiumCalismaAsistani => 'You must be a Premium member to use advanced study assistant features such as AI time estimation and quiz generation.';

  @override
  String get premiumYukselt => 'Upgrade to Premium 🚀';

  @override
  String get pdfSeciliyor => 'Selecting PDF file...';

  @override
  String get pdfOkunuyor => '📄 Reading PDF...';

  @override
  String get aiAnalizEdiyor => '🤖 AI analyzing text...';

  @override
  String get onboardingPdfTitle => 'AI & PDF Study Mode';

  @override
  String get onboardingPdfDesc => 'Upload your study notes; TScan\'s AI will auto-calculate your study duration, keep you focused, and generate interactive quizzes right after your session!';

  @override
  String get onboardingPdfExtra => 'Smart Reading & AI Quizzes';

  @override
  String get aiAnalizSonuclari => 'AI Analysis Results';

  @override
  String get dersAdi => 'Subject';

  @override
  String get zorlukDerecesi => 'Difficulty Level';

  @override
  String get tahminiOkumaSuresi => 'Estimated Reading Time';

  @override
  String tahminiSureDk(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get tscanOnerisi => 'TScan Recommendation';

  @override
  String get calismayiBaslat => 'Start Study ⏱️';

  @override
  String get pdfGizlilikOnayiTitle => 'Privacy & Cloud Analysis Consent';

  @override
  String get pdfGizlilikOnayiBody => 'The text content of your uploaded PDF will be sent to the AI service (Google Gemini) over a secure connection for duration estimation and quiz generation. Do you consent to sending your data to the cloud?';

  @override
  String get onayla => 'Approve';

  @override
  String get reddet => 'Decline';

  @override
  String get aiQuizBaslat => 'Start AI Quiz';

  @override
  String get akilliSoruModu => 'Session ended! Ready to solve AI questions?';

  @override
  String get quizBasligi => 'AI Evaluation Test';

  @override
  String soruSayisi(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get quiziBitir => 'Finish Test';

  @override
  String get quizSonuclari => 'Test Results';

  @override
  String basariSkoru(int score) {
    return 'Success Score: %$score';
  }

  @override
  String dogruSoruSayisi(int correct, int total) {
    return 'Correct: $correct / $total';
  }

  @override
  String get odaklanmayaDon => 'Back to Focus';

  @override
  String get farkliSureSec => 'Select custom duration';

  @override
  String get sureSec => 'Select Duration';

  @override
  String get dakika => 'minutes';

  @override
  String get aiSorulariHazirliyor => '🤖 AI preparing questions...';

  @override
  String get buBirkacSaniyeSurebilir => 'This may take a few seconds';

  @override
  String get quizYuklenemedi => 'Quiz could not be loaded';

  @override
  String get tekrarDene => 'Try Again';

  @override
  String get sonrakiSoru => 'Next Question';

  @override
  String get sonuclariGor => 'View Results';

  @override
  String get aiYanlisAnalizi => '🤖 AI analyzing wrong answers...';

  @override
  String get aiKocAnalizi => 'AI Coach Analysis';

  @override
  String get soruDetaylari => 'Question Details';

  @override
  String get anaSayfayaDon => 'Back to Home';

  @override
  String soruNo(int number) {
    return 'Question $number';
  }

  @override
  String seninCevabin(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String dogruCevap(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get muhtesemKonuyaHakimsin => 'Excellent! You mastered the subject!';

  @override
  String get iyiGidiyorsunTekrar => 'Doing good, practice a bit more!';

  @override
  String get gelismeAlaninVar => 'Room for improvement, read again';

  @override
  String get tekrarCalismalisin => 'You should study the text again';

  @override
  String get pdfCalismasi => 'PDF Study';

  @override
  String get tamamlananQuiz => 'Quiz Completed';

  @override
  String get ortalamaQuizBasarisi => 'Average Quiz Score';

  @override
  String get oturum => 'sessions';

  @override
  String get sinav => 'quizzes';

  @override
  String get basariOrani => 'success rate';

  @override
  String get okumaHizi => 'Personalized Reading Speed';

  @override
  String get okumaHiziAciklama => 'Tailor AI time estimates to your reading speed with Premium.';

  @override
  String get hizYavas => 'Slow';

  @override
  String get hizNormal => 'Normal';

  @override
  String get hizHizli => 'Fast';

  @override
  String get navHome => 'Home';

  @override
  String get navAiQuest => 'AI Quest';

  @override
  String get navAccount => 'Account';

  @override
  String get aiQuestSubtitle => 'Upload a PDF, solve AI quizzes';

  @override
  String get aiQuestUploadTitle => '📄 Upload PDF & Study';

  @override
  String get aiQuestUploadDesc => 'Upload a document, let AI analyze it and build a quiz';

  @override
  String get aiQuestNoDocs => 'No documents yet';

  @override
  String get aiQuestNoDocsDesc => 'Upload your first PDF to start\nAI-assisted studying!';

  @override
  String get aiQuestRecentDocs => '📚 Recently Studied Documents';

  @override
  String get aiQuestClear => 'Clear';

  @override
  String get aiQuestClearConfirm => 'Remove all documents from history?';

  @override
  String aiQuestDeleteConfirm(String name) {
    return 'Remove \"$name\" from history?';
  }

  @override
  String aiQuestDocMeta(int minutes, int pages) {
    return '$minutes min • $pages pages';
  }

  @override
  String get gizlilikKontrol => 'Checking privacy consent...';

  @override
  String get apiKey401Hata => 'The API key was rejected. Please enter a valid Gemini API key; the saved key was cleared.';

  @override
  String get navStats => 'Stats';

  @override
  String get navHistory => 'History';

  @override
  String get activityIntensity => 'ACTIVITY INTENSITY';

  @override
  String timeAgoWeeks(int weeks) {
    return '$weeks weeks ago';
  }

  @override
  String timeAgoMonths(int months) {
    return '$months months ago';
  }

  @override
  String timeAgoYears(int years) {
    return '$years years ago';
  }

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String aiQuestAllDocs(int count) {
    return 'All Documents ($count)';
  }

  @override
  String get allDocsTitle => 'ALL DOCUMENTS';

  @override
  String freePdfRemaining(int count) {
    return '$count free PDF uploads left';
  }

  @override
  String get freeLimitReachedTitle => 'Your free uploads are used up';

  @override
  String get freeLimitReachedBody => 'You have used your 2 free PDF uploads. Go Premium for unlimited PDFs and AI quizzes.';

  @override
  String get statsTotalStudy => 'Total study';

  @override
  String get statsThisWeek => 'This week';

  @override
  String statsWeeklyGoal(int hours) {
    return 'Weekly goal: $hours h';
  }

  @override
  String get statsStreak => 'Day streak';

  @override
  String get statsSessions => 'Sessions done';

  @override
  String get statsSuccess => 'Success';

  @override
  String get statsQuizAvg => 'Quiz average';

  @override
  String get statsDailyMinutes => 'LAST 7 DAYS (MINUTES)';

  @override
  String get statsBySubject => 'TIME BY SUBJECT';

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get paywallTitle => 'TScan Premium';

  @override
  String get paywallSubtitle => 'Study smarter with unlimited PDFs and your AI study coach';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planPerMonth => '/ month';

  @override
  String get planPerYear => '/ year';

  @override
  String get planMonthlyNote => 'Cancel anytime';

  @override
  String get planYearlyNote => 'Only 50 TL a month — save 83%';

  @override
  String get planBestValue => 'BEST VALUE';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String premiumActiveUntil(String date) {
    return 'Premium is active until $date';
  }

  @override
  String get premiumActivatedTitle => '🎉 Premium Activated!';

  @override
  String get premiumActivatedBody => 'You now have unlimited access to every feature. Happy studying!';

  @override
  String get greatBtn => 'Great!';

  @override
  String get paywallTerms => 'You can cancel your subscription at any time from Play Store settings.';

  @override
  String get benefitUnlimitedPdf => 'Unlimited PDFs';

  @override
  String get benefitUnlimitedPdfDesc => 'Upload as many notes and books as you like.';

  @override
  String get benefitAiQuiz => 'AI quiz & study time';

  @override
  String get benefitAiQuizDesc => 'Auto-generated quizzes and reading time for every PDF.';

  @override
  String get benefitWrongAnswers => 'Wrong answer analysis';

  @override
  String get benefitWrongAnswersDesc => 'See which topics to review after each quiz.';

  @override
  String get benefitSounds => 'All focus sounds';

  @override
  String get benefitSoundsDesc => 'Rain, forest, café and more.';

  @override
  String get apiKeyDialogTitle => 'Gemini API Key';

  @override
  String get apiKeyDialogBody => 'Enter your Google Gemini API key to use AI features. You can get a free key from Google AI Studio.';

  @override
  String get apiKeyRequired => 'Please enter your key';

  @override
  String get apiKeyInvalidFormat => 'This doesn\'t look like a Gemini API key';

  @override
  String get flipPhoneHint => 'Turn your phone face down';

  @override
  String get autoQuizTitle => '🎉 Well done!';

  @override
  String get autoQuizDone => 'Your PDF focus session is complete.';

  @override
  String get autoQuizStarting => 'The AI quiz is starting so you can test what you learned...';

  @override
  String get aiErrMissingKey => 'Add your Gemini API key to use AI features.';

  @override
  String get aiErrBusy => 'The AI service is busy right now. Please try again in a few minutes.';

  @override
  String get aiErrRateLimit => 'The AI usage limit was reached. Please try again later.';

  @override
  String get aiErrNetwork => 'No internet connection. Check your connection and try again.';

  @override
  String get aiErrFileMissing => 'The PDF file could not be found on this device.';

  @override
  String get aiErrBadResponse => 'The AI couldn\'t prepare the questions. Please try again.';

  @override
  String get aiErrGeneric => 'Something went wrong with the AI service. Please try again.';

  @override
  String get enterApiKeyBtn => 'Enter API key';

  @override
  String get apiKeyWhere => 'Get a free key at aistudio.google.com/apikey';

  @override
  String pagesWords(int pages, int words) {
    return '$pages pages • $words words';
  }

  @override
  String get aiErrUnavailable => 'AI is temporarily unavailable. Please try again later.';

  @override
  String get olderSessionsTitle => 'OLDER SESSIONS';

  @override
  String olderSessionsBtn(int count) {
    return 'Older sessions ($count)';
  }

  @override
  String get noRecentSessions => 'No sessions in the last 7 days';
}
