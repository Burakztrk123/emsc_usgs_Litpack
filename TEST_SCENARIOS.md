# Test Scenarios - Earthquake Tracker App

## 🧪 Kapsamlı Test Rehberi

Bu doküman, Earthquake Tracker uygulamasının tüm özelliklerini test etmek için detaylı senaryolar içerir.

---

## 📱 Manual Test Scenarios

### 1. **Uygulama Başlatma Testleri**

#### Test 1.1: İlk Açılış
- [ ] Uygulamayı ilk kez aç
- [ ] Splash screen görüntüleniyor mu?
- [ ] Ana ekran yükleniyor mu?
- [ ] İzin istekleri geliyor mu? (Konum, Bildirim)

#### Test 1.2: İkinci Açılış
- [ ] Uygulamayı kapat ve tekrar aç
- [ ] Önceki veriler korunuyor mu?
- [ ] Ayarlar hatırlanıyor mu?

### 2. **API ve Veri Çekme Testleri**

#### Test 2.1: EMSC API
- [ ] EMSC'den veri çekiliyor mu?
- [ ] JSON parsing çalışıyor mu?
- [ ] Hata durumunda graceful fallback var mı?

#### Test 2.2: USGS API  
- [ ] USGS'den veri çekiliyor mu?
- [ ] Koordinat dönüşümleri doğru mu?
- [ ] Zaman dilimi çevirileri doğru mu?

#### Test 2.3: Birleşik Veri
- [ ] Her iki API'den gelen veriler birleştiriliyor mu?
- [ ] Duplikat veriler temizleniyor mu?
- [ ] Sıralama doğru mu? (En yeni önce)

### 3. **SQLite Veritabanı Testleri**

#### Test 3.1: Veri Kaydetme
- [ ] API'den gelen veriler SQLite'a kaydediliyor mu?
- [ ] Tüm tablolar oluşturuluyor mu?
- [ ] İndeksler çalışıyor mu?

#### Test 3.2: Veri Okuma
- [ ] Veritabanından veri okunuyor mu?
- [ ] Filtreleme çalışıyor mu? (tarih, büyüklük)
- [ ] Sayfalama çalışıyor mu?

#### Test 3.3: Cache Yönetimi
- [ ] Eski veriler temizleniyor mu?
- [ ] Cache boyutu kontrol ediliyor mu?
- [ ] Optimizasyon çalışıyor mu?

### 4. **Offline Destek Testleri**

#### Test 4.1: İnternet Kesildiğinde
- [ ] İnternet bağlantısını kes
- [ ] Uygulama çöküyor mu?
- [ ] Cache'den veri gösteriliyor mu?
- [ ] Offline mesajı görünüyor mu?

#### Test 4.2: İnternet Geri Geldiğinde
- [ ] İnternet bağlantısını aç
- [ ] Otomatik yenileme çalışıyor mu?
- [ ] Yeni veriler çekiliyor mu?

### 5. **Konum Servisleri Testleri**

#### Test 5.1: Konum İzni
- [ ] Konum izni isteniyor mu?
- [ ] İzin verildiğinde konum alınıyor mu?
- [ ] İzin reddedildiğinde uygulama çalışıyor mu?

#### Test 5.2: Mesafe Hesaplama
- [ ] Konum ile deprem arasındaki mesafe doğru mu?
- [ ] Yakın depremler filtreleniyor mu?
- [ ] Mesafe birimi doğru mu? (km)

### 6. **Bildirim Testleri**

#### Test 6.1: Telegram Bildirimleri
- [ ] Bot token doğrulanıyor mu?
- [ ] Chat ID kontrolü çalışıyor mu?
- [ ] Bildirim gönderiliyor mu?
- [ ] HTML formatı doğru mu?

#### Test 6.2: Arka Plan İşlemleri
- [ ] Uygulama arka planda çalışıyor mu?
- [ ] 15 dakikada bir kontrol yapılıyor mu?
- [ ] Yeni deprem bulunduğunda bildirim geliyor mu?

### 7. **UI/UX Testleri**

#### Test 7.1: Ana Ekran
- [ ] Deprem listesi görünüyor mu?
- [ ] Yenileme butonu çalışıyor mu?
- [ ] Loading indicator görünüyor mu?

#### Test 7.2: Harita Ekranı
- [ ] Harita yükleniyor mu?
- [ ] Deprem işaretleri görünüyor mu?
- [ ] Zoom in/out çalışıyor mu?

#### Test 7.3: Dashboard
- [ ] Grafikler yükleniyor mu?
- [ ] İstatistikler doğru mu?
- [ ] Responsive tasarım çalışıyor mu?

---

## 🤖 Automated Test Cases

### Unit Tests

#### EarthquakeService Tests
```dart
void main() {
  group('EarthquakeService Tests', () {
    test('EMSC API call returns data', () async {
      // Test implementation
    });
    
    test('USGS API call returns data', () async {
      // Test implementation
    });
    
    test('Data merging removes duplicates', () {
      // Test implementation
    });
  });
}
```

#### DatabaseService Tests
```dart
void main() {
  group('DatabaseService Tests', () {
    test('Database initialization', () async {
      // Test implementation
    });
    
    test('Insert earthquake data', () async {
      // Test implementation
    });
    
    test('Query with filters', () async {
      // Test implementation
    });
  });
}
```

#### CacheManager Tests
```dart
void main() {
  group('CacheManager Tests', () {
    test('Cache status calculation', () async {
      // Test implementation
    });
    
    test('Old data cleanup', () async {
      // Test implementation
    });
    
    test('Cache optimization', () async {
      // Test implementation
    });
  });
}
```

---

## 📊 Performance Tests

### 1. **Memory Usage**
- [ ] Uygulama başlangıç memory: < 100MB
- [ ] Veri yükleme sonrası: < 200MB
- [ ] Memory leak yok mu?

### 2. **CPU Usage**
- [ ] İdle durumda: < %5
- [ ] Veri çekerken: < %30
- [ ] Arka planda: < %2

### 3. **Battery Usage**
- [ ] 1 saatte: < %5 batarya
- [ ] Arka planda: < %1/saat
- [ ] GPS kullanımı optimize mi?

### 4. **Network Usage**
- [ ] İlk yükleme: < 5MB
- [ ] Günlük kullanım: < 10MB
- [ ] Cache hit oranı: > %70

### 5. **Storage Usage**
- [ ] Uygulama boyutu: < 50MB
- [ ] Cache boyutu: < 50MB
- [ ] Log dosyaları: < 5MB

---

## 🔒 Security Tests

### 1. **Data Protection**
- [ ] Hassas veriler şifreleniyor mu?
- [ ] SQL injection koruması var mı?
- [ ] Input validation çalışıyor mu?

### 2. **Network Security**
- [ ] HTTPS kullanılıyor mu?
- [ ] Certificate validation var mı?
- [ ] Rate limiting çalışıyor mu?

### 3. **Permission Tests**
- [ ] Minimum gerekli izinler mi?
- [ ] İzin reddi durumu handle ediliyor mu?
- [ ] Sensitive data leak yok mu?

---

## 🌍 Compatibility Tests

### Android Versions
- [ ] Android 5.0 (API 21)
- [ ] Android 8.0 (API 26)
- [ ] Android 10 (API 29)
- [ ] Android 12 (API 31)
- [ ] Android 14 (API 34)

### iOS Versions
- [ ] iOS 12.0
- [ ] iOS 14.0
- [ ] iOS 15.0
- [ ] iOS 16.0
- [ ] iOS 17.0

### Device Types
- [ ] Telefon (küçük ekran)
- [ ] Tablet (büyük ekran)
- [ ] Foldable devices
- [ ] Different screen densities

---

## 🚨 Error Handling Tests

### 1. **Network Errors**
- [ ] No internet connection
- [ ] Slow internet (2G)
- [ ] API server down
- [ ] Timeout errors
- [ ] Invalid response format

### 2. **Database Errors**
- [ ] Database corruption
- [ ] Disk full
- [ ] Permission denied
- [ ] Schema migration errors

### 3. **System Errors**
- [ ] Low memory
- [ ] Low battery
- [ ] Background restrictions
- [ ] Permission revoked

---

## 📋 Test Execution Checklist

### Pre-Testing
- [ ] Test environment hazır
- [ ] Test data prepared
- [ ] Test devices available
- [ ] Network conditions set

### During Testing
- [ ] Test results documented
- [ ] Screenshots captured
- [ ] Performance metrics recorded
- [ ] Error logs collected

### Post-Testing
- [ ] Results analyzed
- [ ] Bugs reported
- [ ] Performance issues identified
- [ ] Recommendations documented

---

## 🎯 Test Success Criteria

### Functional Tests
- [ ] %95 test cases pass
- [ ] All critical features work
- [ ] No data loss
- [ ] Offline mode functional

### Performance Tests
- [ ] App starts < 3 seconds
- [ ] API calls < 5 seconds
- [ ] Memory usage stable
- [ ] Battery drain acceptable

### Security Tests
- [ ] No security vulnerabilities
- [ ] Data encryption works
- [ ] Permissions properly handled
- [ ] No sensitive data leaks

### Compatibility Tests
- [ ] Works on target OS versions
- [ ] UI adapts to screen sizes
- [ ] No device-specific issues
- [ ] Accessibility features work

---

*Bu test senaryoları, uygulamanın production'a çıkmadan önce kapsamlı olarak test edilmesini sağlar.*
