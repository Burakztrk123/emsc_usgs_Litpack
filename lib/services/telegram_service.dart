import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake.dart';

class TelegramService {
  static const String _botTokenKey = 'telegram_bot_token';
  static const String _chatIdKey = 'telegram_chat_id';
  static const String _notificationsEnabledKey = 'telegram_notifications_enabled';
  static const String _minMagnitudeKey = 'telegram_min_magnitude';
  
  // Telegram Bot API URL
  static const String _telegramApiUrl = 'https://api.telegram.org/bot';
  
  // Bot token ve chat ID kaydet
  static Future<void> saveTelegramCredentials(String botToken, String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_botTokenKey, botToken);
    await prefs.setString(_chatIdKey, chatId);
  }
  
  // Bot token al
  static Future<String?> getBotToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_botTokenKey);
  }
  
  // Chat ID al
  static Future<String?> getChatId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chatIdKey);
  }
  
  // Bildirimleri etkinleştir/devre dışı bırak
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
  
  // Bildirimlerin etkin olup olmadığını kontrol et
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }
  
  // Minimum bildirim büyüklüğünü ayarla
  static Future<void> setMinNotificationMagnitude(double magnitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_minMagnitudeKey, magnitude);
  }
  
  // Minimum bildirim büyüklüğünü al
  static Future<double> getMinNotificationMagnitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_minMagnitudeKey) ?? 4.0;
  }
  
  // Telegram'a mesaj gönder
  static Future<bool> sendMessage(String message) async {
    final botToken = await getBotToken();
    final chatId = await getChatId();
    
    if (botToken == null || chatId == null) {
      return false;
    }
    
    final url = Uri.parse('$_telegramApiUrl$botToken/sendMessage');
    
    try {
      final response = await http.post(
        url,
        body: {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Telegram bildirimi gönderildi: $message', name: 'TelegramService');
      return false;
    }
  }
  
  // Deprem bildirimi gönder
  static Future<bool> sendEarthquakeNotification(Earthquake earthquake, double distanceKm) async {
    if (!(await areNotificationsEnabled())) {
      return false;
    }
    
    final minMagnitude = await getMinNotificationMagnitude();
    if (earthquake.magnitude < minMagnitude) {
      return false;
    }
    
    final message = '''
🚨 <b>DEPREM BİLDİRİMİ!</b> 🚨

📍 <b>Konum:</b> ${earthquake.place}
📏 <b>Büyüklük:</b> ${earthquake.magnitude.toStringAsFixed(1)}
🕳️ <b>Derinlik:</b> ${earthquake.depth.toStringAsFixed(1)} km
🕒 <b>Zaman:</b> ${earthquake.time.toString().substring(0, 19)}
🔍 <b>Koordinatlar:</b> ${earthquake.latitude.toStringAsFixed(4)}, ${earthquake.longitude.toStringAsFixed(4)}
📊 <b>Kaynak:</b> ${earthquake.source}
📍 <b>Uzaklık:</b> ${distanceKm.toStringAsFixed(1)} km
''';
    
    return await sendMessage(message);
  }
  
  // Bot token geçerliliğini kontrol et
  static Future<bool> validateBotToken(String botToken) async {
    final url = Uri.parse('$_telegramApiUrl$botToken/getMe');
    
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      return data['ok'] == true;
    } catch (e) {
      return false;
    }
  }
}
