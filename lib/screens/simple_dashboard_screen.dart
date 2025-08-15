import 'package:flutter/material.dart';
import '../models/seismic_activity.dart';
import '../services/seismic_analysis_service.dart';

class SimpleDashboardScreen extends StatefulWidget {
  const SimpleDashboardScreen({super.key});

  @override
  State<SimpleDashboardScreen> createState() => _SimpleDashboardScreenState();
}

class _SimpleDashboardScreenState extends State<SimpleDashboardScreen> {
  final SeismicAnalysisService _analysisService = SeismicAnalysisService();
  
  SeismicActivity? _globalActivity;
  CountrySeismicData? _countryData;
  Map<String, dynamic>? _magnitudeStats;
  
  bool _isLoading = true;
  String _selectedCountry = 'TR';
  int _selectedPeriod = 30; // days

  final List<String> _countries = [
    'TR', 'US', 'JP', 'IT', 'GR', 'CL', 'ID', 'MX'
  ];

  final List<int> _periods = [7, 30, 90, 365];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _analysisService.getGlobalSeismicActivity(),
        _analysisService.getCountrySeismicActivity(_selectedCountry),
        _analysisService.getMagnitudeStatistics(
          region: _selectedCountry,
          days: _selectedPeriod,
        ),
      ]);

      setState(() {
        _globalActivity = results[0] as SeismicActivity;
        _countryData = results[1] as CountrySeismicData;
        _magnitudeStats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sismik Aktivite Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre seçenekleri
                  _buildFilterSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Küresel sismik aktivite
                  _buildGlobalActivityCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Büyüklük istatistikleri
                  _buildMagnitudeStatsCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Ülke karşılaştırması
                  _buildCountryComparison(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtreler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ülke:', style: TextStyle(fontWeight: FontWeight.w500)),
                      DropdownButton<String>(
                        value: _selectedCountry,
                        isExpanded: true,
                        items: _countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(_analysisService.getCountryName(country)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCountry = value;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Periyot:', style: TextStyle(fontWeight: FontWeight.w500)),
                      DropdownButton<int>(
                        value: _selectedPeriod,
                        isExpanded: true,
                        items: _periods.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text('Son $period gün'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalActivityCard() {
    if (_globalActivity == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Küresel Sismik Aktivite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Aktivite göstergesi (basit)
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _getActivityColor(_globalActivity!.getActivityLevel()),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_globalActivity!.getActivityLevel()}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _globalActivity!.getActivityStatus(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // İstatistikler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow('Toplam Deprem', _globalActivity!.totalEarthquakes.toString()),
                      _buildStatRow('4.0+ Büyüklük', '${_globalActivity!.magnitude4Plus}'),
                      _buildStatRow('5.0+ Büyüklük', '${_globalActivity!.magnitude5Plus}'),
                      _buildStatRow('6.0+ Büyüklük', '${_globalActivity!.magnitude6Plus}'),
                      _buildStatRow('Ortalama Büyüklük', _globalActivity!.averageMagnitude.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagnitudeStatsCard() {
    if (_magnitudeStats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Büyüklük İstatistikleri - ${_analysisService.getCountryName(_selectedCountry)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Basit bar gösterimi
            _buildSimpleBarChart(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Toplam', '${_magnitudeStats!['total']}'),
                _buildStatColumn('Ortalama', (_magnitudeStats!['average_magnitude'] as double).toStringAsFixed(1)),
                _buildStatColumn('En Büyük', (_magnitudeStats!['max_magnitude'] as double).toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    final data = [
      {'label': '1-2', 'value': _magnitudeStats!['magnitude_1_2'] as int, 'color': Colors.green},
      {'label': '2-3', 'value': _magnitudeStats!['magnitude_2_3'] as int, 'color': Colors.lightGreen},
      {'label': '3-4', 'value': _magnitudeStats!['magnitude_3_4'] as int, 'color': Colors.yellow},
      {'label': '4-5', 'value': _magnitudeStats!['magnitude_4_5'] as int, 'color': Colors.orange},
      {'label': '5-6', 'value': _magnitudeStats!['magnitude_5_6'] as int, 'color': Colors.deepOrange},
      {'label': '6-7', 'value': _magnitudeStats!['magnitude_6_7'] as int, 'color': Colors.red},
      {'label': '7+', 'value': _magnitudeStats!['magnitude_7_plus'] as int, 'color': Colors.purple},
    ];

    final maxValue = data.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: data.map((item) {
        final value = item['value'] as int;
        final label = item['label'] as String;
        final color = item['color'] as Color;
        final percentage = maxValue > 0 ? value / maxValue : 0.0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(label, style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade200,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text('$value', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCountryComparison() {
    if (_countryData == null || _globalActivity == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ülke vs Dünya Karşılaştırması',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonCard(
                    _countryData!.countryName,
                    _countryData!.currentActivity.totalEarthquakes,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildComparisonCard(
                    'Dünya',
                    _globalActivity!.totalEarthquakes,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildComparisonStat('4.0+', _countryData!.currentActivity.magnitude4Plus, _globalActivity!.magnitude4Plus),
                _buildComparisonStat('5.0+', _countryData!.currentActivity.magnitude5Plus, _globalActivity!.magnitude5Plus),
                _buildComparisonStat('6.0+', _countryData!.currentActivity.magnitude6Plus, _globalActivity!.magnitude6Plus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Text('Deprem'),
        ],
      ),
    );
  }

  Widget _buildComparisonStat(String label, int countryValue, int globalValue) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('$countryValue / $globalValue'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  Color _getActivityColor(int level) {
    if (level >= 80) return Colors.red;
    if (level >= 60) return Colors.orange;
    if (level >= 40) return Colors.yellow.shade700;
    if (level >= 20) return Colors.lightGreen;
    return Colors.green;
  }
}
