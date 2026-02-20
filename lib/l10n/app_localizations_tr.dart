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
}
