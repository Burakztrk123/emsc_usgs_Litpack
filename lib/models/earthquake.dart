import 'package:latlong2/latlong.dart';

class Earthquake {
  final String id;
  final double magnitude;
  final double latitude;
  final double longitude;
  final double depth;
  final DateTime time;
  final String place;
  final String source; // "EMSC" veya "USGS"

  Earthquake({
    required this.id,
    required this.magnitude,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.time,
    required this.place,
    required this.source,
  });

  factory Earthquake.fromEmsc(Map<String, dynamic> json) {
    try {
      // ID değerini kontrol et
      final id = json['id']?.toString() ?? json['eventid']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Büyüklük değerini kontrol et
      final magnitudeValue = json['magnitude'] ?? json['mag'];
      final double magnitude = magnitudeValue is double 
          ? magnitudeValue 
          : magnitudeValue is int 
              ? magnitudeValue.toDouble() 
              : magnitudeValue is String 
                  ? double.tryParse(magnitudeValue) ?? 0.0 
                  : 0.0;
      
      // Konum değerlerini kontrol et
      final latValue = json['lat'] ?? json['latitude'];
      final lonValue = json['lon'] ?? json['longitude'];
      final double latitude = latValue is double 
          ? latValue 
          : latValue is int 
              ? latValue.toDouble() 
              : latValue is String 
                  ? double.tryParse(latValue) ?? 0.0 
                  : 0.0;
      final double longitude = lonValue is double 
          ? lonValue 
          : lonValue is int 
              ? lonValue.toDouble() 
              : lonValue is String 
                  ? double.tryParse(lonValue) ?? 0.0 
                  : 0.0;
      
      // Derinlik değerini kontrol et
      final depthValue = json['depth'];
      final double depth = depthValue is double 
          ? depthValue 
          : depthValue is int 
              ? depthValue.toDouble() 
              : depthValue is String 
                  ? double.tryParse(depthValue) ?? 0.0 
                  : 0.0;
      
      // Zaman değerini kontrol et ve Türkiye saatine çevir
      DateTime time;
      if (json['time'] is int) {
        time = DateTime.fromMillisecondsSinceEpoch(json['time']);
      } else if (json['time'] is String) {
        time = DateTime.tryParse(json['time']) ?? DateTime.now();
      } else if (json['origin_time'] is String) {
        time = DateTime.tryParse(json['origin_time']) ?? DateTime.now();
      } else {
        time = DateTime.now();
      }
      
      // UTC'den Türkiye saatine çevir (+3 saat)
      time = time.add(const Duration(hours: 3));
      
      // Yer bilgisini kontrol et
      final place = json['flynn_region'] ?? 
                   json['region'] ?? 
                   json['place'] ?? 
                   'Bilinmeyen Konum';
      
      return Earthquake(
        id: id,
        magnitude: magnitude,
        latitude: latitude,
        longitude: longitude,
        depth: depth,
        time: time,
        place: place,
        source: 'EMSC',
      );
    } catch (e) {
      // Hata durumunda varsayılan değerlerle bir deprem nesnesi oluştur
      return Earthquake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        magnitude: 0.0,
        latitude: 0.0,
        longitude: 0.0,
        depth: 0.0,
        time: DateTime.now(),
        place: 'Veri hatası',
        source: 'EMSC',
      );
    }
  }

  factory Earthquake.fromUsgs(Map<String, dynamic> json) {
    try {
      final properties = json['properties'];
      final geometry = json['geometry'];
      final coordinates = geometry['coordinates'];

      // ID değerini kontrol et
      final id = properties['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Büyüklük değerini kontrol et
      final magnitudeValue = properties['mag'];
      final double magnitude = magnitudeValue is double 
          ? magnitudeValue 
          : magnitudeValue is int 
              ? magnitudeValue.toDouble() 
              : magnitudeValue is String 
                  ? double.tryParse(magnitudeValue) ?? 0.0 
                  : 0.0;
      
      // Konum değerlerini kontrol et
      double latitude = 0.0;
      double longitude = 0.0;
      double depth = 0.0;
      
      if (coordinates is List && coordinates.length >= 3) {
        longitude = coordinates[0] is double ? coordinates[0] : coordinates[0] is int ? coordinates[0].toDouble() : 0.0;
        latitude = coordinates[1] is double ? coordinates[1] : coordinates[1] is int ? coordinates[1].toDouble() : 0.0;
        depth = coordinates[2] is double ? coordinates[2] : coordinates[2] is int ? coordinates[2].toDouble() : 0.0;
      }
      
      // Zaman değerini kontrol et ve Türkiye saatine çevir
      DateTime time;
      if (properties['time'] is int) {
        time = DateTime.fromMillisecondsSinceEpoch(properties['time']);
      } else if (properties['time'] is String) {
        time = DateTime.tryParse(properties['time']) ?? DateTime.now();
      } else {
        time = DateTime.now();
      }
      
      // UTC'den Türkiye saatine çevir (+3 saat)
      time = time.add(const Duration(hours: 3));
      
      // Yer bilgisini kontrol et
      final place = properties['place'] ?? 'Bilinmeyen Konum';
      
      return Earthquake(
        id: id,
        magnitude: magnitude,
        latitude: latitude,
        longitude: longitude,
        depth: depth,
        time: time,
        place: place,
        source: 'USGS',
      );
    } catch (e) {
      // Hata durumunda varsayılan değerlerle bir deprem nesnesi oluştur
      return Earthquake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        magnitude: 0.0,
        latitude: 0.0,
        longitude: 0.0,
        depth: 0.0,
        time: DateTime.now(),
        place: 'Veri hatası',
        source: 'USGS',
      );
    }
  }
  
  // Deprem konumunu LatLng nesnesine dönüştür
  LatLng getLatLng() {
    return LatLng(latitude, longitude);
  }
}
