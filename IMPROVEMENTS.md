# Focus Flow - İyileştirme Planı

## 🔴 YÜKSEK ÖNCELİK (Hemen Yapılmalı)

### 1. Session History Görüntüleme Sayfası
**Durum:** Eksik  
**Önem:** Kritik - Kullanıcılar geçmişlerini göremez

**Yapılacaklar:**
- [ ] Session history listesi sayfası oluştur
- [ ] Her session için tarih, süre, durum göster
- [ ] Filtreleme ekle (günlük, haftalık, aylık)
- [ ] Account screen'den session history'ye link ekle

### 2. Şifre Görünürlük Toggle Düzelt
**Durum:** Çalışmıyor  
**Önem:** Kullanıcı deneyimi

**Yapılacaklar:**
- [ ] Login screen'de şifre göster/gizle butonu ekle
- [ ] Register screen'de şifre göster/gizle butonu ekle
- [ ] CommonTextField widget'ına obscureText toggle ekle

### 3. Şifre Güvenliği İyileştir
**Durum:** Güvensiz (düz metin)  
**Önem:** GÜVENLİK RİSKİ

**Yapılacaklar:**
- [ ] `crypto` veya `encrypt` paketi ekle
- [ ] Şifreleri hash'le (örn: SHA-256)
- [ ] Mevcut şifreleri migration yap
- [ ] Salt ekle

### 4. Şifre Değiştirme Özelliği
**Durum:** Yok  
**Önem:** Yüksek - Temel özellik

**Yapılacaklar:**
- [ ] Settings screen'e şifre değiştirme bölümü ekle
- [ ] Eski şifre doğrulama ekle
- [ ] Yeni şifre onay alanı ekle

---

## 🟡 ORTA ÖNCELİK (Yakında Yapılmalı)

### 5. Session Kategorileri
**Yapılacaklar:**
- [ ] Session başlatırken kategori seçimi ekle (Çalışma, Okuma, Meditasyon, vb.)
- [ ] Her kategori için ayrı istatistik göster
- [ ] Kategori bazlı filtreleme

### 6. Session Notları
**Yapılacaklar:**
- [ ] Session tamamlandığında not ekleme imkanı
- [ ] Not görüntüleme geçmişte
- [ ] Not düzenleme/silme

### 7. İstatistik Grafikleri
**Yapılacaklar:**
- [ ] `fl_chart` paketi ekle
- [ ] Haftalık odaklanma grafiği
- [ ] Aylık başarı trendi
- [ ] Kategori dağılım grafiği

### 8. Bildirimler
**Yapılacaklar:**
- [ ] `flutter_local_notifications` paketi ekle
- [ ] Session tamamlandığında bildirim
- [ ] Günlük hatırlatıcı (opsiyonel)
- [ ] Streak hatırlatıcısı

### 9. Dark/Light Mode Toggle
**Yapılacaklar:**
- [ ] Light theme oluştur
- [ ] Settings'e theme seçici ekle
- [ ] Theme değişimini kaydet

### 10. Onboarding/Tutorial
**Yapılacaklar:**
- [ ] İlk kullanımda uygulama rehberi
- [ ] Özellik açıklamaları
- [ ] İzinleri açıklama (sensör, DND, vb.)

---

## 🟢 DÜŞÜK ÖNCELİK (Güzel Olur)

### 11. Sosyal Özellikler
- [ ] Leaderboard (lider tablosu)
- [ ] Arkadaş ekleme
- [ ] Başarı paylaşma

### 12. Hedef Belirleme
- [ ] Günlük hedef belirleme
- [ ] Haftalık hedef takibi
- [ ] Hedef başarı bildirimleri

### 13. Pomodoro Modu
- [ ] 25 dk çalış / 5 dk mola formatı
- [ ] Özelleştirilebilir pomodoro süreleri
- [ ] Uzun mola desteği

### 14. Widget Support
- [ ] Home screen widget
- [ ] Hızlı başlat butonu
- [ ] İstatistik özeti widget

### 15. Export/Backup
- [ ] İstatistikleri CSV olarak export et
- [ ] Verileri yedekle/geri yükle
- [ ] Cloud sync (Firebase)

### 16. Profil Resmi
- [ ] Profil fotoğrafı yükleme
- [ ] Avatar seçenekleri

### 17. Ödül Sistemi
- [ ] Seviye sistemi genişlet
- [ ] Daha fazla rozet ekle  
- [ ] Ödül görselleri ve animasyonlar

### 18. Multi-language Support
- [ ] İngilizce dil desteği
- [ ] Dil seçimi settings'e ekle

---

## 🐛 BİLİNEN BUGLAR

### 1. Timer İlk Başlatmada 1 Saniye Atlayabilir
**Durum:** Minimize bug  
**Çözüm:** `_startTicker()` metodunda immediately decrement yapılıyor, kontrol et

### 2. DND İzni Olmadığında Session Başarısız Olmuyor
**Durum:** İzinsiz çalışıyor ama işlevsiz  
**Çözüm:** İzin kontrolünü başlangıçta yap

---

## 📌 NOTLAR

- Tüm değişikliklerden sonra multi-user desteğini test et
- Her özellik eklendiğinde GitHub'a commit at
- UI/UX tutarlılığını koru (AppColors, tema)
- Performance'ı düzenli test et
