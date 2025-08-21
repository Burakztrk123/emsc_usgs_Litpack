import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/local_notification_service.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  double _radius = 100.0;
  double _minMagnitude = 4.0;
  Position? _userLocation;
  bool _hasLocationPermission = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Yerel bildirim ayarlarını yükle
      final settings = await LocalNotificationService.getNotificationSettings();
      final userLocation = await LocationService.getCurrentLocation();
      final radius = await LocationService.getSavedNotificationRadius();
      
      setState(() {
        _notificationsEnabled = settings['enabled'] as bool;
        _minMagnitude = settings['minMagnitude'] as double;
        _radius = radius;
        _userLocation = userLocation;
        _hasLocationPermission = userLocation != null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ayarlar yüklenirken hata: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = position;
          _hasLocationPermission = true;
        });
        
        // Konumu kaydet
        await LocationService.saveUserLocation(position.latitude, position.longitude);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum başarıyla alındı!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum alınamadı: $e')),
        );
      }
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Konum ayarlarını kaydet
      if (_userLocation != null) {
        await LocationService.saveUserLocation(_userLocation!.latitude, _userLocation!.longitude);
      }
      await LocationService.saveNotificationRadius(_radius);
      
      // Yerel bildirim ayarlarını kaydet
      await LocalNotificationService.saveNotificationSettings(
        enabled: _notificationsEnabled,
        minMagnitude: _minMagnitude,
        radiusKm: _radius,
      );
      
      // Bildirimler etkinse arka plan görevini başlat, değilse durdur
      if (_notificationsEnabled) {
        await NotificationService.initializeBackgroundTask();
      } else {
        await NotificationService.stopBackgroundTask();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ayarlar kaydedilemedi: $e')),
        );
      }
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
                      title: const Text('Yerel Bildirimler'),
                      subtitle: const Text('Yakındaki depremler için uygulama bildirimi al'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      secondary: const Icon(Icons.notifications_active),
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
                            if (_userLocation != null) ...[
                              Text('Enlem: ${_userLocation!.latitude.toStringAsFixed(4)}'),
                              Text('Boylam: ${_userLocation!.longitude.toStringAsFixed(4)}'),
                              Text(
                                'Konum İzni: ${_hasLocationPermission ? "✅ Verildi" : "❌ Verilmedi"}',
                                style: TextStyle(
                                  color: _hasLocationPermission ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Konum bilgisi alınamadı',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.my_location),
                              label: const Text('Mevcut Konumu Al'),
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
                    
                    // Bilgi kartı
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Nasıl Çalışır?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• Uygulama arka planda çalışarak yeni depremleri kontrol eder\n'
                              '• Belirlediğiniz yarıçap içindeki depremler için bildirim gönderir\n'
                              '• Minimum büyüklük altındaki depremler filtrelenir\n'
                              '• Bildirimler cihazınızda yerel olarak gösterilir\n'
                              '• İnternet bağlantısı gereklidir',
                              style: TextStyle(fontSize: 14),
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
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'AYARLARI KAYDET',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
