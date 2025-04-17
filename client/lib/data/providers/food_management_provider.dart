import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodManagementProvider {
  static final FoodManagementProvider _instance =
      FoodManagementProvider._internal();

  factory FoodManagementProvider() {
    return _instance;
  }

  FoodManagementProvider._internal();

  final String _baseUrl =
      'https://test-prod-f427.onrender.com'; // Replace with your actual base URL

  /// Fetches the daily food score for a specific date
  Future<String> getDailyFoodScore(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/food/score/daily/$date'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          double foodScore = responseData['data']['food_score'].toDouble();
          return foodScore.round().toString();
        } else {
          return '0';
        }
      } else {
        return '0';
      }
    } catch (error) {
      print('Error fetching food score: $error');
      return '0';
    }
  }

  /// Gets today's food score
  Future<String> getTodayFoodScore() async {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return getDailyFoodScore(formattedDate);
  }

  /// Fetches daily food data for a specific date
  Future<Map<String, List<Map<String, dynamic>>>> getDailyFoodData(
    String date,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/food/daily/$date'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return _processApiMealData(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to fetch food data',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch food data. Status: ${response.statusCode}',
        );
      }
    } catch (error) {
      print('Error fetching food data: $error');
      // Return empty meal data structure on error
      return {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snacks': [],
        'custom': [],
      };
    }
  }

  /// Gets today's food data
  Future<Map<String, List<Map<String, dynamic>>>> getTodayFoodData() async {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return getDailyFoodData(formattedDate);
  }

  /// Transforms API meal data to the format needed by the app
  Map<String, List<Map<String, dynamic>>> _processApiMealData(
    Map<String, dynamic> apiData,
  ) {
    Map<String, List<Map<String, dynamic>>> result = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snacks': [],
      'custom': [],
    };

    // Process meals data
    if (apiData.containsKey('meals')) {
      Map<String, dynamic> meals = apiData['meals'];

      meals.forEach((mealType, foodList) {
        if (result.containsKey(mealType)) {
          for (var foodItem in foodList) {
            // Parse the time
            DateTime foodTime = DateTime.parse(foodItem['time']);
            double timeValue = foodTime.hour + (foodTime.minute / 60);

            // Create a standardized food item
            Map<String, dynamic> processedFood = {
              'name': foodItem['foodName'],
              'calories':
                  foodItem['calories'] is int
                      ? foodItem['calories']
                      : (foodItem['calories'] as double).toInt(),
              // Set default values for data not provided by API
              'protein': 0.0, // Will need to be updated if API provides this
              'carbs': 0.0, // Will need to be updated if API provides this
              'fat': 0.0, // Will need to be updated if API provides this
              'time': _formatTime(foodTime),
              'timeValue': timeValue,
              // Set default icons and colors based on meal type
              'color': _getColorForMealType(mealType),
              'icon': _getIconForMealType(mealType),
              'image':
                  foodItem['imageUrl'] ?? _getDefaultImageForMealType(mealType),
            };

            result[mealType]!.add(processedFood);
          }
        }
      });
    }

    return result;
  }

  /// Get a formatted time string from DateTime (e.g., "08:30 AM")
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }

  /// Get default color for a meal type
  Color _getColorForMealType(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Color(0xFF4CAF50);
      case 'lunch':
        return Color(0xFFFFA726);
      case 'dinner':
        return Color(0xFFEC407A);
      case 'snacks':
        return Color(0xFF7E57C2);
      default:
        return Color(0xFF26A69A);
    }
  }

  /// Get default icon for a meal type
  IconData _getIconForMealType(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.food_bank;
      default:
        return Icons.local_dining;
    }
  }

  /// Get default image path for a meal type
  String _getDefaultImageForMealType(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'images/breakfast.png';
      case 'lunch':
        return 'images/lunch.png';
      case 'dinner':
        return 'images/dinner.png';
      case 'snacks':
        return 'images/snack.png';
      default:
        return 'images/food.png';
    }
  }

  /// Gets all foods across all meal types, sorted by time
  List<Map<String, dynamic>> getAllFoodsSortedByTime(
    Map<String, List<Map<String, dynamic>>> mealData,
  ) {
    List<Map<String, dynamic>> allFoods = [];

    mealData.forEach((mealType, foods) {
      for (var food in foods) {
        // Add meal type to the food data
        Map<String, dynamic> foodWithType = Map.from(food);
        foodWithType['mealType'] = mealType;
        allFoods.add(foodWithType);
      }
    });

    // Sort by timeValue
    allFoods.sort(
      (a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double),
    );

    return allFoods;
  }

  /// Gets foods for a specific time period
  List<Map<String, dynamic>> getFoodsForTimePeriod(
    Map<String, List<Map<String, dynamic>>> mealData,
    Map<String, dynamic> timePeriod,
  ) {
    // Get all foods sorted by time
    List<Map<String, dynamic>> allFoods = getAllFoodsSortedByTime(mealData);

    // Filter foods that belong to this time period
    return allFoods.where((food) {
      double timeValue = food['timeValue'] as double;
      return timeValue >= timePeriod['startTime'] &&
          timeValue < timePeriod['endTime'];
    }).toList();
  }

  /// Calculate total calories for a specific time period
  int getTotalCaloriesForTimePeriod(
    Map<String, List<Map<String, dynamic>>> mealData,
    Map<String, dynamic> timePeriod,
  ) {
    List<Map<String, dynamic>> periodFoods = getFoodsForTimePeriod(
      mealData,
      timePeriod,
    );

    int totalCalories = 0;
    for (var food in periodFoods) {
      totalCalories += food['calories'] as int;
    }
    return totalCalories;
  }

  /// Calculate total nutrients for a meal type
  Map<String, double> calculateTotalNutrients(
    Map<String, List<Map<String, dynamic>>> mealData, [
    String? specificMealType,
  ]) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    void processMeal(String mealType, List<Map<String, dynamic>> foods) {
      for (var food in foods) {
        totalCalories += food['calories'] as num;
        totalProtein += food['protein'] as num;
        totalCarbs += food['carbs'] as num;
        totalFat += food['fat'] as num;
      }
    }

    if (specificMealType != null && mealData.containsKey(specificMealType)) {
      processMeal(specificMealType, mealData[specificMealType]!);
    } else {
      mealData.forEach(processMeal);
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  /// Determine the current time period based on the current time
  String getCurrentTimePeriod(List<Map<String, dynamic>> timePeriods) {
    final now = DateTime.now();
    double currentTimeValue = now.hour + (now.minute / 60);

    for (var period in timePeriods) {
      double startTime = period['startTime'] as double;
      double endTime = period['endTime'] as double;

      if (currentTimeValue >= startTime && currentTimeValue < endTime) {
        return period['name'] as String;
      }
    }

    // Default to the first time period if current time doesn't match any period
    return timePeriods.isNotEmpty ? timePeriods.first['name'] as String : '';
  }

  Future<List<Map<String, dynamic>>> getPopularFoods() async {
  try {
    final response = await http.get(
      Uri.parse('https://food-service-prod.onrender.com/api/food/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      return responseData.map((item) {
        // Extract macronutrients and ensure they're properly formatted
        final macros = item['macronutrients'] ?? {};
        
        // Calculate total calories (using energy_kcal from macronutrients)
        final int calories = macros['energy_kcal'] != null
            ? (macros['energy_kcal'] is int)
                ? macros['energy_kcal']
                : (macros['energy_kcal'] as double).toInt()
            : 0;
            
        // Extract protein, carbs and fat values
        final double protein = macros['protein_g'] != null
            ? (macros['protein_g'] is int)
                ? (macros['protein_g'] as int).toDouble()
                : macros['protein_g'] as double
            : 0.0;
            
        final double carbs = macros['carbohydrates_g'] != null
            ? (macros['carbohydrates_g'] is int)
                ? (macros['carbohydrates_g'] as int).toDouble()
                : macros['carbohydrates_g'] as double
            : 0.0;
            
        final double fat = macros['fat_g'] != null
            ? (macros['fat_g'] is int)
                ? (macros['fat_g'] as int).toDouble()
                : macros['fat_g'] as double
            : 0.0;
            
        final double fiber = macros['fiber_g'] != null
            ? (macros['fiber_g'] is int)
                ? (macros['fiber_g'] as int).toDouble()
                : macros['fiber_g'] as double
            : 0.0;

        // Get the first ingredient as a fallback for image
        final String firstIngredient =
            (item['ingredients'] != null && item['ingredients'].isNotEmpty)
                ? item['ingredients'][0]
                : 'food';

        return {
          'name': item['food_name'],
          'weight': '100g', // Default weight as it's not provided in API
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'fiber': fiber,
          'icon': _getIconForFoodItem(item['food_name']),
          'image': 'images/${firstIngredient.toLowerCase()}.png',
        };
      }).toList();
    } else {
      throw Exception(
        'Failed to fetch popular foods. Status: ${response.statusCode}',
      );
    }
  } catch (error) {
    print('Error fetching popular foods: $error');
    // Return an empty list as a fallback
    return [];
  }
}

  /// Adds a custom food item to the database
  Future<bool> addCustomFood(Map<String, dynamic> foodData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/food/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(foodData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        print('Failed to add custom food. Status: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error adding custom food: $error');
      return false;
    }
  }

   Future<Map<String, dynamic>> addFoodItem(Map<String, dynamic> foodData) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/food/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(foodData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add food item: ${response.body}');
    }
  }

  /// Helper method to get access token
  Future<String> _getAccessToken() async {
    // Implement your token retrieval logic here
    // This could be from secure storage or a user session manager
    // For now, returning a placeholder
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJkYjJhMGI0YS1kYTNjLTRiNjQtOTYxNS0yYmIwOTBmYzg1OTEiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0ODc3MDQ1LCJleHAiOjE3NDQ4ODA2NDV9.Pcg2wV-HXwjw_G9Wp283w4ulR8V4eA0eEZBnajtsw7g';
  }

  /// Helper method to determine appropriate icon for a food item
  IconData _getIconForFoodItem(String foodName) {
    // Convert to lowercase for case-insensitive comparison
    final name = foodName.toLowerCase();

    if (name.contains('salad') ||
        name.contains('vegetable') ||
        name.contains('spinach')) {
      return Icons.eco;
    } else if (name.contains('fruit') ||
        name.contains('apple') ||
        name.contains('banana')) {
      return Icons.breakfast_dining;
    } else if (name.contains('meat') ||
        name.contains('chicken') ||
        name.contains('beef')) {
      return Icons.dinner_dining;
    } else if (name.contains('drink') ||
        name.contains('juice') ||
        name.contains('smoothie')) {
      return Icons.local_drink;
    } else if (name.contains('protein') || name.contains('bar')) {
      return Icons.food_bank;
    } else {
      return Icons.restaurant;
    }
  }
}
