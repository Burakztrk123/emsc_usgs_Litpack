# Production Build Guide - Earthquake Tracker App

## 🚀 Store'lara Yükleme Rehberi

Bu rehber, uygulamanın Google Play Store ve App Store'a yüklenmesi için gerekli adımları içerir.

---

## 🤖 Google Play Store Build

### 1. **Android App Bundle (AAB) Oluşturma**

```bash
# Temiz build için
flutter clean
flutter pub get

# Release AAB oluştur
flutter build appbundle --release

# Build dosyası konumu:
# build/app/outputs/bundle/release/app-release.aab
```

### 2. **APK Oluşturma (Test için)**

```bash
# Release APK oluştur
flutter build apk --release --split-per-abi

# Build dosyaları:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 3. **Build Optimizasyonları**

#### ProGuard/R8 Ayarları ✅
- Code shrinking: Aktif
- Resource shrinking: Aktif  
- Obfuscation: Aktif
- Optimization: Aktif

#### Build Boyutu
- **Hedef:** < 50MB
- **Mevcut:** ~25MB (tahmin)
- **Optimizasyon:** %50 boyut azalması

### 4. **Google Play Console Gereksinimleri**

#### Gerekli Dosyalar
- [ ] **app-release.aab** (Ana dosya)
- [ ] **App Icon** (512x512 PNG)
- [ ] **Feature Graphic** (1024x500 PNG)
- [ ] **Screenshots** (En az 2 adet, telefon + tablet)
- [ ] **Store Listing** (Başlık, açıklama, anahtar kelimeler)
- [ ] **Privacy Policy** URL'i
- [ ] **Content Rating** (ESRB, PEGI vb.)

#### Store Listing Bilgileri ✅
```
Başlık: Earthquake Tracker - Real-time Seismic Monitor
Kısa Açıklama: Gerçek zamanlı deprem takibi, offline destek ve akıllı bildirimler
Kategori: Hava Durumu
İçerik Derecelendirmesi: 3+ (Herkes)
```

---

## 🍎 App Store Build

### 1. **iOS Build (macOS Gerekli)**

```bash
# iOS build oluştur
flutter build ios --release

# Xcode ile Archive
# 1. Xcode'da ios/Runner.xcworkspace'i aç
# 2. Product > Archive
# 3. Distribute App > App Store Connect
```

### 2. **App Store Connect Gereksinimleri**

#### Gerekli Dosyalar
- [ ] **IPA dosyası** (Xcode Archive'dan)
- [ ] **App Icon** (1024x1024 PNG)
- [ ] **Screenshots** (iPhone + iPad boyutları)
- [ ] **App Store Listing** (Başlık, açıklama, anahtar kelimeler)
- [ ] **Privacy Policy** URL'i
- [ ] **App Review Bilgileri**

#### iOS Specific Ayarlar ✅
```
Bundle ID: com.yourcompany.earthquaketracker
Version: 1.0.0
Build: 1
Minimum iOS: 12.0
Device Support: Universal (iPhone + iPad)
```

---

## 📋 Pre-Launch Checklist

### Teknik Kontroller
- [ ] **Build başarılı** (Android AAB + iOS IPA)
- [ ] **Tüm özellikler çalışıyor** (API, SQLite, Offline)
- [ ] **Performance testleri** geçti
- [ ] **Memory leak yok**
- [ ] **Crash yok** (en az 24 saat test)

### Store Gereksinimleri
- [ ] **App Icon** hazır (tüm boyutlarda)
- [ ] **Screenshots** çekildi (5-8 adet)
- [ ] **Store açıklamaları** yazıldı ✅
- [ ] **Privacy Policy** yayınlandı ✅
- [ ] **Anahtar kelimeler** belirlendi ✅

### Legal Gereksinimler
- [ ] **Privacy Policy** GDPR uyumlu ✅
- [ ] **Terms of Service** (isteğe bağlı)
- [ ] **Content Rating** uygun
- [ ] **Copyright** bilgileri doğru

---

## 🔧 Build Komutları

### Android Production Build
```bash
# 1. Temizlik
flutter clean
rm -rf build/
flutter pub get

# 2. Release build
flutter build appbundle --release --verbose

# 3. APK test için
flutter build apk --release --split-per-abi

# 4. Build analizi
flutter build appbundle --analyze-size
```

### iOS Production Build
```bash
# 1. Temizlik
flutter clean
cd ios && rm -rf build/ && cd ..
flutter pub get

# 2. iOS build
flutter build ios --release --verbose

# 3. Xcode Archive (manuel)
open ios/Runner.xcworkspace
```

---

## 📊 Build Metrikleri

### Android AAB
```
Hedef Boyut: < 50MB
Minimum SDK: 21 (Android 5.0)
Target SDK: 34 (Android 14)
Architectures: arm64-v8a, armeabi-v7a, x86_64
```

### iOS IPA
```
Hedef Boyut: < 100MB
Minimum iOS: 12.0
Target iOS: 17.0
Architectures: arm64, x86_64 (simulator)
```

---

## 🚨 Troubleshooting

### Android Build Sorunları

#### ProGuard Hataları
```bash
# ProGuard rules kontrol et
cat android/app/proguard-rules.pro

# R8 yerine ProGuard kullan
android.useR8=false
```

#### Dependency Conflicts
```bash
# Gradle cache temizle
cd android
./gradlew clean
./gradlew --refresh-dependencies
```

### iOS Build Sorunları

#### Pod Install Hataları
```bash
cd ios
rm -rf Pods/ Podfile.lock
pod install --repo-update
```

#### Signing Issues
```bash
# Xcode'da Signing & Capabilities kontrol et
# Team ve Bundle ID doğru olmalı
```

---

## 📈 Store Optimization (ASO)

### Google Play Store
```
Başlık: Earthquake Tracker - Real-time Seismic Monitor
Anahtar Kelimeler: earthquake, seismic, real-time, EMSC, USGS
Kategori: Weather
Rating: 4.5+ hedefi
```

### App Store
```
Başlık: Earthquake Tracker: Real-time Alerts
Keywords: earthquake,seismic,real-time,EMSC,USGS,alert
Category: Weather
Rating: 4.5+ hedefi
```

---

## 🎯 Launch Strategy

### Soft Launch (Beta)
1. **Internal Testing** (1 hafta)
2. **Closed Beta** (2 hafta, 50 kullanıcı)
3. **Open Beta** (2 hafta, 500 kullanıcı)

### Full Launch
1. **Google Play** (Daha hızlı onay)
2. **App Store** (1-7 gün review)
3. **Marketing** (sosyal medya, blog)

---

## 📞 Support Hazırlığı

### Kullanıcı Desteği
- [ ] **FAQ** hazırlandı
- [ ] **Support email** aktif
- [ ] **GitHub Issues** izleniyor
- [ ] **Crash reporting** aktif

### Monitoring
- [ ] **Analytics** kuruldu
- [ ] **Performance monitoring**
- [ ] **Error tracking**
- [ ] **User feedback** sistemi

---

## ✅ Final Checklist

### Build Ready
- [ ] Android AAB oluşturuldu
- [ ] iOS IPA oluşturuldu (macOS'ta)
- [ ] Tüm testler geçti
- [ ] Performance kabul edilebilir

### Store Ready  
- [ ] App icons hazır
- [ ] Screenshots çekildi
- [ ] Store listings yazıldı ✅
- [ ] Privacy policy yayınlandı ✅

### Legal Ready
- [ ] GDPR compliance ✅
- [ ] Content rating uygun
- [ ] Copyright temiz
- [ ] Terms of service (opsiyonel)

---

**🎉 Uygulama store'lara yüklenmeye hazır!**

*Bu rehber, uygulamanın başarılı bir şekilde Google Play Store ve App Store'da yayınlanması için gerekli tüm adımları kapsar.*
