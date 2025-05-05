import 'package:flutter/material.dart';
import '../../domain/entities/food_item.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.time,
    required super.mealType,
    required super.weight,
    required super.date,
    required super.color,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Unknown Food',
      calories: json['calories'] is int ? json['calories'] : (json['calories'] as num?)?.toInt() ?? 0,
      protein: json['protein'] is int ? json['protein'] : (json['protein'] as num?)?.toInt() ?? 0,
      carbs: json['carbs'] is int ? json['carbs'] : (json['carbs'] as num?)?.toInt() ?? 0,
      fat: json['fat'] is int ? json['fat'] : (json['fat'] as num?)?.toInt() ?? 0,
      time: json['time'] ?? '12:00',
      mealType: json['mealType'] ?? 'snacks',
      weight: json['weight'] ?? '100g',
      date: json['date'] ?? DateTime.now().toString().substring(0, 10),
      color: json['color'] is Color ? json['color'] : Color(json['colorValue'] ?? 0xFF0F67FE),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'time': time,
      'mealType': mealType,
      'weight': weight,
      'date': date,
      'colorValue': color.value,
    };
  }
}
