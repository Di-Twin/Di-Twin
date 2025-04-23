// lib/features/food_management/data/datasources/food_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_data_model.dart';

abstract class FoodLocalDataSource {
  Future<Map<String, List<FoodItemModel>>> getDailyFoodData(String date);
  Future<void> cacheDailyFoodData(String date, Map<String, List<FoodItemModel>> foodData);
  Future<String> getFoodScore();
  Future<void> cacheFoodScore(String score);
  Future<List<FoodItemModel>> getPopularFoods();
  Future<void> cachePopularFoods(List<FoodItemModel> foods);
  Future<NutritionDataModel> getNutritionData(DateTime date);
  Future<void> cacheNutritionData(NutritionDataModel data);
}

class FoodLocalDataSourceImpl implements FoodLocalDataSource {
  final SharedPreferences sharedPreferences;

  FoodLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Map<String, List<FoodItemModel>>> getDailyFoodData(String date) async {
    final jsonString = sharedPreferences.getString('DAILY_FOOD_DATA_$date');
    if (jsonString != null) {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      Map<String, List<FoodItemModel>> result = {};
      
      jsonMap.forEach((mealType, foods) {
        result[mealType] = (foods as List)
            .map((food) => FoodItemModel.fromJson(food))
            .toList();
      });
      
      return result;
    } else {
      throw Exception('No cached food data found for date: $date');
    }
  }

  @override
  Future<void> cacheDailyFoodData(String date, Map<String, List<FoodItemModel>> foodData) async {
    Map<String, dynamic> jsonMap = {};
    
    foodData.forEach((mealType, foods) {
      jsonMap[mealType] = foods.map((food) => food.toJson()).toList();
    });
    
    await sharedPreferences.setString('DAILY_FOOD_DATA_$date', json.encode(jsonMap));
  }

  @override
  Future<String> getFoodScore() async {
    final score = sharedPreferences.getString('FOOD_SCORE');
    if (score != null) {
      return score;
    } else {
      return '0'; // Default score if not found
    }
  }

  @override
  Future<void> cacheFoodScore(String score) async {
    await sharedPreferences.setString('FOOD_SCORE', score);
  }

  @override
  Future<List<FoodItemModel>> getPopularFoods() async {
    final jsonString = sharedPreferences.getString('POPULAR_FOODS');
    if (jsonString != null) {
      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((food) => FoodItemModel.fromJson(food)).toList();
    } else {
      return []; // Return empty list if no cached data
    }
  }

  @override
  Future<void> cachePopularFoods(List<FoodItemModel> foods) async {
    List<Map<String, dynamic>> jsonList = foods.map((food) => food.toJson()).toList();
    await sharedPreferences.setString('POPULAR_FOODS', json.encode(jsonList));
  }

  @override
  Future<NutritionDataModel> getNutritionData(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0]; // Get YYYY-MM-DD format
    final jsonString = sharedPreferences.getString('NUTRITION_DATA_$dateStr');
    if (jsonString != null) {
      return NutritionDataModel.fromJson(json.decode(jsonString));
    } else {
      throw Exception('No cached nutrition data found for date: $dateStr');
    }
  }

  @override
  Future<void> cacheNutritionData(NutritionDataModel data) async {
    final dateStr = data.date.toIso8601String().split('T')[0]; // Get YYYY-MM-DD format
    await sharedPreferences.setString('NUTRITION_DATA_$dateStr', json.encode(data.toJson()));
  }
}
