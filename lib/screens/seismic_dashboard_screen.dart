import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/seismic_activity.dart';
import '../services/seismic_analysis_service.dart';

class SeismicDashboardScreen extends StatefulWidget {
  const SeismicDashboardScreen({super.key});

  @override
  State<SeismicDashboardScreen> createState() => _SeismicDashboardScreenState();
}

class _SeismicDashboardScreenState extends State<SeismicDashboardScreen> {
  final SeismicAnalysisService _analysisService = SeismicAnalysisService();
  
  SeismicActivity? _globalActivity;
  SeismicTrend? _seismicTrend;
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
        _analysisService.getSeismicTrend(),
        _analysisService.getCountrySeismicActivity(_selectedCountry),
        _analysisService.getMagnitudeStatistics(
          region: _selectedCountry,
          days: _selectedPeriod,
        ),
      ]);

      setState(() {
        _globalActivity = results[0] as SeismicActivity;
        _seismicTrend = results[1] as SeismicTrend;
        _countryData = results[2] as CountrySeismicData;
        _magnitudeStats = results[3] as Map<String, dynamic>;
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
                  
                  // Küresel sismik aktivite göstergesi
                  _buildGlobalActivityGauge(),
                  
                  const SizedBox(height: 20),
                  
                  // Trend analizi
                  _buildTrendAnalysis(),
                  
                  const SizedBox(height: 20),
                  
                  // Büyüklük bazlı istatistikler
                  _buildMagnitudeStatistics(),
                  
                  const SizedBox(height: 20),
                  
                  // Yıllık deprem sayısı grafiği
                  _buildYearlyChart(),
                  
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

  Widget _buildGlobalActivityGauge() {
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
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          ranges: <GaugeRange>[
                            GaugeRange(
                              startValue: 0,
                              endValue: 20,
                              color: Colors.green,
                              startWidth: 10,
                              endWidth: 10,
                            ),
                            GaugeRange(
                              startValue: 20,
                              endValue: 40,
                              color: Colors.lightGreen,
                              startWidth: 10,
                              endWidth: 10,
                            ),
                            GaugeRange(
                              startValue: 40,
                              endValue: 60,
                              color: Colors.yellow,
                              startWidth: 10,
                              endWidth: 10,
                            ),
                            GaugeRange(
                              startValue: 60,
                              endValue: 80,
                              color: Colors.orange,
                              startWidth: 10,
                              endWidth: 10,
                            ),
                            GaugeRange(
                              startValue: 80,
                              endValue: 100,
                              color: Colors.red,
                              startWidth: 10,
                              endWidth: 10,
                            ),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(
                              value: _globalActivity!.getActivityLevel().toDouble(),
                              enableDragging: false,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                '${_globalActivity!.getActivityLevel()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durum: ${_globalActivity!.getActivityStatus()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Toplam Deprem: ${_globalActivity!.totalEarthquakes}'),
                      Text('4.0+ Büyüklük: ${_globalActivity!.magnitude4Plus}'),
                      Text('5.0+ Büyüklük: ${_globalActivity!.magnitude5Plus}'),
                      Text('6.0+ Büyüklük: ${_globalActivity!.magnitude6Plus}'),
                      Text('Ortalama Büyüklük: ${_globalActivity!.averageMagnitude.toStringAsFixed(1)}'),
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

  Widget _buildTrendAnalysis() {
    if (_seismicTrend == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Analizi (Son 30 Gün)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
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
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktivite ${_seismicTrend!.getTrendPercentage().abs().toStringAsFixed(1)}% ${_seismicTrend!.getTrendDirection() == 'Increasing' ? 'arttı' : _seismicTrend!.getTrendDirection() == 'Decreasing' ? 'azaldı' : 'stabil'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Önceki güne göre',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 == 0) {
                            return Text('${value.toInt()}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _seismicTrend!.dailyData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.totalEarthquakes.toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagnitudeStatistics() {
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
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_magnitudeStats!['magnitude_4_5'] as int).toDouble() * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('1-2');
                            case 1: return const Text('2-3');
                            case 2: return const Text('3-4');
                            case 3: return const Text('4-5');
                            case 4: return const Text('5-6');
                            case 5: return const Text('6-7');
                            case 6: return const Text('7+');
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_1_2'] as int).toDouble(), 
                        color: Colors.green,
                        width: 20,
                      )]
                    ),
                    BarChartGroupData(
                      x: 1, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_2_3'] as int).toDouble(), 
                        color: Colors.lightGreen,
                        width: 20,
                      )]
                    ),
                    BarChartGroupData(
                      x: 2, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_3_4'] as int).toDouble(), 
                        color: Colors.yellow,
                        width: 20,
                      )]
                    ),
                    BarChartGroupData(
                      x: 3, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_4_5'] as int).toDouble(), 
                        color: Colors.orange,
                        width: 20,
                      )]
                    ),
                    BarChartGroupData(
                      x: 4, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_5_6'] as int).toDouble(), 
                        color: Colors.deepOrange,
                        width: 20,
                      )]
                    ),
                    BarChartGroupData(
                      x: 5, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_6_7'] as int).toDouble(), 
                        color: Colors.red,
                        width: 20,
                      )]
                    ),
                    BarChartGroupData(
                      x: 6, 
                      barRods: [BarChartRodData(
                        toY: (_magnitudeStats!['magnitude_7_plus'] as int).toDouble(), 
                        color: Colors.purple,
                        width: 20,
                      )]
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_magnitudeStats!['total']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Toplam Deprem'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      (_magnitudeStats!['average_magnitude'] as double).toStringAsFixed(1),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Ortalama Büyüklük'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      (_magnitudeStats!['max_magnitude'] as double).toStringAsFixed(1),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('En Büyük'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyChart() {
    if (_seismicTrend == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yıllık Deprem Sayısı (Son 10 Yıl)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                primaryYAxis: const NumericAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<SeismicActivity, String>(
                    dataSource: _seismicTrend!.yearlyData,
                    xValueMapper: (SeismicActivity data, _) => data.date.year.toString(),
                    yValueMapper: (SeismicActivity data, _) => data.totalEarthquakes,
                    color: Colors.blue,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  child: Column(
                    children: [
                      Text(
                        _countryData!.countryName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${_countryData!.currentActivity.totalEarthquakes}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Deprem Sayısı'),
                    ],
                  ),
                ),
                const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Dünya',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.orange,
                        child: Text(
                          '${_globalActivity!.totalEarthquakes}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Deprem Sayısı'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildComparisonItem(
                  '4.0+ Büyüklük',
                  _countryData!.currentActivity.magnitude4Plus,
                  _globalActivity!.magnitude4Plus,
                ),
                _buildComparisonItem(
                  '5.0+ Büyüklük',
                  _countryData!.currentActivity.magnitude5Plus,
                  _globalActivity!.magnitude5Plus,
                ),
                _buildComparisonItem(
                  '6.0+ Büyüklük',
                  _countryData!.currentActivity.magnitude6Plus,
                  _globalActivity!.magnitude6Plus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String label, int countryValue, int globalValue) {
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
}
