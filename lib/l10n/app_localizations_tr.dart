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
  String get statusIdleLvl1 => '30 saniyelik testi tamamla ve\ngerçek odaklanmaya başla!';

  @override
  String get statusIdle => 'Süreyi ayarla, kategori seç ve odaklan!';

  @override
  String get statusRunning => 'Derin odaklanma başlıyor...\nTelefonu ters çevir!';

  @override
  String get statusPaused => 'Duraklatıldı';

  @override
  String get statusFailure => 'ODAK BOZULDU!\nTelefonu kaldırdın.';

  @override
  String get statusSuccessFirst => 'TEBRİKLER! İlk aşama tamam.\n1 saatlik odaklanma açıldı!';

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
  String get forgotPasswordDialog => 'Şifrenizi unuttuğunuz için yeni bir hesap oluşturmanız gerekecek. Emin misiniz?';

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
  String get agreeTerms => 'Kayıt olarak Kullanım Koşulları\'nı ve Gizlilik Politikası\'nı kabul etmiş olursunuz.';

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
  String get deleteAccountConfirm => 'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

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
  String get passwordSecureNote => 'Not: Şifreniz güvenli bir şekilde saklanır.';

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
  String get notifSuccessBody => 'Odaklanma oturumu başarıyla tamamlandı. Harikasın!';

  @override
  String get notifBreakEndTitle => 'Mola Bitti!';

  @override
  String get notifBreakEndBody => 'Yeni bir odaklanma seansına hazırsın.';

  @override
  String get onboardingWelcome => 'TScan\'e Hoş Geldiniz';

  @override
  String get onboardingWelcomeDesc => 'En iyi deneyim için odaklanma ortamınızı ayarlayalım.';

  @override
  String get onboardingSensorTitle => 'Sensör Erişimi';

  @override
  String get onboardingSensorDesc => 'TScan, telefonunuzun ters çevrildiğini algılamak için ivmeölçeri kullanır. Bu odaklanmanıza yardımcı olur!';

  @override
  String get onboardingDndTitle => 'Rahatsız Etme';

  @override
  String get onboardingDndDesc => 'Dikkat dağıtıcı bildirimleri engellemek için Rahatsız Etme modunu yönetme iznine ihtiyacımız var.';

  @override
  String get onboardingPhoneTitle => 'Arama Algılama';

  @override
  String get onboardingPhoneDesc => 'Odaklanma sırasında bir arama gelirse, karar vermeniz için otomatik olarak duraklatacağız.';

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

  @override
  String get addSessionNoteTitle => 'Ne üzerine odaklandın?';

  @override
  String get sessionNoteHint => 'örn: matematik çalışmak, kodlama';

  @override
  String get sessionNoteLabel => 'Oturum Notu';

  @override
  String get saveBtn => 'Kaydet';

  @override
  String get dailyGoalSetting => 'Günlük Odaklanma Hedefi';

  @override
  String get dailyGoalSubtitle => 'Günlük hedef odaklanma süresi';

  @override
  String get dailyGoalReached => 'GÜNLÜK ODAKLANMA HEDEFİ TAMAM! 🎉';

  @override
  String get dailyGoalProgress => 'Günlük Hedef İlerlemesi';

  @override
  String dailyMinutesFocused(int minutes, int goal) {
    return '$minutes / $goal dakika';
  }

  @override
  String dailyGoalRemaining(Object minutes) {
    return 'Hedefine ulaşmak için $minutes dakika kaldı!';
  }

  @override
  String get pdfStudyTitle => 'PDF Çalışma';

  @override
  String get pdfDestekliCalisma => 'AI Destekli PDF Çalışma';

  @override
  String get pdfYukleAciklama => 'Ders notlarını yükle, AI okuma süresini tahmin etsin.\nSüre bitince seni test etsin! 🚀';

  @override
  String get pdfStep1 => 'PDF Yükle';

  @override
  String get pdfStep2 => 'AI Analiz Etsin';

  @override
  String get pdfStep3 => 'Odaklan & Oku';

  @override
  String get pdfStep4 => 'Quiz ile Test Ol';

  @override
  String get pdfDosyaSec => 'PDF Dosyası Seç';

  @override
  String get sonCalisilanBelgeler => 'Son Çalışılan Belgeler';

  @override
  String get temizle => 'Temizle';

  @override
  String get tekrarCalis => 'Tekrar Çalış';

  @override
  String get sil => 'Sil';

  @override
  String get premiumOzellik => 'Premium Özellik';

  @override
  String get premiumCalismaAsistani => 'AI ile süre tahmini ve sınav üretme gibi gelişmiş çalışma asistanı özelliklerini kullanabilmek için Premium üye olmalısınız.';

  @override
  String get premiumYukselt => 'Premium\'a Yükselt 🚀';

  @override
  String get pdfSeciliyor => 'PDF dosyası seçiliyor...';

  @override
  String get pdfOkunuyor => '📄 PDF okunuyor...';

  @override
  String get aiAnalizEdiyor => '🤖 AI metin analiz ediyor...';

  @override
  String get onboardingPdfTitle => 'Yapay Zeka ve PDF Modu';

  @override
  String get onboardingPdfDesc => 'Ders notlarınızı yükleyin; TScan yapay zekası ideal çalışma sürenizi hesaplasın, siz odaklanırken odanızı sessize alsın ve seans bitiminde sizi akıllı testlerle sınasın!';

  @override
  String get onboardingPdfExtra => 'Akıllı Okuma & AI Quiz Modu';

  @override
  String get aiAnalizSonuclari => 'Yapay Zeka Analiz Sonuçları';

  @override
  String get dersAdi => 'Ders / Konu';

  @override
  String get zorlukDerecesi => 'Zorluk Derecesi';

  @override
  String get tahminiOkumaSuresi => 'Tahmini Okuma Süresi';

  @override
  String tahminiSureDk(int minutes) {
    return '$minutes dakika';
  }

  @override
  String get tscanOnerisi => 'TScan Önerisi';

  @override
  String get calismayiBaslat => 'Çalışmayı Başlat ⏱️';

  @override
  String get pdfGizlilikOnayiTitle => 'KVKK ve Bulut Analiz Onayı';

  @override
  String get pdfGizlilikOnayiBody => 'Yüklediğiniz PDF\'in metin içeriği, süre tahmini ve quiz üretimi amacıyla güvenli bağlantı üzerinden yapay zeka servisine (Google Gemini) gönderilir. Kişisel verilerinizin buluta gönderilmesini onaylıyor musunuz?';

  @override
  String get onayla => 'Onayla';

  @override
  String get reddet => 'Reddet';

  @override
  String get aiQuizBaslat => 'AI Quiz Başlat';

  @override
  String get akilliSoruModu => 'Seans bitti! AI soruları çözmeye hazır mısınız?';

  @override
  String get quizBasligi => 'Yapay Zeka Değerlendirme Testi';

  @override
  String soruSayisi(int current, int total) {
    return 'Soru $current / $total';
  }

  @override
  String get quiziBitir => 'Testi Bitir';

  @override
  String get quizSonuclari => 'Test Sonuçları';

  @override
  String basariSkoru(int score) {
    return 'Başarı Skoru: %$score';
  }

  @override
  String dogruSoruSayisi(int correct, int total) {
    return 'Doğru: $correct / $total';
  }

  @override
  String get odaklanmayaDon => 'Odaklanmaya Dön';

  @override
  String get farkliSureSec => 'Farklı süre seç';

  @override
  String get sureSec => 'Süre Seç';

  @override
  String get dakika => 'dakika';

  @override
  String get aiSorulariHazirliyor => '🤖 AI sorularını hazırlıyor...';

  @override
  String get buBirkacSaniyeSurebilir => 'Bu birkaç saniye sürebilir';

  @override
  String get quizYuklenemedi => 'Quiz yüklenemedi';

  @override
  String get tekrarDene => 'Tekrar Dene';

  @override
  String get sonrakiSoru => 'Sonraki Soru';

  @override
  String get sonuclariGor => 'Sonuçları Gör';

  @override
  String get aiYanlisAnalizi => '🤖 AI yanlışlarını analiz ediyor...';

  @override
  String get aiKocAnalizi => 'AI Koç Analizi';

  @override
  String get soruDetaylari => 'Soru Detayları';

  @override
  String get anaSayfayaDon => 'Ana Sayfaya Dön';

  @override
  String soruNo(int number) {
    return 'Soru $number';
  }

  @override
  String seninCevabin(String answer) {
    return 'Senin cevabın: $answer';
  }

  @override
  String dogruCevap(String answer) {
    return 'Doğru cevap: $answer';
  }

  @override
  String get muhtesemKonuyaHakimsin => 'Muhteşem! Konuya hakimsin!';

  @override
  String get iyiGidiyorsunTekrar => 'İyi gidiyorsun, biraz daha tekrar!';

  @override
  String get gelismeAlaninVar => 'Gelişme alanın var, tekrar oku';

  @override
  String get tekrarCalismalisin => 'Metin üzerinde tekrar çalışmalısın';

  @override
  String get pdfCalismasi => 'PDF Çalışması';

  @override
  String get tamamlananQuiz => 'Tamamlanan Quiz';

  @override
  String get ortalamaQuizBasarisi => 'Ortalama Quiz Başarısı';

  @override
  String get oturum => 'oturum';

  @override
  String get sinav => 'sınav';

  @override
  String get basariOrani => 'başarı oranı';

  @override
  String get okumaHizi => 'Kişisel Okuma Hızı';

  @override
  String get okumaHiziAciklama => 'Premium ile AI süre tahminlerini okuma hızınıza göre uyarlayın.';

  @override
  String get hizYavas => 'Yavaş';

  @override
  String get hizNormal => 'Normal';

  @override
  String get hizHizli => 'Hızlı';

  @override
  String get navHome => 'Anasayfa';

  @override
  String get navAiQuest => 'AI Quest';

  @override
  String get navAccount => 'Hesap';

  @override
  String get aiQuestSubtitle => 'PDF yükle, AI ile quiz çöz';

  @override
  String get aiQuestUploadTitle => '📄 PDF Yükle & Çalış';

  @override
  String get aiQuestUploadDesc => 'Belge yükle, AI analiz etsin ve quiz oluştursun';

  @override
  String get aiQuestNoDocs => 'Henüz belge yok';

  @override
  String get aiQuestNoDocsDesc => 'İlk PDF\'ini yükleyerek AI destekli\nçalışmaya başla!';

  @override
  String get aiQuestRecentDocs => '📚 Son Çalışılan Belgeler';

  @override
  String get aiQuestClear => 'Temizle';

  @override
  String get aiQuestClearConfirm => 'Tüm belgeler geçmişten silinsin mi?';

  @override
  String aiQuestDeleteConfirm(String name) {
    return '\"$name\" geçmişten silinsin mi?';
  }

  @override
  String aiQuestDocMeta(int minutes, int pages) {
    return '$minutes dk • $pages Sayfa';
  }

  @override
  String get gizlilikKontrol => 'Gizlilik onayı kontrol ediliyor...';

  @override
  String get apiKey401Hata => 'API anahtarı reddedildi. Lütfen geçerli bir Gemini API anahtarı gir; kayıtlı anahtar temizlendi.';

  @override
  String get navStats => 'İstatistik';

  @override
  String get navHistory => 'Geçmiş';

  @override
  String get activityIntensity => 'AKTİVİTE YOĞUNLUĞU';

  @override
  String timeAgoWeeks(int weeks) {
    return '$weeks hafta önce';
  }

  @override
  String timeAgoMonths(int months) {
    return '$months ay önce';
  }

  @override
  String timeAgoYears(int years) {
    return '$years yıl önce';
  }

  @override
  String minutesValue(int minutes) {
    return '$minutes dk';
  }

  @override
  String aiQuestAllDocs(int count) {
    return 'Tüm Belgeler ($count)';
  }

  @override
  String get allDocsTitle => 'TÜM BELGELER';

  @override
  String freePdfRemaining(int count) {
    return '$count ücretsiz PDF hakkın kaldı';
  }

  @override
  String get freeLimitReachedTitle => 'Ücretsiz hakkın doldu';

  @override
  String get freeLimitReachedBody => '2 ücretsiz PDF hakkını kullandın. Sınırsız PDF ve AI quiz için Premium\'a geç.';

  @override
  String get statsTotalStudy => 'Toplam çalışma';

  @override
  String get statsThisWeek => 'Bu hafta';

  @override
  String statsWeeklyGoal(int hours) {
    return 'Haftalık hedef: $hours saat';
  }

  @override
  String get statsStreak => 'Gün serisi';

  @override
  String get statsSessions => 'Biten oturum';

  @override
  String get statsSuccess => 'Başarı';

  @override
  String get statsQuizAvg => 'Quiz ortalaması';

  @override
  String get statsDailyMinutes => 'SON 7 GÜN (DAKİKA)';

  @override
  String get statsBySubject => 'DERSLERE GÖRE SÜRE';

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String get paywallTitle => 'TScan Premium';

  @override
  String get paywallSubtitle => 'Sınırsız PDF ve AI çalışma koçuyla daha akıllı çalış';

  @override
  String get planMonthly => 'Aylık';

  @override
  String get planYearly => 'Yıllık';

  @override
  String get planPerMonth => '/ ay';

  @override
  String get planPerYear => '/ yıl';

  @override
  String get planMonthlyNote => 'İstediğin zaman iptal et';

  @override
  String get planYearlyNote => 'Ayda sadece 50 TL — %83 tasarruf';

  @override
  String get planBestValue => 'EN AVANTAJLI';

  @override
  String get subscribeNow => 'Şimdi Abone Ol';

  @override
  String premiumActiveUntil(String date) {
    return 'Premium $date tarihine kadar aktif';
  }

  @override
  String get premiumActivatedTitle => '🎉 Premium Aktif!';

  @override
  String get premiumActivatedBody => 'Artık tüm özelliklere sınırsız erişimin var. İyi çalışmalar!';

  @override
  String get greatBtn => 'Harika!';

  @override
  String get paywallTerms => 'Aboneliğini istediğin zaman Play Store ayarlarından iptal edebilirsin.';

  @override
  String get benefitUnlimitedPdf => 'Sınırsız PDF';

  @override
  String get benefitUnlimitedPdfDesc => 'İstediğin kadar ders notu ve kitap yükle.';

  @override
  String get benefitAiQuiz => 'AI quiz ve çalışma süresi';

  @override
  String get benefitAiQuizDesc => 'Her PDF için otomatik quiz ve okuma süresi.';

  @override
  String get benefitWrongAnswers => 'Yanlış cevap analizi';

  @override
  String get benefitWrongAnswersDesc => 'Her quizden sonra tekrar etmen gereken konuları gör.';

  @override
  String get benefitSounds => 'Tüm odak sesleri';

  @override
  String get benefitSoundsDesc => 'Yağmur, orman, kafe ve daha fazlası.';

  @override
  String get apiKeyDialogTitle => 'Gemini API Anahtarı';

  @override
  String get apiKeyDialogBody => 'AI özelliklerini kullanmak için Google Gemini API anahtarını gir. Ücretsiz anahtarı Google AI Studio\'dan alabilirsin.';

  @override
  String get apiKeyRequired => 'Lütfen anahtarını gir';

  @override
  String get apiKeyInvalidFormat => 'Bu bir Gemini API anahtarına benzemiyor';

  @override
  String get flipPhoneHint => 'Telefonu yüzüstü çevirin';

  @override
  String get autoQuizTitle => '🎉 Tebrikler!';

  @override
  String get autoQuizDone => 'PDF odaklanma seansın başarıyla tamamlandı.';

  @override
  String get autoQuizStarting => 'Öğrendiklerini test etmek için AI Quiz başlıyor...';

  @override
  String get aiErrMissingKey => 'AI özelliklerini kullanmak için Gemini API anahtarını ekle.';

  @override
  String get aiErrBusy => 'AI servisi şu an yoğun. Birkaç dakika sonra tekrar dene.';

  @override
  String get aiErrRateLimit => 'AI kullanım limitine ulaşıldı. Biraz sonra tekrar dene.';

  @override
  String get aiErrNetwork => 'İnternet bağlantısı yok. Bağlantını kontrol edip tekrar dene.';

  @override
  String get aiErrFileMissing => 'PDF dosyası bu cihazda bulunamadı.';

  @override
  String get aiErrBadResponse => 'AI soruları hazırlayamadı. Lütfen tekrar dene.';

  @override
  String get aiErrGeneric => 'AI servisinde bir sorun oldu. Lütfen tekrar dene.';

  @override
  String get enterApiKeyBtn => 'API anahtarı gir';

  @override
  String get apiKeyWhere => 'Ücretsiz anahtar: aistudio.google.com/apikey';

  @override
  String pagesWords(int pages, int words) {
    return '$pages sayfa • $words kelime';
  }

  @override
  String get aiErrUnavailable => 'AI şu an kullanılamıyor. Lütfen daha sonra tekrar dene.';

  @override
  String get olderSessionsTitle => 'ESKİ OTURUMLAR';

  @override
  String olderSessionsBtn(int count) {
    return 'Eski oturumlar ($count)';
  }

  @override
  String get noRecentSessions => 'Son 7 günde oturum yok';
}
