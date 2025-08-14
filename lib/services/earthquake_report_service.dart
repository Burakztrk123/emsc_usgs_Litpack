import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake_report.dart';

class EarthquakeReportService {
  static const String _reportsKey = 'earthquake_reports';

  // Deprem bildirimini kaydet
  static Future<bool> saveReport(EarthquakeReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await getReports();
      reports.add(report);
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, json.encode(reportsJson));
      
      return true;
    } catch (e) {
      developer.log('Deprem bildirimi kaydedilemedi: $e', name: 'EarthquakeReportService');
      return false;
    }
  }

  // Tüm deprem bildirimlerini getir
  static Future<List<EarthquakeReport>> getReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsString = prefs.getString(_reportsKey);
      
      if (reportsString == null) return [];
      
      final reportsJson = json.decode(reportsString) as List;
      return reportsJson.map((json) => EarthquakeReport.fromJson(json)).toList();
    } catch (e) {
      developer.log('Deprem bildirimleri yüklenemedi: $e', name: 'EarthquakeReportService');
      return [];
    }
  }

  // Belirli bir bildirimi sil
  static Future<bool> deleteReport(String reportId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await getReports();
      reports.removeWhere((report) => report.id == reportId);
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, json.encode(reportsJson));
      
      return true;
    } catch (e) {
      developer.log('Deprem bildirimi silinemedi: $e', name: 'EarthquakeReportService');
      return false;
    }
  }

  // Tüm bildirimleri sil
  static Future<bool> clearAllReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reportsKey);
      return true;
    } catch (e) {
      developer.log('Tüm deprem bildirimleri silinemedi: $e', name: 'EarthquakeReportService');
      return false;
    }
  }

  // Son 24 saatteki bildirimleri getir
  static Future<List<EarthquakeReport>> getRecentReports() async {
    final reports = await getReports();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    
    return reports.where((report) => 
      report.reportTime.isAfter(yesterday)
    ).toList();
  }

  // Bildirimi e-posta formatında hazırla
  static String formatReportForEmail(EarthquakeReport report) {
    return '''
Deprem Bildirimi

Bildirim ID: ${report.id}
Bildirim Tarihi: ${report.reportTime.toString()}
Deprem Tarihi/Saati: ${report.earthquakeTime.toString()}

Konum Bilgileri:
- Adres: ${report.location}
- Koordinatlar: ${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}

Şiddet Algısı: ${report.getIntensityText()}

Gözlemler:
${report.getObservationsText()}

Bildiren Kişi: ${report.reporterName}
${report.contactEmail != null ? 'E-posta: ${report.contactEmail}' : ''}
${report.contactPhone != null ? 'Telefon: ${report.contactPhone}' : ''}

Bu bildirim otomatik olarak oluşturulmuştur.
    ''';
  }
}
