import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class EarthquakeService {
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';

  // EMSC'den deprem verilerini çeker
  Future<List<Earthquake>> getEmscEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
  }) async {
    final DateTime endTime = DateTime.now();
    final DateTime startTime = endTime.subtract(Duration(days: days));

    final String formattedStartTime = startTime.toIso8601String();
    final String formattedEndTime = endTime.toIso8601String();

    // EMSC API için düzeltilmiş URL
    final Uri uri = Uri.parse('$emscApiUrl?format=json&limit=$limit&minmag=$minMagnitude&start=$formattedStartTime&end=$formattedEndTime');

    try {
      developer.log('EMSC API isteği yapılıyor: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        developer.log('EMSC API yanıtı alındı: ${response.body.substring(0, min(100, response.body.length))}...');
        
        // Boş veya geçersiz yanıt kontrolü
        if (response.body.isEmpty) {
          developer.log('EMSC API boş yanıt döndürdü');
          return [];
        }
        
        Map<String, dynamic> data;
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
          // Dart null safety ile as dönüşümü başarısız olursa exception fırlatır, null kontrolü gereksiz
        } catch (e) {
          developer.log('EMSC API JSON ayrıştırma hatası: $e');
          return [];
        }
        
        // API yanıt yapısını kontrol et
        if (data.containsKey('features')) {
          final List<dynamic> features = data['features'] ?? [];
          
          return features.map((feature) {
            try {
              // Özellikler properties içinde olmalı
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
          }).whereType<Earthquake>().toList(); // null değerleri filtrele
        } else {
          // Alternatif API yanıt yapısını dene
          final List<dynamic> earthquakes = data['earthquakes'] ?? [];
          if (earthquakes.isNotEmpty) {
            return earthquakes.map((quake) {
              try {
                return Earthquake.fromEmsc(quake);
              } catch (e) {
                developer.log('Deprem dönüştürme hatası: $e');
                return null;
              }
            }).whereType<Earthquake>().toList();
          } else {
            developer.log('EMSC API yanıtında deprem verisi bulunamadı');
            return [];
          }
        }
      } else {
        developer.log('EMSC API hata kodu: ${response.statusCode}, Yanıt: ${response.body}');
        throw Exception('EMSC API\'den veri çekilemedi: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('EMSC API hatası: $e');
      // Hata durumunda boş liste döndür, uygulamanın çalışmaya devam etmesini sağla
      return [];
    }
  }

  // USGS'den deprem verilerini çeker
  Future<List<Earthquake>> getUsgsEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
  }) async {
    final DateTime endTime = DateTime.now();
    final DateTime startTime = endTime.subtract(Duration(days: days));

    final String formattedStartTime = startTime.toIso8601String();
    final String formattedEndTime = endTime.toIso8601String();

    final Uri uri = Uri.parse(
      '$usgsApiUrl?format=geojson&limit=$limit&minmagnitude=$minMagnitude&starttime=$formattedStartTime&endtime=$formattedEndTime'
    );

    try {
      developer.log('USGS API isteği yapılıyor: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        developer.log('USGS API yanıtı alındı');
        
        // Boş veya geçersiz yanıt kontrolü
        if (response.body.isEmpty) {
          developer.log('USGS API boş yanıt döndürdü');
          return [];
        }
        
        Map<String, dynamic> data;
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
          // Dart null safety ile as dönüşümü başarısız olursa exception fırlatır, null kontrolü gereksiz
        } catch (e) {
          developer.log('USGS API JSON ayrıştırma hatası: $e');
          return [];
        }
        
        final List<dynamic> features = data['features'] ?? [];
        
        return features.map((feature) {
          try {
            return Earthquake.fromUsgs(feature);
          } catch (e) {
            developer.log('USGS deprem dönüştürme hatası: $e');
            return null;
          }
        }).whereType<Earthquake>().toList();
      } else {
        developer.log('USGS API hata kodu: ${response.statusCode}');
        throw Exception('USGS API\'den veri çekilemedi: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('USGS API hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // Her iki kaynaktan da deprem verilerini çeker ve birleştirir
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
  }) async {
    List<Earthquake> emscEarthquakes = [];
    List<Earthquake> usgsEarthquakes = [];
    
    // EMSC API'den veri çekmeyi dene
    try {
      emscEarthquakes = await getEmscEarthquakes(
        limit: limit,
        minMagnitude: minMagnitude,
        days: days,
      );
      developer.log('EMSC deprem sayısı: ${emscEarthquakes.length}');
    } catch (e) {
      developer.log('EMSC veri çekme hatası: $e');
      // Hata durumunda devam et
    }
    
    // USGS API'den veri çekmeyi dene
    try {
      usgsEarthquakes = await getUsgsEarthquakes(
        limit: limit,
        minMagnitude: minMagnitude,
        days: days,
      );
      developer.log('USGS deprem sayısı: ${usgsEarthquakes.length}');
    } catch (e) {
      developer.log('USGS veri çekme hatası: $e');
      // Hata durumunda devam et
    }
    
    // Her iki kaynaktan da veri alınamadıysa boş liste döndür
    if (emscEarthquakes.isEmpty && usgsEarthquakes.isEmpty) {
      developer.log('Her iki kaynaktan da veri alınamadı');
      return [];
    }
    
    final allEarthquakes = [...emscEarthquakes, ...usgsEarthquakes];
    
    // Tarihe göre sırala (en yeniden en eskiye)
    allEarthquakes.sort((a, b) => b.time.compareTo(a.time));
    
    return allEarthquakes;
  }
}
