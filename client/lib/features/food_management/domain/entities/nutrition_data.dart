// lib/features/food_management/domain/entities/nutrition_data.dart
class NutritionData {
  final String totalNutrition;
  final String proteins;
  final String macro;
  final String fiber;
  final double blueProgress;
  final double lightBlueProgress;
  final double redProgress;
  final double pinkProgress;
  final double navyProgress;
  final double grayProgress;
  final DateTime date;

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
  });
}