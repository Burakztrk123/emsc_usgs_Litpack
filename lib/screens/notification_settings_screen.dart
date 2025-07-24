import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/telegram_service.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _notificationsEnabled = true; // Varsayılan olarak bildirimleri etkinleştir
  double _radius = 100.0;
  double _minMagnitude = 4.0;
  LatLng _userLocation = const LatLng(41.0082, 28.9784); // İstanbul varsayılan
  final TextEditingController _botTokenController = TextEditingController(text: '7965478820:AAGyhJzEPcfmCh2l9QLBewRTeRHUvV1QwS8');
  final TextEditingController _chatIdController = TextEditingController();
  bool _isValidatingToken = false;
  bool _isTokenValid = true; // Bot token'ın geçerli olduğunu biliyoruz
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Konum ayarlarını yükle
      final userLocation = await LocationService.getSavedUserLocation();
      final radius = await LocationService.getSavedNotificationRadius();
      
      // Telegram ayarlarını yükle
      final botToken = await TelegramService.getBotToken();
      final chatId = await TelegramService.getChatId();
      final notificationsEnabled = await TelegramService.areNotificationsEnabled();
      final minMagnitude = await TelegramService.getMinNotificationMagnitude();
      
      setState(() {
        _userLocation = userLocation;
        _radius = radius;
        _notificationsEnabled = notificationsEnabled;
        _minMagnitude = minMagnitude;
        
        if (botToken != null) {
          _botTokenController.text = botToken;
        }
        
        if (chatId != null) {
          _chatIdController.text = chatId;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar yüklenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      
      // Konumu kaydet
      await LocationService.saveUserLocation(position.latitude, position.longitude);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum güncellendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    }
  }
  
  Future<void> _validateBotToken() async {
    final token = _botTokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir bot token girin')),
      );
      return;
    }
    
    setState(() {
      _isValidatingToken = true;
    });
    
    try {
      final isValid = await TelegramService.validateBotToken(token);
      
      setState(() {
        _isTokenValid = isValid;
        _isValidatingToken = false;
      });
      
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bot token geçerli')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bot token geçersiz')),
        );
      }
    } catch (e) {
      setState(() {
        _isValidatingToken = false;
        _isTokenValid = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token doğrulanamadı: $e')),
      );
    }
  }
  
  Future<void> _saveSettings() async {
    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();
    
    if (botToken.isEmpty || chatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bot token ve chat ID girin')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Konum ayarlarını kaydet
      await LocationService.saveUserLocation(_userLocation.latitude, _userLocation.longitude);
      await LocationService.saveNotificationRadius(_radius);
      
      // Telegram ayarlarını kaydet
      await TelegramService.saveTelegramCredentials(botToken, chatId);
      await TelegramService.setNotificationsEnabled(_notificationsEnabled);
      await TelegramService.setMinNotificationMagnitude(_minMagnitude);
      
      // Bildirimler etkinse arka plan görevini başlat, değilse durdur
      if (_notificationsEnabled) {
        await NotificationService.initializeBackgroundTask();
      } else {
        await NotificationService.stopBackgroundTask();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar kaydedildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar kaydedilemedi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Bildirim açma/kapama
                  SwitchListTile(
                    title: const Text('Telegram Bildirimleri'),
                    subtitle: const Text('Yakındaki depremler için bildirim al'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  
                  const Divider(),
                  
                  // Konum ayarları
                  const Text(
                    'Konum Ayarları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enlem: ${_userLocation.latitude.toStringAsFixed(4)}'),
                          Text('Boylam: ${_userLocation.longitude.toStringAsFixed(4)}'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Mevcut Konumu Kullan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Yarıçap ayarı
                  Text(
                    'Bildirim Yarıçapı: ${_radius.toStringAsFixed(0)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _radius,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: '${_radius.toStringAsFixed(0)} km',
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Minimum büyüklük ayarı
                  Text(
                    'Minimum Deprem Büyüklüğü: ${_minMagnitude.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _minMagnitude,
                    min: 1.0,
                    max: 7.0,
                    divisions: 12,
                    label: _minMagnitude.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _minMagnitude = value;
                      });
                    },
                  ),
                  
                  const Divider(),
                  
                  // Telegram ayarları
                  const Text(
                    'Telegram Ayarları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Telegram Bot Token:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _botTokenController,
                            decoration: InputDecoration(
                              hintText: 'Örn: 1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                              suffixIcon: _isValidatingToken
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : _botTokenController.text.isNotEmpty
                                      ? Icon(
                                          _isTokenValid ? Icons.check_circle : Icons.error,
                                          color: _isTokenValid ? Colors.green : Colors.red,
                                        )
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _validateBotToken,
                            child: const Text('Token Doğrula'),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          const Text(
                            'Chat ID:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _chatIdController,
                            decoration: const InputDecoration(
                              hintText: 'Örn: 123456789',
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          const Text(
                            'Nasıl Telegram Bot oluşturulur?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '1. Telegram\'da @BotFather ile konuşma başlat\n'
                            '2. /newbot komutunu gönder\n'
                            '3. Bot için bir isim ve kullanıcı adı belirle\n'
                            '4. BotFather\'ın gönderdiği token\'ı yukarıya yapıştır\n'
                            '5. Botunuzla bir konuşma başlat\n'
                            '6. Chat ID\'nizi almak için @userinfobot ile konuşun',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Kaydet butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'AYARLARI KAYDET',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
    );
  }
}
