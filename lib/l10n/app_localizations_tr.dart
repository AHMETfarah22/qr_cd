// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get focusTimer => 'ODAKLANMA SAYACI';

  @override
  String level(int level) {
    return 'SEVİYE $level';
  }

  @override
  String get accountInfo => 'Hesap Bilgileri';

  @override
  String get cannotGoToAccount => 'Timer çalışırken hesaba gidemezsiniz!';

  @override
  String get ready => 'HAZIR';

  @override
  String get focus => 'ODAKLAN';

  @override
  String get paused => 'DURAKLATILDI';

  @override
  String get failed => 'HATALI';

  @override
  String get success => 'BAŞARILI';

  @override
  String get breakLabel => 'MOLA';

  @override
  String get secondsFocusTest => '30 Saniye Odaklanma Testi';

  @override
  String get beginnerLevel => 'Başlangıç Seviyesi';

  @override
  String minuteFocus(int minutes) {
    return '$minutes Dakika Odaklanma';
  }

  @override
  String get selectCategory => 'KATEGORİ SEÇ';

  @override
  String get start => 'BAŞLAT';

  @override
  String get breakTimeTitle => 'MOLA ZAMANI';

  @override
  String minBreak(int minutes) {
    return '$minutes dk Mola';
  }

  @override
  String get dontTakeBreak => 'Mola Verme, Devam Et';

  @override
  String get endBreak => 'MOLAYI BİTİR';

  @override
  String get cancel => 'VAZGEÇ';

  @override
  String get statusIdleLvl1 =>
      '30 saniyelik testi tamamla ve\ngerçek odaklanmaya başla!';

  @override
  String get statusIdle => 'Süreyi ayarla, kategori seç ve odaklan!';

  @override
  String get statusRunning =>
      'Derin odaklanma başlıyor...\nTelefonu ters çevir!';

  @override
  String get statusPaused => 'Duraklatıldı';

  @override
  String get statusFailure => 'ODAK BOZULDU!\nTelefonu kaldırdın.';

  @override
  String get statusSuccessFirst =>
      'TEBRİKLER! İlk aşama tamam.\n1 saatlik odaklanma açıldı!';

  @override
  String get statusSuccess => 'Tebrikler! Oturum tamamlandı.';

  @override
  String get statusBreak => 'Dinlenme zamanı...\nİyi molalar!';

  @override
  String get catWork => 'Çalışma';

  @override
  String get catStudy => 'Ders Çalışma';

  @override
  String get catReading => 'Okuma';

  @override
  String get catMeditation => 'Meditasyon';

  @override
  String get catExercise => 'Egzersiz';

  @override
  String get catCreative => 'Yaratıcı İş';

  @override
  String get catBreak => 'Mola';

  @override
  String get catOther => 'Diğer';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get enterEmailPassword => 'Lütfen e-posta ve şifrenizi girin';

  @override
  String get welcome => 'Hoş Geldiniz';

  @override
  String get startFocusingToday => 'Odaklanmaya ve üretkenliğe bugün başlayın.';

  @override
  String get enterYourPassword => 'Şifrenizi giriniz';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu? ';

  @override
  String get forgotPasswordDialog =>
      'Şifrenizi unuttuğunuz için yeni bir hesap oluşturmanız gerekecek. Emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get fillAllFields => 'Lütfen tüm alanları doldurun';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get createNewAccount => 'Yeni Hesap Oluştur';

  @override
  String get nameSurname => 'Ad Soyad';

  @override
  String get enterNameSurname => 'Adınızı ve soyadınızı girin';

  @override
  String get agreeTerms =>
      'Kayıt olarak Kullanım Koşulları\'nı ve Gizlilik Politikası\'nı kabul etmiş olursunuz.';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabınız var mı? ';

  @override
  String get accountInfoTitle => 'HESAP BİLGİLERİ';

  @override
  String get focusSummary => 'ODAKLANMA ÖZETİ';

  @override
  String get total => 'Toplam';

  @override
  String get successful => 'Başarılı';

  @override
  String get cancelled => 'Vazgeçilen';

  @override
  String get totalTime => 'Toplam Süre';

  @override
  String session(num count) {
    return 'Oturum';
  }

  @override
  String get earnedBadges => 'KAZANILAN ROZETLER';

  @override
  String get successAnalysis => 'BAŞARI ANALİZİ';

  @override
  String get sessionHistory => 'OTURUM GEÇMİŞİ';

  @override
  String get detailedCharts => 'DETAYLI GRAFİKLER';

  @override
  String get logout => 'ÇIKIŞ YAP';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get delete => 'SİL';

  @override
  String get cancelBtn => 'İptal';

  @override
  String get successRate => 'Başarı Oranı';

  @override
  String get dailyStreak => 'GÜNLÜK SERİ';

  @override
  String day(num count) {
    return 'GÜN';
  }

  @override
  String get badgeEarlyBird => 'Erkenci Kuş';

  @override
  String get badgeMarathoner => 'Maratoncu';

  @override
  String get badgeMaster => 'Usta Odaklanıcı';

  @override
  String get user => 'Kullanıcı';

  @override
  String get settingsTitle => 'AYARLAR';

  @override
  String get sectionVoiceNotification => 'SES VE BİLDİRİM';

  @override
  String get alarmSound => 'Alarm Sesi';

  @override
  String get vibration => 'Titreşim';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get sectionFocusSettings => 'ODAKLANMA AYARLARI';

  @override
  String get defaultDuration => 'Varsayılan Süre';

  @override
  String mins(Object minutes) {
    return '$minutes dakika';
  }

  @override
  String get sectionAccountSettings => 'HESAP AYARLARI';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get updatePasswordSubtitle => 'Hesap şifrenizi güncelleyin';

  @override
  String get passwordSecureNote =>
      'Not: Şifreniz güvenli bir şekilde saklanır.';

  @override
  String get sectionDataManagement => 'VERİ YÖNETİMİ';

  @override
  String get backupData => 'Verileri Yedekle';

  @override
  String get exportDataSubtitle => 'Verilerinizi dışa aktarın';

  @override
  String get restoreData => 'Geri Yükle';

  @override
  String get importDataSubtitle => 'Yedekten verileri yükleyin';

  @override
  String get resetStatistics => 'İstatistikleri Sıfırla';

  @override
  String get resetStatsSubtitle => 'Tüm oturum verilerini temizleyin';

  @override
  String get sectionApplication => 'UYGULAMA';

  @override
  String get shareWithFriends => 'Arkadaşlarınla Paylaş';

  @override
  String get shareSubtitle => 'WhatsApp veya diğer uygulamalarla paylaşın';

  @override
  String version(Object version) {
    return 'Versiyon $version';
  }

  @override
  String get historyTitle => 'OTURUM GEÇMİŞİ';

  @override
  String get noHistoryYet => 'Henüz kaydedilmiş bir oturum yok';

  @override
  String get startFocusNow => 'Hemen odaklanmaya başla ve ilk kaydını oluştur!';

  @override
  String get startFocusingBtn => 'Odaklanmaya Başla';

  @override
  String get weeklyGoalSuccess => 'HAFTALIK HEDEF TAMAM!';

  @override
  String get weeklyGoalFailed => 'HEDEFE ULAŞILAMADI';

  @override
  String weeklyMinutesNote(Object hours, Object minutes) {
    return 'Bu hafta toplam $hours saat $minutes dakika odaklandın.';
  }

  @override
  String moreMinutesRequired(Object minutes) {
    return '$minutes dakika daha gerekli!';
  }

  @override
  String get today => 'BUGÜN';

  @override
  String get yesterday => 'DÜN';

  @override
  String get successLabel => 'BAŞARILI';

  @override
  String get failedLabel => 'YARIM KALDI';

  @override
  String get timeAgoJustNow => 'Az önce';

  @override
  String timeAgoMinutes(Object minutes) {
    return '$minutes dk önce';
  }

  @override
  String timeAgoHours(Object hours) {
    return '$hours saat önce';
  }

  @override
  String timeAgoDays(Object days) {
    return '$days gün önce';
  }

  @override
  String get statisticsTitle => 'İSTATİSTİKLER';

  @override
  String get categoryDistribution => 'KATEGORİ DAĞILIMI';

  @override
  String get weeklyActivity => 'SON 7 GÜN AKTİVİTE';

  @override
  String get timeDistribution => 'ZAMAN DAĞILIMI';

  @override
  String get noDataYet => 'Henüz veri yok';

  @override
  String get successfulSessions => 'Tamamlanan';

  @override
  String get cancelledSessionsCount => 'Vazgeçilen';

  @override
  String get activeDaysCount => 'Aktif Günler';

  @override
  String get hoursShort => 's';

  @override
  String get minutesShort => 'dk';

  @override
  String hoursLong(Object hours) {
    return '$hours saat';
  }

  @override
  String minutesLong(Object minutes) {
    return '$minutes dakika';
  }

  @override
  String get sectionAppearance => 'GÖRÜNÜM';

  @override
  String get darkMode => 'Koyu Tema';

  @override
  String get notifSuccessTitle => 'Tebrikler!';

  @override
  String get notifSuccessBody =>
      'Odaklanma oturumu başarıyla tamamlandı. Harikasın!';

  @override
  String get notifBreakEndTitle => 'Mola Bitti!';

  @override
  String get notifBreakEndBody => 'Yeni bir odaklanma seansına hazırsın.';

  @override
  String get onboardingWelcome => 'TScan\'a Hoş Geldiniz';

  @override
  String get onboardingWelcomeDesc =>
      'En iyi deneyim için odaklanma ortamınızı ayarlayalım.';

  @override
  String get onboardingSensorTitle => 'Sensör Erişimi';

  @override
  String get onboardingSensorDesc =>
      'TScan, telefonunuzun ters çevrildiğini algılamak için ivmeölçeri kullanır. Bu odaklanmanıza yardımcı olur!';

  @override
  String get onboardingDndTitle => 'Rahatsız Etme';

  @override
  String get onboardingDndDesc =>
      'Dikkat dağıtıcı bildirimleri engellemek için Rahatsız Etme modunu yönetme iznine ihtiyacımız var.';

  @override
  String get onboardingPhoneTitle => 'Arama Algılama';

  @override
  String get onboardingPhoneDesc =>
      'Odaklanma sırasında bir arama gelirse, karar vermeniz için otomatik olarak duraklatacağız.';

  @override
  String get btnGrant => 'İzin Ver';

  @override
  String get btnNext => 'İLERİ';

  @override
  String get btnBack => 'GERİ';

  @override
  String get btnStart => 'BAŞLAYALIM';

  @override
  String get permissionGranted => 'İzin Verildi';

  @override
  String get permissionDenied => 'İzin Reddildi';

  @override
  String get tutorialTitle => 'Uygulama Rehberi';

  @override
  String get tutorialSubtitle => 'Tanıtım ekranlarını tekrar göster';
}
