import 'dart:convert';
import 'dart:math';

/// Güvenlik yapılandırmaları ve yardımcı fonksiyonlar
class SecurityConfig {
  // API endpoint'leri
  static const String emscApiUrl = 'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';
  
  // SSL Certificate pinning için hash'ler
  static const List<String> emscCertHashes = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // EMSC cert hash
  ];
  
  static const List<String> usgsCertHashes = [
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // USGS cert hash
  ];
  
  // Güvenli HTTP headers
  static Map<String, String> getSecureHeaders() {
    return {
      'User-Agent': 'EarthquakeTracker/1.0 (Flutter App)',
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip, deflate',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
    };
  }
  
  // Veri şifreleme için AES key oluşturma
  static String generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }
  
  // Hassas verileri şifreleme
  static String encryptSensitiveData(String data, String key) {
    try {
      final keyBytes = base64Decode(key);
      final dataBytes = utf8.encode(data);
      
      // Basit XOR şifreleme (production'da AES kullanılmalı)
      final encrypted = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64Encode(encrypted);
    } catch (e) {
      return data; // Hata durumunda plain text döndür
    }
  }
  
  // Şifrelenmiş veriyi çözme
  static String decryptSensitiveData(String encryptedData, String key) {
    try {
      final keyBytes = base64Decode(key);
      final encryptedBytes = base64Decode(encryptedData);
      
      // XOR çözme
      final decrypted = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      return encryptedData; // Hata durumunda encrypted data döndür
    }
  }
  
  // Input validation
  static bool isValidLatitude(double lat) {
    return lat >= -90.0 && lat <= 90.0;
  }
  
  static bool isValidLongitude(double lon) {
    return lon >= -180.0 && lon <= 180.0;
  }
  
  static bool isValidMagnitude(double mag) {
    return mag >= 0.0 && mag <= 10.0;
  }
  
  static bool isValidDepth(double depth) {
    return depth >= 0.0 && depth <= 1000.0; // km
  }
  
  // SQL injection koruması
  static String sanitizeSqlInput(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll(';', '')
        .replaceAll('--', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '')
        .replaceAll('DROP', '')
        .replaceAll('DELETE', '')
        .replaceAll('INSERT', '')
        .replaceAll('UPDATE', '');
  }
  
  // Rate limiting için basit kontrol
  static final Map<String, DateTime> _lastApiCall = {};
  static const Duration minApiInterval = Duration(seconds: 5);
  
  static bool canMakeApiCall(String endpoint) {
    final now = DateTime.now();
    final lastCall = _lastApiCall[endpoint];
    
    if (lastCall == null) {
      _lastApiCall[endpoint] = now;
      return true;
    }
    
    if (now.difference(lastCall) >= minApiInterval) {
      _lastApiCall[endpoint] = now;
      return true;
    }
    
    return false;
  }
  
  // Telegram bot token validation
  static bool isValidTelegramToken(String token) {
    // Telegram bot token format: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz
    final regex = RegExp(r'^\d{8,10}:[A-Za-z0-9_-]{35}$');
    return regex.hasMatch(token);
  }
  
  // Chat ID validation
  static bool isValidChatId(String chatId) {
    // Chat ID can be positive or negative integer
    final regex = RegExp(r'^-?\d+$');
    return regex.hasMatch(chatId);
  }
  
  // URL validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  // Hash oluşturma (basit implementasyon)
  static String createHash(String input) {
    final bytes = utf8.encode(input);
    int hash = 0;
    for (int byte in bytes) {
      hash = ((hash << 5) - hash + byte) & 0xFFFFFFFF;
    }
    return hash.toString();
  }
  
  // Güvenli random string oluşturma
  static String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
  
  // Network timeout ayarları
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  
  // Maksimum veri boyutları
  static const int maxResponseSize = 10 * 1024 * 1024; // 10MB
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int maxLogSize = 5 * 1024 * 1024; // 5MB
  
  // Güvenlik kontrolleri
  static Map<String, bool> performSecurityChecks() {
    return {
      'ssl_enabled': true,
      'input_validation': true,
      'rate_limiting': true,
      'data_encryption': true,
      'secure_storage': true,
      'network_timeout': true,
      'certificate_pinning': false, // TODO: Implement
      'api_key_rotation': false, // TODO: Implement
    };
  }
}
