import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';
import 'database_service.dart';
import 'cache_manager.dart';

/// SQLite entegrasyonlu ana deprem servisi
/// Bu servis API'den veri çeker, veritabanına kaydeder ve offline erişim sağlar
class EarthquakeServiceIntegrated {
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';
  
  final DatabaseService _databaseService = DatabaseService();
  final CacheManager _cacheManager = CacheManager();

  /// Tüm kaynaklardan deprem verilerini çek (önce cache, sonra API)
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool forceRefresh = false,
  }) async {
    try {
      // Önce cache'den kontrol et
      if (!forceRefresh) {
        final cachedEarthquakes = await _getCachedEarthquakes(
          limit: limit,
          minMagnitude: minMagnitude,
          days: days,
        );
        
        if (cachedEarthquakes.isNotEmpty) {
          developer.log('Cache\'den ${cachedEarthquakes.length} deprem verisi alındı');
          return cachedEarthquakes;
        }
      }

      // Cache boşsa veya yenileme isteniyorsa API'den çek
      final earthquakes = <Earthquake>[];
      
      // EMSC ve USGS'den paralel olarak veri çek
      final futures = [
        _fetchEmscEarthquakes(limit: limit ~/ 2, minMagnitude: minMagnitude, days: days),
        _fetchUsgsEarthquakes(limit: limit ~/ 2, minMagnitude: minMagnitude, days: days),
      ];
      
      final results = await Future.wait(futures);
      
      for (final result in results) {
        earthquakes.addAll(result);
      }

      // Duplikatları temizle ve sırala
      final uniqueEarthquakes = _removeDuplicates(earthquakes);
      uniqueEarthquakes.sort((a, b) => b.time.compareTo(a.time));
      
      final limitedEarthquakes = uniqueEarthquakes.take(limit).toList();

      // Veritabanına kaydet
      if (limitedEarthquakes.isNotEmpty) {
        await _databaseService.insertEarthquakes(limitedEarthquakes);
        developer.log('${limitedEarthquakes.length} deprem verisi veritabanına kaydedildi');
      }

      return limitedEarthquakes;
    } catch (e) {
      developer.log('Deprem verisi çekme hatası: $e');
      
      // Hata durumunda cache'den veri döndür
      return await _getCachedEarthquakes(
        limit: limit,
        minMagnitude: minMagnitude,
        days: days,
      );
    }
  }

  /// Cache'den deprem verilerini al
  Future<List<Earthquake>> _getCachedEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    return await _databaseService.getEarthquakes(
      limit: limit,
      startDate: startDate,
      minMagnitude: minMagnitude,
      orderBy: 'time DESC',
    );
  }

  /// EMSC API'den deprem verilerini çek
  Future<List<Earthquake>> _fetchEmscEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final endDate = DateTime.now();
      
      final uri = Uri.parse(emscApiUrl).replace(queryParameters: {
        'format': 'geojson',
        'limit': limit.toString(),
        'minmagnitude': minMagnitude.toString(),
        'starttime': startDate.toIso8601String().split('T')[0],
        'endtime': endDate.toIso8601String().split('T')[0],
        'orderby': 'time-desc',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        return features.map((feature) {
          final properties = feature['properties'];
          final geometry = feature['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          return Earthquake(
            id: properties['unid']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
            place: properties['place']?.toString() ?? 'Bilinmeyen Konum',
            time: DateTime.parse(properties['time']),
            latitude: (coordinates[1] as num).toDouble(),
            longitude: (coordinates[0] as num).toDouble(),
            depth: (coordinates.length > 2 ? coordinates[2] as num : 0).toDouble(),
            source: 'EMSC',
          );
        }).toList();
      }
      
      return [];
    } catch (e) {
      developer.log('EMSC API hatası: $e');
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
      final startDate = DateTime.now().subtract(Duration(days: days));
      final endDate = DateTime.now();
      
      final uri = Uri.parse(usgsApiUrl).replace(queryParameters: {
        'format': 'geojson',
        'limit': limit.toString(),
        'minmagnitude': minMagnitude.toString(),
        'starttime': startDate.toIso8601String().split('T')[0],
        'endtime': endDate.toIso8601String().split('T')[0],
        'orderby': 'time',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        return features.map((feature) {
          final properties = feature['properties'];
          final geometry = feature['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          return Earthquake(
            id: properties['ids']?.toString().split(',')[0] ?? 
                DateTime.now().millisecondsSinceEpoch.toString(),
            magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
            place: properties['place']?.toString() ?? 'Unknown Location',
            time: DateTime.fromMillisecondsSinceEpoch(properties['time'] as int),
            latitude: (coordinates[1] as num).toDouble(),
            longitude: (coordinates[0] as num).toDouble(),
            depth: (coordinates[2] as num).toDouble(),
            source: 'USGS',
          );
        }).toList();
      }
      
      return [];
    } catch (e) {
      developer.log('USGS API hatası: $e');
      return [];
    }
  }

  /// Duplikat depremleri temizle
  List<Earthquake> _removeDuplicates(List<Earthquake> earthquakes) {
    final seen = <String>{};
    return earthquakes.where((earthquake) {
      final key = '${earthquake.latitude}_${earthquake.longitude}_${earthquake.time.millisecondsSinceEpoch}';
      return seen.add(key);
    }).toList();
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

  /// Cache durumunu kontrol et
  Future<CacheStatus> getCacheStatus() async {
    return await _cacheManager.getCacheStatus();
  }

  /// Cache'i temizle
  Future<bool> clearCache() async {
    return await _cacheManager.clearCache();
  }

  /// Cache'i optimize et
  Future<void> optimizeCache() async {
    await _cacheManager.optimizeCache();
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
