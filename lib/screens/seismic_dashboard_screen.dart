import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/seismic_analysis_service.dart';
import '../models/seismic_activity.dart';

class SeismicDashboardScreen extends StatefulWidget {
  const SeismicDashboardScreen({super.key});

  @override
  State<SeismicDashboardScreen> createState() => _SeismicDashboardScreenState();
}

class _SeismicDashboardScreenState extends State<SeismicDashboardScreen> {
  final SeismicAnalysisService _analysisService = SeismicAnalysisService();
  bool _isLoading = true;
  SeismicActivity? _globalActivity;
  SeismicTrend? _seismicTrend;
  CountrySeismicData? _countryData;
  Map<String, dynamic>? _magnitudeStats;
  String _selectedCountry = 'TR';
  String _selectedPeriod = '30';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _analysisService.getGlobalSeismicActivity(),
        _analysisService.getSeismicTrend(),
        _analysisService.getCountrySeismicActivity(_selectedCountry),
        _analysisService.getMagnitudeStatistics(region: _selectedCountry, days: int.parse(_selectedPeriod)),
      ]);

      if (mounted) {
        setState(() {
          _globalActivity = results[0] as SeismicActivity?;
          _seismicTrend = results[1] as SeismicTrend?;
          _countryData = results[2] as CountrySeismicData?;
          _magnitudeStats = results[3] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Dashboard yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sismik Aktivite Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filtre Bölümü
                  _buildModernFilters(),
                  const SizedBox(height: 20),
                  
                  // Özet Kartları
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  
                  // Trend Analizi
                  _buildTrendCard(),
                  const SizedBox(height: 20),
                  
                  // Büyüklük Dağılımı
                  _buildMagnitudeDistribution(),
                  const SizedBox(height: 20),
                  
                  // Ülke Karşılaştırması kaldırıldı
                ],
              ),
            ),
    );
  }

  Widget _buildModernFilters() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Ülke',
                    _selectedCountry,
                    ['TR', 'US', 'JP', 'IT', 'GR'],
                    (value) => setState(() => _selectedCountry = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterDropdown(
                    'Periyot',
                    _selectedPeriod,
                    ['7', '30', '90'],
                    (value) => setState(() => _selectedPeriod = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    if (_globalActivity == null) return const SizedBox();
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Toplam Deprem',
            '${_globalActivity!.totalEarthquakes}',
            Icons.assessment,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            '4.0+ Büyüklük',
            '${_globalActivity!.magnitude4Plus}',
            Icons.warning_amber,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            '6.0+ Büyüklük',
            '${_globalActivity!.magnitude6Plus}',
            Icons.warning,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard() {
    if (_seismicTrend == null) return const SizedBox();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analizi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _seismicTrend!.getTrendDirection() == 'Increasing'
                        ? Icons.trending_up
                        : _seismicTrend!.getTrendDirection() == 'Decreasing'
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    color: _seismicTrend!.getTrendDirection() == 'Increasing'
                        ? Colors.red
                        : _seismicTrend!.getTrendDirection() == 'Decreasing'
                            ? Colors.green
                            : Colors.blue,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Aktivite ${_seismicTrend!.getTrendPercentage().abs().toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _seismicTrend!.getTrendDirection() == 'Increasing' 
                                ? 'arttı' 
                                : _seismicTrend!.getTrendDirection() == 'Decreasing' 
                                    ? 'azaldı' 
                                    : 'stabil',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagnitudeDistribution() {
    if (_magnitudeStats == null) return const SizedBox();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Büyüklük Dağılımı',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // İstatistik Özeti
            Row(
              children: [
                Expanded(child: _buildStatItem('Toplam', '${_magnitudeStats!['total']}', Colors.blue)),
                Expanded(child: _buildStatItem('Ortalama', (_magnitudeStats!['average_magnitude'] as double).toStringAsFixed(1), Colors.orange)),
                Expanded(child: _buildStatItem('En Büyük', (_magnitudeStats!['max_magnitude'] as double).toStringAsFixed(1), Colors.red)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Büyüklük Çubukları
            _buildMagnitudeBar('1.0-2.0', _magnitudeStats!['magnitude_1_2'] as int, Colors.green.shade300),
            _buildMagnitudeBar('2.0-3.0', _magnitudeStats!['magnitude_2_3'] as int, Colors.green),
            _buildMagnitudeBar('3.0-4.0', _magnitudeStats!['magnitude_3_4'] as int, Colors.yellow.shade700),
            _buildMagnitudeBar('4.0-5.0', _magnitudeStats!['magnitude_4_5'] as int, Colors.orange),
            _buildMagnitudeBar('5.0-6.0', _magnitudeStats!['magnitude_5_6'] as int, Colors.deepOrange),
            _buildMagnitudeBar('6.0-7.0', _magnitudeStats!['magnitude_6_7'] as int, Colors.red),
            _buildMagnitudeBar('7.0+', _magnitudeStats!['magnitude_7_plus'] as int, Colors.red.shade900),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagnitudeBar(String label, int value, Color color) {
    // Find the maximum value across all magnitude ranges for proper scaling
    final allValues = [
      _magnitudeStats!['magnitude_1_2'] as int,
      _magnitudeStats!['magnitude_2_3'] as int,
      _magnitudeStats!['magnitude_3_4'] as int,
      _magnitudeStats!['magnitude_4_5'] as int,
      _magnitudeStats!['magnitude_5_6'] as int,
      _magnitudeStats!['magnitude_6_7'] as int,
      _magnitudeStats!['magnitude_7_plus'] as int,
    ];
    final maxValue = allValues.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

}
