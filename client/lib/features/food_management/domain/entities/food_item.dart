import 'dart:ui';
import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final int calories;
  final String weight;
  final String date;
  final String time;
  final String mealType;
  final int protein;
  final int carbs;
  final int fat;
  final Color color;

  const FoodItem({
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

  @override
  List<Object?> get props => [
        id,
        name,
        calories,
        weight,
        date,
        time,
        mealType,
        protein,
        carbs,
        fat,
        color,
      ];
}
