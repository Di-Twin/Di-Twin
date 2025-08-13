import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/food_item.dart';
import '../entities/nutrition_data.dart';

abstract class FoodRepository {
 Future<Either<Failure, Map<String, List<FoodItem>>>> getDailyFoodData(String date);
 Future<Either<Failure, String>> getFoodScore();
 Future<Either<Failure, String>> getDailyFoodScore(String date);
 Future<Either<Failure, List<FoodItem>>> getPopularFoods();
 Future<Either<Failure, NutritionData>> getNutritionData(DateTime date);
 Future<Either<Failure, bool>> addFoodItem(FoodItem foodItem);
 Future<Either<Failure, void>> updateFoodItem(FoodItem foodItem);
 Future<Either<Failure, void>> deleteFoodItem(String id);
 Future<Either<Failure, bool>> logFoodItems(String date, List<Map<String, dynamic>> foodItems);
 Future<Either<Failure, List<FoodItem>>> getFoodItems(String accessToken);
}
