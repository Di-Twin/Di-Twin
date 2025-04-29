import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodImpactCalculator {
  // Calculate the impact of a food item on blood sugar
  static Future<Map<String, dynamic>> calculateImpact(
    Map<String, dynamic> food,
    WidgetRef ref,
  ) async {
    // Simulate a calculation delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Extract food properties
    final int calories = food['calories'] ?? 0;
    final int carbs = food['carbs'] ?? 0;
    final int protein = food['protein'] ?? 0;
    final int fat = food['fat'] ?? 0;
    
    // Calculate a sugar spike score based on carbs, protein, and fat
    // This is a simplified model - in a real app, this would be more sophisticated
    double sugarSpike = 0.0;
    
    // Carbs have the highest impact on blood sugar
    sugarSpike += carbs * 1.0;
    
    // Protein has a moderate impact
    sugarSpike += protein * 0.5;
    
    // Fat has the lowest impact
    sugarSpike += fat * 0.2;
    
    // Normalize the score to a 0-10 scale
    sugarSpike = sugarSpike / 10;
    if (sugarSpike > 10) sugarSpike = 10;
    
    // Determine impact level and color
    String impactLevel;
    Color impactColor;
    
    if (sugarSpike < 3) {
      impactLevel = 'Low';
      impactColor = Colors.green;
    } else if (sugarSpike < 7) {
      impactLevel = 'Moderate';
      impactColor = Colors.orange;
    } else {
      impactLevel = 'High';
      impactColor = Colors.red;
    }
    
    // Return the impact data
    return {
      'sugarSpike': sugarSpike,
      'impactLevel': impactLevel,
      'impactColor': impactColor,
    };
  }
}
