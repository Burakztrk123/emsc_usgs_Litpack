class SeismicActivity {
  final DateTime date;
  final int totalEarthquakes;
  final int magnitude4Plus;
  final int magnitude5Plus;
  final int magnitude6Plus;
  final int magnitude7Plus;
  final double averageMagnitude;
  final String region; // 'global' veya ülke kodu

  SeismicActivity({
    required this.date,
    required this.totalEarthquakes,
    required this.magnitude4Plus,
    required this.magnitude5Plus,
    required this.magnitude6Plus,
    required this.magnitude7Plus,
    required this.averageMagnitude,
    required this.region,
  });

  // Aktivite seviyesini hesapla (0-100 arası)
  int getActivityLevel() {
    // Son 30 günün ortalamasına göre aktivite seviyesi
    if (totalEarthquakes >= 100) return 100;
    if (totalEarthquakes >= 80) return 80;
    if (totalEarthquakes >= 60) return 60;
    if (totalEarthquakes >= 40) return 40;
    if (totalEarthquakes >= 20) return 20;
    return 10;
  }

  // Aktivite durumu metni
  String getActivityStatus() {
    final level = getActivityLevel();
    if (level >= 80) return 'Çok Yüksek';
    if (level >= 60) return 'Yüksek';
    if (level >= 40) return 'Normal';
    if (level >= 20) return 'Düşük';
    return 'Çok Düşük';
  }

  // Aktivite rengi
  String getActivityColor() {
    final level = getActivityLevel();
    if (level >= 80) return '#FF0000'; // Kırmızı
    if (level >= 60) return '#FF8C00'; // Turuncu
    if (level >= 40) return '#FFD700'; // Sarı
    if (level >= 20) return '#90EE90'; // Açık yeşil
    return '#00FF00'; // Yeşil
  }
}

class SeismicTrend {
  final List<SeismicActivity> dailyData;
  final List<SeismicActivity> monthlyData;
  final List<SeismicActivity> yearlyData;

  SeismicTrend({
    required this.dailyData,
    required this.monthlyData,
    required this.yearlyData,
  });

  // Trend yönünü hesapla
  String getTrendDirection() {
    if (dailyData.length < 2) return 'Stable';
    
    final recent = dailyData.last.totalEarthquakes;
    final previous = dailyData[dailyData.length - 2].totalEarthquakes;
    
    if (recent > previous * 1.1) return 'Increasing';
    if (recent < previous * 0.9) return 'Decreasing';
    return 'Stable';
  }

  // Trend yüzdesi
  double getTrendPercentage() {
    if (dailyData.length < 2) return 0.0;
    
    final recent = dailyData.last.totalEarthquakes;
    final previous = dailyData[dailyData.length - 2].totalEarthquakes;
    
    if (previous == 0) return 0.0;
    return ((recent - previous) / previous * 100);
  }
}

class CountrySeismicData {
  final String countryCode;
  final String countryName;
  final SeismicActivity currentActivity;
  final List<SeismicActivity> historicalData;

  CountrySeismicData({
    required this.countryCode,
    required this.countryName,
    required this.currentActivity,
    required this.historicalData,
  });
}
