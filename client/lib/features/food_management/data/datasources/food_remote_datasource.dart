import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/nutrition_data.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_data_model.dart';
import 'package:flutter/material.dart';

abstract class FoodRemoteDataSource {
  Future<bool> addFoodItem(FoodItem foodItem);
  Future<List<FoodItem>> getPopularFoods();
  Future<Map<String, List<FoodItem>>> getDailyFoodData(String date);
  Future<String> getFoodScore();
  Future<String> getDailyFoodScore(String accessToken, String date);
  Future<NutritionData> getNutritionData(DateTime date);
  Future<void> updateFoodItem(FoodItemModel foodItem);
  Future<void> deleteFoodItem(String id);
  Future<bool> logFoodItems(String accessToken, String date, List<Map<String, dynamic>> foodItems);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final ApiClient apiClient;

  FoodRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<bool> addFoodItem(FoodItem foodItem) async {
    try {
      // Convert food item to JSON
      final Map<String, dynamic> foodData = {
        'name': foodItem.name,
        'calories': foodItem.calories,
        'protein': foodItem.protein,
        'carbs': foodItem.carbs,
        'fat': foodItem.fat,
        'weight': foodItem.weight,
        'mealType': foodItem.mealType,
        'time': foodItem.time, // Fixed: time is already a string
      };

      // Send POST request to add food
      final response = await apiClient.post('/food/add', body: foodData);
      
      // Check if the response has the expected structure
      if (response['success'] == true) {
        return true;
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to add food item',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error adding food item: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<FoodItem>> getPopularFoods() async {
    try {
      final response = await apiClient.get('/food/popular');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> foodsData = response['data'];
        return foodsData.map((food) {
          final Map<String, dynamic> foodMap = food as Map<String, dynamic>;
          return FoodItemModel(
            id: foodMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: foodMap['name'] ?? '',
            calories: foodMap['calories'] ?? 0,
            protein: foodMap['protein'] ?? 0,
            carbs: foodMap['carbs'] ?? 0,
            fat: foodMap['fat'] ?? 0,
            weight: foodMap['weight'] ?? '0g',
            mealType: foodMap['mealType'] ?? '',
            time: foodMap['time'] ?? '',
            date: DateTime.now(),
            color: foodMap['color'] ?? const Color(0xFF0F67FE),
          );
        }).toList();
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch popular foods',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error fetching popular foods: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<Map<String, List<FoodItem>>> getDailyFoodData(String date) async {
    try {
      final response = await apiClient.get('/food/daily/$date');
      
      if (response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> data = response['data'];
        final Map<String, List<FoodItem>> result = {};
        
        data.forEach((mealType, foods) {
          if (foods is List) {
            result[mealType] = (foods as List).map((food) {
              final Map<String, dynamic> foodMap = food as Map<String, dynamic>;
              return FoodItemModel.fromJson(foodMap);
            }).toList();
          }
        });
        
        return result;
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch daily food data',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error fetching daily food data: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<String> getFoodScore() async {
    try {
      final response = await apiClient.get('/food/score');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'].toString();
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch food score',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error fetching food score: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<String> getDailyFoodScore(String accessToken, String date) async {
    try {
      // Add the access token to the URL as a query parameter instead
      final response = await apiClient.get('/food/score/daily/$date?token=$accessToken');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'].toString();
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch daily food score',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error fetching daily food score: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<NutritionData> getNutritionData(DateTime date) async {
    try {
      final String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await apiClient.get('/food/nutrition/$formattedDate');
      
      if (response['success'] == true && response['data'] != null) {
        return NutritionDataModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch nutrition data',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error fetching nutrition data: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<void> updateFoodItem(FoodItemModel foodItem) async {
    try {
      final response = await apiClient.put(
        '/food/update/${foodItem.id}',
        body: foodItem.toJson(),
      );
      
      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to update food item',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error updating food item: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<void> deleteFoodItem(String id) async {
    try {
      final response = await apiClient.delete('/food/delete/$id');
      
      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to delete food item',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error deleting food item: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
  
  @override
  Future<bool> logFoodItems(String accessToken, String date, List<Map<String, dynamic>> foodItems) async {
    try {
      // Include the access token in the body instead
      final response = await apiClient.post(
        '/food/log',
        body: {
          'token': accessToken,
          'date': date,
          'items': foodItems,
        },
      );
      
      if (response['success'] == true) {
        return true;
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to log food items',
          statusCode: response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Error logging food items: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
