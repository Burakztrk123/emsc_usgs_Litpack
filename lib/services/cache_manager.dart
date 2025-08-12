import 'dart:developer' as developer;
import 'database_service.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory CacheManager() {
    return _instance;
  }

  CacheManager._internal();

  // Önbellek durumunu kontrol et
  Future<CacheStatus> getCacheStatus() async {
    try {
      final stats = await _databaseService.getEarthquakeStatistics();
      final dbSize = await _databaseService.getDatabaseSize();
      
      final totalEarthquakes = stats['total_count'] ?? 0;
      final oldestEarthquake = await _getOldestEarthquakeDate();
      final newestEarthquake = await _getNewestEarthquakeDate();
      
      return CacheStatus(
        totalEarthquakes: totalEarthquakes,
        databaseSizeBytes: dbSize,
        oldestEarthquakeDate: oldestEarthquake,
        newestEarthquakeDate: newestEarthquake,
        emscCount: stats['emsc_count'] ?? 0,
        usgsCount: stats['usgs_count'] ?? 0,
      );
    } catch (e) {
      developer.log('Cache status hatası: $e');
      return CacheStatus.empty();
    }
  }

  // En eski deprem tarihini getir
  Future<DateTime?> _getOldestEarthquakeDate() async {
    try {
      final earthquakes = await _databaseService.getEarthquakes(
        limit: 1,
        orderBy: 'time ASC',
      );
      return earthquakes.isNotEmpty ? earthquakes.first.time : null;
    } catch (e) {
      return null;
    }
  }

  // En yeni deprem tarihini getir
  Future<DateTime?> _getNewestEarthquakeDate() async {
    try {
      final earthquakes = await _databaseService.getEarthquakes(
        limit: 1,
        orderBy: 'time DESC',
      );
      return earthquakes.isNotEmpty ? earthquakes.first.time : null;
    } catch (e) {
      return null;
    }
  }

  // Önbelleği temizle
  Future<bool> clearCache() async {
    try {
      await _databaseService.clearDatabase();
      developer.log('Önbellek temizlendi');
      return true;
    } catch (e) {
      developer.log('Önbellek temizleme hatası: $e');
      return false;
    }
  }

  // Eski verileri temizle
  Future<int> cleanOldData({int daysToKeep = 90}) async {
    try {
      final deletedCount = await _databaseService.cleanOldEarthquakes(
        daysToKeep: daysToKeep,
      );
      developer.log('$deletedCount eski deprem verisi temizlendi');
      return deletedCount;
    } catch (e) {
      developer.log('Eski veri temizleme hatası: $e');
      return 0;
    }
  }

  // Önbellek optimizasyonu
  Future<void> optimizeCache() async {
    try {
      // Eski verileri temizle (90 günden eski)
      await cleanOldData(daysToKeep: 90);
      
      // Veritabanı boyutunu kontrol et
      final dbSize = await _databaseService.getDatabaseSize();
      final maxSizeMB = 50; // 50MB maksimum boyut
      
      if (dbSize > maxSizeMB * 1024 * 1024) {
        // Eğer veritabanı çok büyükse, daha agresif temizlik yap
        await cleanOldData(daysToKeep: 30);
        developer.log('Veritabanı boyutu büyük, agresif temizlik yapıldı');
      }
      
      developer.log('Önbellek optimizasyonu tamamlandı');
    } catch (e) {
      developer.log('Önbellek optimizasyon hatası: $e');
    }
  }
}

// Cache durumu modeli
class CacheStatus {
  final int totalEarthquakes;
  final int databaseSizeBytes;
  final DateTime? oldestEarthquakeDate;
  final DateTime? newestEarthquakeDate;
  final int emscCount;
  final int usgsCount;

  CacheStatus({
    required this.totalEarthquakes,
    required this.databaseSizeBytes,
    this.oldestEarthquakeDate,
    this.newestEarthquakeDate,
    required this.emscCount,
    required this.usgsCount,
  });

  factory CacheStatus.empty() {
    return CacheStatus(
      totalEarthquakes: 0,
      databaseSizeBytes: 0,
      emscCount: 0,
      usgsCount: 0,
    );
  }

  double get databaseSizeMB => databaseSizeBytes / (1024 * 1024);
  
  String get formattedSize {
    if (databaseSizeMB < 1) {
      return '${(databaseSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${databaseSizeMB.toStringAsFixed(1)} MB';
    }
  }
}

// Cache sağlık durumu modeli
class CacheHealth {
  final bool isHealthy;
  final bool hasRecentData;
  final bool hasBalancedSources;
  final bool isSizeOptimal;
  final double databaseSizeMB;
  final List<String> recommendations;

  CacheHealth({
    required this.isHealthy,
    required this.hasRecentData,
    required this.hasBalancedSources,
    required this.isSizeOptimal,
    required this.databaseSizeMB,
    required this.recommendations,
  });

  factory CacheHealth.unhealthy() {
    return CacheHealth(
      isHealthy: false,
      hasRecentData: false,
      hasBalancedSources: false,
      isSizeOptimal: false,
      databaseSizeMB: 0,
      recommendations: ['Veritabanı durumu kontrol edilemiyor'],
    );
  }
}
