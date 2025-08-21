import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';
// Cache manager import removed - not used in production mode

/// SQLite entegrasyonlu ana deprem servisi
/// Bu servis API'den veri çeker, veritabanına kaydeder ve offline erişim sağlar
class EarthquakeServiceIntegrated {
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';
  
  // Cache manager removed - production mode uses live API only

  /// Tüm kaynaklardan deprem verilerini çek (önce cache, sonra API)
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool forceRefresh = false,
  }) async {
    try {
      developer.log('🚀 SADECE CANLI API - SQLite devre dışı, maksimum hız!');
      
      final earthquakes = <Earthquake>[];
      
      // EMSC ve USGS'den paralel olarak veri çek - HIZLI MOD
      final futures = [
        _fetchEmscEarthquakes(limit: limit, minMagnitude: minMagnitude, days: days),
        _fetchUsgsEarthquakes(limit: limit, minMagnitude: minMagnitude, days: days),
      ];

      // 20 saniye timeout - düşük magnitude için yeterli süre
      final results = await Future.wait(futures).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          developer.log('⚠️ API timeout - 20 saniye geçti, mevcut veriler döndürülüyor');
          return [<Earthquake>[], <Earthquake>[]];
        },
      );
      
      // Tüm sonuçları birleştir
      earthquakes.addAll(results[0]);
      earthquakes.addAll(results[1]);
      
      developer.log('⚡ HIZLI API sonuçları: EMSC=${results[0].length}, USGS=${results[1].length}');
      
      if (earthquakes.isEmpty) {
        developer.log('⚠️ API\'lerden veri gelmedi! Filtre: magnitude=$minMagnitude, days=$days');
        return <Earthquake>[]; // Boş liste döndür
      }

      developer.log('✅ CANLI API: ${earthquakes.length} güncel deprem verisi alındı!');

      // Duplikatları temizle ve sırala
      final uniqueEarthquakes = _removeDuplicates(earthquakes);
      uniqueEarthquakes.sort((a, b) => b.time.compareTo(a.time));
      
      final limitedEarthquakes = uniqueEarthquakes.take(limit).toList();

      // SQLite DEVRE DIŞI - Sadece canlı API verileri
      developer.log('🔥 SQLite atlandı - Sadece canlı ${limitedEarthquakes.length} deprem verisi döndürülüyor');

      return limitedEarthquakes;
    } catch (e) {
      developer.log('🚨 API hatası: $e');
      developer.log('💡 Sadece canlı API modu - Cache yok, boş liste döndürülüyor');
      
      // Hata durumunda boş liste döndür - Cache yok!
      return <Earthquake>[];
    }
  }

  /// EMSC API'den deprem verilerini çek
  Future<List<Earthquake>> _fetchEmscEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      // Gerçek zamanlı API için son günleri kullan (2024 yılından)
      final endDate = DateTime(2024, 8, 13); // Gerçek tarih
      final startDate = endDate.subtract(Duration(days: days));
      
      // EMSC API basit parametreler
      final uri = Uri.parse(emscApiUrl).replace(queryParameters: {
        'format': 'json',
        'limit': limit.toString(),
        'minmag': minMagnitude.toString(),
        'start': startDate.toIso8601String().split('T')[0], // Sadece tarih
        'end': endDate.toIso8601String().split('T')[0],
      });

      developer.log('EMSC API çağrısı: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      
      developer.log('EMSC API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // EMSC JSON formatı kontrol et
        if (data is Map && data.containsKey('features')) {
          // GeoJSON formatı
          final features = data['features'] as List;
          developer.log('EMSC API\'den ${features.length} deprem alındı (GeoJSON)');
          
          return features.map((feature) {
            final properties = feature['properties'];
            final geometry = feature['geometry'];
            final coordinates = geometry['coordinates'] as List;
            
            return Earthquake(
              id: properties['unid']?.toString() ?? 'emsc_${DateTime.now().millisecondsSinceEpoch}',
              magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
              place: properties['place']?.toString() ?? properties['flynn_region']?.toString() ?? 'Bilinmeyen Konum',
              time: DateTime.parse(properties['time']),
              latitude: (coordinates[1] as num).toDouble(),
              longitude: (coordinates[0] as num).toDouble(),
              depth: (coordinates.length > 2 ? coordinates[2] as num : 0).toDouble(),
              source: 'EMSC',
            );
          }).toList();
        } else if (data is List) {
          // Direkt array formatı
          developer.log('EMSC API\'den ${data.length} deprem alındı (Array)');
          
          return data.map((item) {
            return Earthquake(
              id: item['unid']?.toString() ?? 'emsc_${DateTime.now().millisecondsSinceEpoch}',
              magnitude: (item['mag'] as num?)?.toDouble() ?? 0.0,
              place: item['place']?.toString() ?? item['flynn_region']?.toString() ?? 'Bilinmeyen Konum',
              time: DateTime.parse(item['time']),
              latitude: (item['lat'] as num).toDouble(),
              longitude: (item['lon'] as num).toDouble(),
              depth: (item['depth'] as num?)?.toDouble() ?? 0.0,
              source: 'EMSC',
            );
          }).toList();
        }
      } else {
        developer.log('EMSC API hatası: ${response.statusCode} - ${response.body}');
      }
      
      return [];
    } catch (e) {
      developer.log('EMSC API exception: $e');
      return [];
    }
  }

  /// USGS API'den deprem verilerini çek
  Future<List<Earthquake>> _fetchUsgsEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      // Gerçek zamanlı API için son günleri kullan (2024 yılından)
      final endDate = DateTime(2024, 8, 13); // Gerçek tarih
      final startDate = endDate.subtract(Duration(days: days));
      
      // USGS API en basit parametreler
      final uri = Uri.parse(usgsApiUrl).replace(queryParameters: {
        'format': 'geojson',
        'limit': '500', // Daha fazla veri için limit artırıldı
        'minmagnitude': minMagnitude.toString(), // Değişken magnitude
        'starttime': startDate.toIso8601String().split('T')[0], // Başlangıç tarihi
        'endtime': endDate.toIso8601String().split('T')[0], // Bitiş tarihi
      });

      developer.log('USGS API çağrısı: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      
      developer.log('USGS API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        developer.log('USGS API\'den ${features.length} deprem alındı');
        
        return features.map((feature) {
          final properties = feature['properties'];
          final geometry = feature['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          return Earthquake(
            id: properties['id']?.toString() ?? 
                'usgs_${DateTime.now().millisecondsSinceEpoch}',
            magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
            place: properties['place']?.toString() ?? 'Unknown Location',
            time: DateTime.fromMillisecondsSinceEpoch(properties['time'] as int),
            latitude: (coordinates[1] as num).toDouble(),
            longitude: (coordinates[0] as num).toDouble(),
            depth: (coordinates[2] as num).toDouble(),
            source: 'USGS',
          );
        }).toList();
      } else {
        developer.log('USGS API hatası: ${response.statusCode} - ${response.body}');
      }
      
      return [];
    } catch (e) {
      developer.log('USGS API exception: $e');
      return [];
    }
  }

  // Test data removed for production

  /// Duplikatları temizle
  List<Earthquake> _removeDuplicates(List<Earthquake> earthquakes) {
    final seen = <String>{};
    return earthquakes.where((earthquake) => seen.add(earthquake.id)).toList();
  }

  /// Favori deprem ekle
  Future<void> addFavorite(String earthquakeId) async {
    // Not: DatabaseService'de addFavoriteEarthquake metodu implement edilmeli
    developer.log('Favori ekleme özelliği: $earthquakeId');
  }

  /// Favori depremleri getir
  Future<List<Earthquake>> getFavorites() async {
    // Not: DatabaseService'de getFavoriteEarthquakes metodu implement edilmeli
    return [];
  }

  /// Cache durumunu kontrol et (devre dışı)
  Future<Map<String, dynamic>> getCacheStatus() async {
    return {'enabled': false, 'message': 'Cache devre dışı'};
  }

  /// Cache'i temizle (devre dışı)
  Future<bool> clearCache() async {
    return true;
  }

  /// Cache'i optimize et (devre dışı)
  Future<void> optimizeCache() async {
    // Cache devre dışı
  }

  /// Offline modda mı kontrol et
  Future<bool> isOfflineMode() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode != 200;
    } catch (e) {
      return true; // İnternet bağlantısı yok
    }
  }
}
