import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/food_management/data/datasources/food_local_datasource.dart';
import 'package:client/features/food_management/data/datasources/food_remote_datasource.dart';
import 'package:client/features/food_management/data/repositories/food_repository_impl.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/domain/usecases/add_food_item_usecase.dart';
import 'package:client/features/food_management/domain/usecases/delete_food_item_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_daily_food_data_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_food_score_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_nutrition_data_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_popular_foods_usecase.dart';
import 'package:client/features/food_management/domain/usecases/update_food_item_usecase.dart';
import 'package:client/features/food_management/presentation/controllers/food_management_controller.dart';

class FoodManagementProvider {
  late FoodManagementController _controller;
  bool _isInitialized = false;

  FoodManagementProvider() {
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (_isInitialized) return;

    // Initialize dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    final networkInfo = NetworkInfoImpl(InternetConnectionChecker());
    final apiClient = ApiClient(
      baseUrl: 'https://test-prod-f427.onrender.com', // Replace with your actual API URL
      httpClient: http.Client(),
    );

    // Initialize data sources
    final remoteDataSource = FoodRemoteDataSourceImpl(apiClient: apiClient);
    final localDataSource = FoodLocalDataSourceImpl(sharedPreferences: sharedPreferences);

    // Initialize repository
    final repository = FoodRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );

    // Initialize use cases
    final getDailyFoodDataUseCase = GetDailyFoodDataUseCase(repository);
    final getFoodScoreUseCase = GetFoodScoreUseCase(repository);
    final getPopularFoodsUseCase = GetPopularFoodsUseCase(repository);
    final getNutritionDataUseCase = GetNutritionDataUseCase(repository);
    final addFoodItemUseCase = AddFoodItemUseCase(repository);
    final updateFoodItemUseCase = UpdateFoodItemUseCase(repository);
    final deleteFoodItemUseCase = DeleteFoodItemUseCase(repository);

    // Initialize controller
    _controller = FoodManagementController(
      getDailyFoodDataUseCase: getDailyFoodDataUseCase,
      getFoodScoreUseCase: getFoodScoreUseCase,
      getPopularFoodsUseCase: getPopularFoodsUseCase,
      getNutritionDataUseCase: getNutritionDataUseCase,
      addFoodItemUseCase: addFoodItemUseCase,
      updateFoodItemUseCase: updateFoodItemUseCase,
      deleteFoodItemUseCase: deleteFoodItemUseCase,
    );

    _isInitialized = true;
  }

  // Get today's food score
  Future<String> getTodayFoodScore() async {
    await _initializeController();
    await _controller.getFoodScore();
    return _controller.foodScore.value;
  }

  // Get popular foods
  Future<List<Map<String, dynamic>>> getPopularFoods() async {
    await _initializeController();
    await _controller.getPopularFoods();
    
    // Convert FoodItem entities to Map for UI consumption
    return _controller.popularFoods.map((food) {
      return {
        'id': food.id,
        'name': food.name,
        'calories': food.calories,
        'weight': food.weight,
        'protein': food.protein,
        'carbs': food.carbs,
        'fat': food.fat,
        'color': food.color,
        'mealType': food.mealType,
      };
    }).toList();
  }

  // Get daily food data
  Future<Map<String, List<Map<String, dynamic>>>> getDailyFoodData(String date) async {
    await _initializeController();
    await _controller.getDailyFoodData(date);
    
    // Convert FoodItem entities to Map for UI consumption
    Map<String, List<Map<String, dynamic>>> result = {};
    
    _controller.foodData.value.forEach((mealType, foods) {
      result[mealType] = foods.map((food) {
        return {
          'id': food.id,
          'name': food.name,
          'calories': food.calories,
          'weight': food.weight,
          'protein': food.protein,
          'carbs': food.carbs,
          'fat': food.fat,
          'color': food.color,
          'time': food.time,
        };
      }).toList();
    });
    
    return result;
  }

  // Add food item
  Future<bool> addFoodItem(Map<String, dynamic> foodData) async {
    await _initializeController();
    
    // Create a FoodItem from the map
    final foodItem = FoodItem(
      id: foodData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: foodData['name'],
      calories: foodData['calories'],
      weight: foodData['weight'],
      date: foodData['date'] ?? DateTime.now(),
      time: foodData['time'] ?? TimeOfDay.now().format(Get.context!),
      mealType: foodData['mealType'],
      protein: foodData['protein'],
      carbs: foodData['carbs'],
      fat: foodData['fat'],
      color: foodData['color'] ?? Colors.blue,
    );
    
    return await _controller.addFoodItem(foodItem);
  }

  // Update food item
  Future<bool> updateFoodItem(Map<String, dynamic> foodData) async {
    await _initializeController();
    
    // Create a FoodItem from the map
    final foodItem = FoodItem(
      id: foodData['id'],
      name: foodData['name'],
      calories: foodData['calories'],
      weight: foodData['weight'],
      date: foodData['date'],
      time: foodData['time'],
      mealType: foodData['mealType'],
      protein: foodData['protein'],
      carbs: foodData['carbs'],
      fat: foodData['fat'],
      color: foodData['color'],
    );
    
    return await _controller.updateFoodItem(foodItem);
  }

  // Delete food item
  Future<bool> deleteFoodItem(String id, DateTime date) async {
    await _initializeController();
    return await _controller.deleteFoodItem(id, date);
  }

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
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/food/score/daily/$date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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
// Future<String> getTodayFoodScore() async {
//   final today = DateTime.now();
//   final formattedDate =
//       "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
//   return getDailyFoodScore(formattedDate);
// }

/// Fetches daily food data for a specific date
// Future<Map<String, List<Map<String, dynamic>>>> getDailyFoodData(
//   String date,
// ) async {
//   try {
//     // First try to get from cache
//     final cachedData = await _getFoodDataFromCache(date);
//     if (cachedData.isNotEmpty) {
//       print('Retrieved food data from cache for date: $date');
//       return cachedData;
//     }

//     // If not in cache, try to get from API
//     final token = await _getAccessToken();

//     final response = await http.get(
//       Uri.parse('$_baseUrl/food/daily/$date'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);

//       if (responseData['success'] == true) {
//         final processedData = _processApiMealData(responseData['data']);
//         // Save to cache
//         await _saveFoodDataToCache(date, processedData);
//         return processedData;
//       } else {
//         throw Exception(
//           responseData['message'] ?? 'Failed to fetch food data',
//         );
//       }
//     } else {
//       throw Exception(
//         'Failed to fetch food data. Status: ${response.statusCode}',
//       );
//     }
//   } catch (error) {
//     print('Error fetching food data: $error');
//     // Return empty meal data structure on error
//     return {
//       'breakfast': [],
//       'lunch': [],
//       'dinner': [],
//       'snacks': [],
//       'custom': [],
//     };
//   }
// }

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
            'protein': foodItem['protein'] ?? 0.0,
            'carbs': foodItem['carbs'] ?? 0.0,
            'fat': foodItem['fat'] ?? 0.0,
            'time': _formatTime(foodTime),
            'timeValue': timeValue,
            // Set default icons and colors based on meal type
            'colorValue': _getColorValueForMealType(mealType),
            'iconName': _getIconNameForMealType(mealType),
            'image':
                foodItem['imageUrl'] ?? _getDefaultImageForMealType(mealType),
            'weight': foodItem['weight'] ?? '100g',
            'date': DateTime.now().toString(),
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

/// Get default color value for a meal type
int _getColorValueForMealType(String mealType) {
  switch (mealType) {
    case 'breakfast':
      return 0xFF4CAF50;
    case 'lunch':
      return 0xFFFFA726;
    case 'dinner':
      return 0xFFEC407A;
    case 'snacks':
      return 0xFF7E57C2;
    default:
      return 0xFF26A69A;
  }
}

/// Get default icon name for a meal type
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

// Future<List<Map<String, dynamic>>> getPopularFoods() async {
//   try {
//     final token = await _getAccessToken();

//     final response = await http.get(
//       Uri.parse('https://food-service-prod.onrender.com/api/food/items'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);

//       return responseData.map((item) {
//         // Extract macronutrients and ensure they're properly formatted
//         final macros = item['macronutrients'] ?? {};

//         // Calculate total calories (using energy_kcal from macronutrients)
//         final int calories =
//             macros['energy_kcal'] != null
//                 ? (macros['energy_kcal'] is int)
//                     ? macros['energy_kcal']
//                     : (macros['energy_kcal'] as double).toInt()
//                 : 0;

//         // Extract protein, carbs and fat values
//         final double protein =
//             macros['protein_g'] != null
//                 ? (macros['protein_g'] is int)
//                     ? (macros['protein_g'] as int).toDouble()
//                     : macros['protein_g'] as double
//                 : 0.0;

//         final double carbs =
//             macros['carbohydrates_g'] != null
//                 ? (macros['carbohydrates_g'] is int)
//                     ? (macros['carbohydrates_g'] as int).toDouble()
//                     : macros['carbohydrates_g'] as double
//                 : 0.0;

//         final double fat =
//             macros['fat_g'] != null
//                 ? (macros['fat_g'] is int)
//                     ? (macros['fat_g'] as int).toDouble()
//                     : macros['fat_g'] as double
//                 : 0.0;

//         final double fiber =
//             macros['fiber_g'] != null
//                 ? (macros['fiber_g'] is int)
//                     ? (macros['fiber_g'] as int).toDouble()
//                     : macros['fiber_g'] as double
//                 : 0.0;

//         // Get the first ingredient as a fallback for image
//         final String firstIngredient =
//             (item['ingredients'] != null && item['ingredients'].isNotEmpty)
//                 ? item['ingredients'][0]
//                 : 'food';

//         return {
//           'name': item['food_name'],
//           'weight': '100g', // Default weight as it's not provided in API
//           'calories': calories,
//           'protein': protein,
//           'carbs': carbs,
//           'fat': fat,
//           'fiber': fiber,
//           'iconName': _getIconNameForFoodItem(item['food_name']),
//           'image': 'images/${firstIngredient.toLowerCase()}.png',
//         };
//       }).toList();
//     } else {
//       throw Exception(
//         'Failed to fetch popular foods. Status: ${response.statusCode}',
//       );
//     }
//   } catch (error) {
//     print('Error fetching popular foods: $error');
//     // Return an empty list as a fallback
//     return [];
//   }
// }

/// Adds a custom food item to the database
// Future<bool> addCustomFood(Map<String, dynamic> foodData) async {
//   try {
//     final token = await _getAccessToken();

//     final response = await http.post(
//       Uri.parse('https://food-service-prod.onrender.com/api/food/items'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode(foodData),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final responseData = json.decode(response.body);
//       return responseData['success'] == true;
//     } else {
//       print('Failed to add custom food. Status: ${response.statusCode}');
//       return false;
//     }
//   } catch (error) {
//     print('Error adding custom food: $error');
//     return false;
//   }
// }

// Update the addFoodItem method to use the correct endpoint and data structure
// Future<Map<String, dynamic>> addFoodItem(
//   Map<String, dynamic> foodData,
// ) async {
//   try {
//     // First save to cache
//     await _addFoodItemToCache(foodData);
    
//     // Then try to send to API
//     final token = await _getAccessToken();

//     // Format the request according to the API documentation
//     final requestData = {
//       "date": foodData["date"],
//       "foodItems": [
//         {
//           "foodName": foodData["foodName"],
//           "macronutrients": foodData["macronutrients"],
//           "serving_size": foodData["serving_size"],
//           "serving_amount": foodData["serving_amount"],
//           "mealType": foodData["mealType"]
//         }
//       ]
//     };

//     final response = await http.post(
//       Uri.parse('$_baseUrl/food/'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode(requestData),
//     );

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       print('Food added successfully: ${responseData.toString()}');
//       return responseData;
//     } else {
//       print('Failed to add food item to API: ${response.body}');
//       // Return success anyway since we saved to cache
//       return {'success': true, 'message': 'Food saved to cache'};
//     }
//   } catch (error) {
//     print('Error adding food item to API: $error');
//     // Return success anyway since we saved to cache
//     return {'success': true, 'message': 'Food saved to cache'};
//   }
// }

/// Deletes a food item from the database
// Future<bool> deleteFoodItem(Map<String, dynamic> foodData) async {
//   try {
//     // First delete from cache
//     await _deleteFoodItemFromCache(foodData);
    
//     // Then try to delete from API
//     final token = await _getAccessToken();
//     final date = foodData['date'] as String? ?? 
//         DateFormat('yyyy-MM-dd').format(foodData['date'] as DateTime);
    
//     final response = await http.delete(
//       Uri.parse('$_baseUrl/food/item'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         "date": date,
//         "foodName": foodData["foodName"] ?? foodData["name"],
//         "time": foodData["time"],
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('Food deleted successfully from API');
//       return true;
//     } else {
//       print('Failed to delete food from API: ${response.body}');
//       // Return success anyway since we deleted from cache
//       return true;
//     }
//   } catch (error) {
//     print('Error deleting food item: $error');
//     // Return success anyway since we deleted from cache
//     return true;
//   }
// }

/// Helper method to get access token
Future<String?> _getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  if (token == null) {
    throw Exception('No access token found. Please log in.');
  }
  return token;
}

/// Helper method to determine appropriate icon name for a food item
String _getIconNameForFoodItem(String foodName) {
  // Convert to lowercase for case-insensitive comparison
  final name = foodName.toLowerCase();

  if (name.contains('salad') ||
      name.contains('vegetable') ||
      name.contains('spinach')) {
    return 'eco';
  } else if (name.contains('fruit') ||
      name.contains('apple') ||
      name.contains('banana')) {
    return 'breakfast_dining';
  } else if (name.contains('meat') ||
      name.contains('chicken') ||
      name.contains('beef')) {
    return 'dinner_dining';
  } else if (name.contains('drink') ||
      name.contains('juice') ||
      name.contains('smoothie')) {
    return 'local_drink';
  } else if (name.contains('protein') || name.contains('bar')) {
    return 'food_bank';
  } else {
    return 'restaurant';
  }
}

/// Save food data to cache
Future<void> _saveFoodDataToCache(
  String date,
  Map<String, List<Map<String, dynamic>>> foodData,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'food_data_$date';
    
    // Convert food data to JSON string
    final jsonData = json.encode(foodData);
    
    // Save to SharedPreferences
    await prefs.setString(key, jsonData);
    print('Food data saved to cache for date: $date');
  } catch (e) {
    print('Error saving food data to cache: $e');
  }
}

/// Get food data from cache
Future<Map<String, List<Map<String, dynamic>>>> _getFoodDataFromCache(
  String date,
) async {
try {
  final prefs = await SharedPreferences.getInstance();
  final key = 'food_data_$date';
  
  print('Getting food data from cache for date: $date, key: $key');
  
  // Get JSON string from SharedPreferences
  final jsonData = prefs.getString(key);
  
  if (jsonData != null) {
    print('Found cached data for date: $date');
    
    // Parse JSON string to Map
    final Map<String, dynamic> decodedData = Map<String, dynamic>.from(json.decode(jsonData));
    
    // Convert to the expected format
    Map<String, List<Map<String, dynamic>>> result = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snacks': [],
      'custom': [],
    };
    
    decodedData.forEach((mealType, foodList) {
      if (result.containsKey(mealType)) {
        result[mealType]!.addAll((foodList as List).map((e) => Map<String, dynamic>.from(e)).toList());
      }
    });
    
    print('Returning ${result.entries.fold(0, (sum, entry) => sum + entry.value.length)} food items from cache');
    return result;
  } else {
    print('No cached data found for date: $date');
  }
} catch (e) {
  print('Error getting food data from cache: $e');
}

// Return empty structure if no data found or error occurred
print('Returning empty food data structure');
return {
  'breakfast': [],
  'lunch': [],
  'dinner': [],
  'snacks': [],
  'custom': [],
};
}

/// Add a food item to cache
Future<void> _addFoodItemToCache(Map<String, dynamic> foodData) async {
try {
  final date = foodData['date'] as String? ?? 
      DateTime.now().toString().split(' ')[0]; // Use today's date if not provided
  
  print('Adding food to cache for date: $date');
  
  final mealType = foodData['mealType'] as String? ?? 'snacks';
  
  // Get existing food data for the date
  final existingData = await _getFoodDataFromCache(date);
  
  // Create a standardized food item
  final processedFood = {
    'name': foodData['foodName'],
    'calories': foodData['calories'] ?? 0,
    'protein': foodData['protein'] ?? 0.0,
    'carbs': foodData['carbs'] ?? 0.0,
    'fat': foodData['fat'] ?? 0.0,
    'time': foodData['time'] ?? _formatTime(DateTime.now()),
    'timeValue': foodData['timeValue'] ?? 
        (DateTime.now().hour + (DateTime.now().minute / 60)),
    'colorValue': _getColorValueForMealType(mealType),
    'iconName': _getIconNameForMealType(mealType),
    'image': foodData['image'] ?? _getDefaultImageForMealType(mealType),
    'weight': foodData['weight'] ?? '100g',
    'date': date,
  };
  
  print('Processed food item: $processedFood');
  
  // Add the new food item to the appropriate meal type
  if (existingData.containsKey(mealType)) {
    existingData[mealType]!.add(processedFood);
  }
  
  // Save the updated data back to cache
  await _saveFoodDataToCache(date, existingData);
  
  // Update top nutrients cache
  await _updateTopNutrientsCache();
  
  print('Food item added to cache for date: $date, meal type: $mealType');
} catch (e) {
  print('Error adding food item to cache: $e');
}
}

/// Delete a food item from cache
Future<void> _deleteFoodItemFromCache(Map<String, dynamic> foodData) async {
  try {
    final date = foodData['date'] is DateTime 
        ? DateFormat('yyyy-MM-dd').format(foodData['date'] as DateTime)
        : foodData['date'] as String;
    
    final mealType = foodData['mealType'] as String? ?? 'snacks';
    final foodName = foodData['name'] ?? foodData['foodName'];
    final foodTime = foodData['time'];
    
    // Get existing food data for the date
    final existingData = await _getFoodDataFromCache(date);
    
    // Remove the food item from the appropriate meal type
    if (existingData.containsKey(mealType)) {
      existingData[mealType]!.removeWhere((item) => 
        item['name'] == foodName && item['time'] == foodTime);
    }
    
    // Save the updated data back to cache
    await _saveFoodDataToCache(date, existingData);
    
    // Update top nutrients cache
    await _updateTopNutrientsCache();
    
    print('Food item deleted from cache for date: $date, meal type: $mealType');
  } catch (e) {
    print('Error deleting food item from cache: $e');
  }
}

/// Get top nutrients from all cached food data
Future<List<Map<String, dynamic>>> getTopNutrients() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'top_nutrients';
    
    // Get JSON string from SharedPreferences
    final jsonData = prefs.getString(key);
    
    if (jsonData != null) {
      // Parse JSON string to List
      final List<dynamic> decodedData = json.decode(jsonData);
      return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    
    // If no cached data, calculate and cache it
    return await _updateTopNutrientsCache();
  } catch (e) {
    print('Error getting top nutrients from cache: $e');
    return _getDefaultTopNutrients();
  }
}

/// Update top nutrients cache based on all food data
Future<List<Map<String, dynamic>>> _updateTopNutrientsCache() async {
  try {
    // Get today's date
    final today = DateTime.now();
    final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Get food data for today
    final foodData = await _getFoodDataFromCache(formattedDate);
    
    // Calculate total nutrients
    final totalNutrients = calculateTotalNutrients(foodData);
    
    // Create top nutrients list with serializable values
    final List<Map<String, dynamic>> topNutrients = [
      {
        'name': 'Protein',
        'value': totalNutrients['protein']!.toStringAsFixed(1),
        'unit': 'g',
        'colorValue': 0xFF4CAF50,
        'iconName': 'fitness_center',
      },
      {
        'name': 'Carbs',
        'value': totalNutrients['carbs']!.toStringAsFixed(1),
        'unit': 'g',
        'colorValue': 0xFF2196F3,
        'iconName': 'grain',
      },
      {
        'name': 'Fat',
        'value': totalNutrients['fat']!.toStringAsFixed(1),
        'unit': 'g',
        'colorValue': 0xFFFF9800,
        'iconName': 'opacity',
      },
    ];
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'top_nutrients';
    await prefs.setString(key, json.encode(topNutrients));
    
    return topNutrients;
  } catch (e) {
    print('Error updating top nutrients cache: $e');
    return _getDefaultTopNutrients();
  }
}

/// Get default top nutrients
List<Map<String, dynamic>> _getDefaultTopNutrients() {
  return [
    {
      'name': 'Protein',
      'value': '0.0',
      'unit': 'g',
      'colorValue': 0xFF4CAF50,
      'iconName': 'fitness_center',
    },
    {
      'name': 'Carbs',
      'value': '0.0',
      'unit': 'g',
      'colorValue': 0xFF2196F3,
      'iconName': 'grain',
    },
    {
      'name': 'Fat',
      'value': '0.0',
      'unit': 'g',
      'colorValue': 0xFFFF9800,
      'iconName': 'opacity',
    },
  ];
}

/// Convert icon name to IconData
IconData getIconFromName(String iconName) {
  // Use a map of predefined icons to ensure they are constant
  const Map<String, IconData> iconMap = {
    'breakfast_dining': Icons.breakfast_dining,
    'lunch_dining': Icons.lunch_dining,
    'dinner_dining': Icons.dinner_dining,
    'food_bank': Icons.food_bank,
    'local_dining': Icons.local_dining,
    'eco': Icons.eco,
    'restaurant': Icons.restaurant,
    'local_drink': Icons.local_drink,
    'fitness_center': Icons.fitness_center,
    'grain': Icons.grain,
    'opacity': Icons.opacity,
  };
  
  return iconMap[iconName] ?? Icons.help_outline; // Default to help_outline if icon name not found
}

/// Convert color value to Color
Color getColorFromValue(int colorValue) {
  return Color(colorValue);
}
}
