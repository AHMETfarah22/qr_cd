# Focus Flow - İyileştirme Planı

## ✅ TAMAMLANANLAR (Son Güncellemeyle)
- [x] **Session History Sayfası:** Tüm geçmiş verileri günlük gruplanmış halde görüntüleyebilme.
- [x] **Şifre Güvenliği:** `crypto` ve `flutter_secure_storage` kullanılarak hash+salt şifreleme ve güvenli saklama.
- [x] **Şifre Değiştirme:** Ayarlar bölümünden eski şifre doğrulamalı şifre güncelleme.
- [x] **Çoklu Dil Desteği:** İngilizce ve Türkçe dil desteği (L10n).
- [x] **Dark/Light Mode:** Ayarlar üzerinden tema değiştirme ve kalıcı saklama.
- [x] **Gelişmiş İstatistikler:** `fl_chart` ile başarı oranı, kategori dağılımı ve haftalık aktivite grafikleri.
- [x] **Profil Resmi:** Kullanıcı bazlı profil fotoğrafı seçme ve saklama.
- [x] **Veri Yedekleme/Geri Yükleme:** JSON formatında dışa aktarma ve geri yükleme.
- [x] **Kategoriler:** Odaklanma oturumlarını kategorize etme ve kategori bazlı analiz.

---

## 🔴 YÜKSEK ÖNCELİK (Sıradaki Adımlar)

### 1. Onboarding / Tutorial
**Yapılacaklar:**
- [ ] İlk kullanımda uygulama rehberi ekle.
- [ ] İzinleri (Sensör, DND) açıklayan bilgilendirme ekranları.

### 2. DND İzni ve Güvenlik Kontrolü
**Yapılacaklar:**
- [ ] DND izni yoksa kullanıcıyı uyar.
- [ ] Phone State izni eksikliğinde uyarı ver.

---

## 🟡 ORTA ÖNCELİK

### 3. Session Notları
**Yapılacaklar:**
- [ ] Session tamamlandığında kısa not ekleme.
- [ ] Geçmiş sayfasında notları görüntüleme.

### 4. Gelişmiş Hedef Takibi
**Yapılacaklar:**
- [ ] Günlük/Haftalık odaklanma hedefleri belirleme.
- [ ] Hedefe yaklaşınca bildirim gönderme.

### 5. AI Odaklanma Koçu (Yeni Fikir)
**Yapılacaklar:**
- [ ] Gemini API entegrasyonu ile odaklanma verilerini analiz etme.
- [ ] Kullanıcıya özel verimlilik ipuçları sunma.

---

## 🟢 DÜŞÜK ÖNCELİK

### 6. Pomodoro Modu
- [ ] Klasik 25+5 formatı desteği.

### 7. Sosyal Özellikler
- [ ] Arkadaşlarla başarı paylaşma (Paylaş butonu var, genişletilebilir).
- [ ] Basit bir leaderboard sistemi.

### 8. Widget Support
- [ ] Ana ekran için hızlı başlat veya günlük durum widgetı.

---

## 🐛 BİLİNEN BUGLAR
- [ ] Timer ilk başlatmada bazen 1 saniye atlayabiliyor.
- [ ] Bazı cihazlarda arka planda bildirim sesi geç gelebiliyor.

---

## 📌 NOTLAR
- UI/UX artık hem Koyu hem Açık temada tutarlı.
- Dil desteği yeni eklenen özelliklerle güncellenmeli.
