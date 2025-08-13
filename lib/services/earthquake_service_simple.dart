import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

/// ESKİ ÇALIŞAN SİSTEM - BASİT VE ETKİLİ
class EarthquakeServiceSimple {
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';

  /// ESKİ ÇALIŞAN SİSTEM - Son 30 günlük deprem verileri
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool forceRefresh = false,
  }) async {
    try {
      developer.log('🔥 ESKİ ÇALIŞAN SİSTEM - Basit ve etkili!');
      
      final earthquakes = <Earthquake>[];
      
      // EMSC ve USGS'den paralel olarak veri çek - ESKİ SİSTEM
      final futures = [
        _fetchEmscEarthquakes(limit: 200, minMagnitude: minMagnitude, days: days),
        _fetchUsgsEarthquakes(limit: 200, minMagnitude: minMagnitude, days: days),
      ];

      // 8 saniye timeout - ESKİ SİSTEM
      final results = await Future.wait(futures).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          developer.log('⚠️ API timeout - 8 saniye');
          return [<Earthquake>[], <Earthquake>[]];
        },
      );
      
      // Tüm sonuçları birleştir
      earthquakes.addAll(results[0]);
      earthquakes.addAll(results[1]);
      
      developer.log('⚡ ESKİ SİSTEM sonuçları: EMSC=${results[0].length}, USGS=${results[1].length}');
      
      if (earthquakes.isEmpty) {
        developer.log('⚠️ Hiç veri gelmedi! Filtre: magnitude=$minMagnitude, days=$days');
        return <Earthquake>[];
      }

      developer.log('✅ ESKİ SİSTEM: ${earthquakes.length} deprem verisi alındı!');

      // Duplikatları temizle ve sırala - ESKİ SİSTEM
      final uniqueEarthquakes = _removeDuplicates(earthquakes);
      uniqueEarthquakes.sort((a, b) => b.time.compareTo(a.time));
      
      final limitedEarthquakes = uniqueEarthquakes.take(limit).toList();

      developer.log('🎯 ESKİ SİSTEM: ${limitedEarthquakes.length} deprem döndürülüyor');

      return limitedEarthquakes;
    } catch (e) {
      developer.log('🚨 ESKİ SİSTEM hatası: $e');
      return <Earthquake>[];
    }
  }

  /// EMSC API - ESKİ ÇALIŞAN SİSTEM
  Future<List<Earthquake>> _fetchEmscEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      // ESKİ SİSTEM - Son 30 gün gerçek veri
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final uri = Uri.parse(emscApiUrl).replace(queryParameters: {
        'format': 'json',
        'limit': limit.toString(),
        'minmag': minMagnitude.toString(),
        'start': startDate.toIso8601String().split('T')[0],
        'end': endDate.toIso8601String().split('T')[0],
      });

      developer.log('EMSC API (ÇALIŞAN TARİH): $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('features')) {
          final features = data['features'] as List;
          developer.log('EMSC: ${features.length} deprem alındı');
          
          return features.map((feature) {
            final properties = feature['properties'];
            final geometry = feature['geometry'];
            final coordinates = geometry['coordinates'] as List;
            
            return Earthquake(
              id: properties['unid']?.toString() ?? 
                  'emsc_${DateTime.now().millisecondsSinceEpoch}',
              magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
              place: properties['flynn_region']?.toString() ?? 'Unknown Location',
              time: DateTime.parse(properties['time']),
              latitude: (coordinates[1] as num).toDouble(),
              longitude: (coordinates[0] as num).toDouble(),
              depth: (coordinates[2] as num).toDouble(),
              source: 'EMSC',
            );
          }).toList();
        }
      }
      
      developer.log('EMSC API boş döndü');
      return [];
    } catch (e) {
      developer.log('EMSC API hatası: $e');
      return [];
    }
  }

  /// USGS API - ESKİ ÇALIŞAN SİSTEM
  Future<List<Earthquake>> _fetchUsgsEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      // ESKİ SİSTEM - Son 30 gün gerçek veri
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final uri = Uri.parse(usgsApiUrl).replace(queryParameters: {
        'format': 'geojson',
        'limit': limit.toString(),
        'minmagnitude': minMagnitude.toString(),
        'starttime': startDate.toIso8601String().split('T')[0],
        'endtime': endDate.toIso8601String().split('T')[0],
      });

      developer.log('USGS API (ÇALIŞAN TARİH): $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        developer.log('USGS: ${features.length} deprem alındı');
        
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
      }
      
      developer.log('USGS API boş döndü');
      return [];
    } catch (e) {
      developer.log('USGS API hatası: $e');
      return [];
    }
  }

  /// Duplikatları temizle - ESKİ SİSTEM
  List<Earthquake> _removeDuplicates(List<Earthquake> earthquakes) {
    final seen = <String>{};
    return earthquakes.where((earthquake) => seen.add(earthquake.id)).toList();
  }
}
