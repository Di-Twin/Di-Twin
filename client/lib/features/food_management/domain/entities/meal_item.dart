class MealItem {
  final String foodName;
  final double calories;
  final DateTime time;
  final String? imageUrl;

  const MealItem({
    required this.foodName,
    required this.calories,
    required this.time,
    this.imageUrl,
  });
}
