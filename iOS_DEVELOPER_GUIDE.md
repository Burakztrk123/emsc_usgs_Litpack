# 📱 iOS Developer Guide - Earthquake Tracker App

## 🎯 Proje Durumu ve Devam Rehberi

Bu doküman, **Earthquake Tracker Flutter uygulamasının iOS versiyonu** için yazılım mühendislerine yönelik detaylı bir geliştirme rehberidir.

---

## 📋 Mevcut Durum

### ✅ Tamamlanan iOS Yapılandırmaları

#### 1. **Info.plist Yapılandırması** ✅
Dosya: `ios/Runner/Info.plist`

```xml
<!-- Konum İzinleri -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Bu uygulama deprem mesafesi hesaplamak ve size yakın depremleri bildirmek için konumunuzu kullanır.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Bu uygulama arka planda deprem bildirimleri gönderebilmek için konumunuza erişim gerektirir.</string>

<!-- Network Security -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>seismicportal.eu</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
        <key>earthquake.usgs.gov</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>

<!-- Arka Plan İşlemleri -->
<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
    <string>background-processing</string>
</array>
```

#### 2. **Podfile Yapılandırması** ✅
Dosya: `ios/Podfile`

- iOS 12.0+ deployment target
- SQLite desteği (FMDB)
- CoreLocation framework
- Gerekli build settings

#### 3. **AppDelegate.swift Güncellemeleri** ✅
Dosya: `ios/Runner/AppDelegate.swift`

- Arka plan fetch desteği eklendi
- Background processing yapılandırması

---

## 🚀 iOS Geliştirme Ortamı Kurulumu

### Ön Gereksinimler
```bash
# macOS gerekli (iOS geliştirme için)
# Xcode 14.0+ yüklü olmalı
# CocoaPods yüklü olmalı

# CocoaPods kurulumu (eğer yoksa)
sudo gem install cocoapods

# Flutter iOS toolchain kontrolü
flutter doctor
```

### İlk Kurulum Adımları
```bash
# 1. Proje dizinine git
cd path/to/emsc_usgs_Litpack

# 2. Flutter bağımlılıklarını yükle
flutter pub get

# 3. iOS bağımlılıklarını yükle
cd ios
pod install
cd ..

# 4. iOS simülatörde test et
flutter run -d ios
```

---

## 🔧 Yapılması Gereken İşlemler

### 1. **Acil Öncelik - Test ve Debug** 🔴

#### A. iOS Simülatörde Test
```bash
# iOS simülatörü başlat
open -a Simulator

# Uygulamayı çalıştır
flutter run -d ios

# Debug modda çalıştır
flutter run --debug -d ios
```

#### B. Kontrol Edilmesi Gerekenler
- [ ] **SQLite veritabanı** iOS'ta düzgün çalışıyor mu?
- [ ] **Konum servisleri** izin alıyor mu?
- [ ] **API çağrıları** (EMSC/USGS) çalışıyor mu?
- [ ] **Arka plan işlemleri** aktif mi?
- [ ] **Bildirimler** iOS'ta görünüyor mu?

### 2. **Orta Öncelik - Optimizasyon** 🟡

#### A. Performance Tuning
```swift
// AppDelegate.swift'e eklenebilir
override func applicationDidEnterBackground(_ application: UIApplication) {
    // Arka plan optimizasyonları
}

override func applicationWillEnterForeground(_ application: UIApplication) {
    // Foreground optimizasyonları
}
```

#### B. Memory Management
- SQLite bağlantılarının düzgün kapatılması
- HTTP isteklerinin timeout ayarları
- Cache boyut kontrolü

### 3. **Düşük Öncelik - İyileştirmeler** 🟢

#### A. iOS Specific Features
- **Haptic Feedback**: Deprem bildirimleri için
- **Siri Shortcuts**: Hızlı erişim için
- **Widgets**: iOS 14+ widget desteği
- **Dark Mode**: iOS dark mode uyumluluğu

---

## 🐛 Bilinen iOS Sorunları ve Çözümleri

### 1. **CocoaPods Sorunları**
```bash
# Pod cache temizle
pod cache clean --all

# Podfile.lock sil ve yeniden yükle
rm Podfile.lock
pod install

# Workspace'i temizle
rm -rf build/
flutter clean
flutter pub get
cd ios && pod install
```

### 2. **Konum İzni Sorunları**
```swift
// LocationService.swift (oluşturulabilir)
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // İzin verildi
            break
        case .denied, .restricted:
            // İzin reddedildi
            break
        case .notDetermined:
            // Henüz karar verilmedi
            break
        @unknown default:
            break
        }
    }
}
```

### 3. **Arka Plan İşlemleri Sorunları**
```swift
// AppDelegate.swift'e eklenebilir
func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Arka plan veri çekme işlemi
    
    // Flutter engine'i uyandır
    let flutterEngine = FlutterEngine(name: "background")
    flutterEngine.run()
    
    // Background task tamamlandığında
    completionHandler(.newData)
}
```

---

## 📊 Test Senaryoları

### 1. **Functional Testing**
```bash
# Test komutları
flutter test
flutter integration_test

# iOS specific testler
cd ios
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 14'
```

### 2. **Manual Test Checklist**
- [ ] Uygulama başlatma
- [ ] Konum izni alma
- [ ] API'den veri çekme
- [ ] SQLite'a veri kaydetme
- [ ] Offline modda çalışma
- [ ] Arka plan bildirimleri
- [ ] Harita görünümü
- [ ] Grafik gösterimleri

---

## 🔄 CI/CD Pipeline (Öneriler)

### GitHub Actions Workflow
```yaml
# .github/workflows/ios.yml
name: iOS Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  ios:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Setup iOS
      run: |
        cd ios
        pod install
    
    - name: Build iOS
      run: flutter build ios --no-codesign
    
    - name: Run tests
      run: flutter test
```

---

## 📱 App Store Hazırlığı

### 1. **Bundle Identifier**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourcompany.earthquaketracker</string>
```

### 2. **App Icons**
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Tüm boyutlarda icon'lar gerekli (20x20'den 1024x1024'e)

### 3. **Launch Screen**
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- Splash screen tasarımı

### 4. **Privacy Policy**
- Konum verisi kullanımı için gerekli
- App Store Connect'te belirtilmeli

---

## 🔐 Güvenlik Kontrolleri

### 1. **API Keys**
```dart
// lib/config/api_keys.dart (oluşturulabilir)
class ApiKeys {
  static const String emscApiKey = String.fromEnvironment('EMSC_API_KEY');
  static const String usgsApiKey = String.fromEnvironment('USGS_API_KEY');
}
```

### 2. **Certificate Pinning**
```swift
// Network güvenliği için SSL pinning eklenebilir
```

---

## 📞 Destek ve İletişim

### Geliştirici Notları
- **Proje Sahibi**: [@Burakztrk123](https://github.com/Burakztrk123)
- **Repository**: [emsc_usgs_Litpack](https://github.com/Burakztrk123/emsc_usgs_Litpack)

### Önemli Dosyalar
```
ios/
├── Runner/
│   ├── Info.plist          # İzinler ve yapılandırma
│   ├── AppDelegate.swift   # iOS lifecycle
│   └── Assets.xcassets/    # App icons
├── Podfile                 # CocoaPods bağımlılıkları
└── Runner.xcworkspace      # Xcode workspace
```

### Debug Komutları
```bash
# Flutter doctor
flutter doctor -v

# iOS build verbose
flutter build ios --verbose

# Device logs
flutter logs

# iOS simulator logs
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
```

---

## ⚡ Hızlı Başlangıç Checklist

### İlk Gün (Setup)
- [ ] macOS + Xcode kurulumu
- [ ] CocoaPods kurulumu
- [ ] `flutter doctor` kontrolü
- [ ] `pod install` çalıştırma
- [ ] iOS simülatörde test

### İkinci Gün (Testing)
- [ ] Tüm özellikler test edilmeli
- [ ] Performance profiling
- [ ] Memory leak kontrolü
- [ ] Battery usage analizi

### Üçüncü Gün (Optimization)
- [ ] Build size optimizasyonu
- [ ] Startup time iyileştirmesi
- [ ] Network efficiency
- [ ] UI/UX polish

---

**🎯 Hedef**: iOS uygulamasını App Store'a hazır hale getirmek ve production'da stabil çalışmasını sağlamak.

**📅 Tahmini Süre**: 3-5 iş günü (deneyimli iOS developer için)

---

*Bu rehber, projenin mevcut durumuna göre hazırlanmıştır. Geliştirme sırasında karşılaşılan yeni durumlar için güncellenmelidir.*
