import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/daily_food.dart';
import '../../domain/entities/meal_item.dart';
import '../../domain/usecases/get_daily_food_usecase.dart';

class DailyFoodProvider extends ChangeNotifier {
  final GetDailyFoodUseCase getDailyFoodUseCase;

  DailyFoodProvider({required this.getDailyFoodUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  DailyFood? _dailyFood;
  DailyFood? get dailyFood => _dailyFood;

  // Get meals by time period (Morning, Afternoon, Evening)
  Map<String, List<MealItem>> getMealsByTimePeriod(String timePeriod) {
    if (_dailyFood == null) return {};

    Map<String, List<MealItem>> result = {};
    
    // Define time ranges for each period
    int startHour = 0;
    int endHour = 24;
    
    if (timePeriod == 'Morning') {
      startHour = 6;
      endHour = 12;
    } else if (timePeriod == 'Afternoon') {
      startHour = 12;
      endHour = 18;
    } else if (timePeriod == 'Evening') {
      startHour = 18;
      endHour = 24;
    }

    // Filter meals by time period
    _dailyFood!.meals.forEach((mealType, mealItems) {
      List<MealItem> filteredItems = mealItems.where((item) {
        final hour = item.time.hour;
        return hour >= startHour && hour < endHour;
      }).toList();
      
      if (filteredItems.isNotEmpty) {
        result[mealType] = filteredItems;
      }
    });

    return result;
  }

  // Calculate total calories for a specific time period
  double getTotalCaloriesForTimePeriod(String timePeriod) {
    final meals = getMealsByTimePeriod(timePeriod);
    double total = 0;
    
    meals.forEach((_, mealItems) {
      for (var item in mealItems) {
        total += item.calories;
      }
    });
    
    return total;
  }

  // Get daily food data for a specific date - directly from API, not from cache
  Future<void> getDailyFood({String? date, bool forceRefresh = true}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    // Use provided date or current date in YYYY-MM-DD format
    final dateStr = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Always fetch fresh data from the API
    final result = await getDailyFoodUseCase(dateStr);
    
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        _dailyFood = data;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
