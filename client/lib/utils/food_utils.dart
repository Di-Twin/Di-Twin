import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:client/model/sugar_data_point.dart';

class FoodUtils {
  // Calculate metabolic impact score
  static int calculateMetabolicImpact(Map<String, dynamic> food) {
    final String foodName = food['name'].toString().toLowerCase();
    final int calories = food['calories'] as int;

    int impact = 0;

    if (foodName.contains('sugar') ||
        foodName.contains('cake') ||
        foodName.contains('sweet') ||
        foodName.contains('candy')) {
      impact = -3 - (calories ~/ 100);
    } else if (foodName.contains('fruit') ||
        foodName.contains('banana') ||
        foodName.contains('apple') ||
        foodName.contains('smoothie')) {
      impact = 1 + (calories ~/ 200);
    } else if (foodName.contains('protein') ||
        foodName.contains('meat') ||
        foodName.contains('chicken') ||
        foodName.contains('fish') ||
        foodName.contains('egg')) {
      impact = 2 + (calories ~/ 150);
    } else if (foodName.contains('vegetable') ||
        foodName.contains('salad') ||
        foodName.contains('greens')) {
      impact = 3 + (calories ~/ 100);
    } else {
      impact = (calories > 300) ? -1 : 1;
    }

    return impact.clamp(-5, 5);
  }

  // Get impact level description
  static String getImpactLevel(int impact) {
    if (impact >= 3) return 'Excellent';
    if (impact >= 1) return 'Good';
    if (impact >= -1) return 'Neutral';
    if (impact >= -3) return 'Moderate';
    return 'High';
  }

  // Get impact color
  static Color getImpactColor(int impact) {
    if (impact >= 3) return Color(0xFF4CAF50); // Green
    if (impact >= 1) return Color(0xFF8BC34A); // Light Green
    if (impact >= -1) return Color(0xFFFFC107); // Amber
    if (impact >= -3) return Color(0xFFFF9800); // Orange
    return Color(0xFFF44336); // Red
  }

  // Get impact icon
  static IconData getImpactIcon(int impact) {
    if (impact >= 3) return Icons.emoji_events; // Trophy
    if (impact >= 1) return Icons.thumb_up; // Thumbs up
    if (impact >= -1) return Icons.thumbs_up_down; // Neutral
    if (impact >= -3) return Icons.warning; // Warning
    return Icons.priority_high; // Alert
  }

  // Get simplified sugar explanation
  static String getSimplifiedSugarExplanation(String foodName, String impactLevel) {
    switch (impactLevel) {
      case 'Excellent':
      case 'Good':
        return '$foodName has a minimal effect on blood sugar levels, making it a good choice for metabolic health.';
      case 'Neutral':
        return '$foodName causes a moderate rise in blood sugar that returns to normal within 2-3 hours.';
      case 'Moderate':
        return '$foodName may cause a moderate blood sugar spike. Consider pairing with protein or fiber.';
      case 'High':
        return '$foodName may cause a significant blood sugar spike. Consider smaller portions or alternatives.';
      default:
        return 'This shows how $foodName affects your blood sugar over time after eating.';
    }
  }

  // Generate sugar spike data based on food type
  static List<SugarDataPoint> generateSugarSpikeData(Map<String, dynamic> food) {
    final List<SugarDataPoint> data = [];
    final String foodName = food['name'].toString().toLowerCase();

    double peakValue = 0;
    double peakTime = 0;
    double endValue = 0;

    if (foodName.contains('sugar') ||
        foodName.contains('cake') ||
        foodName.contains('sweet') ||
        foodName.contains('candy')) {
      peakValue = 9.0 + (math.Random().nextDouble() * 2.0);
      peakTime = 0.5 + (math.Random().nextDouble() * 0.5);
      endValue = 4.0 + (math.Random().nextDouble() * 1.0);
    } else if (foodName.contains('fruit') ||
        foodName.contains('banana') ||
        foodName.contains('apple') ||
        foodName.contains('smoothie')) {
      peakValue = 7.0 + (math.Random().nextDouble() * 1.5);
      peakTime = 1.0 + (math.Random().nextDouble() * 0.5);
      endValue = 4.5 + (math.Random().nextDouble() * 0.5);
    } else if (foodName.contains('protein') ||
        foodName.contains('meat') ||
        foodName.contains('chicken') ||
        foodName.contains('fish') ||
        foodName.contains('egg')) {
      peakValue = 5.5 + (math.Random().nextDouble() * 1.0);
      peakTime = 1.5 + (math.Random().nextDouble() * 0.5);
      endValue = 4.8 + (math.Random().nextDouble() * 0.3);
    } else {
      peakValue = 6.5 + (math.Random().nextDouble() * 2.0);
      peakTime = 1.0 + (math.Random().nextDouble() * 1.0);
      endValue = 4.5 + (math.Random().nextDouble() * 0.5);
    }

    for (double i = 0; i <= 4; i += 0.2) {
      double value;
      if (i == 0) {
        value = 5.0;
      } else if (i < peakTime) {
        value = 5.0 + (peakValue - 5.0) * math.pow(i / peakTime, 1.5);
      } else {
        value = peakValue -
            (peakValue - endValue) *
                math.pow((i - peakTime) / (4 - peakTime), 0.8);
      }

      value += (math.Random().nextDouble() * 0.3) - 0.15;
      data.add(SugarDataPoint(i, value));
    }

    return data;
  }

  // Generate ideal response data
  static List<SugarDataPoint> generateIdealResponseData() {
    return [
      SugarDataPoint(0, 5.0),
      SugarDataPoint(0.5, 5.5),
      SugarDataPoint(1.0, 6.0),
      SugarDataPoint(1.5, 5.8),
      SugarDataPoint(2.0, 5.5),
      SugarDataPoint(2.5, 5.2),
      SugarDataPoint(3.0, 5.0),
      SugarDataPoint(3.5, 4.9),
      SugarDataPoint(4.0, 4.8),
    ];
  }
}
