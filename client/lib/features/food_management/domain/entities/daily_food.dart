import 'package:equatable/equatable.dart';
import 'meal_item.dart';

class DailyFood extends Equatable {
  final String id;
  final DateTime sessionTime;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final Map<String, double> scores;
  final Map<String, List<MealItem>> meals;

  const DailyFood({
    required this.id,
    required this.sessionTime,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.scores,
    required this.meals,
  });

  @override
  List<Object?> get props => [
    id,
    sessionTime,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFats,
    scores,
    meals,
  ];
}
