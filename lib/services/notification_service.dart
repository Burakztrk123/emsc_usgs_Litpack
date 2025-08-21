import 'dart:developer' as developer;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake.dart';
import 'earthquake_service_real.dart';
import 'local_notification_service.dart';

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
    try {
      final earthquakeService = EarthquakeServiceReal();
      
      // Son 1 saatteki depremleri al
      final earthquakes = await earthquakeService.getAllEarthquakes(
        limit: 100,
        minMagnitude: 2.0,
        days: 1,
      );
      
      // Son kontrol zamanını güncelle
      await saveLastCheckTime();
      
      // Yerel bildirim servisine gönder
      await LocalNotificationService.checkForNewEarthquakes(earthquakes);
      
      return earthquakes;
    } catch (e) {
      developer.log('❌ Deprem kontrolü hatası: $e', name: 'NotificationService');
      return [];
    }
  }
}

// WorkManager callback fonksiyonu
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await NotificationService.checkForNewEarthquakes();
      return true;
    } catch (e) {
      developer.log('Arka plan görevi hatası: $e', name: 'BackgroundTask');
      return false;
    }
  });
}
