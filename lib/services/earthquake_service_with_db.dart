import 'dart:convert';

import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';
import 'database_service.dart';

class EarthquakeServiceWithDB {
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';
  
  final DatabaseService _databaseService = DatabaseService();

  // EMSC'den deprem verilerini çeker ve veritabanına kaydeder
  Future<List<Earthquake>> getEmscEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool useCache = true,
  }) async {
    try {
      // Önce veritabanından kontrol et
      if (useCache) {
        final cachedEarthquakes = await _databaseService.getEarthquakes(
          source: 'EMSC',
          minMagnitude: minMagnitude,
          startDate: DateTime.now().subtract(Duration(days: days)),
          limit: limit,
        );
        
        if (cachedEarthquakes.isNotEmpty) {
          developer.log('EMSC verileri önbellekten alındı: ${cachedEarthquakes.length}');
          return cachedEarthquakes;
        }
      }

      // API'den veri çek
      final DateTime endTime = DateTime.now();
      final DateTime startTime = endTime.subtract(Duration(days: days));

      final String formattedStartTime = startTime.toIso8601String();
      final String formattedEndTime = endTime.toIso8601String();

      final Uri uri = Uri.parse('$emscApiUrl?format=json&limit=$limit&minmag=$minMagnitude&start=$formattedStartTime&end=$formattedEndTime');

      developer.log('EMSC API isteği yapılıyor: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        developer.log('EMSC API yanıtı alındı');
        
        if (response.body.isEmpty) {
          developer.log('EMSC API boş yanıt döndürdü');
          return [];
        }
        
        Map<String, dynamic> data;
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          developer.log('EMSC API JSON ayrıştırma hatası: $e');
          return [];
        }
        
        List<Earthquake> earthquakes = [];
        
        if (data.containsKey('features')) {
          final List<dynamic> features = data['features'] ?? [];
          
          earthquakes = features.map((feature) {
            try {
              final properties = feature['properties'];
              if (properties == null) {
                developer.log('Uyarı: Özellikler null: $feature');
                return null;
              }
              return Earthquake.fromEmsc(properties);
            } catch (e) {
              developer.log('Deprem dönüştürme hatası: $e');
              return null;
            }
          }).whereType<Earthquake>().toList();
        }

        // Veritabanına kaydet
        if (earthquakes.isNotEmpty) {
          await _databaseService.insertEarthquakes(earthquakes);
          developer.log('EMSC verileri veritabanına kaydedildi: ${earthquakes.length}');
        }

        return earthquakes;
      } else {
        developer.log('EMSC API hata kodu: ${response.statusCode}');
        
        // Hata durumunda önbellekten döndür
        return await _databaseService.getEarthquakes(
          source: 'EMSC',
          minMagnitude: minMagnitude,
          startDate: DateTime.now().subtract(Duration(days: days)),
          limit: limit,
        );
      }
    } catch (e) {
      developer.log('EMSC API hatası: $e');
      
      // Hata durumunda önbellekten döndür
      return await _databaseService.getEarthquakes(
        source: 'EMSC',
        minMagnitude: minMagnitude,
        startDate: DateTime.now().subtract(Duration(days: days)),
        limit: limit,
      );
    }
  }

  // USGS'den deprem verilerini çeker ve veritabanına kaydeder
  Future<List<Earthquake>> getUsgsEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool useCache = true,
  }) async {
    try {
      // Önce veritabanından kontrol et
      if (useCache) {
        final cachedEarthquakes = await _databaseService.getEarthquakes(
          source: 'USGS',
          minMagnitude: minMagnitude,
          startDate: DateTime.now().subtract(Duration(days: days)),
          limit: limit,
        );
        
        if (cachedEarthquakes.isNotEmpty) {
          developer.log('USGS verileri önbellekten alındı: ${cachedEarthquakes.length}');
          return cachedEarthquakes;
        }
      }

      // API'den veri çek
      final DateTime endTime = DateTime.now();
      final DateTime startTime = endTime.subtract(Duration(days: days));

      final String formattedStartTime = startTime.toIso8601String();
      final String formattedEndTime = endTime.toIso8601String();

      final Uri uri = Uri.parse(
        '$usgsApiUrl?format=geojson&limit=$limit&minmagnitude=$minMagnitude&starttime=$formattedStartTime&endtime=$formattedEndTime'
      );

      developer.log('USGS API isteği yapılıyor: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        developer.log('USGS API yanıtı alındı');
        
        if (response.body.isEmpty) {
          developer.log('USGS API boş yanıt döndürdü');
          return [];
        }
        
        Map<String, dynamic> data;
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          developer.log('USGS API JSON ayrıştırma hatası: $e');
          return [];
        }
        
        final List<dynamic> features = data['features'] ?? [];
        
        List<Earthquake> earthquakes = features.map((feature) {
          try {
            return Earthquake.fromUsgs(feature);
          } catch (e) {
            developer.log('USGS deprem dönüştürme hatası: $e');
            return null;
          }
        }).whereType<Earthquake>().toList();

        // Veritabanına kaydet
        if (earthquakes.isNotEmpty) {
          await _databaseService.insertEarthquakes(earthquakes);
          developer.log('USGS verileri veritabanına kaydedildi: ${earthquakes.length}');
        }

        return earthquakes;
      } else {
        developer.log('USGS API hata kodu: ${response.statusCode}');
        
        // Hata durumunda önbellekten döndür
        return await _databaseService.getEarthquakes(
          source: 'USGS',
          minMagnitude: minMagnitude,
          startDate: DateTime.now().subtract(Duration(days: days)),
          limit: limit,
        );
      }
    } catch (e) {
      developer.log('USGS API hatası: $e');
      
      // Hata durumunda önbellekten döndür
      return await _databaseService.getEarthquakes(
        source: 'USGS',
        minMagnitude: minMagnitude,
        startDate: DateTime.now().subtract(Duration(days: days)),
        limit: limit,
      );
    }
  }

  // Her iki kaynaktan da deprem verilerini çeker ve birleştirir
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    List<Earthquake> allEarthquakes = [];
    
    if (forceRefresh) {
      // Zorla yenileme - önbellek kullanma
      useCache = false;
    }

    // EMSC API'den veri çekmeyi dene
    try {
      final emscEarthquakes = await getEmscEarthquakes(
        limit: limit,
        minMagnitude: minMagnitude,
        days: days,
        useCache: useCache,
      );
      allEarthquakes.addAll(emscEarthquakes);
      developer.log('EMSC deprem sayısı: ${emscEarthquakes.length}');
    } catch (e) {
      developer.log('EMSC veri çekme hatası: $e');
    }
    
    // USGS API'den veri çekmeyi dene
    try {
      final usgsEarthquakes = await getUsgsEarthquakes(
        limit: limit,
        minMagnitude: minMagnitude,
        days: days,
        useCache: useCache,
      );
      allEarthquakes.addAll(usgsEarthquakes);
      developer.log('USGS deprem sayısı: ${usgsEarthquakes.length}');
    } catch (e) {
      developer.log('USGS veri çekme hatası: $e');
    }
    
    // Eğer hiç veri alınamadıysa veritabanından al
    if (allEarthquakes.isEmpty) {
      allEarthquakes = await _databaseService.getEarthquakes(
        minMagnitude: minMagnitude,
        startDate: DateTime.now().subtract(Duration(days: days)),
        limit: limit * 2, // Her iki kaynaktan da veri olabileceği için limit'i artır
      );
      developer.log('Veritabanından alınan deprem sayısı: ${allEarthquakes.length}');
    }
    
    // Tarihe göre sırala (en yeniden en eskiye)
    allEarthquakes.sort((a, b) => b.time.compareTo(a.time));
    
    // Limit uygula
    if (allEarthquakes.length > limit) {
      allEarthquakes = allEarthquakes.take(limit).toList();
    }
    
    return allEarthquakes;
  }

  // Veritabanından deprem verilerini getir (çevrimdışı mod)
  Future<List<Earthquake>> getOfflineEarthquakes({
    double? minMagnitude,
    double? maxMagnitude,
    String? source,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return await _databaseService.getEarthquakes(
      minMagnitude: minMagnitude,
      maxMagnitude: maxMagnitude,
      source: source,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  // Favori depremleri getir
  Future<List<Earthquake>> getFavoriteEarthquakes() async {
    return await _databaseService.getFavoriteEarthquakes();
  }

  // Depremi favorilere ekle/çıkar
  Future<bool> toggleEarthquakeFavorite(String earthquakeId) async {
    final result = await _databaseService.toggleEarthquakeFavorite(earthquakeId);
    return result > 0;
  }

  // Deprem istatistiklerini getir
  Future<Map<String, dynamic>> getEarthquakeStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.getEarthquakeStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Günlük deprem sayılarını getir (grafik için)
  Future<List<Map<String, dynamic>>> getDailyEarthquakeCounts({
    required int days,
  }) async {
    return await _databaseService.getDailyEarthquakeCounts(days: days);
  }

  // Büyüklük dağılımını getir
  Future<List<Map<String, dynamic>>> getMagnitudeDistribution() async {
    return await _databaseService.getMagnitudeDistribution();
  }

  // Belirli bir depremi getir
  Future<Earthquake?> getEarthquakeById(String id) async {
    return await _databaseService.getEarthquakeById(id);
  }

  // Eski verileri temizle
  Future<int> cleanOldEarthquakes({int daysToKeep = 90}) async {
    return await _databaseService.cleanOldEarthquakes(daysToKeep: daysToKeep);
  }

  // Veritabanı boyutunu getir
  Future<int> getDatabaseSize() async {
    return await _databaseService.getDatabaseSize();
  }

  // Veritabanını temizle
  Future<void> clearDatabase() async {
    await _databaseService.clearDatabase();
  }

  // Son güncelleme zamanını kontrol et
  Future<bool> needsUpdate({int minutesSinceLastUpdate = 15}) async {
    final recentEarthquakes = await _databaseService.getEarthquakes(
      startDate: DateTime.now().subtract(Duration(minutes: minutesSinceLastUpdate)),
      limit: 1,
    );
    
    return recentEarthquakes.isEmpty;
  }

  // Akıllı güncelleme - sadece gerektiğinde API'yi çağır
  Future<List<Earthquake>> smartUpdate({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    int updateIntervalMinutes = 15,
  }) async {
    final needsUpdate = await this.needsUpdate(
      minutesSinceLastUpdate: updateIntervalMinutes,
    );

    if (needsUpdate) {
      developer.log('Veri güncelleme gerekli, API\'den çekiliyor...');
      return await getAllEarthquakes(
        limit: limit,
        minMagnitude: minMagnitude,
        days: days,
        useCache: false,
        forceRefresh: true,
      );
    } else {
      developer.log('Veri güncel, önbellekten alınıyor...');
      return await getOfflineEarthquakes(
        minMagnitude: minMagnitude,
        startDate: DateTime.now().subtract(Duration(days: days)),
        limit: limit,
      );
    }
  }
}
