import 'package:equatable/equatable.dart';

class MealItem extends Equatable {
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

  @override
  List<Object?> get props => [foodName, calories, time, imageUrl];
}
