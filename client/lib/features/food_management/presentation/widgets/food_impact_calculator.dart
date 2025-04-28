import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class FoodImpactCalculator {
  // Calculate the impact of a food on blood sugar
  static Future<Map<String, dynamic>> calculateImpact(
    Map<String, dynamic> food,
    WidgetRef ref,
  ) async {
    // Simulate a network delay for calculation
    await Future.delayed(Duration(milliseconds: 800));
    
    // Extract nutritional values
    final carbs = food['carbs'] as num? ?? 0;
    final protein = food['protein'] as num? ?? 0;
    final fat = food['fat'] as num? ?? 0;
    
    // Calculate glycemic impact (simplified algorithm)
    // Higher carbs = higher spike, protein and fat reduce the spike
    double sugarSpike = carbs * 1.2;
    sugarSpike -= protein * 0.5;
    sugarSpike -= fat * 0.3;
    
    // Ensure spike is not negative
    sugarSpike = max(0, sugarSpike);
    
    // Determine impact level
    String impactLevel;
    Color impactColor;
    
    if (sugarSpike < 5) {
      impactLevel = 'Low';
      impactColor = Colors.green;
    } else if (sugarSpike < 15) {
      impactLevel = 'Moderate';
      impactColor = Colors.orange;
    } else {
      impactLevel = 'High';
      impactColor = Colors.red;
    }
    
    // Return impact data
    return {
      'sugarSpike': sugarSpike,
      'impactLevel': impactLevel,
      'impactColor': impactColor,
    };
  }
}
