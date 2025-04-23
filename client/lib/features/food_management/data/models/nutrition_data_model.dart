// lib/features/food_management/data/models/nutrition_data_model.dart
import '../../domain/entities/nutrition_data.dart';

class NutritionDataModel extends NutritionData {
  NutritionDataModel({
    required super.totalNutrition,
    required super.proteins,
    required super.macro,
    required super.fiber,
    required super.blueProgress,
    required super.lightBlueProgress,
    required super.redProgress,
    required super.pinkProgress,
    required super.navyProgress,
    required super.grayProgress,
    required super.date,
  });

  factory NutritionDataModel.fromJson(Map<String, dynamic> json) {
    return NutritionDataModel(
      totalNutrition: json['totalNutrition'],
      proteins: json['proteins'],
      macro: json['macro'],
      fiber: json['fiber'],
      blueProgress: json['blueProgress'].toDouble(),
      lightBlueProgress: json['lightBlueProgress'].toDouble(),
      redProgress: json['redProgress'].toDouble(),
      pinkProgress: json['pinkProgress'].toDouble(),
      navyProgress: json['navyProgress'].toDouble(),
      grayProgress: json['grayProgress'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNutrition': totalNutrition,
      'proteins': proteins,
      'macro': macro,
      'fiber': fiber,
      'blueProgress': blueProgress,
      'lightBlueProgress': lightBlueProgress,
      'redProgress': redProgress,
      'pinkProgress': pinkProgress,
      'navyProgress': navyProgress,
      'grayProgress': grayProgress,
      'date': date.toIso8601String(),
    };
  }
}
