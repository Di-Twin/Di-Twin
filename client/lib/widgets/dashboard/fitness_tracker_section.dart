import 'dart:convert';

import 'package:client/features/activity_management/presentation/pages/activity_calories_tracker_page.dart';
import 'package:client/features/activity_management/presentation/pages/activity_steps_page.dart';
import 'package:client/features/activity_management/presentation/pages/my_activities_page.dart';
import 'package:client/features/food_management/presentation/pages/nutrition_tracking_screen.dart';
import 'package:client/features/water_intake/presentation/pages/water_intake_page.dart';
import 'package:client/features/water_intake/data/providers/water_intake_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/health_metrics_provider.dart';
import 'package:client/data/API/health_metrics_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  double _targetCalories = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchHealthMetrics();
  }

  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  // <CHANGE> Added method to fetch target calories from API
  Future<void> _fetchTargetCalories() async {
    try {
      final accessToken = await _getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('No access token found');
        return;
      }

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month}-${today.day}';

      final url = Uri.parse(
        'https://test-prod-f427.onrender.com/api/health-metrics?date=$dateString',
      );

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          setState(() {
            _targetCalories =
                (jsonData['data']['target_calories'] ?? 2000).toDouble();
          });
        }
      } else {
        debugPrint('Failed to fetch target calories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching target calories: $e');
    }
  }

  Future<void> _fetchHealthMetrics() async {
    try {
      // <CHANGE> Fetch target calories from API alongside existing health metrics
      await _fetchTargetCalories();

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
    // <CHANGE> Use API target calories instead of health metrics target calories
    if (_targetCalories <= 0 || _healthMetrics?.totalCaloriesBurnt == null) {
      return 0.0;
    }
    return (_healthMetrics!.totalCaloriesBurnt! / _targetCalories).clamp(
      0.0,
      1.0,
    );
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

  double _getWaterProgress() {
    try {
      final waterProvider = Provider.of<WaterIntakeProvider>(
        context,
        listen: false,
      );
      final dashboardData = waterProvider.dashboardData;

      if (dashboardData != null) {
        final totalWaterTaken =
            dashboardData['total_water_taken']?.toDouble() ?? 0.0;
        final targetWaterMl =
            dashboardData['target_water_ml']?.toDouble() ?? 2000.0;

        if (targetWaterMl > 0) {
          return (totalWaterTaken / targetWaterMl).clamp(0.0, 1.0);
        }
      }

      // Fallback to default if no data available
      return 0.0;
    } catch (e) {
      debugPrint('Error getting water progress: $e');
      return 0.0;
    }
  }

  String _getWaterIntakeSubtitle() {
    try {
      final waterProvider = Provider.of<WaterIntakeProvider>(
        context,
        listen: false,
      );
      final dashboardData = waterProvider.dashboardData;

      if (dashboardData != null) {
        final totalWaterTaken =
            dashboardData['total_water_taken']?.toInt() ?? 0;
        return '${totalWaterTaken}ml consumed today';
      }

      return '0ml consumed today';
    } catch (e) {
      debugPrint('Error getting water intake subtitle: $e');
      return '0ml consumed today';
    }
  }

  String _getWaterIntakeMaxValue() {
    try {
      final waterProvider = Provider.of<WaterIntakeProvider>(
        context,
        listen: false,
      );
      final dashboardData = waterProvider.dashboardData;

      if (dashboardData != null) {
        final targetWaterMl = dashboardData['target_water_ml']?.toInt() ?? 2000;
        return '${targetWaterMl}ml';
      }

      return '2,000ml';
    } catch (e) {
      debugPrint('Error getting water intake max value: $e');
      return '2,000ml';
    }
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

    return Consumer<WaterIntakeProvider>(
      builder: (context, waterProvider, child) {
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
                        builder:
                            (context) => MyActivitiesPage(
                              userJoinDate: DateTime(
                                2023,
                                1,
                                15,
                              ), // Replace with actual user join date
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
                  subtitle:
                      '${_healthMetrics?.totalCaloriesBurnt?.toString() ?? '0'} kcal',
                  maxValue:
                      '${_targetCalories > 0 ? _targetCalories.toStringAsFixed(0) : '0'} kcal',
                  progress: _getCaloriesProgress(),
                  progressColor: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityCaloriesTrackerPage(),
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                FitnessTrackerItem(
                  icon: Icons.directions_walk,
                  title: 'Steps Taken',
                  subtitle:
                      'You\'ve taken ${_healthMetrics?.totalSteps?.toString() ?? '0'} steps.',
                  progress: _getStepsProgress(),
                  progressColor: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActivityStepsPage(),
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                FitnessTrackerItem(
                  icon: Icons.water_drop,
                  title: 'Water Intake',
                  subtitle: _getWaterIntakeSubtitle(),
                  maxValue: _getWaterIntakeMaxValue(),
                  progress: _getWaterProgress(),
                  progressColor: const Color(0xFF06B6D4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WaterIntakePage(),
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                FitnessTrackerItem(
                  icon: Icons.apple,
                  title: 'Nutrition',
                  subtitle: _getNutritionSummary(),
                  showChips: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NutritionTrackingPage(),
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
