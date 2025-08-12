# 🌍 EMSC & USGS Deprem Takip Uygulaması

Gerçek zamanlı deprem verilerini EMSC (Avrupa-Akdeniz Sismoloji Merkezi) ve USGS (Amerika Birleşik Devletleri Jeoloji Araştırmaları) API'lerinden alan, Telegram bildirim entegrasyonu ve konum tabanlı filtreleme özelliklerine sahip kapsamlı bir Flutter mobil uygulaması.

## 📱 Uygulama Özellikleri

### 🔥 Ana Özellikler
- **Gerçek Zamanlı Deprem Verileri**: Güvenilir kaynaklardan anlık deprem bilgileri
- **İnteraktif Haritalar**: Özel işaretçilerle depremleri harita üzerinde görselleştirme
- **Mesafe Hesaplama**: Konumunuzdan deprem merkezlerine olan mesafeleri hesaplama
- **Arka Plan İzleme**: Sürekli izleme ve arka plan bildirimleri
- **Çoklu Kaynak Entegrasyonu**: EMSC ve USGS verilerini birleştirerek kapsamlı kapsama
- **Çevrimdışı Destek**: Çevrimdışı görüntüleme için deprem verilerini önbelleğe alma
- **Özelleştirilebilir Filtreler**: Büyüklük, mesafe ve zaman aralığına göre filtreleme

### 🔔 Bildirim Sistemi
- **Akıllı Bildirimler**: Tercihlerinize göre deprem uyarıları alma
- **Telegram Entegrasyonu**: Telegram bot aracılığıyla deprem uyarıları alma
- **Özelleştirilebilir Eşikler**: Bildirimler için minimum büyüklük ve maksimum mesafe ayarlama
- **Arka Plan İşleme**: Uygulama kapalıyken bile deprem izleme (15 dakikada bir kontrol)

### 📊 Analitik ve Görselleştirme
- **Sismik Dashboard**: Grafik ve çizelgelerle gelişmiş analizler
- **Büyüklük Dağılımı**: Deprem büyüklüklerinin görsel temsili
- **Zamansal Analiz**: Zaman içindeki deprem modellerini takip etme
- **Bölgesel İstatistikler**: Ülke ve bölge özelinde deprem verileri
- **Tarihsel Eğilimler**: Deprem eğilimlerini ve modellerini görüntüleme

### 🛡️ Güvenlik Özellikleri
- **Acil Durum Bilgileri**: Deprem güvenliği rehberi ve ipuçları
- **SSS Bölümü**: Depremle ilgili yaygın soruların kapsamlı cevapları
- **Rapor Sistemi**: Hissedilen depremleri rapor etme ve topluluk verilerine katkıda bulunma

## 🚀 Kurulum ve Başlangıç

### Gereksinimler
- Flutter SDK (3.6.0 veya üzeri)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Android cihaz veya emülatör
- Telegram Bot Token (bildirimler için)

### Kurulum Adımları

1. **Depoyu klonlayın**
   ```bash
   git clone https://github.com/Burakztrk123/emsc_usgs_Litpack.git
   cd emsc_usgs_Litpack
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

4. **Fiziksel cihaza yüklemek için**
   ```bash
   # Bağlı cihazları listele
   flutter devices
   
   # Belirli cihaza yükle
   flutter run -d [DEVICE_ID]
   ```

## 🤖 Telegram Bot Kurulumu

### Adım 1: Bot Oluşturma
1. Telegram'da @BotFather'ı arayın
2. `/newbot` komutunu gönderin
3. Bot için bir isim seçin (örn: "Deprem Takip Botum")
4. Bot için bir kullanıcı adı seçin (örn: "deprem_takip_bot")
5. BotFather size bir token verecek (örn: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### Adım 2: Chat ID Alma
1. Oluşturduğunuz bot ile sohbet başlatın
2. @userinfobot'u arayın ve `/start` gönderin
3. Chat ID'nizi alın (örn: `123456789`)

### Adım 3: Uygulamada Yapılandırma
1. Uygulamayı açın
2. **Ayarlar** > **Bildirim Ayarları**'na gidin
3. Bot Token ve Chat ID'yi girin
4. Bildirim tercihlerinizi ayarlayın

## 🌐 API Detayları ve Veri Kaynakları

### 📡 EMSC API (European-Mediterranean Seismological Centre)
**Base URL:** `https://www.seismicportal.eu/fdsnws/event/1/query`

**Desteklenen Parametreler:**
- `format=json` - JSON formatında veri
- `limit` - Maksimum sonuç sayısı (varsayılan: 100)
- `minmag` - Minimum büyüklük (varsayılan: 4.0)
- `start` - Başlangıç tarihi (ISO 8601 formatı)
- `end` - Bitiş tarihi (ISO 8601 formatı)

**Örnek İstek:**
```
https://www.seismicportal.eu/fdsnws/event/1/query?format=json&limit=100&minmag=4.0&start=2024-01-01T00:00:00&end=2024-01-31T23:59:59
```

**Yanıt Yapısı:**
```json
{
  "features": [
    {
      "properties": {
        "id": "1234567",
        "magnitude": 5.2,
        "lat": 38.7749,
        "lon": 35.4854,
        "depth": 10.5,
        "time": "2024-01-15T14:30:00Z",
        "flynn_region": "TURKEY",
        "region": "Central Turkey"
      }
    }
  ]
}
```

### 🇺🇸 USGS API (United States Geological Survey)
**Base URL:** `https://earthquake.usgs.gov/fdsnws/event/1/query`

**Desteklenen Parametreler:**
- `format=geojson` - GeoJSON formatında veri
- `limit` - Maksimum sonuç sayısı (varsayılan: 100)
- `minmagnitude` - Minimum büyüklük (varsayılan: 4.0)
- `starttime` - Başlangıç tarihi (ISO 8601 formatı)
- `endtime` - Bitiş tarihi (ISO 8601 formatı)

**Örnek İstek:**
```
https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&limit=100&minmagnitude=4.0&starttime=2024-01-01&endtime=2024-01-31
```

**Yanıt Yapısı:**
```json
{
  "features": [
    {
      "properties": {
        "id": "us7000abcd",
        "mag": 5.2,
        "place": "15km NE of Ankara, Turkey",
        "time": 1705329000000,
        "updated": 1705329300000,
        "url": "https://earthquake.usgs.gov/earthquakes/eventpage/us7000abcd",
        "felt": 45,
        "cdi": 4.2,
        "mmi": 3.8,
        "alert": "green",
        "status": "reviewed",
        "tsunami": 0,
        "sig": 432,
        "net": "us",
        "code": "7000abcd",
        "magType": "mww",
        "type": "earthquake",
        "title": "M 5.2 - 15km NE of Ankara, Turkey"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [32.8597, 39.9334, 10.5]
      }
    }
  ]
}
```

## 🏗️ Proje Yapısı

### 📁 Dizin Yapısı
```
lib/
├── main.dart                 # Ana uygulama giriş noktası
├── models/                   # Veri modelleri
│   ├── earthquake.dart       # Deprem veri modeli
│   ├── earthquake_report.dart # Deprem raporu modeli
│   └── seismic_activity.dart # Sismik aktivite modeli
├── services/                 # İş mantığı servisleri
│   ├── earthquake_service.dart      # API entegrasyonu
│   ├── seismic_analysis_service.dart # Sismik analiz
│   ├── location_service.dart        # Konum servisleri
│   ├── notification_service.dart    # Bildirim yönetimi
│   ├── earthquake_report_service.dart # Rapor servisi
│   └── telegram_service.dart        # Telegram entegrasyonu
├── screens/                  # Uygulama ekranları
│   ├── home_screen.dart             # Ana sayfa
│   ├── seismic_dashboard_screen.dart # Sismik dashboard
│   ├── simple_dashboard_screen.dart  # Basit dashboard
│   ├── earthquake_safety_screen.dart # Güvenlik bilgileri
│   ├── earthquake_faq_screen.dart    # SSS
│   ├── notification_settings_screen.dart # Bildirim ayarları
│   ├── earthquake_report_screen.dart # Deprem raporu
│   └── my_reports_screen.dart       # Raporlarım
└── widgets/                  # Yeniden kullanılabilir bileşenler
    └── source_attribution.dart # Kaynak atıfları
```

### 🔧 Servis Detayları

#### EarthquakeService
Deprem verilerini API'lerden çeken ana servis:

```dart
class EarthquakeService {
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';

  // EMSC API'den deprem verilerini çeker
  Future<List<Earthquake>> getEmscEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
  })

  // USGS API'den deprem verilerini çeker
  Future<List<Earthquake>> getUsgsEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
  })

  // Her iki kaynaktan da veri çeker ve birleştirir
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
  })
}
```

#### SeismicAnalysisService
Sismik veri analizi ve istatistikler:

```dart
class SeismicAnalysisService {
  // Küresel sismik aktivite analizi
  Future<SeismicActivity> getGlobalSeismicActivity()
  
  // Ülke bazlı sismik aktivite (Türkiye, ABD, Japonya vb.)
  Future<CountrySeismicData> getCountrySeismicActivity(String countryCode)
  
  // Günlük, aylık, yıllık sismik trend analizi
  Future<SeismicTrend> getSeismicTrend()
  
  // Büyüklük bazlı istatistikler (1.0-2.0, 2.0-3.0, vb.)
  Future<Map<String, dynamic>> getMagnitudeStatistics({
    String region = 'global',
    int days = 30,
  })
}
```

#### NotificationService
Arka plan bildirimleri ve izleme:

```dart
class NotificationService {
  // Arka plan görevini başlat (15 dakikada bir çalışır)
  static Future<void> initializeBackgroundTask()
  
  // Yeni depremleri kontrol et
  static Future<List<Earthquake>> checkForNewEarthquakes()
  
  // Kullanıcının belirlediği yarıçap içindeki depremleri filtrele
  static Future<List<Earthquake>> filterEarthquakesInRadius(List<Earthquake> earthquakes)
  
  // Telegram bildirimleri gönder
  static Future<void> sendTelegramNotifications(List<Earthquake> earthquakes)
}
```

#### TelegramService
Telegram bot entegrasyonu:

```dart
class TelegramService {
  static const String _telegramApiUrl = 'https://api.telegram.org/bot';
  
  // Bot token ve chat ID kaydet
  static Future<void> saveTelegramCredentials(String botToken, String chatId)
  
  // Telegram'a mesaj gönder
  static Future<bool> sendMessage(String message)
  
  // Deprem bildirimi gönder (HTML formatında)
  static Future<bool> sendEarthquakeNotification(Earthquake earthquake, double distanceKm)
  
  // Bot token geçerliliğini kontrol et
  static Future<bool> validateBotToken(String botToken)
}
```

#### LocationService
GPS ve konum servisleri:

```dart
class LocationService {
  // Kullanıcının mevcut konumunu al
  static Future<LatLng> getCurrentLocation()
  
  // İki nokta arasındaki mesafeyi hesapla (Haversine formülü)
  static double calculateDistance(LatLng point1, LatLng point2)
  
  // Konum izinlerini kontrol et ve iste
  static Future<bool> requestLocationPermission()
}
```

## 🛠️ Kullanılan Teknolojiler

### 📱 Flutter Framework
- **Flutter SDK**: 3.6.0+
- **Dart**: 3.0+
- **Material Design 3**: Modern UI tasarımı

### 🌐 HTTP ve API
- **http**: ^1.1.0 - HTTP istekleri için
- **intl**: ^0.18.1 - Tarih/saat formatlaması ve uluslararasılaştırma

### 🗺️ Harita ve Konum
- **flutter_map**: ^6.0.1 - İnteraktif haritalar (OpenStreetMap tabanlı)
- **latlong2**: ^0.9.0 - Koordinat hesaplamaları ve dönüşümleri
- **geolocator**: ^10.0.0 - GPS konum servisleri
- **permission_handler**: ^11.0.0 - Sistem izinleri yönetimi

### 💾 Veri Depolama
- **shared_preferences**: ^2.2.0 - Yerel veri depolama (ayarlar, tercihler)
- **sqflite**: ^2.3.0 - SQLite veritabanı
- **path**: ^1.8.3 - Dosya yolu yönetimi
- **path_provider**: ^2.1.1 - Sistem dizinleri erişimi

### 🔔 Arka Plan İşlemleri
- **workmanager**: ^0.5.1 - Arka plan görevleri (15 dakikada bir deprem kontrolü)

### 📊 Grafik ve Görselleştirme
- **fl_chart**: ^0.68.0 - Grafik çizimi (çizgi, bar, pasta grafikleri)
- **syncfusion_flutter_charts**: ^24.1.41 - Gelişmiş grafikler ve analizler
- **syncfusion_flutter_gauges**: ^24.1.41 - Gösterge panelleri ve ölçekler

## 📋 Tam Bağımlılık Listesi

```yaml
name: emsc_usgs_mobile
description: "EMSC ve USGS API'lerinden gerçek zamanlı deprem verileri alan Flutter uygulaması"
version: 1.0.0+1

environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^1.1.0
  intl: ^0.18.1
  flutter_map: ^6.0.1
  geolocator: ^10.0.0
  permission_handler: ^11.0.0
  shared_preferences: ^2.2.0
  workmanager: ^0.5.1
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
  syncfusion_flutter_charts: ^24.1.41
  syncfusion_flutter_gauges: ^24.1.41

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

## 🔧 Yapılandırma

### 📱 iOS Yapılandırması
iOS için gerekli tüm yapılandırmalar tamamlanmıştır:

#### ✅ Otomatik Yapılandırılanlar
- **Info.plist**: Konum, network ve bildirim izinleri eklendi
- **Podfile**: iOS 12.0+ deployment target ve gerekli pod'lar
- **AppDelegate.swift**: Arka plan işlemleri desteği
- **SQLite**: iOS'ta native olarak destekleniyor

#### 🔐 İzinler
- **Konum İzni**: Deprem mesafesi hesaplama için
- **Arka Plan İzni**: Bildirimler için
- **Network İzni**: API erişimi için
- **Bildirim İzni**: Push notification için

#### 🚀 iOS'ta Çalıştırma
```bash
# iOS bağımlılıklarını yükle
cd ios && pod install

# iOS simülatörde çalıştır
flutter run -d ios

# iOS cihazda çalıştır
flutter run -d [device-id]
```

### Konum Servisleri
- **GPS İzni**: Mesafe hesaplamaları için konum izinlerini etkinleştirin
- **Konum Doğruluğu**: Uygulama, yakınlık tabanlı özellikler için GPS kullanarak konumunuzu belirler
- **Arka Plan Konumu**: Bildirimler için arka planda konum erişimi

### Bildirim Ayarları
- **Bot Token**: Telegram BotFather'dan alınan bot token
- **Chat ID**: Telegram kullanıcı ID'niz
- **Bildirim Yarıçapı**: Kilometre cinsinden uyarı mesafesi (varsayılan: 100km)
- **Minimum Büyüklük**: Bildirim için minimum deprem büyüklüğü (varsayılan: 4.0)
- **Bildirim Sıklığı**: 15 dakikada bir kontrol

### Telegram Bildirim Formatı
```
🚨 DEPREM BİLDİRİMİ! 🚨

📍 Konum: 15km NE of Ankara, Turkey
📏 Büyüklük: 5.2
🕳️ Derinlik: 10.5 km
🕒 Zaman: 2024-01-15 17:30:00
🔍 Koordinatlar: 39.9334, 32.8597
📊 Kaynak: USGS
📍 Uzaklık: 45.2 km
```

## 📱 Ekran Detayları

### 🏠 Ana Sayfa (HomeScreen)
- Son depremlerin listesi
- Harita görünümü
- Hızlı filtreler
- Yenileme butonu

### 📊 Sismik Dashboard (SeismicDashboardScreen)
- Büyüklük dağılım grafikleri
- Zamansal trend analizleri
- Bölgesel istatistikler
- Karşılaştırmalı analizler

### 🎯 Basit Dashboard (SimpleDashboardScreen)
- Basitleştirilmiş görünüm
- Temel istatistikler
- Hızlı erişim butonları

### 🛡️ Güvenlik Bilgileri (EarthquakeSafetyScreen)
- Deprem öncesi hazırlık
- Deprem anında yapılacaklar
- Deprem sonrası güvenlik
- Acil durum çantası listesi

### ❓ SSS (EarthquakeFaqScreen)
- Sık sorulan sorular
- Deprem bilimi temel bilgileri
- Büyüklük ölçekleri açıklaması
- Tsunami riski bilgileri

### ⚙️ Bildirim Ayarları (NotificationSettingsScreen)
- Telegram bot yapılandırması
- Bildirim tercihleri
- Konum ayarları
- Test bildirimi gönderme

### 📝 Deprem Raporu (EarthquakeReportScreen)
- Hissedilen deprem raporu
- Şiddet seçimi
- Konum bilgisi
- Ek açıklamalar

### 📋 Raporlarım (MyReportsScreen)
- Gönderilen raporların listesi
- Rapor detayları
- Düzenleme ve silme

## 💾 SQLite Veritabanı Entegrasyonu

### 🗄️ Veritabanı Yapısı
Uygulama, yerel veri depolama ve offline erişim için SQLite veritabanı kullanır:

#### Tablolar
- **earthquakes**: Deprem verileri önbelleği
- **user_reports**: Kullanıcı deprem raporları
- **notification_history**: Bildirim geçmişi
- **user_settings**: Kullanıcı ayarları
- **seismic_cache**: Sismik aktivite önbelleği

#### DatabaseService
```dart
class DatabaseService {
  // Deprem verilerini kaydet
  Future<void> insertEarthquakes(List<Earthquake> earthquakes)
  
  // Önbellekten deprem verilerini al
  Future<List<Earthquake>> getEarthquakes({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    double? minMagnitude,
    String? orderBy,
  })
  
  // Favori depremleri yönet
  Future<void> addFavoriteEarthquake(String earthquakeId)
  Future<List<Earthquake>> getFavoriteEarthquakes()
  
  // Kullanıcı raporları
  Future<void> insertUserReport(EarthquakeReport report)
  Future<List<EarthquakeReport>> getUserReports()
  
  // Veritabanı temizleme
  Future<void> clearDatabase()
  Future<int> cleanOldEarthquakes({int daysToKeep = 90})
}
```

#### CacheManager
Önbellek yönetimi ve optimizasyon:

```dart
class CacheManager {
  // Önbellek durumunu kontrol et
  Future<CacheStatus> getCacheStatus()
  
  // Önbelleği temizle
  Future<bool> clearCache()
  
  // Eski verileri temizle
  Future<int> cleanOldData({int daysToKeep = 90})
  
  // Önbellek optimizasyonu
  Future<void> optimizeCache()
}
```

### 📊 Offline Özellikler
- **Veri Önbelleğe Alma**: API'den çekilen veriler otomatik olarak SQLite'a kaydedilir
- **Offline Erişim**: İnternet bağlantısı olmadığında önbellekten veri gösterilir
- **Akıllı Senkronizasyon**: Sadece yeni veriler API'den çekilir
- **Veri Temizleme**: 90 günden eski veriler otomatik temizlenir

### 🔧 Veritabanı Yapılandırması
- **Veritabanı Adı**: `earthquake_tracker.db`
- **Sürüm**: 1
- **Maksimum Boyut**: 50MB (otomatik temizleme)
- **Konum**: Uygulama documents dizini

### 📝 Kullanım Örnekleri

#### Temel Kullanım
```dart
// Ana entegre servisi kullan
final earthquakeService = EarthquakeServiceIntegrated();

// Deprem verilerini çek (önce cache, sonra API)
final earthquakes = await earthquakeService.getAllEarthquakes(
  limit: 50,
  minMagnitude: 4.0,
  days: 7,
);

// Offline modda mı kontrol et
final isOffline = await earthquakeService.isOfflineMode();
if (isOffline) {
  print('Offline modda - cache\'den veri gösteriliyor');
}
```

#### Cache Yönetimi
```dart
final cacheManager = CacheManager();

// Cache durumunu kontrol et
final status = await cacheManager.getCacheStatus();
print('Toplam deprem: ${status.totalEarthquakes}');
print('Veritabanı boyutu: ${status.formattedSize}');

// Eski verileri temizle
final deletedCount = await cacheManager.cleanOldData(daysToKeep: 30);
print('$deletedCount eski kayıt silindi');

// Cache'i optimize et
await cacheManager.optimizeCache();
```

#### Favori Deprem Yönetimi
```dart
// Favori ekle
await earthquakeService.addFavorite('earthquake_id_123');

// Favorileri listele
final favorites = await earthquakeService.getFavorites();
print('${favorites.length} favori deprem');
```

#### Veritabanı İşlemleri
```dart
final databaseService = DatabaseService();

// Son 24 saatteki depremleri al
final recentEarthquakes = await databaseService.getEarthquakes(
  startDate: DateTime.now().subtract(Duration(hours: 24)),
  minMagnitude: 3.0,
  orderBy: 'magnitude DESC',
);

// Kullanıcı raporu kaydet
final report = EarthquakeReport(
  id: 'report_123',
  latitude: 39.9334,
  longitude: 32.8597,
  location: 'Ankara, Turkey',
  reportTime: DateTime.now(),
  earthquakeTime: DateTime.now().subtract(Duration(minutes: 5)),
  intensity: 'Hafif',
  observations: ['Sallanma hissedildi'],
  reporterName: 'Kullanıcı',
);

await databaseService.insertUserReport(report);
```

## 🚀 Performans Optimizasyonları

### API Optimizasyonu
- **Önbelleğe Alma**: Deprem verileri yerel olarak önbelleğe alınır
- **Akıllı Yenileme**: Sadece yeni veriler çekilir
- **Hata Yönetimi**: API hatalarında graceful fallback

### Arka Plan İşlemleri
- **Verimli Kontrol**: 15 dakikada bir minimal veri kontrolü
- **Batarya Optimizasyonu**: Gereksiz işlemler minimize edilir
- **Ağ Kontrolü**: Sadece internet bağlantısı varken çalışır

### UI/UX Optimizasyonları
- **Lazy Loading**: Büyük listeler için sayfalama
- **Smooth Animations**: Akıcı geçişler ve animasyonlar
- **Responsive Design**: Farklı ekran boyutlarına uyum

## 🔒 Güvenlik

### Veri Güvenliği
- **API Anahtarları**: Güvenli depolama
- **Kullanıcı Verileri**: Yerel cihazda şifreleme
- **Ağ Güvenliği**: HTTPS protokolü

### Gizlilik
- **Konum Verileri**: Sadece gerekli durumlarda kullanım
- **Veri Paylaşımı**: Üçüncü taraflarla veri paylaşımı yok
- **Şeffaflık**: Açık kaynak kod

## 🐛 Bilinen Sorunlar ve Çözümler

### Yaygın Sorunlar
1. **Konum İzni Hatası**
   - Çözüm: Cihaz ayarlarından konum iznini manuel olarak verin

2. **Telegram Bildirimleri Gelmiyor**
   - Bot token'ın doğru olduğundan emin olun
   - Chat ID'nin doğru olduğundan emin olun
   - Bot ile en az bir kez sohbet başlatın

3. **API Veri Çekme Hatası**
   - İnternet bağlantınızı kontrol edin
   - Uygulamayı yeniden başlatın

### Performans Sorunları
- **Yavaş Yükleme**: Önbellek temizleme deneyin
- **Yüksek Batarya Kullanımı**: Bildirim sıklığını azaltın

## 🤝 Katkıda Bulunma

### Geliştirme Ortamı Kurulumu
1. Flutter SDK'yı yükleyin
2. Projeyi fork edin
3. Yerel geliştirme ortamını kurun
4. Değişikliklerinizi yapın
5. Pull request gönderin

### Katkı Türleri
- **Bug Raporları**: GitHub Issues kullanın
- **Özellik İstekleri**: Detaylı açıklama ile issue açın
- **Kod Katkıları**: Pull request gönderin
- **Dokümantasyon**: README ve kod yorumları geliştirin
- **Çeviri**: Yeni dil desteği ekleyin

## 📞 İletişim ve Destek

### Geliştirici
- **GitHub**: [@Burakztrk123](https://github.com/Burakztrk123)
- **Proje Deposu**: [emsc_usgs_Litpack](https://github.com/Burakztrk123/emsc_usgs_Litpack)

### Destek
- **Issues**: GitHub Issues bölümünü kullanın
- **Dokümantasyon**: Bu README dosyasını inceleyin
- **Topluluk**: GitHub Discussions

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 🙏 Teşekkürler

- **EMSC**: Avrupa-Akdeniz bölgesi deprem verileri için
- **USGS**: Küresel deprem verileri için
- **Flutter Topluluğu**: Açık kaynak kütüphaneler için
- **OpenStreetMap**: Harita verileri için

---

**⚠️ Önemli Not**: Bu uygulama bilgilendirme amaçlıdır. Resmi acil durum uyarıları için yerel makamları takip edin.

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This app is for informational purposes only. For official earthquake information and emergency alerts, please refer to your local geological survey and emergency services.

## 📞 Support

If you have any questions or issues, please open an issue on GitHub.
