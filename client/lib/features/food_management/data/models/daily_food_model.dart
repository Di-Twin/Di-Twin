import 'package:flutter/material.dart';
import '../../domain/entities/daily_food.dart';
import '../../domain/entities/meal_item.dart';

class DailyFoodModel extends DailyFood {
  DailyFoodModel({
    required super.id,
    required super.sessionTime,
    required super.totalCalories,
    required super.totalProtein,
    required super.totalCarbs,
    required super.totalFats,
    required super.scores,
    required super.meals,
  });

  factory DailyFoodModel.fromJson(Map<String, dynamic> json) {
    // Parse scores
    Map<String, double> scores = {};
    if (json['scores'] != null) {
      json['scores'].forEach((key, value) {
        scores[key] = value.toDouble();
      });
    }

    // Parse meals
    Map<String, List<MealItem>> meals = {};
    if (json['meals'] != null) {
      json['meals'].forEach((mealType, mealItems) {
        meals[mealType] = (mealItems as List)
            .map((item) => MealItemModel.fromJson(item, mealType))
            .toList();
      });
    }

    return DailyFoodModel(
      id: json['id'] ?? '',
      sessionTime: DateTime.parse(json['sessionTime']),
      totalCalories: (json['totalCalories'] ?? 0).toDouble(),
      totalProtein: (json['totalProtein'] ?? 0).toDouble(),
      totalCarbs: (json['totalCarbs'] ?? 0).toDouble(),
      totalFats: (json['totalFats'] ?? 0).toDouble(),
      scores: scores,
      meals: meals,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> mealsJson = {};
    meals.forEach((key, value) {
      mealsJson[key] = value.map((item) => (item as MealItemModel).toJson()).toList();
    });

    return {
      'id': id,
      'sessionTime': sessionTime.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'scores': scores,
      'meals': mealsJson,
    };
  }
}

class MealItemModel extends MealItem {
  MealItemModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.time,
    required super.imageUrl,
    required super.mealType,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json, String mealType) {
    return MealItemModel(
      id: json['id'] ?? '',
      name: json['foodName'] ?? '',
      calories: (json['calories'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      time: DateTime.parse(json['time']),
      imageUrl: json['imageUrl'] ?? '',
      mealType: mealType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'time': time.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  // Helper method to get color based on meal type
  Color getColor() {
    switch (mealType) {
      case 'breakfast':
        return Color(0xFFFF9500);
      case 'lunch':
        return Color(0xFF0A84FF);
      case 'dinner':
        return Color(0xFF5E5CE6);
      case 'snacks':
        return Color(0xFF66BB6A);
      default:
        return Color(0xFF9E9E9E);
    }
  }

  // Helper method to get icon name based on meal type
  IconData getIcon() {
    switch (mealType) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.food_bank;
      default:
        return Icons.local_dining;
    }
  }
}
