class EarthquakeReport {
  final String id;
  final double latitude;
  final double longitude;
  final String location;
  final DateTime reportTime;
  final DateTime earthquakeTime;
  final String intensity; // 'very_light', 'light', 'moderate', 'strong', 'very_strong'
  final List<String> observations;
  final String? contactEmail;
  final String? contactPhone;
  final String reporterName;

  EarthquakeReport({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.reportTime,
    required this.earthquakeTime,
    required this.intensity,
    required this.observations,
    this.contactEmail,
    this.contactPhone,
    required this.reporterName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'reportTime': reportTime.toIso8601String(),
      'earthquakeTime': earthquakeTime.toIso8601String(),
      'intensity': intensity,
      'observations': observations,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'reporterName': reporterName,
    };
  }

  factory EarthquakeReport.fromJson(Map<String, dynamic> json) {
    return EarthquakeReport(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
      reportTime: DateTime.parse(json['reportTime']),
      earthquakeTime: DateTime.parse(json['earthquakeTime']),
      intensity: json['intensity'],
      observations: List<String>.from(json['observations']),
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      reporterName: json['reporterName'],
    );
  }

  String getIntensityText() {
    switch (intensity) {
      case 'very_light':
        return 'Çok Hafif';
      case 'light':
        return 'Hafif';
      case 'moderate':
        return 'Orta';
      case 'strong':
        return 'Şiddetli';
      case 'very_strong':
        return 'Çok Şiddetli';
      default:
        return 'Bilinmiyor';
    }
  }

  String getObservationsText() {
    if (observations.isEmpty) return 'Gözlem belirtilmedi';
    return observations.join(', ');
  }
}
