import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

/// GERÇEK ÇALIŞAN API SERVİSİ - SADECE USGS + GÜNCEL TARİHLER
class EarthquakeServiceReal {
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';
  
  /// GERÇEK ÇALIŞAN SİSTEM - Sadece USGS + güncel tarihler
  Future<List<Earthquake>> getAllEarthquakes({
    int limit = 100,
    double minMagnitude = 4.0,
    int days = 30,
    bool forceRefresh = false,
  }) async {
    try {
      developer.log('🔥 GERÇEK ÇALIŞAN SİSTEM - Sadece USGS + güncel tarihler!');
      
      // SADECE USGS - EMSC ÇALIŞMIYOR! USGS'Yİ MAKSİMUM OPTİMİZE ET!
      final earthquakes = await _fetchUsgsEarthquakes(
        limit: 20000, // MAKSIMUM LİMİT!
        minMagnitude: 0.1, // EN DÜŞÜK MAGNITUDE
        days: 90 // SON 90 GÜN - DAHA FAZLA VERİ!
      );
      
      developer.log('⚡ USGS sonuçları: ${earthquakes.length} deprem');
      
      if (earthquakes.isEmpty) {
        developer.log('⚠️ USGS\'den veri gelmedi! Filtre: magnitude=$minMagnitude, days=$days');
        return <Earthquake>[];
      }

      developer.log('✅ GERÇEK SİSTEM: ${earthquakes.length} deprem verisi alındı!');

      // Client-side magnitude filtrele (kullanıcının istediği magnitude)
      final filteredEarthquakes = earthquakes.where((eq) => eq.magnitude >= minMagnitude).toList();
      developer.log('🔍 Magnitude $minMagnitude filtresinden sonra: ${filteredEarthquakes.length} deprem');

      // Sırala ve limitle
      filteredEarthquakes.sort((a, b) => b.time.compareTo(a.time));
      final limitedEarthquakes = filteredEarthquakes.take(limit).toList();

      developer.log('🎯 GERÇEK SİSTEM: ${limitedEarthquakes.length} deprem döndürülüyor');

      return limitedEarthquakes;
    } catch (e) {
      developer.log('🚨 GERÇEK SİSTEM hatası: $e');
      return <Earthquake>[];
    }
  }

  /// USGS API - GÜNCEL TARİHLER İLE
  Future<List<Earthquake>> _fetchUsgsEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      // EN GÜNCEL VERİLER - Son birkaç saat dahil
      final endDate = DateTime.now().add(Duration(hours: 1)); // 1 saat ileri
      final startDate = endDate.subtract(Duration(days: days));
      
      final uri = Uri.parse(usgsApiUrl).replace(queryParameters: {
        'format': 'geojson',
        'limit': limit.toString(),
        'minmagnitude': minMagnitude.toString(),
        'starttime': startDate.toIso8601String(),
        'endtime': endDate.toIso8601String(),
        'orderby': 'time', // Doğru orderby parametresi
      });

      developer.log('USGS API (GÜNCEL TARİHLER): $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      
      developer.log('USGS API response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('features')) {
          final features = data['features'] as List;
          developer.log('USGS: ${features.length} deprem alındı (GÜNCEL TARİHLER)');
          
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
          developer.log('USGS API: features yok - ${data.toString()}');
        }
      } else {
        developer.log('USGS API HATASI: ${response.statusCode} - ${response.body}');
      }
      
      return [];
    } catch (e) {
      developer.log('USGS API exception: $e');
      return [];
    }
  }

  /// EMSC API - ÇALIŞAN VERSİYON
  Future<List<Earthquake>> _fetchEmscEarthquakes({
    required int limit,
    required double minMagnitude,
    required int days,
  }) async {
    try {
      final endDate = DateTime.now().add(Duration(hours: 1));
      final startDate = endDate.subtract(Duration(days: days));
      
      final uri = Uri.parse('https://www.seismicportal.eu/fdsnws/event/1/query').replace(queryParameters: {
        'format': 'json',
        'limit': limit.toString(),
        'minmag': minMagnitude.toString(),
        'start': startDate.toIso8601String().split('T')[0],
        'end': endDate.toIso8601String().split('T')[0],
      });

      developer.log('EMSC API (ÇALIŞAN): $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      
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
              id: properties['unid']?.toString() ?? 'emsc_${DateTime.now().millisecondsSinceEpoch}',
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
      
      return [];
    } catch (e) {
      developer.log('EMSC API exception: $e');
      return [];
    }
  }

  /// Duplikatları temizle
  List<Earthquake> _removeDuplicates(List<Earthquake> earthquakes) {
    final seen = <String>{};
    return earthquakes.where((earthquake) => seen.add(earthquake.id)).toList();
  }
}
