import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'health_metric_card.dart';
import 'package:client/data/providers/heart_provider.dart';
import 'package:client/data/API/heart_data.dart';
import 'package:intl/intl.dart';
import 'package:client/data/providers/health_metrics_provider.dart';
import 'package:client/data/API/health_metrics_data.dart';

class HealthMetricsSection extends StatefulWidget {
  const HealthMetricsSection({super.key});

  @override
  State<HealthMetricsSection> createState() => _HealthMetricsSectionState();
}

class _HealthMetricsSectionState extends State<HealthMetricsSection> {
  final HeartProvider _heartProvider = HeartProvider();
  final HealthMetricsProvider _healthMetricsProvider = HealthMetricsProvider();
  HeartRateData? _heartRateData;
  HealthMetrics? _healthMetrics;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Fetch heart rate data
      final heartResponse = await _heartProvider.getHeartRateData(today);
      
      // Fetch health metrics data
      final healthMetricsResponse = await _healthMetricsProvider.getHealthMetrics(today);

      if (mounted) {
        setState(() {
          _heartRateData = heartResponse.data;
          _healthMetrics = healthMetricsResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('No heart rate data') || 
              e.toString().contains('Failed to load health metrics')) {
            _heartRateData = null;
            _healthMetrics = null;
            _errorMessage = '';
          } else {
            _errorMessage = 'Failed to load health data';
          }
          _isLoading = false;
        });
        debugPrint('Error: $e');
      }
    }
  }

  String _getSpo2Status(int? spo2Value) {
    if (spo2Value == null) return 'NO DATA';
    if (spo2Value >= 95) return 'EXCELLENT';
    if (spo2Value >= 90) return 'GOOD';
    if (spo2Value >= 85) return 'FAIR';
    return 'LOW';
  }

  String _getSleepStatus(double? sleepHours) {
    if (sleepHours == null) return 'NO DATA';
    if (sleepHours >= 7) return 'OPTIMAL';
    if (sleepHours >= 5) return 'ADEQUATE';
    return 'INSUFFICIENT';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Smart Health Metrics',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
              color: const Color(0xFF64748B),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        HealthMetricCard(
                          title: 'Heart Rate',
                          value: _heartRateData?.restingHeartRate?.toString() ?? '0',
                          unit: 'BPM',
                          color: const Color(0xFF2563EB),
                          icon: Icons.favorite_border,
                          status: _heartRateData?.restingHeartRate != null
                              ? 'RESTING'
                              : 'NO DATA',
                        ),
                        const SizedBox(width: 12),
                        HealthMetricCard(
                          title: 'SPO2',
                          value: _healthMetrics?.spo2Avg?.toString() ?? '--',
                          unit: '%',
                          color: const Color(0xFFEF4444),
                          icon: Icons.show_chart,
                          status: _getSpo2Status(_healthMetrics?.spo2Avg),
                        ),
                        const SizedBox(width: 12),
                        HealthMetricCard(
                          title: 'Sleep',
                          value: _healthMetrics?.sleepHours?.toStringAsFixed(1) ?? '--',
                          unit: 'hours',
                          color: const Color(0xFF06B6D4),
                          icon: Icons.nightlight_outlined,
                          status: _getSleepStatus(_healthMetrics?.sleepHours),
                        ),
                      ],
                    ),
                  ),
      ],
    );
  }
}