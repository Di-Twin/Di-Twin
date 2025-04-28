// lib/features/food_management/domain/entities/nutrition_data.dart
class NutritionData {
  final int totalNutrition;
  final int proteins;
  final int macro;
  final int fiber;
  final double blueProgress;
  final double lightBlueProgress;
  final double redProgress;
  final double pinkProgress;
  final double navyProgress;
  final double grayProgress;
  final DateTime date;
  
  // Add these fields to support the new implementation
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fat;
  final int? sugar;

  NutritionData({
    required this.totalNutrition,
    required this.proteins,
    required this.macro,
    required this.fiber,
    required this.blueProgress,
    required this.lightBlueProgress,
    required this.redProgress,
    required this.pinkProgress,
    required this.navyProgress,
    required this.grayProgress,
    required this.date,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.sugar,
  });
  
  // Add a named constructor for the new implementation
  factory NutritionData.fromApi({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int sugar,
    required int fiber,
    DateTime? date,
  }) {
    return NutritionData(
      totalNutrition: calories,
      proteins: protein,
      macro: carbs,
      fiber: fiber,
      blueProgress: 0.7,
      lightBlueProgress: 0.6,
      redProgress: 0.5,
      pinkProgress: 0.4,
      navyProgress: 0.3,
      grayProgress: 0.2,
      date: date ?? DateTime.now(),
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sugar: sugar,
    );
  }
}
