import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/earthquake_report.dart';
import '../services/earthquake_report_service.dart';
import '../services/location_service.dart';

class EarthquakeReportScreen extends StatefulWidget {
  const EarthquakeReportScreen({super.key});

  @override
  State<EarthquakeReportScreen> createState() => _EarthquakeReportScreenState();
}

class _EarthquakeReportScreenState extends State<EarthquakeReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime _earthquakeTime = DateTime.now();
  String _selectedIntensity = 'light';
  final List<String> _selectedObservations = [];
  bool _isLoading = false;
  Position? _currentPosition;

  final List<String> _intensityOptions = [
    'very_light',
    'light', 
    'moderate',
    'strong',
    'very_strong',
  ];

  final Map<String, String> _intensityLabels = {
    'very_light': 'Çok Hafif - Sadece hassas kişiler hissetti',
    'light': 'Hafif - Çoğu kişi hissetti, hafif sallantı',
    'moderate': 'Orta - Herkes hissetti, eşyalar sallandı',
    'strong': 'Şiddetli - Eşyalar devrildi, çatlaklar oluştu',
    'very_strong': 'Çok Şiddetli - Yapısal hasar, büyük çatlaklar',
  };

  final List<String> _observationOptions = [
    'Avizeler sallandı',
    'Eşyalar masadan düştü',
    'Kapılar açılıp kapandı',
    'Camlar çınladı',
    'Bina gıcırdadı',
    'Duvarlarda çatlak oluştu',
    'Sıva döküldü',
    'Mobilyalar kaydı',
    'Hayvanlar tedirgin oldu',
    'Araçlar sallandı',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _locationController.text = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      developer.log('Konum alınamadı: $e', name: 'EarthquakeReportScreen');
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _earthquakeTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_earthquakeTime),
      );

      if (time != null && mounted) {
        setState(() {
          _earthquakeTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPosition == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum bilgisi alınamadı. Lütfen bekleyin veya manuel olarak girin.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final report = EarthquakeReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        location: _locationController.text.trim(),
        reportTime: DateTime.now(),
        earthquakeTime: _earthquakeTime,
        intensity: _selectedIntensity,
        observations: _selectedObservations,
        contactEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        contactPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        reporterName: _nameController.text.trim(),
      );

      final result = await EarthquakeReportService.saveReport(report);

      if (result == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deprem raporu başarıyla kaydedildi!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rapor kaydedilemedi. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: const Text('Deprem Bildirimi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bilgi kartı
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Deprem mi hissettiniz?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hissettiğiniz depremi bildirerek bilim insanlarına yardımcı olun. Bilgileriniz deprem araştırmalarında kullanılacaktır.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Kişisel bilgiler
                    const Text(
                      'Kişisel Bilgiler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Adınız Soyadınız *',
                        hintText: 'Örn: Ahmet Yılmaz',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen adınızı soyadınızı girin';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-posta (İsteğe bağlı)',
                        hintText: 'ornek@email.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon (İsteğe bağlı)',
                        hintText: '0555 123 45 67',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Deprem bilgileri
                    const Text(
                      'Deprem Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tarih ve saat seçimi
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Deprem Tarihi ve Saati'),
                        subtitle: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(_earthquakeTime),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: _selectDateTime,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Konum bilgisi
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Konum *',
                        hintText: 'İl, İlçe veya koordinatlar',
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen konum bilgisi girin';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Şiddet seçimi
                    const Text(
                      'Hissettiğiniz Şiddet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ..._intensityOptions.map((intensity) => RadioListTile<String>(
                      title: Text(_intensityLabels[intensity]!),
                      value: intensity,
                      groupValue: _selectedIntensity,
                      onChanged: (value) {
                        setState(() {
                          _selectedIntensity = value!;
                        });
                      },
                    )),
                    
                    const SizedBox(height: 24),
                    
                    // Gözlemler
                    const Text(
                      'Gözlemleriniz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Deprem sırasında gözlemlediğiniz durumları seçin (birden fazla seçebilirsiniz):',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _observationOptions.map((observation) {
                        final isSelected = _selectedObservations.contains(observation);
                        return FilterChip(
                          label: Text(observation),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedObservations.add(observation);
                              } else {
                                _selectedObservations.remove(observation);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Gönder butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'BİLDİRİMİ GÖNDER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Uyarı metni
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bu bildirim sadece bilimsel araştırma amaçlıdır. Acil durumlar için 112\'yi arayın.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                              ),
                            ),
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
}
