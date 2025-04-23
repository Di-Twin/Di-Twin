// lib/features/food_management/domain/entities/food_item.dart
class FoodItem {
  final String id;
  final String name;
  final int calories;
  final String weight;
  final DateTime date;
  final String time;
  final String mealType;
  final int protein;
  final int carbs;
  final int fat;
  final Color color;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.weight,
    required this.date,
    required this.time,
    required this.mealType,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.color,
  });
}