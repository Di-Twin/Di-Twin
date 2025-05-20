import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/nutrition_data.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_data_model.dart';
import 'package:flutter/material.dart';
// Add this import at the top of the file
import 'dart:developer' as developer;

abstract class FoodRemoteDataSource {
  Future<Map<String, List<FoodItem>>> getDailyFoodData(String date);
  Future<String> getFoodScore();
  Future<String> getDailyFoodScore(String date);
  Future<List<FoodItem>> getPopularFoods();
  Future<NutritionData> getNutritionData(DateTime date);
  Future<bool> addFoodItem(FoodItem foodItem);
  Future<void> updateFoodItem(FoodItem foodItem);
  Future<void> deleteFoodItem(String id);
  Future<bool> logFoodItems(String date, List<Map<String, dynamic>> foodItems);
  Future<List<FoodItem>> getFoodItems(String accessToken);
  Future<Map<String, dynamic>> getMonthlyFoodData(int year, int month);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final ApiClient apiClient;
  final http.Client client;

  FoodRemoteDataSourceImpl({
    required this.apiClient,
    required this.client,
  });

  @override
  Future<Map<String, List<FoodItem>>> getDailyFoodData(String date) async {
    try {
      final response = await client.get(
        Uri.parse('${apiClient.baseUrl}/daily/$date'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return _processDailyFoodData(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch daily food data',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ServerException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error getting daily food data: $e');
      throw ServerException(
        message: 'Failed to fetch daily food data: $e',
        statusCode: 500,
      );
    }
  }

  Map<String, List<FoodItem>> _processDailyFoodData(dynamic data) {
    Map<String, List<FoodItem>> result = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snacks': [],
      'custom': [],
    };

    if (data != null && data.containsKey('meals')) {
      final meals = data['meals'] as Map<String, dynamic>;
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      meals.forEach((mealType, foodList) {
        if (result.containsKey(mealType)) {
          for (var foodItem in foodList) {
            DateTime foodTime = DateTime.parse(foodItem['time']);

            FoodItem processedFood = FoodItemModel(
              id: foodItem['id'] ?? '',
              name: foodItem['foodName'],
              calories: foodItem['calories'] is int
                  ? foodItem['calories']
                  : (foodItem['calories'] as num).toInt(),
              protein: foodItem['protein'] ?? 0,
              carbs: foodItem['carbs'] ?? 0,
              fat: foodItem['fat'] ?? 0,
              time: _formatTime(foodTime),
              weight: foodItem['weight'] ?? '100g',
              mealType: mealType,
              date: currentDate,
              color: _getColorForMealType(mealType),
            );

            result[mealType]!.add(processedFood);
          }
        }
      });
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> getMonthlyFoodData(int year, int month) async {
    try {
      print('🗓️ Fetching monthly food data for $month/$year');
      final response = await apiClient.get('/food/monthly/$year/$month');
      
      if (response['success'] == true) {
        print('✅ Successfully fetched monthly food data');
        return response['data'];
      } else {
        print('❌ Failed to fetch monthly food data: ${response['message']}');
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch monthly food data',
          statusCode: 500,
        );
      }
    } catch (e) {
      print('❌ Error in getMonthlyFoodData: $e');
      throw ServerException(message: 'Failed to fetch monthly food data: $e', statusCode: 500);
    }
  }

  @override
  Future<String> getFoodScore() async {
    try {
      final response = await apiClient.get('/food/score/today');
      
      if (response['success'] == true) {
        final score = response['data']['score'].toString();
        return score;
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch food score',
          statusCode: 500,
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch food score: $e', statusCode: 500);
    }
  }

  @override
  Future<String> getDailyFoodScore(String date) async {
    try {
      final response = await client.get(
        Uri.parse('${apiClient.baseUrl}/score/daily/$date'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          double foodScore = data['data']['food_score'].toDouble();
          return foodScore.round().toString();
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch daily food score',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ServerException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error getting daily food score: $e');
      throw ServerException(
        message: 'Failed to fetch daily food score: $e',
        statusCode: 500,
      );
    }
  }

  // Update the getPopularFoods method to include better error logging
  @override
  Future<List<FoodItem>> getPopularFoods() async {
    try {
      final url = Uri.parse('https://food-service-prod.onrender.com/api/food/items');
      developer.log('Food Remote DS - Request URL: $url', name: 'FoodRemoteDS');
      
      // Try to get token for debugging purposes
      final token = await _getAccessToken();
      developer.log('Food Remote DS - Token available: ${token != null}', name: 'FoodRemoteDS');
      
      // Prepare headers
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        developer.log('Food Remote DS - Using authorization header', name: 'FoodRemoteDS');
      }
      
      developer.log('Food Remote DS - Request Headers: $headers', name: 'FoodRemoteDS');
      
      final response = await client.get(
        url,
        headers: headers,
      );

      developer.log('Food Remote DS - Response Status: ${response.statusCode}', name: 'FoodRemoteDS');
      
      if (response.statusCode == 401) {
        developer.log('Food Remote DS - 401 Unauthorized Error', name: 'FoodRemoteDS');
        developer.log('Food Remote DS - Response Body: ${response.body}', name: 'FoodRemoteDS');
        throw ServerException(
          message: 'Authentication failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Food Remote DS - Success: ${data['success']}', name: 'FoodRemoteDS');
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          developer.log('Food Remote DS - Items count: ${items.length}', name: 'FoodRemoteDS');
          return items.map((item) => FoodItemModel.fromJson(item)).toList();
        } else {
          developer.log('Food Remote DS - Invalid response format: ${response.body}', name: 'FoodRemoteDS');
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch popular foods',
            statusCode: response.statusCode,
          );
        }
      } else {
        developer.log('Food Remote DS - Failed with status: ${response.statusCode}', name: 'FoodRemoteDS');
        developer.log('Food Remote DS - Response Body: ${response.body}', name: 'FoodRemoteDS');
        throw ServerException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      developer.log('Food Remote DS - Error: $e', name: 'FoodRemoteDS');
      developer.log('Food Remote DS - Stack trace: $stackTrace', name: 'FoodRemoteDS');
      throw ServerException(
        message: 'Failed to fetch popular foods: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<NutritionData> getNutritionData(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await apiClient.get('/food/nutrition/$formattedDate');
      
      if (response['success'] == true) {
        return NutritionDataModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch nutrition data',
          statusCode: 500,
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch nutrition data: $e', statusCode: 500);
    }
  }

  @override
  Future<bool> addFoodItem(FoodItem foodItem) async {
    try {
      final response = await apiClient.post(
        '/food/add',
        body: {
          'mealType': foodItem.mealType,
          'foodName': foodItem.name,
          'calories': foodItem.calories,
          'protein': foodItem.protein,
          'carbs': foodItem.carbs,
          'fat': foodItem.fat,
          'weight': foodItem.weight,
          'time': DateTime.now().toIso8601String(),
        },
      );
      
      return response['success'] == true;
    } catch (e) {
      throw ServerException(message: 'Failed to add food item: $e', statusCode: 500);
    }
  }

  @override
  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      await apiClient.put(
        '/food/${foodItem.id}',
        body: {
          'mealType': foodItem.mealType,
          'foodName': foodItem.name,
          'calories': foodItem.calories,
          'protein': foodItem.protein,
          'carbs': foodItem.carbs,
          'fat': foodItem.fat,
          'weight': foodItem.weight,
        },
      );
    } catch (e) {
      throw ServerException(message: 'Failed to update food item: $e', statusCode: 500);
    }
  }

  @override
  Future<void> deleteFoodItem(String id) async {
    try {
      await apiClient.delete('/food/$id');
    } catch (e) {
      throw ServerException(message: 'Failed to delete food item: $e', statusCode: 500);
    }
  }

  @override
  Future<bool> logFoodItems(String date, List<Map<String, dynamic>> foodItems) async {
    try {
      final response = await apiClient.post(
        '/food/log',
        body: {
          'date': date,
          'foodItems': foodItems,
        },
      );
      
      return response['success'] == true;
    } catch (e) {
      throw ServerException(message: 'Failed to log food items: $e', statusCode: 500);
    }
  }

  // Update the getFoodItems method to include better error logging
  @override
  Future<List<FoodItem>> getFoodItems(String accessToken) async {
    try {
      final url = Uri.parse('https://food-service-prod.onrender.com/api/food/items');
      developer.log('Food Remote DS - getFoodItems - Request URL: $url', name: 'FoodRemoteDS');
      
      // Prepare headers
      final headers = {'Content-Type': 'application/json'};
      if (accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
        developer.log('Food Remote DS - getFoodItems - Using provided token', name: 'FoodRemoteDS');
      } else {
        // Try to get token for debugging purposes
        final token = await _getAccessToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          developer.log('Food Remote DS - getFoodItems - Using stored token', name: 'FoodRemoteDS');
        }
      }
      
      developer.log('Food Remote DS - getFoodItems - Request Headers: $headers', name: 'FoodRemoteDS');
      
      final response = await client.get(
        url,
        headers: headers,
      );

      developer.log('Food Remote DS - getFoodItems - Response Status: ${response.statusCode}', name: 'FoodRemoteDS');
      
      if (response.statusCode == 401) {
        developer.log('Food Remote DS - getFoodItems - 401 Unauthorized Error', name: 'FoodRemoteDS');
        developer.log('Food Remote DS - getFoodItems - Response Body: ${response.body}', name: 'FoodRemoteDS');
        throw ServerException(
          message: 'Authentication failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Food Remote DS - getFoodItems - Success: ${data['success']}', name: 'FoodRemoteDS');
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          developer.log('Food Remote DS - getFoodItems - Items count: ${items.length}', name: 'FoodRemoteDS');
          return items.map((item) => FoodItemModel.fromJson(item)).toList();
        } else {
          developer.log('Food Remote DS - getFoodItems - Invalid response format: ${response.body}', name: 'FoodRemoteDS');
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch food items',
            statusCode: response.statusCode,
          );
        }
      } else {
        developer.log('Food Remote DS - getFoodItems - Failed with status: ${response.statusCode}', name: 'FoodRemoteDS');
        developer.log('Food Remote DS - getFoodItems - Response Body: ${response.body}', name: 'FoodRemoteDS');
        throw ServerException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      developer.log('Food Remote DS - getFoodItems - Error: $e', name: 'FoodRemoteDS');
      developer.log('Food Remote DS - getFoodItems - Stack trace: $stackTrace', name: 'FoodRemoteDS');
      throw ServerException(message: 'Failed to fetch food items: $e', statusCode: 500);
    }
  }

  // Add a helper method to get access token
  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      developer.log('Food Remote DS - Token retrieval - Token available: ${token != null}', name: 'FoodRemoteDS');
      if (token != null && token.isNotEmpty) {
        developer.log('Food Remote DS - Token retrieval - Token prefix: ${token.substring(0, 5)}...', name: 'FoodRemoteDS');
      } else {
        developer.log('Food Remote DS - Token retrieval - No token found', name: 'FoodRemoteDS');
      }
      
      return token;
    } catch (e, stackTrace) {
      developer.log('Food Remote DS - Token retrieval - Error: $e', name: 'FoodRemoteDS');
      developer.log('Food Remote DS - Token retrieval - Stack trace: $stackTrace', name: 'FoodRemoteDS');
      return null;
    }
  }

  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }

  // Helper method to get color for meal type
  Color _getColorForMealType(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return const Color(0xFFFF9500);
      case 'lunch':
        return const Color(0xFF0A84FF);
      case 'dinner':
        return const Color(0xFF5E5CE6);
      case 'snacks':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Helper method to get icon name for meal type
  String _getIconNameForMealType(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'breakfast_dining';
      case 'lunch':
        return 'lunch_dining';
      case 'dinner':
        return 'dinner_dining';
      case 'snacks':
        return 'food_bank';
      default:
        return 'local_dining';
    }
  }
}
