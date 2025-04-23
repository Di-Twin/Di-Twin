import 'package:flutter/material.dart';
import 'package:client/utils/sugar_spike_calculator.dart';
import 'package:client/data/providers/activity_provider.dart';
import 'package:client/data/providers/sleep_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodImpactCalculator {
  static Future<Map<String, dynamic>> calculateImpact(
    Map<String, dynamic> food,
    WidgetRef? ref,
  ) async {
    try {
      // Get current date for API calls
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;
      final formattedDate = DateFormat('yyyy-M-d').format(now);

      // Default values
      double activityScore = 70;
      double sleepHours = 7;
      double lastActivityHours = 4;

      // Get activity score if possible
      try {
        final activityProvider = ActivityProvider();
        activityScore = await activityProvider.getMonthlyActivityScore(year, month);
        lastActivityHours = await activityProvider.getLastActivityHours(formattedDate);
      } catch (e) {
        print('Error getting activity data: $e');
        // Use default values
      }
      
      // Get sleep hours if possible
      try {
        if (ref != null) {
          final sleepProvider = ref.read(sleepServiceProvider);
          final sleepData = await ref.read(sleepDataProvider.future);
          sleepHours = sleepData.data.durationSeconds / 3600; // Convert seconds to hours
        }
      } catch (e) {
        print('Error getting sleep data: $e');
        // Use default values
      }

      // Calculate sugar spike
      final carbs = food.containsKey('carbs') ? (food['carbs'] is double ? food['carbs'] : double.parse(food['carbs'].toString())) : 0.0;
      final fiber = food.containsKey('fiber') ? (food['fiber'] is double ? food['fiber'] : double.parse(food['fiber'].toString())) : 0.0;
      final protein = food.containsKey('protein') ? (food['protein'] is double ? food['protein'] : double.parse(food['protein'].toString())) : 0.0;
      
      // Estimate GI and GL based on carbs and fiber ratio
      final estimatedGI = _estimateGlycemicIndex(food);
      final estimatedGL = (estimatedGI * carbs) / 100;
      
      // Calculate sugar spike
      final sugarSpike = estimateSugarSpikeAdvanced(
        estimatedGI,
        estimatedGL,
        carbs,
        fiber,
        protein,
        1800, // Default BMR - ideally from user profile
        activityScore,
        lastActivityHours,
        sleepHours,
      );

      // Determine impact level and color
      final impactData = _getImpactLevelAndColor(sugarSpike);

      return {
        'sugarSpike': sugarSpike,
        'impactLevel': impactData['level'],
        'impactColor': impactData['color'],
        'activityScore': activityScore,
        'sleepHours': sleepHours,
        'lastActivityHours': lastActivityHours,
      };
    } catch (e) {
      print('Error calculating impact: $e');
      // Return default values
      return {
        'sugarSpike': 2.5,
        'impactLevel': 'Moderate',
        'impactColor': Colors.orange,
        'activityScore': 70,
        'sleepHours': 7,
        'lastActivityHours': 4,
      };
    }
  }

  // Estimate glycemic index based on food composition
  static double _estimateGlycemicIndex(Map<String, dynamic> food) {
    // This is a simplified estimation
    final carbs = food.containsKey('carbs') ? (food['carbs'] is double ? food['carbs'] : double.parse(food['carbs'].toString())) : 0.0;
    final fiber = food.containsKey('fiber') ? (food['fiber'] is double ? food['fiber'] : double.parse(food['fiber'].toString())) : 0.0;
    final protein = food.containsKey('protein') ? (food['protein'] is double ? food['protein'] : double.parse(food['protein'].toString())) : 0.0;
    final fat = food.containsKey('fat') ? (food['fat'] is double ? food['fat'] : double.parse(food['fat'].toString())) : 0.0;
    
    // Base GI value
    double baseGI = 50;
    
    // Adjust based on fiber-to-carb ratio (higher fiber lowers GI)
    if (carbs > 0) {
      double fiberRatio = fiber / carbs;
      baseGI -= (fiberRatio * 30); // Reduce GI by up to 30 points for high fiber foods
    }
    
    // Adjust based on protein and fat (higher protein and fat lower GI)
    baseGI -= (protein * 0.2); // Reduce GI slightly for protein content
    baseGI -= (fat * 0.3); // Reduce GI slightly for fat content
    
    // Ensure GI is within valid range (0-100)
    return baseGI.clamp(0, 100);
  }

  // Get impact level and color based on sugar spike value
  static Map<String, dynamic> _getImpactLevelAndColor(double sugarSpike) {
    if (sugarSpike < 1.0) {
      return {
        'level': 'Minimal',
        'color': Color(0xFF4CAF50), // Green
      };
    } else if (sugarSpike < 2.0) {
      return {
        'level': 'Low',
        'color': Color(0xFF8BC34A), // Light Green
      };
    } else if (sugarSpike < 3.0) {
      return {
        'level': 'Moderate',
        'color': Color(0xFFFFC107), // Amber
      };
    } else if (sugarSpike < 4.0) {
      return {
        'level': 'High',
        'color': Color(0xFFFF9800), // Orange
      };
    } else {
      return {
        'level': 'Very High',
        'color': Color(0xFFF44336), // Red
      };
    }
  }
}
