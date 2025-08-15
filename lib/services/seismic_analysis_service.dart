import 'dart:math';
import 'dart:developer' as developer;
import '../models/earthquake.dart';
import '../models/seismic_activity.dart';
import 'earthquake_service_real.dart';

class SeismicAnalysisService {
  
  final EarthquakeServiceReal _earthquakeService = EarthquakeServiceReal();

  // Küresel sismik aktivite analizi
  Future<SeismicActivity> getGlobalSeismicActivity() async {
    try {
      // Son 24 saatteki depremler
      final earthquakes = await _earthquakeService.getAllEarthquakes(
        minMagnitude: 1.0,
        days: 1,
        limit: 1000,
      );

      return _analyzeEarthquakeData(earthquakes, 'global');
    } catch (e) {
      developer.log('Küresel sismik aktivite analizi hatası: $e');
      return _getDefaultActivity();
    }
  }

  // Ülke bazlı sismik aktivite
  Future<CountrySeismicData> getCountrySeismicActivity(String countryCode) async {
    try {
      // Ülke koordinatlarına göre filtreleme yapılabilir
      final earthquakes = await _earthquakeService.getAllEarthquakes(
        minMagnitude: 1.0,
        days: 30,
        limit: 1000,
      );

      // Ülke bazlı filtreleme (basit yaklaşım - koordinat aralığına göre)
      final countryEarthquakes = _filterEarthquakesByCountry(earthquakes, countryCode);
      final currentActivity = _analyzeEarthquakeData(countryEarthquakes, countryCode);
      
      // Geçmiş veriler için örnek data
      final historicalData = await _getHistoricalData(countryCode);

      return CountrySeismicData(
        countryCode: countryCode,
        countryName: getCountryName(countryCode),
        currentActivity: currentActivity,
        historicalData: historicalData,
      );
    } catch (e) {
      developer.log('Ülke sismik aktivite analizi hatası: $e');
      return CountrySeismicData(
        countryCode: countryCode,
        countryName: getCountryName(countryCode),
        currentActivity: _getDefaultActivity(),
        historicalData: [],
      );
    }
  }

  // Sismik trend analizi
  Future<SeismicTrend> getSeismicTrend() async {
    try {
      final dailyData = <SeismicActivity>[];
      final monthlyData = <SeismicActivity>[];
      final yearlyData = <SeismicActivity>[];

      // Son 30 günlük günlük veriler
      for (int i = 29; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final earthquakes = await _getEarthquakesForDate(date);
        dailyData.add(_analyzeEarthquakeData(earthquakes, 'global', date));
        
        // Performans için her 5 günde bir veri al
        if (i % 5 == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      // Son 12 aylık veriler (örnek)
      for (int i = 11; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i * 30));
        monthlyData.add(SeismicActivity(
          date: date,
          totalEarthquakes: 50 + Random().nextInt(100),
          magnitude4Plus: 20 + Random().nextInt(30),
          magnitude5Plus: 5 + Random().nextInt(15),
          magnitude6Plus: 1 + Random().nextInt(5),
          magnitude7Plus: Random().nextInt(2),
          averageMagnitude: 3.5 + Random().nextDouble() * 2,
          region: 'global',
        ));
      }

      // Son 10 yıllık veriler (örnek)
      for (int i = 9; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i * 365));
        yearlyData.add(SeismicActivity(
          date: date,
          totalEarthquakes: 15000 + Random().nextInt(5000),
          magnitude4Plus: 2000 + Random().nextInt(1000),
          magnitude5Plus: 200 + Random().nextInt(300),
          magnitude6Plus: 20 + Random().nextInt(30),
          magnitude7Plus: 2 + Random().nextInt(8),
          averageMagnitude: 4.0 + Random().nextDouble() * 1.5,
          region: 'global',
        ));
      }

      return SeismicTrend(
        dailyData: dailyData,
        monthlyData: monthlyData,
        yearlyData: yearlyData,
      );
    } catch (e) {
      developer.log('Sismik analiz başlatılıyor...');
      return SeismicTrend(dailyData: [], monthlyData: [], yearlyData: []);
    }
  }

  // Belirli bir tarih için deprem verilerini al
  Future<List<Earthquake>> _getEarthquakesForDate(DateTime date) async {
    try {
      // Gerçek API'den veri almak yerine örnek veri üret
      final random = Random();
      final earthquakes = <Earthquake>[];
      
      final count = 10 + random.nextInt(40); // 10-50 arası deprem
      
      for (int i = 0; i < count; i++) {
        earthquakes.add(Earthquake(
          id: '${date.millisecondsSinceEpoch}_$i',
          magnitude: 1.0 + random.nextDouble() * 7.0,
          latitude: -90 + random.nextDouble() * 180,
          longitude: -180 + random.nextDouble() * 360,
          depth: random.nextDouble() * 700,
          time: date.add(Duration(hours: random.nextInt(24))),
          place: 'Sample Location $i',
          source: 'SAMPLE',
        ));
      }
      
      return earthquakes;
    } catch (e) {
      return [];
    }
  }

  // Deprem verilerini analiz et
  SeismicActivity _analyzeEarthquakeData(
    List<Earthquake> earthquakes, 
    String region, 
    [DateTime? date]
  ) {
    final analysisDate = date ?? DateTime.now();
    
    final magnitude4Plus = earthquakes.where((e) => e.magnitude >= 4.0).length;
    final magnitude5Plus = earthquakes.where((e) => e.magnitude >= 5.0).length;
    final magnitude6Plus = earthquakes.where((e) => e.magnitude >= 6.0).length;
    final magnitude7Plus = earthquakes.where((e) => e.magnitude >= 7.0).length;
    
    final averageMagnitude = earthquakes.isEmpty 
        ? 0.0 
        : earthquakes.map((e) => e.magnitude).reduce((a, b) => a + b) / earthquakes.length;

    return SeismicActivity(
      date: analysisDate,
      totalEarthquakes: earthquakes.length,
      magnitude4Plus: magnitude4Plus,
      magnitude5Plus: magnitude5Plus,
      magnitude6Plus: magnitude6Plus,
      magnitude7Plus: magnitude7Plus,
      averageMagnitude: averageMagnitude,
      region: region,
    );
  }

  // Ülkeye göre deprem filtrele (basit koordinat bazlı)
  List<Earthquake> _filterEarthquakesByCountry(List<Earthquake> earthquakes, String countryCode) {
    // Türkiye için örnek koordinat aralığı
    if (countryCode == 'TR') {
      return earthquakes.where((e) => 
        e.latitude >= 35.0 && e.latitude <= 42.0 &&
        e.longitude >= 25.0 && e.longitude <= 45.0
      ).toList();
    }
    
    // Diğer ülkeler için tüm depremleri döndür (geliştirilebilir)
    return earthquakes;
  }

  // Geçmiş veriler (örnek)
  Future<List<SeismicActivity>> _getHistoricalData(String countryCode) async {
    final historicalData = <SeismicActivity>[];
    final random = Random();
    
    // Son 30 günlük veriler
    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      historicalData.add(SeismicActivity(
        date: date,
        totalEarthquakes: 5 + random.nextInt(20),
        magnitude4Plus: 1 + random.nextInt(8),
        magnitude5Plus: random.nextInt(3),
        magnitude6Plus: random.nextInt(2),
        magnitude7Plus: 0,
        averageMagnitude: 2.5 + random.nextDouble() * 2,
        region: countryCode,
      ));
    }
    
    return historicalData;
  }

  // Varsayılan aktivite verisi
  SeismicActivity _getDefaultActivity() {
    return SeismicActivity(
      date: DateTime.now(),
      totalEarthquakes: 0,
      magnitude4Plus: 0,
      magnitude5Plus: 0,
      magnitude6Plus: 0,
      magnitude7Plus: 0,
      averageMagnitude: 0.0,
      region: 'unknown',
    );
  }

  // Ülke adını getir
  String getCountryName(String countryCode) {
    const countryNames = {
      'TR': 'Türkiye',
      'GR': 'Yunanistan',
      'IT': 'İtalya',
      'JP': 'Japonya',
      'US': 'Amerika Birleşik Devletleri',
      'CL': 'Şili',
      'ID': 'Endonezya',
      'IR': 'İran',
      'AF': 'Afganistan',
      'PK': 'Pakistan',
      'CN': 'Çin',
      'PH': 'Filipinler',
      'NZ': 'Yeni Zelanda',
      'MX': 'Meksika',
      'PE': 'Peru',
      'EC': 'Ekvador',
      'RO': 'Romanya',
      'AL': 'Arnavutluk',
      'BG': 'Bulgaristan',
      'HR': 'Hırvatistan',
      'RS': 'Sırbistan',
      'MK': 'Kuzey Makedonya',
      'ALL': 'Tüm Dünya',
      'global': 'Dünya',
    };
    
    return countryNames[countryCode] ?? countryCode;
  }

  // Büyüklük bazlı istatistikler
  Future<Map<String, dynamic>> getMagnitudeStatistics({
    String region = 'global',
    int days = 30,
  }) async {
    try {
      final earthquakes = await _earthquakeService.getAllEarthquakes(
        minMagnitude: 1.0,
        days: days,
        limit: 1000,
      );

      final filteredEarthquakes = region == 'global' 
          ? earthquakes 
          : _filterEarthquakesByCountry(earthquakes, region);

      return {
        'total': filteredEarthquakes.length,
        'magnitude_1_2': filteredEarthquakes.where((e) => e.magnitude >= 1.0 && e.magnitude < 2.0).length,
        'magnitude_2_3': filteredEarthquakes.where((e) => e.magnitude >= 2.0 && e.magnitude < 3.0).length,
        'magnitude_3_4': filteredEarthquakes.where((e) => e.magnitude >= 3.0 && e.magnitude < 4.0).length,
        'magnitude_4_5': filteredEarthquakes.where((e) => e.magnitude >= 4.0 && e.magnitude < 5.0).length,
        'magnitude_5_6': filteredEarthquakes.where((e) => e.magnitude >= 5.0 && e.magnitude < 6.0).length,
        'magnitude_6_7': filteredEarthquakes.where((e) => e.magnitude >= 6.0 && e.magnitude < 7.0).length,
        'magnitude_7_plus': filteredEarthquakes.where((e) => e.magnitude >= 7.0).length,
        'average_magnitude': filteredEarthquakes.isEmpty 
            ? 0.0 
            : filteredEarthquakes.map((e) => e.magnitude).reduce((a, b) => a + b) / filteredEarthquakes.length,
        'max_magnitude': filteredEarthquakes.isEmpty 
            ? 0.0 
            : filteredEarthquakes.map((e) => e.magnitude).reduce((a, b) => a > b ? a : b),
        'region': region,
        'period_days': days,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log('Büyüklük istatistikleri hatası: $e');
      return {
        'total': 0,
        'magnitude_1_2': 0,
        'magnitude_2_3': 0,
        'magnitude_3_4': 0,
        'magnitude_4_5': 0,
        'magnitude_5_6': 0,
        'magnitude_6_7': 0,
        'magnitude_7_plus': 0,
        'average_magnitude': 0.0,
        'max_magnitude': 0.0,
        'region': region,
        'period_days': days,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Ülke kodunu ülke ismine çevir
 
}
