import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake.dart';
import 'location_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Ayar anahtarları
  static const String _notificationsEnabledKey = 'local_notifications_enabled';
  static const String _minMagnitudeKey = 'notification_min_magnitude';
  static const String _radiusKmKey = 'notification_radius_km';
  static const String _lastNotificationTimeKey = 'last_notification_time';
  
  /// Bildirim servisini başlat
  static Future<void> initialize() async {
    developer.log('🔔 Yerel bildirim servisi başlatılıyor...', name: 'LocalNotificationService');
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Android bildirim kanalı oluştur
    await _createNotificationChannel();
    
    developer.log('✅ Yerel bildirim servisi başlatıldı', name: 'LocalNotificationService');
  }
  
  /// Android bildirim kanalı oluştur
  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'earthquake_alerts',
      'Deprem Uyarıları',
      description: 'Yakınınızdaki depremler için uyarı bildirimleri',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  /// Bildirime tıklandığında çalışır
  static void _onNotificationTapped(NotificationResponse response) {
    developer.log('📱 Bildirime tıklandı: ${response.payload}', name: 'LocalNotificationService');
    // Burada ana ekrana yönlendirme yapılabilir
  }
  
  /// Bildirim ayarlarını kaydet
  static Future<void> saveNotificationSettings({
    required bool enabled,
    required double minMagnitude,
    required double radiusKm,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    await prefs.setDouble(_minMagnitudeKey, minMagnitude);
    await prefs.setDouble(_radiusKmKey, radiusKm);
    
    developer.log('⚙️ Bildirim ayarları kaydedildi: enabled=$enabled, magnitude=$minMagnitude, radius=${radiusKm}km', 
                  name: 'LocalNotificationService');
  }
  
  /// Bildirim ayarlarını al
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_notificationsEnabledKey) ?? true,
      'minMagnitude': prefs.getDouble(_minMagnitudeKey) ?? 4.0,
      'radiusKm': prefs.getDouble(_radiusKmKey) ?? 100.0,
    };
  }
  
  /// Yeni depremleri kontrol et ve bildirim gönder
  static Future<void> checkForNewEarthquakes(List<Earthquake> earthquakes) async {
    try {
      final settings = await getNotificationSettings();
      
      if (!settings['enabled']) {
        developer.log('🔕 Bildirimler devre dışı', name: 'LocalNotificationService');
        return;
      }
      
      // Kullanıcının mevcut konumunu al
      final userLocation = await LocationService.getCurrentLocation();
      if (userLocation == null) {
        developer.log('⚠️ Kullanıcı konumu alınamadı', name: 'LocalNotificationService');
        return;
      }
      
      final minMagnitude = settings['minMagnitude'] as double;
      final radiusKm = settings['radiusKm'] as double;
      
      // Son bildirim zamanını kontrol et (spam önleme)
      final prefs = await SharedPreferences.getInstance();
      final lastNotificationTime = prefs.getInt(_lastNotificationTimeKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // 10 dakikadan önce bildirim gönderilmişse skip et
      if (now - lastNotificationTime < 600000) {
        developer.log('⏰ Son bildirimden 10 dakika geçmedi, atlanıyor', name: 'LocalNotificationService');
        return;
      }
      
      // Yakındaki depremleri filtrele
      final nearbyEarthquakes = <Earthquake>[];
      
      for (final earthquake in earthquakes) {
        // Büyüklük kontrolü
        if (earthquake.magnitude < minMagnitude) continue;
        
        // Mesafe kontrolü
        final distance = LocationService.calculateDistance(
          userLocation,
          earthquake.latitude,
          earthquake.longitude,
        );
        
        if (distance <= radiusKm) {
          nearbyEarthquakes.add(earthquake);
          developer.log('📍 Yakın deprem bulundu: ${earthquake.place} (${distance.toStringAsFixed(1)}km)', 
                        name: 'LocalNotificationService');
        }
      }
      
      // Yakın deprem varsa bildirim gönder
      if (nearbyEarthquakes.isNotEmpty) {
        await _sendEarthquakeNotification(nearbyEarthquakes, userLocation);
        await prefs.setInt(_lastNotificationTimeKey, now);
      }
      
    } catch (e) {
      developer.log('❌ Deprem kontrolü hatası: $e', name: 'LocalNotificationService');
    }
  }
  
  /// Deprem bildirimi gönder
  static Future<void> _sendEarthquakeNotification(List<Earthquake> earthquakes, Position userLocation) async {
    try {
      final earthquake = earthquakes.first; // En büyük veya en yakın
      
      // Mesafeyi hesapla
      final distance = LocationService.calculateDistance(
        userLocation,
        earthquake.latitude,
        earthquake.longitude,
      );
      
      // Bildirim içeriği
      final title = '🚨 Yakınızda Deprem!';
      final body = '${earthquake.magnitude.toStringAsFixed(1)} büyüklüğünde deprem\n'
                  '📍 ${earthquake.place}\n'
                  '📏 ${distance.toStringAsFixed(1)} km uzaklıkta';
      
      // Bildirim gönder
      await _notifications.show(
        earthquake.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'earthquake_alerts',
            'Deprem Uyarıları',
            channelDescription: 'Yakınınızdaki depremler için uyarı bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: earthquake.id,
      );
      
      developer.log('📨 Deprem bildirimi gönderildi: ${earthquake.place}', name: 'LocalNotificationService');
      
      // Birden fazla deprem varsa özet bildirim
      if (earthquakes.length > 1) {
        await _sendSummaryNotification(earthquakes.length, userLocation);
      }
      
    } catch (e) {
      developer.log('❌ Bildirim gönderme hatası: $e', name: 'LocalNotificationService');
    }
  }
  
  /// Özet bildirim gönder (birden fazla deprem varsa)
  static Future<void> _sendSummaryNotification(int count, Position userLocation) async {
    await _notifications.show(
      999999, // Sabit ID
      '📊 Deprem Özeti',
      'Son kontrol: $count adet deprem tespit edildi',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'earthquake_alerts',
          'Deprem Uyarıları',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  /// Test bildirimi gönder
  static Future<void> sendTestNotification() async {
    await _notifications.show(
      0,
      '🧪 Test Bildirimi',
      'Deprem bildirim sistemi çalışıyor!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'earthquake_alerts',
          'Deprem Uyarıları',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    
    developer.log('🧪 Test bildirimi gönderildi', name: 'LocalNotificationService');
  }
  
  /// Tüm bildirimleri temizle
  static Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
    developer.log('🗑️ Tüm bildirimler temizlendi', name: 'LocalNotificationService');
  }
  
  /// Bildirim izni iste
  static Future<bool> requestPermission() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    bool? granted;
    
    if (androidImplementation != null) {
      granted = await androidImplementation.requestNotificationsPermission();
    }
    
    if (iosImplementation != null) {
      granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    
    developer.log('🔔 Bildirim izni: ${granted ?? false}', name: 'LocalNotificationService');
    return granted ?? false;
  }
}
