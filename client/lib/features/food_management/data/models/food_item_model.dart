// lib/features/food_management/data/models/food_item_model.dart
import 'dart:ui';

import '../../domain/entities/food_item.dart';

class FoodItemModel extends FoodItem {
  FoodItemModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.weight,
    required super.date,
    required super.time,
    required super.mealType,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.color,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      weight: json['weight'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      mealType: json['mealType'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'weight': weight,
      'date': date.toIso8601String(),
      'time': time,
      'mealType': mealType,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'color': color.value,
    };
  }
}