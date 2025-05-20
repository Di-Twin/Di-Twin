class MealItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime time;
  final String imageUrl;
  final String mealType;

  MealItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.time,
    required this.imageUrl,
    required this.mealType,
  });
}
