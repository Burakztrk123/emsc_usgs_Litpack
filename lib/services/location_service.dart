import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _latKey = 'user_latitude';
  static const String _lngKey = 'user_longitude';
  static const String _radiusKey = 'notification_radius';
  
  // Varsayılan değerler (İstanbul koordinatları)
  static const double _defaultLat = 41.0082;
  static const double _defaultLng = 28.9784;
  static const double _defaultRadius = 100.0; // km cinsinden
  
  // Kullanıcının konumunu al
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisinin etkin olup olmadığını kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisleri devre dışı.');
    }

    // Konum izinlerini kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izinleri reddedildi.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Konum izinleri kalıcı olarak reddedildi, ayarlardan değiştirilemez.');
    }

    // Kullanıcının mevcut konumunu al
    return await Geolocator.getCurrentPosition();
  }
  
  // Kullanıcı konumunu kaydet
  static Future<void> saveUserLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, latitude);
    await prefs.setDouble(_lngKey, longitude);
  }
  
  // Kaydedilmiş kullanıcı konumunu al
  static Future<LatLng> getSavedUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey) ?? _defaultLat;
    final lng = prefs.getDouble(_lngKey) ?? _defaultLng;
    return LatLng(lat, lng);
  }
  
  // Bildirim yarıçapını kaydet
  static Future<void> saveNotificationRadius(double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_radiusKey, radius);
  }
  
  // Kaydedilmiş bildirim yarıçapını al
  static Future<double> getSavedNotificationRadius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_radiusKey) ?? _defaultRadius;
  }
  
  // İki konum arasındaki mesafeyi hesapla (km cinsinden)
  static double calculateDistance(dynamic point1, double lat2, double lng2) {
    LatLng latLng1;
    
    if (point1 is Position) {
      latLng1 = LatLng(point1.latitude, point1.longitude);
    } else if (point1 is LatLng) {
      latLng1 = point1;
    } else {
      throw ArgumentError('point1 must be Position or LatLng');
    }
    
    final latLng2 = LatLng(lat2, lng2);
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, latLng1, latLng2);
  }
  
  // Deprem kullanıcının bildirim yarıçapı içinde mi kontrol et
  static Future<bool> isEarthquakeInRadius(double eqLat, double eqLng) async {
    final userLocation = await getSavedUserLocation();
    final radius = await getSavedNotificationRadius();
    
    final distance = calculateDistance(userLocation, eqLat, eqLng);
    
    return distance <= radius;
  }
}
