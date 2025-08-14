import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_map/flutter_map.dart' hide SourceAttribution;
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/earthquake.dart';
import '../services/earthquake_service_real.dart';
import '../widgets/source_attribution.dart';
import 'notification_settings_screen.dart';
import 'earthquake_report_screen.dart';
import 'my_reports_screen.dart';
import 'simple_dashboard_screen.dart';
import 'earthquake_safety_screen.dart';
import 'earthquake_faq_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final EarthquakeServiceReal _earthquakeService = EarthquakeServiceReal();
  List<Earthquake> _earthquakes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;
  final MapController _mapController = MapController();
  double _minMagnitude = 2.5; // Daha düşük magnitude
  int _days = 30; // 30 günlük veri
  bool _showFilterOptions = false;
  
  // Harita pozisyonu için state değişkenleri
  LatLng _mapCenter = const LatLng(39.0, 35.0); // Türkiye merkezi
  double _mapZoom = 5.0;
  bool _shouldMoveToEarthquake = false;
  Earthquake? _selectedEarthquake;
  
  // Harita yeniden oluşturma için key
  Key _mapKey = UniqueKey();
  
  // 15 dakikalık otomatik güncelleme timer'ı
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchEarthquakes();
    _startAutoRefresh();
  }
  
  /// Optimized otomatik API sorgusu (10 dakika - production ready)
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      developer.log('⏹️ Otomatik yenileme durduruldu', name: 'HomeScreen');
      _fetchEarthquakes();
    });
    developer.log('🔄 Otomatik yenileme başlatıldı', name: 'HomeScreen');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _autoRefreshTimer?.cancel(); // Timer'ı temizle
    super.dispose();
  }
  
  // Haritayı belirli bir deprem konumuna taşı
  void _moveToEarthquake(Earthquake earthquake) {
    developer.log('🗺️ Harita görünümüne geçiliyor', name: 'HomeScreen');
    developer.log('Deprem konumuna gidiliyor: ${earthquake.place}', name: 'HomeScreen');
    developer.log('Koordinatlar: Lat: ${earthquake.latitude}, Lng: ${earthquake.longitude}', name: 'HomeScreen');
    
    setState(() {
      _mapCenter = LatLng(earthquake.latitude, earthquake.longitude);
      _mapZoom = 14.0; // Daha yakın zoom
      _shouldMoveToEarthquake = false;
      _selectedEarthquake = null;
      _mapKey = UniqueKey(); // Haritayı yeniden oluştur
    });
    
    print('Harita state güncellendi - Yeni merkez: $_mapCenter, Zoom: $_mapZoom');
  }

  bool _isFetching = false; // API call protection
  
  Future<void> _fetchEarthquakes() async {
    // Eğer zaten API çağrısı yapılıyorsa, yeni çağrıyı engelle
    if (_isFetching) {
        developer.log('⚠️ API çağrısı zaten devam ediyor, yeni çağrı engellendi', name: 'HomeScreen');
      return;
    }
    
    _isFetching = true; // API çağrısını başlat
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      developer.log('🔄 Deprem verileri yenileniyor...', name: 'HomeScreen');
      
      // Yeni entegre servisi kullan - Her zaman API'den güncel veri çeker
      final earthquakes = await _earthquakeService.getAllEarthquakes(
        limit: 100,
        minMagnitude: _minMagnitude,
        days: _days,
        // forceRefresh kaldırıldı - her zaman güncel veri
      );
      
      final filteredEarthquakes = earthquakes.where((earthquake) => earthquake.magnitude >= _minMagnitude).toList();
      
      developer.log('🔍 Arama sonucu: ${filteredEarthquakes.length} deprem bulundu', name: 'HomeScreen');
      
      // Hiç veri yoksa hata mesajı göster
      if (filteredEarthquakes.isEmpty) {
        setState(() {
          if (_minMagnitude > 5.0) {
            _errorMessage = 'Bu büyüklükte (${_minMagnitude.toStringAsFixed(1)}+) güncel deprem bulunamadı.\nFiltre değerini düşürmeyi deneyin (örn: 2.5-4.0).';
          } else {
            _errorMessage = 'Hiç deprem verisi bulunamadı.\nİnternet bağlantınızı kontrol edin veya filtreyi değiştirin.';
          }
          _isLoading = false;
        });
        _isFetching = false; // API çağrısını tamamla (boş veri durumunda da)
        return;
      }

      setState(() {
        _earthquakes = filteredEarthquakes;
        _isLoading = false;
        _mapKey = UniqueKey(); // Haritayı force refresh et
      });
      
      _isFetching = false; // API çağrısını tamamla
      
    } catch (e) {
      developer.log('📊 Deprem analizi tamamlandı', name: 'HomeScreen');
      setState(() {
        _errorMessage = 'Deprem verileri yüklenemedi: $e';
        _isLoading = false;
      });
      
      _isFetching = false; // API çağrısını tamamla (hata durumunda da)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Deprem Verileri',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchEarthquakes(); // Güncel veri çek
            },
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilterOptions = !_showFilterOptions;
              });
            },
            tooltip: 'Filtre Seçenekleri',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Daha Fazla',
            onSelected: (value) {
              switch (value) {
                case 'dashboard':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleDashboardScreen(),
                    ),
                  );
                  break;
                case 'reports':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReportsScreen(),
                    ),
                  );
                  break;
                case 'safety':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EarthquakeSafetyScreen(),
                    ),
                  );
                  break;
                case 'faq':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EarthquakeFaqScreen(),
                    ),
                  );
                  break;
                case 'notifications':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'dashboard',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Sismik Dashboard'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'reports',
                child: ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('Bildirimlerim'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'safety',
                child: ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Güvenlik Rehberi'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'faq',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('SSS'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'notifications',
                child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Bildirim Ayarları'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Liste'),
            Tab(icon: Icon(Icons.map), text: 'Harita'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtre seçenekleri
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilterOptions ? 80 : 0,
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: _showFilterOptions
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Min. Büyüklük: ${_minMagnitude.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: _minMagnitude,
                                min: 0.0,
                                max: 9.0,
                                divisions: 18,
                                label: _minMagnitude.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    _minMagnitude = value;
                                  });
                                },
                                onChangeEnd: (value) {
                                  _fetchEarthquakes();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son $_days gün',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: _days.toDouble(),
                                min: 1,
                                max: 30,
                                divisions: 29,
                                label: '$_days gün',
                                onChanged: (value) {
                                  setState(() {
                                    _days = value.toInt();
                                  });
                                },
                                onChangeEnd: (value) {
                                  _fetchEarthquakes();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          // Ana içerik
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    // Liste Görünümü
                    _buildListView(),
                    
                    // Harita Görünümü
                    _buildMapView(),
                  ],
                ),
                
                // Kaynak Bilgisi (köşede küçük yazı)
                const Positioned(
                  bottom: 5,
                  right: 5,
                  child: SourceAttribution(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EarthquakeReportScreen(),
            ),
          );
          // Eğer bildirim başarıyla kaydedildiyse, bir mesaj göster
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Teşekkürler! Deprem bildiriminiz kaydedildi.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.report_problem),
        label: const Text(
          'Deprem mi hissettiniz?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deprem verileri yükleniyor...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchEarthquakes,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_earthquakes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 48),
            SizedBox(height: 16),
            Text('Seçilen kriterlere uygun deprem verisi bulunamadı'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEarthquakes,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: _earthquakes.length + 2, // +2 güvenlik ve SSS kartı için
        itemBuilder: (context, index) {
          if (index == _earthquakes.length) {
            // Son eleman: Güvenlik kartı
            return const EarthquakeSafetyTip();
          }
          if (index == _earthquakes.length + 1) {
            // Son eleman: SSS kartı
            return const EarthquakeFaqTip();
          }
          final earthquake = _earthquakes[index];
          return _buildEarthquakeListItem(earthquake);
        },
      ),
    );
  }

  Widget _buildEarthquakeListItem(Earthquake earthquake) {
    // Büyüklüğe göre renk belirle
    Color magnitudeColor = Colors.green;
    IconData magnitudeIcon = Icons.circle;
    
    if (earthquake.magnitude >= 7.0) {
      magnitudeColor = Colors.red.shade900;
      magnitudeIcon = Icons.warning_rounded;
    } else if (earthquake.magnitude >= 6.0) {
      magnitudeColor = Colors.red;
    } else if (earthquake.magnitude >= 5.0) {
      magnitudeColor = Colors.orange;
    } else if (earthquake.magnitude >= 4.0) {
      magnitudeColor = Colors.amber;
    }

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(earthquake.time);
    
    // Şu anki zamanla fark
    final Duration difference = DateTime.now().difference(earthquake.time);
    String timeAgo;
    
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} dakika önce';
    } else {
      timeAgo = 'Az önce';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEarthquakeDetails(earthquake),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Büyüklük göstergesi
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      earthquake.magnitude >= 7.0
                          ? Icon(magnitudeIcon, color: magnitudeColor, size: 16)
                          : const SizedBox(),
                      Text(
                        earthquake.magnitude.toStringAsFixed(1),
                        style: TextStyle(
                          color: magnitudeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Deprem bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      earthquake.place,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.layers, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${earthquake.depth.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: earthquake.source == 'EMSC' ? Colors.blue.shade100 : Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            earthquake.source,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: earthquake.source == 'EMSC' ? Colors.blue.shade800 : Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deprem verileri yükleniyor...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchEarthquakes,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          key: _mapKey, // Harita yeniden oluşturma için key
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: _mapZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              enableScrollWheel: true,
              enableMultiFingerGestureRace: true,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.emsc_usgs_mobile',
              tileBuilder: (context, tileWidget, tile) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: Colors.red.withValues(alpha: 0.7),
                    ),
                  ),
                  position: DecorationPosition.foreground,
                  child: tileWidget,
                );
              },
            ),
            MarkerLayer(
              markers: _earthquakes.map((earthquake) {
                // Büyüklüğe göre renk belirle
                Color markerColor = Colors.green;
                double markerSize = 30.0;
                
                if (earthquake.magnitude >= 7.0) {
                  markerColor = Colors.red.shade900;
                  markerSize = 45.0;
                } else if (earthquake.magnitude >= 6.0) {
                  markerColor = Colors.red;
                  markerSize = 40.0;
                } else if (earthquake.magnitude >= 5.0) {
                  markerColor = Colors.orange;
                  markerSize = 35.0;
                } else if (earthquake.magnitude >= 4.0) {
                  markerColor = Colors.amber;
                }

                return Marker(
                  point: LatLng(earthquake.latitude, earthquake.longitude),
                  width: markerSize,
                  height: markerSize,
                  child: GestureDetector(
                    onTap: () {
                      _showEarthquakeDetails(earthquake);
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.4, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withAlpha(25),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                earthquake.magnitude.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Harita kontrolleri
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoomIn',
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom + 1);
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoomOut',
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom - 1);
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'recenter',
                onPressed: () {
                  _mapController.move(const LatLng(39.0, 35.0), 5.0);
                },
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEarthquakeDetails(Earthquake earthquake) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
    final formattedDate = dateFormat.format(earthquake.time);
    
    // Büyüklüğe göre renk belirle
    Color magnitudeColor = Colors.green;
    
    if (earthquake.magnitude >= 7.0) {
      magnitudeColor = Colors.red.shade900;
    } else if (earthquake.magnitude >= 6.0) {
      magnitudeColor = Colors.red;
    } else if (earthquake.magnitude >= 5.0) {
      magnitudeColor = Colors.orange;
    } else if (earthquake.magnitude >= 4.0) {
      magnitudeColor = Colors.amber;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Başlık çubuğu
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Deprem Detayları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: earthquake.source == 'EMSC' ? Colors.blue.shade100 : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      earthquake.source,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: earthquake.source == 'EMSC' ? Colors.blue.shade800 : Colors.purple.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // İçerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Büyüklük ve Derinlik
                    Row(
                      children: [
                        // Büyüklük
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Büyüklük',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.waves,
                                        color: magnitudeColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        earthquake.magnitude.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: magnitudeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Derinlik
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Derinlik',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.layers,
                                        color: Colors.brown.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${earthquake.depth.toStringAsFixed(1)} km',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Konum
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text(
                                  'Konum',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // Haritada göster butonu
                                TextButton.icon(
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text('Haritada Göster'),
                                  onPressed: () async {
                                    print('Haritada Göster butonuna tıklandı: ${earthquake.place}');
                                    Navigator.pop(context);
                                    
                                    // Harita sekmesine geç
                                    _tabController.animateTo(1);
                                    
                                    // Kısa gecikme sonrası haritayı yeniden oluştur
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    _moveToEarthquake(earthquake);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              earthquake.place,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Koordinatlar: ${earthquake.latitude.toStringAsFixed(4)}, ${earthquake.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Zaman
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  'Zaman',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Alt butonlar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
