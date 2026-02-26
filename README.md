# 🎯 TScan

**Odaklanmanızı artırmak için tasarlanmış akıllı zamanlayıcı uygulaması**

![Flutter](https://img.shields.io/badge/Flutter-3.10.8-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20Web-brightgreen)

---

## ✨ Özellikler

### 🧠 **Akıllı Zamanlayıcı**
- ⏱️ Özelleştirilebilir odaklanma süreleri
- 📊 Seviye bazlı ilerleme sistemi
- 🎯 Pomodoro tekniği desteği

### 📱 **Akıllı Telefon Koruması**
- 🔒 **Sensör Teknolojisi**: Telefonu kaldırdığınızda algılar ve uyarır
- 📞 **Arama Kontrolü**: Gelen çağrılarda zamanlayıcıyı durdurur
- 🚫 **Uygulama Takibi**: Arka plana geçişte uyarı verir
- 🔕 **Rahatsız Etmeyin Modu**: Otomatik DND aktivasyonu

### 📈 **İstatistikler & Rozetler**
- 📊 Detaylı odaklanma istatistikleri
- 🔥 Günlük seri takibi (streak)
- 🏆 Başarı rozetleri sistemi
  - 🐦 **Erkenci Kuş**: Sabah 9'dan önce odaklan
  - 🏃 **Maratoncu**: 180+ dakika toplam odaklanma
  - ⭐ **Usta Odaklanıcı**: 10+ tamamlanmış oturum

### 🎵 **Özelleştirilebilir Ayarlar**
- 🔊 6 farklı alarm sesi seçeneği
- 📳 Titreşim kontrolü
- 🎨 Dark mode arayüz
- ⚙️ Kişiselleştirilmiş odaklanma süreleri

---

## 🚀 Nasıl Kullanılır?

### 📥 **Kurulum**

#### **1. Kaynak Koddan Çalıştırma** (Geliştiriciler için)

**Gereksinimler:**
- Flutter SDK (>= 3.10.8)
- Dart SDK
- Android Studio / VS Code
- Git

**Adımlar:**

```bash
# 1. Projeyi klonlayın
git clone https://github.com/AHMETfarah22/tscan.git
cd tscan

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Uygulamayı çalıştırın
flutter run

# Veya platform seçerek:
flutter run -d windows    # Windows
flutter run -d android    # Android
flutter run -d chrome     # Web
```

#### **2. Hazır APK/EXE İndirme** (Kullanıcılar için)

**Android APK:**
- [GitHub Releases](https://github.com/AHMETfarah22/tscan/releases) sayfasından `app-release.apk` indirin
- Telefonunuzda "Bilinmeyen Kaynaklardan Yükleme"yi aktifleştirin
- APK'yı yükleyin ve kullanmaya başlayın

**Windows EXE:**
- [GitHub Releases](https://github.com/AHMETfarah22/tscan/releases) sayfasından Windows sürümünü indirin
- ZIP dosyasını çıkartın
- `tscan.exe` dosyasını çalıştırın

---

## 🎮 **Kullanım Kılavuzu**

1. **Kayıt Olun/Giriş Yapın**: İlk açılışta hesap oluşturun
2. **Süre Seçin**: İstediğiniz odaklanma süresini ayarlayın
3. **Başlat**: Timer'ı başlatın
4. **Telefonu Yüzüstü Bırakın**: Telefonu masaya yüzüstü koyun
5. **Odaklanın**: Telefona dokunmadan çalışın!
6. **Başarıyla Tamamlayın**: Süre bitince tebrikler! 🎉

⚠️ **Dikkat**: Telefonu kaldırırsanız, arama gelirse veya uygulamadan çıkarsanız zamanlayıcı başarısız olur!

---

## 🛠️ **Teknoloji Stack**

### **Framework**
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### **Ana Paketler**
```yaml
sensors_plus: ^7.0.0        # Telefon sensör kontrolü
audioplayers: ^6.5.1        # Ses çalma
wakelock_plus: ^1.4.0       # Ekran kilit kontrolü
provider: ^6.1.5            # State management
shared_preferences: ^2.5.4  # Yerel veri saklama
vibration: ^3.1.5           # Titreşim kontrolü
phone_state: ^3.0.1         # Telefon durumu takibi
do_not_disturb: ^1.0.3      # DND modu kontrolü
google_fonts: ^8.0.0        # Özel fontlar
percent_indicator: ^4.2.5   # İlerleme göstergeleri
```

### **Mimari**
- **Clean Architecture** prensiplerine uygun
- **Provider Pattern** ile state management
- **Service Layer** ile iş mantığı ayrımı
- **Reactive Programming** (Streams)

---

## 📱 **Desteklenen Platformlar**

| Platform | Durum | Notlar |
|----------|-------|--------|
| Android | ✅ Tam destek | API 21+ gerekli |
| iOS | ✅ Tam destek | iOS 12.0+ |
| Windows | ✅ Tam destek | Windows 10+ |
| Linux | ✅ Tam destek | - |
| macOS | ✅ Tam destek | macOS 10.14+ |
| Web | ⚠️ Kısmi | Sensör desteği sınırlı |

---

## 🔐 **Gizlilik & Güvenlik**

- ✅ **Verileriniz cihazınızda kalır** - Bulut senkronizasyonu yok
- ✅ **Offline çalışır** - İnternet bağlantısı gerektirmez
- ✅ **Güvenli Şifreleme** - Şifreler hash+salt yöntemiyle korunur

---

## 🤝 **Katkıda Bulunma**

Projeye katkıda bulunmak isterseniz:

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi pushlayın (`git push origin feature/AmazingFeature`)
5. Pull Request açın

---

## 📄 **Lisans**

Bu proje özel bir projedir. Kullanım için lütfen iletişime geçin.

---

## 👨‍💻 **Geliştirici**

**AHMET Farah**
- GitHub: [@AHMETfarah22](https://github.com/AHMETfarah22)

---

## 🐛 **Sorun Bildirimi**

Hata bulursanız veya öneriniz varsa:
- [GitHub Issues](https://github.com/AHMETfarah22/tscan/issues) sayfasından bildirebilirsiniz

---

## 📸 **Ekran Görüntüleri**

_(Ekran görüntüleri eklenecek)_

---

## 🎯 **Gelecek Özellikler**

- [ ] Bulut senkronizasyonu (Firebase)
- [ ] Leaderboard (liderlik tablosu)
- [ ] Arkadaş sistemi
- [ ] Daha fazla rozet
- [ ] Tema seçenekleri
- [ ] Widget desteği
- [ ] Wear OS uyumluluğu

---

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!**
