import 'package:client/features/activity_management/activity_my_stats.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/health_metrics_provider.dart';
import 'package:client/data/API/health_metrics_data.dart';
import 'package:intl/intl.dart';
import 'fitness_tracker_item.dart';

class FitnessTrackerSection extends StatefulWidget {
  const FitnessTrackerSection({super.key});

  @override
  State<FitnessTrackerSection> createState() => _FitnessTrackerSectionState();
}

class _FitnessTrackerSectionState extends State<FitnessTrackerSection> {
  final HealthMetricsProvider _healthMetricsProvider = HealthMetricsProvider();
  HealthMetrics? _healthMetrics;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHealthMetrics();
  }

  Future<void> _fetchHealthMetrics() async {
    try {
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await _healthMetricsProvider.getHealthMetrics(today);

      if (mounted) {
        setState(() {
          _healthMetrics = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load fitness data';
          _isLoading = false;
        });
        debugPrint('Error: $e');
      }
    }
  }

  double _getCaloriesProgress() {
    if (_healthMetrics?.targetCalories == null || 
        _healthMetrics?.totalCaloriesBurnt == null ||
        _healthMetrics!.targetCalories! <= 0) {
      return 0.0;
    }
    return (_healthMetrics!.totalCaloriesBurnt! / _healthMetrics!.targetCalories!).clamp(0.0, 1.0);
  }

  double _getStepsProgress() {
    const int targetSteps = 10000; // Standard step goal
    if (_healthMetrics?.totalSteps == null) return 0.0;
    return (_healthMetrics!.totalSteps! / targetSteps).clamp(0.0, 1.0);
  }

  double _getSleepProgress() {
    const double targetSleep = 8.0; // 8 hours target
    if (_healthMetrics?.sleepHours == null) return 0.0;
    return (_healthMetrics!.sleepHours! / targetSleep).clamp(0.0, 1.0);
  }

  String _getNutritionSummary() {
    if (_healthMetrics?.nutritionTaken == null) return 'No nutrition data';
    
    // Assuming nutritionTaken is a Map with macro nutrients
    final nutrition = _healthMetrics!.nutritionTaken;
    if (nutrition is Map) {
      return '${nutrition['protein']?.toStringAsFixed(0) ?? '0'}g protein, '
           '${nutrition['carbs']?.toStringAsFixed(0) ?? '0'}g carbs, '
           '${nutrition['fat']?.toStringAsFixed(0) ?? '0'}g fat';
    }
    return 'Nutrition data available';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fitness & Activity Tracker',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyActivitiesScreen(
                      userJoinDate: DateTime(2023, 1, 15), // Replace with actual user join date
                    ),
                  ),
                );
              },
              child: Text(
                'See All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            FitnessTrackerItem(
              icon: Icons.fitness_center,
              title: 'Calories Burned',
              subtitle: '${_healthMetrics?.totalCaloriesBurnt?.toString() ?? '0'}kcal',
              maxValue: '${_healthMetrics?.targetCalories?.toString() ?? '2000'}kcal',
              progress: _getCaloriesProgress(),
              progressColor: const Color(0xFFEF4444),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ActivityCaloriesTracker(),
                //   ),
                // );
              },
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            FitnessTrackerItem(
              icon: Icons.directions_walk,
              title: 'Steps Taken',
              subtitle: 'You\'ve taken ${_healthMetrics?.totalSteps?.toString() ?? '0'} steps.',
              progress: _getStepsProgress(),
              progressColor: const Color(0xFF3B82F6),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            // FitnessTrackerItem(
            //   icon: Icons.apple,
            //   title: 'Nutrition',
            //   subtitle: _getNutritionSummary(),
            //   showChips: true,
            // ),
            // const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            // FitnessTrackerItem(
            //   icon: Icons.monitor_weight_outlined,
            //   title: 'Weight Loss',
            //   subtitle: _healthMetrics?.weight != null 
            //       ? 'Current weight: ${_healthMetrics!.weight!.toStringAsFixed(1)}kg'
            //       : 'No weight data',
            //   showDots: true,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const WeightScreen()),
            //     );
            //   },
            // ),
          ],
        ),
      ],
    );
  }
}