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
        if (mealItems is List) {
          meals[mealType] = mealItems.map((item) {
            return MealItem(
              foodName: item['foodName'] ?? 'Unknown Food',
              calories: (item['calories'] ?? 0).toDouble(),
              time: item['time'] != null 
                  ? DateTime.parse(item['time']) 
                  : DateTime.now(),
              imageUrl: item['imageUrl'],
            );
          }).toList();
        }
      });
    }

    return DailyFoodModel(
      id: json['id'] ?? '',
      sessionTime: json['sessionTime'] != null 
          ? DateTime.parse(json['sessionTime']) 
          : DateTime.now(),
      totalCalories: (json['totalCalories'] ?? 0).toDouble(),
      totalProtein: (json['totalProtein'] ?? 0).toDouble(),
      totalCarbs: (json['totalCarbs'] ?? 0).toDouble(),
      totalFats: (json['totalFats'] ?? 0).toDouble(),
      scores: scores,
      meals: meals,
    );
  }
}

class MealItemModel extends MealItem {
  const MealItemModel({
    required super.foodName,
    required super.calories,
    required super.time,
    super.imageUrl,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      foodName: json['foodName'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      time: json['time'] != null 
          ? DateTime.parse(json['time']) 
          : DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }
}
