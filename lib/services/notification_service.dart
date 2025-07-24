import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake.dart';
import 'earthquake_service.dart';
import 'location_service.dart';
import 'telegram_service.dart';

class NotificationService {
  static const String _lastCheckTimeKey = 'last_check_time';
  static const String _backgroundTaskName = 'earthquakeCheckTask';
  
  // Arka plan görevini başlat
  static Future<void> initializeBackgroundTask() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _backgroundTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
  
  // Arka plan görevini durdur
  static Future<void> stopBackgroundTask() async {
    await Workmanager().cancelByUniqueName(_backgroundTaskName);
  }
  
  // Son kontrol zamanını kaydet
  static Future<void> saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCheckTimeKey, DateTime.now().toIso8601String());
  }
  
  // Son kontrol zamanını al
  static Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_lastCheckTimeKey);
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }
  
  // Yeni depremleri kontrol et
  static Future<List<Earthquake>> checkForNewEarthquakes() async {
    final lastCheckTime = await getLastCheckTime();
    final earthquakeService = EarthquakeService();
    
    // Son 1 saatteki depremleri al
    final emscEarthquakes = await earthquakeService.getEmscEarthquakes(
      days: 1,
      minMagnitude: 0.0, // Tüm büyüklükleri al, filtreleme sonra yapılacak
    );
    
    final usgsEarthquakes = await earthquakeService.getUsgsEarthquakes(
      days: 1,
      minMagnitude: 0.0, // Tüm büyüklükleri al, filtreleme sonra yapılacak
    );
    
    // Tüm depremleri birleştir
    final allEarthquakes = [...emscEarthquakes, ...usgsEarthquakes];
    
    // Son kontrol zamanından sonraki depremleri filtrele
    final newEarthquakes = lastCheckTime != null
        ? allEarthquakes.where((eq) => eq.time.isAfter(lastCheckTime)).toList()
        : allEarthquakes;
    
    // Son kontrol zamanını güncelle
    await saveLastCheckTime();
    
    return newEarthquakes;
  }
  
  // Kullanıcının yarıçapı içindeki depremleri filtrele
  static Future<List<Earthquake>> filterEarthquakesInRadius(List<Earthquake> earthquakes) async {
    final userLocation = await LocationService.getSavedUserLocation();
    final radius = await LocationService.getSavedNotificationRadius();
    final minMagnitude = await TelegramService.getMinNotificationMagnitude();
    
    final filteredEarthquakes = <Earthquake>[];
    
    for (final earthquake in earthquakes) {
      // Minimum büyüklük kontrolü
      if (earthquake.magnitude < minMagnitude) continue;
      
      // Mesafe kontrolü
      final earthquakeLocation = earthquake.getLatLng();
      final distance = LocationService.calculateDistance(userLocation, earthquakeLocation);
      
      if (distance <= radius) {
        filteredEarthquakes.add(earthquake);
      }
    }
    
    return filteredEarthquakes;
  }
  
  // Telegram bildirimleri gönder
  static Future<void> sendTelegramNotifications(List<Earthquake> earthquakes) async {
    if (earthquakes.isEmpty) return;
    
    final userLocation = await LocationService.getSavedUserLocation();
    
    for (final earthquake in earthquakes) {
      final earthquakeLocation = earthquake.getLatLng();
      final distance = LocationService.calculateDistance(userLocation, earthquakeLocation);
      
      await TelegramService.sendEarthquakeNotification(earthquake, distance);
    }
  }
}

// WorkManager için callback fonksiyonu
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == NotificationService._backgroundTaskName) {
      try {
        // Bildirimlerin etkin olup olmadığını kontrol et
        final notificationsEnabled = await TelegramService.areNotificationsEnabled();
        if (!notificationsEnabled) return true;
        
        // Yeni depremleri kontrol et
        final newEarthquakes = await NotificationService.checkForNewEarthquakes();
        
        // Kullanıcının yarıçapı içindeki depremleri filtrele
        final nearbyEarthquakes = await NotificationService.filterEarthquakesInRadius(newEarthquakes);
        
        // Telegram bildirimleri gönder
        await NotificationService.sendTelegramNotifications(nearbyEarthquakes);
      } catch (e) {
        print('Arka plan görevi hatası: $e');
      }
    }
    return true;
  });
}
