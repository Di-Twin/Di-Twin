import 'dart:convert';
import 'dart:ui';

import 'package:client/core/errors/exceptions.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/features/food_management/data/models/food_item_model.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/domain/entities/nutrition_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
      final response = await apiClient.get('/food/daily/$date');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Mock data structure for demonstration
        Map<String, List<FoodItem>> result = {
          'breakfast': [],
          'lunch': [],
          'dinner': [],
          'snacks': [],
        };
        
        // Process the response data and populate the result map
        // This is a simplified example; adjust according to your actual API response structure
        if (responseData.containsKey('meals')) {
          final meals = responseData['meals'] as Map<String, dynamic>;
          
          meals.forEach((mealType, mealItems) {
            if (mealItems is List) {
              result[mealType] = mealItems.map((item) {
                return FoodItemModel(
                  id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: item['name'] ?? 'Unknown Food',
                  calories: item['calories'] ?? 0,
                  weight: item['weight'] ?? '100g',
                  date: date,
                  time: item['time'] ?? DateFormat('HH:mm').format(DateTime.now()),
                  mealType: mealType,
                  protein: item['protein'] ?? 0,
                  carbs: item['carbs'] ?? 0,
                  fat: item['fat'] ?? 0,
                  color: Color(0xFF0F67FE),
                );
              }).toList();
            }
          });
        }
        
        return result;
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to load daily food data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // If no data is available, return empty lists for each meal type
      return {
        'breakfast': _getMockBreakfastItems(),
        'lunch': _getMockLunchItems(),
        'dinner': _getMockDinnerItems(),
        'snacks': _getMockSnackItems(),
      };
    }
  }

  List<FoodItem> _getMockBreakfastItems() {
    return [
      FoodItemModel(
        id: '1',
        name: 'Oatmeal with Berries',
        calories: 320,
        weight: '1 bowl',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '08:00',
        mealType: 'breakfast',
        protein: 12,
        carbs: 58,
        fat: 6.toInt(),
        color: Color(0xFF0F67FE),
      ),
      FoodItemModel(
        id: '2',
        name: 'Greek Yogurt',
        calories: 150,
        weight: '1 cup',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '08:15',
        mealType: 'breakfast',
        protein: 15,
        carbs: 8,
        fat: 4,
        color: Color(0xFF0F67FE),
      ),
    ];
  }

  List<FoodItem> _getMockLunchItems() {
    return [
      FoodItemModel(
        id: '3',
        name: 'Grilled Chicken Salad',
        calories: 350,
        weight: '1 plate',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '12:30',
        mealType: 'lunch',
        protein: 30,
        carbs: 15,
        fat: 18.toInt(),
        color: Color(0xFF0F67FE),
      ),
      FoodItemModel(
        id: '4',
        name: 'Whole Grain Bread',
        calories: 120,
        weight: '1 slice',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '12:45',
        mealType: 'lunch',
        protein: 4,
        carbs: 22,
        fat: 2,
        color: Color(0xFF0F67FE),
      ),
    ];
  }

  List<FoodItem> _getMockDinnerItems() {
    return [
      FoodItemModel(
        id: '5',
        name: 'Grilled Salmon',
        calories: 280,
        weight: '150g',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '19:00',
        mealType: 'dinner',
        protein: 25,
        carbs: 0,
        fat: 18,
        color: Color(0xFF0F67FE),
      ),
      FoodItemModel(
        id: '6',
        name: 'Steamed Vegetables',
        calories: 85,
        weight: '1 cup',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '19:15',
        mealType: 'dinner',
        protein: 3.toInt(),
        carbs: 11.toInt(),
        fat: 0.toInt(),
        color: Color(0xFF0F67FE),
      ),
    ];
  }

  List<FoodItem> _getMockSnackItems() {
    return [
      FoodItemModel(
        id: '7',
        name: 'Apple',
        calories: 95,
        weight: '1 medium',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '15:30',
        mealType: 'snacks',
        protein: 0,
        carbs: 25,
        fat: 0,
        color: Color(0xFF0F67FE),
      ),
      FoodItemModel(
        id: '8',
        name: 'Almonds',
        calories: 160,
        weight: '1 oz',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: '16:00',
        mealType: 'snacks',
        protein: 6,
        carbs: 6,
        fat: 14,
        color: Color(0xFF0F67FE),
      ),
    ];
  }

  @override
  Future<String> getFoodScore() async {
    try {
      final response = await apiClient.get('/food/score');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['score'].toString();
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to load food score. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Return a mock score for demonstration
      return '85';
    }
  }

  @override
  Future<String> getDailyFoodScore(String date) async {
    try {
      final response = await apiClient.get('/food/score/daily/$date');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['score'].toString();
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to load daily food score. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Return a mock score for demonstration
      return '78';
    }
  }

  @override
  Future<List<FoodItem>> getPopularFoods() async {
    try {
      final response = await apiClient.get('/food/popular');
      
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        
        return responseData.map((item) {
          return FoodItemModel(
            id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: item['name'] ?? 'Unknown Food',
            calories: item['calories'] ?? 0,
            weight: item['weight'] ?? '100g',
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            time: DateFormat('HH:mm').format(DateTime.now()),
            mealType: 'snacks', // Default meal type
            protein: item['protein'] ?? 0,
            carbs: item['carbs'] ?? 0,
            fat: item['fat'] ?? 0,
            color: Color(0xFF0F67FE),
          );
        }).toList();
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to load popular foods. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Return mock popular foods for demonstration
      return [
        FoodItemModel(
          id: 'p1',
          name: 'Avocado Toast',
          calories: 220,
          weight: '1 slice',
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          time: DateFormat('HH:mm').format(DateTime.now()),
          mealType: 'breakfast',
          protein: 5,
          carbs: 18,
          fat: 15,
          color: Color(0xFF0F67FE),
        ),
        FoodItemModel(
          id: 'p2',
          name: 'Protein Smoothie',
          calories: 280,
          weight: '1 cup',
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          time: DateFormat('HH:mm').format(DateTime.now()),
          mealType: 'breakfast',
          protein: 20,
          carbs: 30,
          fat: 5,
          color: Color(0xFF0F67FE),
        ),
        FoodItemModel(
          id: 'p3',
          name: 'Quinoa Bowl',
          calories: 350,
          weight: '1 bowl',
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          time: DateFormat('HH:mm').format(DateTime.now()),
          mealType: 'lunch',
          protein: 12,
          carbs: 60,
          fat: 8,
          color: Color(0xFF0F67FE),
        ),
      ];
    }
  }

  @override
  Future<NutritionData> getNutritionData(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await apiClient.get('/food/nutrition/$formattedDate');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return NutritionData.fromApi(
          calories: responseData['calories'] ?? 0,
          protein: responseData['protein'] ?? 0,
          carbs: responseData['carbs'] ?? 0,
          fat: responseData['fat'] ?? 0,
          sugar: responseData['sugar'] ?? 0,
          fiber: responseData['fiber'] ?? 0,
          date: date,
        );
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to load nutrition data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Return mock nutrition data for demonstration
      return NutritionData.fromApi(
        calories: 1850,
        protein: 85,
        carbs: 220,
        fat: 60,
        sugar: 45,
        fiber: 25,
        date: DateTime.now(),
      );
    }
  }

  @override
  Future<bool> addFoodItem(FoodItem foodItem) async {
    try {
      final Map<String, dynamic> body = {
        'name': foodItem.name,
        'calories': foodItem.calories,
        'weight': foodItem.weight,
        'date': foodItem.date,
        'time': foodItem.time,
        'mealType': foodItem.mealType,
        'protein': foodItem.protein,
        'carbs': foodItem.carbs,
        'fat': foodItem.fat,
      };
      
      final response = await apiClient.post(
        '/food/add',
        body: body,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to add food item. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // For demonstration, return success
      return true;
    }
  }

  @override
  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      final Map<String, dynamic> body = {
        'name': foodItem.name,
        'calories': foodItem.calories,
        'weight': foodItem.weight,
        'date': foodItem.date,
        'time': foodItem.time,
        'mealType': foodItem.mealType,
        'protein': foodItem.protein,
        'carbs': foodItem.carbs,
        'fat': foodItem.fat,
      };
      
      final response = await apiClient.put(
        '/food/update/${foodItem.id}',
        body: body,
      );
      
      if (response.statusCode != 200) {
        throw ServerException.fromMessage(
          message: 'Failed to update food item. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // For demonstration, just return without throwing an exception
      return;
    }
  }

  @override
  Future<void> deleteFoodItem(String id) async {
    try {
      final response = await apiClient.delete('/food/delete/$id');
      
      if (response.statusCode != 200) {
        throw ServerException.fromMessage(
          message: 'Failed to delete food item. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // For demonstration, just return without throwing an exception
      return;
    }
  }

  @override
  Future<bool> logFoodItems(String date, List<Map<String, dynamic>> foodItems) async {
    try {
      final Map<String, dynamic> body = {
        'date': date,
        'items': foodItems,
      };
      
      final response = await apiClient.post(
        '/food/log',
        body: body,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to log food items. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // For demonstration, return success
      return true;
    }
  }

  @override
  Future<List<FoodItem>> getFoodItems(String accessToken) async {
    try {
      final response = await client.get(
        Uri.parse('https://food-service-prod.onrender.com/api/food/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        
        return responseData.map((item) {
          // Convert each item to a FoodItemModel
          return FoodItemModel(
            id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: item['name'] ?? 'Unknown Food',
            calories: item['calories'] ?? 0,
            weight: item['weight'] ?? '100g',
            date: item['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
            time: item['time'] ?? DateFormat('HH:mm').format(DateTime.now()),
            mealType: item['mealType'] ?? 'snacks',
            protein: item['protein'] ?? 0,
            carbs: item['carbs'] ?? 0,
            fat: item['fat'] ?? 0,
            color: _getFoodColor(item['name'] ?? ''),
          );
        }).toList();
      } else {
        throw ServerException.fromMessage(
          message: 'Failed to load food items. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching food items: $e');
      // Return mock food items for demonstration in case of error
      return _getMockPopularFoods();
    }
  }

// Helper method to assign colors based on food names
Color _getFoodColor(String foodName) {
  final lowerCaseName = foodName.toLowerCase();
  
  if (lowerCaseName.contains('vegetable') || 
      lowerCaseName.contains('salad') ||
      lowerCaseName.contains('broccoli')) {
    return Color(0xFF4CAF50); // Green for vegetables
  } else if (lowerCaseName.contains('fruit') || 
             lowerCaseName.contains('apple') || 
             lowerCaseName.contains('banana')) {
    return Color(0xFFFF9800); // Orange for fruits
  } else if (lowerCaseName.contains('meat') || 
             lowerCaseName.contains('chicken') ||
             lowerCaseName.contains('beef')) {
    return Color(0xFFE57373); // Light red for meats
  } else if (lowerCaseName.contains('bread') || 
             lowerCaseName.contains('pasta') ||
             lowerCaseName.contains('rice')) {
    return Color(0xFFFFB74D); // Light orange for carbs
  } else if (lowerCaseName.contains('dairy') || 
             lowerCaseName.contains('milk') ||
             lowerCaseName.contains('cheese')) {
    return Color(0xFF90CAF9); // Light blue for dairy
  } else if (lowerCaseName.contains('dessert') || 
             lowerCaseName.contains('cake') ||
             lowerCaseName.contains('cookie')) {
    return Color(0xFFF48FB1); // Pink for desserts
  } else if (lowerCaseName.contains('beverage') || 
             lowerCaseName.contains('drink') ||
             lowerCaseName.contains('juice')) {
    return Color(0xFF81D4FA); // Light blue for beverages
  }
  
  // Default color
  return Color(0xFF0F67FE);
}

  List<FoodItem> _getMockPopularFoods() {
    return [
      FoodItemModel(
        id: 'p1',
        name: 'Avocado Toast',
        calories: 220,
        weight: '1 slice',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        mealType: 'breakfast',
        protein: 5,
        carbs: 18,
        fat: 15,
        color: Color(0xFF0F67FE),
      ),
      FoodItemModel(
        id: 'p2',
        name: 'Protein Smoothie',
        calories: 280,
        weight: '1 cup',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        mealType: 'breakfast',
        protein: 20,
        carbs: 30,
        fat: 5,
        color: Color(0xFF0F67FE),
      ),
      FoodItemModel(
        id: 'p3',
        name: 'Quinoa Bowl',
        calories: 350,
        weight: '1 bowl',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        mealType: 'lunch',
        protein: 12,
        carbs: 60,
        fat: 8,
        color: Color(0xFF0F67FE),
      ),
    ];
  }
}
