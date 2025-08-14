import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/earthquake_report.dart';
import '../services/earthquake_report_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<EarthquakeReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await EarthquakeReportService.getReports();
      setState(() {
        _reports = reports;
        _reports.sort((a, b) => b.reportTime.compareTo(a.reportTime)); // En yeni önce
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bildirimler yüklenemedi: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReport(String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Sil'),
        content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await EarthquakeReportService.deleteReport(reportId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim silindi')),
        );
        _loadReports();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim silinemedi')),
        );
      }
    }
  }

  void _showReportDetails(EarthquakeReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bildirim Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Bildirim ID', report.id),
              _buildDetailRow('Bildiren', report.reporterName),
              _buildDetailRow('Bildirim Tarihi', DateFormat('dd.MM.yyyy HH:mm').format(report.reportTime)),
              _buildDetailRow('Deprem Tarihi', DateFormat('dd.MM.yyyy HH:mm').format(report.earthquakeTime)),
              _buildDetailRow('Konum', report.location),
              _buildDetailRow('Koordinatlar', '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}'),
              _buildDetailRow('Şiddet', report.getIntensityText()),
              _buildDetailRow('Gözlemler', report.getObservationsText()),
              if (report.contactEmail != null)
                _buildDetailRow('E-posta', report.contactEmail!),
              if (report.contactPhone != null)
                _buildDetailRow('Telefon', report.contactPhone!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity) {
      case 'very_light':
        return Colors.green;
      case 'light':
        return Colors.lightGreen;
      case 'moderate':
        return Colors.orange;
      case 'strong':
        return Colors.deepOrange;
      case 'very_strong':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimlerim'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.report_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz bildiriminiz yok',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deprem hissettiğinizde bildirim yapabilirsiniz',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getIntensityColor(report.intensity),
                          child: const Icon(
                            Icons.report,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          report.location,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Şiddet: ${report.getIntensityText()}',
                              style: TextStyle(
                                color: _getIntensityColor(report.intensity),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Bildirim: ${DateFormat('dd.MM.yyyy HH:mm').format(report.reportTime)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Deprem: ${DateFormat('dd.MM.yyyy HH:mm').format(report.earthquakeTime)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'details') {
                              _showReportDetails(report);
                            } else if (value == 'delete') {
                              _deleteReport(report.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline),
                                  SizedBox(width: 8),
                                  Text('Detaylar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Sil', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showReportDetails(report),
                      ),
                    );
                  },
                ),
    );
  }
}
