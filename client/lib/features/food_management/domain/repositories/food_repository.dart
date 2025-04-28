// lib/features/food_management/domain/repositories/food_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/food_item.dart';
import '../entities/nutrition_data.dart';
import '../../../../core/errors/failures.dart';

abstract class FoodRepository {
  Future<Either<Failure, Map<String, List<FoodItem>>>> getDailyFoodData(String date);
  Future<Either<Failure, String>> getFoodScore();
  Future<Either<Failure, String>> getDailyFoodScore(String accessToken, String date);
  Future<Either<Failure, List<FoodItem>>> getPopularFoods();
  Future<Either<Failure, NutritionData>> getNutritionData(DateTime date);
  Future<Either<Failure, void>> addFoodItem(FoodItem foodItem);
  Future<Either<Failure, void>> updateFoodItem(FoodItem foodItem);
  Future<Either<Failure, void>> deleteFoodItem(String id);
  Future<Either<Failure, bool>> logFoodItems(String accessToken, String date, List<Map<String, dynamic>> foodItems);
}
