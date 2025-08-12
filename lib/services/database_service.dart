import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/earthquake.dart';
import '../models/earthquake_report.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'earthquake_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Depremler tablosu
    await db.execute('''
      CREATE TABLE earthquakes (
        id TEXT PRIMARY KEY,
        magnitude REAL NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        depth REAL NOT NULL,
        time INTEGER NOT NULL,
        place TEXT NOT NULL,
        source TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Kullanıcı raporları tablosu
    await db.execute('''
      CREATE TABLE earthquake_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        earthquake_id TEXT,
        user_latitude REAL NOT NULL,
        user_longitude REAL NOT NULL,
        intensity INTEGER NOT NULL,
        description TEXT,
        felt_time INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Bildirim geçmişi tablosu
    await db.execute('''
      CREATE TABLE notification_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        earthquake_id TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        sent_at INTEGER NOT NULL,
        is_successful INTEGER NOT NULL
      )
    ''');

    // Kullanıcı ayarları tablosu
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Sismik aktivite önbelleği tablosu
    await db.execute('''
      CREATE TABLE seismic_activity_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        region TEXT NOT NULL,
        date INTEGER NOT NULL,
        total_earthquakes INTEGER NOT NULL,
        magnitude_4_plus INTEGER NOT NULL,
        magnitude_5_plus INTEGER NOT NULL,
        magnitude_6_plus INTEGER NOT NULL,
        magnitude_7_plus INTEGER NOT NULL,
        average_magnitude REAL NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');

    // İndeksler oluştur
    await db.execute('CREATE INDEX idx_earthquakes_time ON earthquakes(time)');
    await db.execute('CREATE INDEX idx_earthquakes_magnitude ON earthquakes(magnitude)');
    await db.execute('CREATE INDEX idx_earthquakes_source ON earthquakes(source)');
    await db.execute('CREATE INDEX idx_reports_earthquake_id ON earthquake_reports(earthquake_id)');
    await db.execute('CREATE INDEX idx_notifications_earthquake_id ON notification_history(earthquake_id)');
    await db.execute('CREATE INDEX idx_seismic_cache_region_date ON seismic_activity_cache(region, date)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gelecekteki versiyonlar için upgrade mantığı
    if (oldVersion < 2) {
      // Örnek: Yeni sütun ekleme
      // await db.execute('ALTER TABLE earthquakes ADD COLUMN new_column TEXT');
    }
  }

  // DEPREM VERİLERİ İŞLEMLERİ
  
  /// Deprem verilerini veritabanına kaydet
  Future<int> insertEarthquake(Earthquake earthquake) async {
    final db = await database;
    
    final earthquakeMap = {
      'id': earthquake.id,
      'magnitude': earthquake.magnitude,
      'latitude': earthquake.latitude,
      'longitude': earthquake.longitude,
      'depth': earthquake.depth,
      'time': earthquake.time.millisecondsSinceEpoch,
      'place': earthquake.place,
      'source': earthquake.source,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_favorite': 0,
    };

    return await db.insert(
      'earthquakes',
      earthquakeMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Birden fazla depremi toplu olarak kaydet
  Future<void> insertEarthquakes(List<Earthquake> earthquakes) async {
    final db = await database;
    final batch = db.batch();

    for (final earthquake in earthquakes) {
      final earthquakeMap = {
        'id': earthquake.id,
        'magnitude': earthquake.magnitude,
        'latitude': earthquake.latitude,
        'longitude': earthquake.longitude,
        'depth': earthquake.depth,
        'time': earthquake.time.millisecondsSinceEpoch,
        'place': earthquake.place,
        'source': earthquake.source,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'is_favorite': 0,
      };

      batch.insert(
        'earthquakes',
        earthquakeMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Depremleri getir (filtreleme ve sıralama ile)
  Future<List<Earthquake>> getEarthquakes({
    double? minMagnitude,
    double? maxMagnitude,
    String? source,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    String orderBy = 'time DESC',
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (minMagnitude != null) {
      whereClause += ' AND magnitude >= ?';
      whereArgs.add(minMagnitude);
    }

    if (maxMagnitude != null) {
      whereClause += ' AND magnitude <= ?';
      whereArgs.add(maxMagnitude);
    }

    if (source != null) {
      whereClause += ' AND source = ?';
      whereArgs.add(source);
    }

    if (startDate != null) {
      whereClause += ' AND time >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND time <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    String query = 'SELECT * FROM earthquakes WHERE $whereClause ORDER BY $orderBy';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      return Earthquake(
        id: maps[i]['id'],
        magnitude: maps[i]['magnitude'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        depth: maps[i]['depth'],
        time: DateTime.fromMillisecondsSinceEpoch(maps[i]['time']),
        place: maps[i]['place'],
        source: maps[i]['source'],
      );
    });
  }

  /// Belirli bir depremi getir
  Future<Earthquake?> getEarthquakeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'earthquakes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Earthquake(
        id: maps[0]['id'],
        magnitude: maps[0]['magnitude'],
        latitude: maps[0]['latitude'],
        longitude: maps[0]['longitude'],
        depth: maps[0]['depth'],
        time: DateTime.fromMillisecondsSinceEpoch(maps[0]['time']),
        place: maps[0]['place'],
        source: maps[0]['source'],
      );
    }
    return null;
  }

  /// Favori depremleri getir
  Future<List<Earthquake>> getFavoriteEarthquakes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'earthquakes',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'time DESC',
    );

    return List.generate(maps.length, (i) {
      return Earthquake(
        id: maps[i]['id'],
        magnitude: maps[i]['magnitude'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        depth: maps[i]['depth'],
        time: DateTime.fromMillisecondsSinceEpoch(maps[i]['time']),
        place: maps[i]['place'],
        source: maps[i]['source'],
      );
    });
  }

  /// Depremi favorilere ekle/çıkar
  Future<int> toggleEarthquakeFavorite(String earthquakeId) async {
    final db = await database;
    
    // Mevcut favori durumunu kontrol et
    final List<Map<String, dynamic>> result = await db.query(
      'earthquakes',
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [earthquakeId],
    );

    if (result.isNotEmpty) {
      final currentFavorite = result[0]['is_favorite'] as int;
      final newFavorite = currentFavorite == 1 ? 0 : 1;
      
      return await db.update(
        'earthquakes',
        {'is_favorite': newFavorite},
        where: 'id = ?',
        whereArgs: [earthquakeId],
      );
    }
    return 0;
  }

  /// Eski deprem verilerini temizle
  Future<int> cleanOldEarthquakes({int daysToKeep = 90}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    return await db.delete(
      'earthquakes',
      where: 'time < ? AND is_favorite = 0',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // KULLANICI RAPORU İŞLEMLERİ

  /// Kullanıcı raporunu kaydet
  Future<int> insertEarthquakeReport(EarthquakeReport report) async {
    final db = await database;
    
    final reportMap = {
      'earthquake_id': report.id,
      'user_latitude': report.latitude,
      'user_longitude': report.longitude,
      'intensity': report.intensity,
      'description': report.observations.join(', '),
      'felt_time': report.earthquakeTime.millisecondsSinceEpoch,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_synced': 0,
    };

    return await db.insert('earthquake_reports', reportMap);
  }

  /// Kullanıcı raporlarını getir
  Future<List<EarthquakeReport>> getEarthquakeReports({
    String? earthquakeId,
    bool? onlyUnsynced,
    int? limit,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (earthquakeId != null) {
      whereClause += ' AND earthquake_id = ?';
      whereArgs.add(earthquakeId);
    }

    if (onlyUnsynced == true) {
      whereClause += ' AND is_synced = 0';
    }

    String query = 'SELECT * FROM earthquake_reports WHERE $whereClause ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      return EarthquakeReport(
        id: maps[i]['id'].toString(),
        latitude: maps[i]['user_latitude'],
        longitude: maps[i]['user_longitude'],
        location: 'Kullanıcı Konumu',
        reportTime: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at']),
        earthquakeTime: DateTime.fromMillisecondsSinceEpoch(maps[i]['felt_time']),
        intensity: maps[i]['intensity'],
        observations: maps[i]['description']?.split(', ') ?? [],
        reporterName: 'Kullanıcı',
      );
    });
  }

  /// Raporu senkronize edildi olarak işaretle
  Future<int> markReportAsSynced(int reportId) async {
    final db = await database;
    return await db.update(
      'earthquake_reports',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // BİLDİRİM GEÇMİŞİ İŞLEMLERİ

  /// Bildirim geçmişini kaydet
  Future<int> insertNotificationHistory({
    required String earthquakeId,
    required String notificationType,
    required bool isSuccessful,
  }) async {
    final db = await database;
    
    final notificationMap = {
      'earthquake_id': earthquakeId,
      'notification_type': notificationType,
      'sent_at': DateTime.now().millisecondsSinceEpoch,
      'is_successful': isSuccessful ? 1 : 0,
    };

    return await db.insert('notification_history', notificationMap);
  }

  /// Bildirim geçmişini getir
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    String? earthquakeId,
    int? limit = 100,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (earthquakeId != null) {
      whereClause += ' AND earthquake_id = ?';
      whereArgs.add(earthquakeId);
    }

    String query = 'SELECT * FROM notification_history WHERE $whereClause ORDER BY sent_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
    }

    return await db.rawQuery(query, whereArgs);
  }

  // İSTATİSTİK VE ANALİZ İŞLEMLERİ

  /// Deprem istatistiklerini getir
  Future<Map<String, dynamic>> getEarthquakeStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND time >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND time <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        AVG(magnitude) as avg_magnitude,
        MAX(magnitude) as max_magnitude,
        MIN(magnitude) as min_magnitude,
        AVG(depth) as avg_depth,
        COUNT(CASE WHEN magnitude >= 4.0 THEN 1 END) as magnitude_4_plus,
        COUNT(CASE WHEN magnitude >= 5.0 THEN 1 END) as magnitude_5_plus,
        COUNT(CASE WHEN magnitude >= 6.0 THEN 1 END) as magnitude_6_plus,
        COUNT(CASE WHEN magnitude >= 7.0 THEN 1 END) as magnitude_7_plus,
        COUNT(CASE WHEN source = 'EMSC' THEN 1 END) as emsc_count,
        COUNT(CASE WHEN source = 'USGS' THEN 1 END) as usgs_count
      FROM earthquakes 
      WHERE $whereClause
    ''', whereArgs);

    return result.isNotEmpty ? result[0] : {};
  }

  /// Günlük deprem sayılarını getir (grafik için)
  Future<List<Map<String, dynamic>>> getDailyEarthquakeCounts({
    required int days,
  }) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));

    return await db.rawQuery('''
      SELECT 
        DATE(time/1000, 'unixepoch') as date,
        COUNT(*) as count,
        AVG(magnitude) as avg_magnitude,
        MAX(magnitude) as max_magnitude
      FROM earthquakes 
      WHERE time >= ?
      GROUP BY DATE(time/1000, 'unixepoch')
      ORDER BY date ASC
    ''', [startDate.millisecondsSinceEpoch]);
  }

  /// Büyüklük dağılımını getir
  Future<List<Map<String, dynamic>>> getMagnitudeDistribution() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT 
        CASE 
          WHEN magnitude < 2.0 THEN '0-2'
          WHEN magnitude < 3.0 THEN '2-3'
          WHEN magnitude < 4.0 THEN '3-4'
          WHEN magnitude < 5.0 THEN '4-5'
          WHEN magnitude < 6.0 THEN '5-6'
          WHEN magnitude < 7.0 THEN '6-7'
          ELSE '7+'
        END as magnitude_range,
        COUNT(*) as count
      FROM earthquakes 
      GROUP BY magnitude_range
      ORDER BY magnitude_range ASC
    ''');
  }

  // VERİTABANI YÖNETİMİ

  /// Veritabanını temizle
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('earthquakes');
    await db.delete('earthquake_reports');
    await db.delete('notification_history');
    await db.delete('seismic_activity_cache');
  }

  /// Veritabanı boyutunu getir
  Future<int> getDatabaseSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()');
    return result.isNotEmpty ? result[0]['size'] as int : 0;
  }

  /// Veritabanını kapat
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
