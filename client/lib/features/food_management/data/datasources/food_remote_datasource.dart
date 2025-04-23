// lib/features/food_management/data/datasources/food_remote_datasource.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_data_model.dart';
import '../../../../core/network/api_client.dart';

abstract class FoodRemoteDataSource {
  Future<Map<String, List<FoodItemModel>>> getDailyFoodData(String date);
  Future<String> getFoodScore();
  Future<List<FoodItemModel>> getPopularFoods();
  Future<NutritionDataModel> getNutritionData(DateTime date);
  Future<void> addFoodItem(FoodItemModel foodItem);
  Future<void> updateFoodItem(FoodItemModel foodItem);
  Future<void> deleteFoodItem(String id);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final ApiClient apiClient;

  FoodRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, List<FoodItemModel>>> getDailyFoodData(String date) async {
    try {
      final response = await apiClient.get('/food/daily/$date');
      
      Map<String, List<FoodItemModel>> result = {};
      
      response.forEach((mealType, foods) {
        result[mealType] = (foods as List)
            .map((food) => FoodItemModel.fromJson(food))
            .toList();
      });
      
      return result;
    } catch (e) {
      // For demo purposes, return mock data if API fails
      return _getMockDailyFoodData(date);
    }
  }

  @override
  Future<String> getFoodScore() async {
    try {
      final response = await apiClient.get('/food/score');
      return response['score'].toString();
    } catch (e) {
      // For demo purposes, return mock score if API fails
      return _getMockFoodScore();
    }
  }

  @override
  Future<List<FoodItemModel>> getPopularFoods() async {
    try {
      final response = await apiClient.get('/food/popular');
      return (response as List)
          .map((food) => FoodItemModel.fromJson(food))
          .toList();
    } catch (e) {
      // For demo purposes, return mock popular foods if API fails
      return _getMockPopularFoods();
    }
  }

  @override
  Future<NutritionDataModel> getNutritionData(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0]; // Get YYYY-MM-DD format
      final response = await apiClient.get('/food/nutrition/$dateStr');
      return NutritionDataModel.fromJson(response);
    } catch (e) {
      // For demo purposes, return mock nutrition data if API fails
      return _getMockNutritionData(date);
    }
  }

  @override
  Future<void> addFoodItem(FoodItemModel foodItem) async {
    try {
      await apiClient.post('/food/add', body: foodItem.toJson());
    } catch (e) {
      // For demo purposes, just print error
      print('Error adding food item: $e');
    }
  }

  @override
  Future<void> updateFoodItem(FoodItemModel foodItem) async {
    try {
      await apiClient.put('/food/update/${foodItem.id}', body: foodItem.toJson());
    } catch (e) {
      // For demo purposes, just print error
      print('Error updating food item: $e');
    }
  }

  @override
  Future<void> deleteFoodItem(String id) async {
    try {
      await apiClient.delete('/food/delete/$id');
    } catch (e) {
      // For demo purposes, just print error
      print('Error deleting food item: $e');
    }
  }

  // Mock data generators for demo purposes
  Map<String, List<FoodItemModel>> _getMockDailyFoodData(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    
    return {
      'breakfast': [
        FoodItemModel(
          id: 'b1',
          name: 'Oatmeal with Berries',
          calories: 320,
          weight: '250g',
          date: parsedDate,
          time: '08:30',
          mealType: 'breakfast',
          protein: 12,
          carbs: 58,
          fat: 6,
          color: Colors.brown,
        ),
        FoodItemModel(
          id: 'b2',
          name: 'Greek Yogurt',
          calories: 150,
          weight: '150g',
          date: parsedDate,
          time: '08:45',
          mealType: 'breakfast',
          protein: 15,
          carbs: 8,
          fat: 5,
          color: Colors.white,
        ),
      ],
      'lunch': [
        FoodItemModel(
          id: 'l1',
          name: 'Grilled Chicken Salad',
          calories: 420,
          weight: '350g',
          date: parsedDate,
          time: '13:00',
          mealType: 'lunch',
          protein: 35,
          carbs: 20,
          fat: 22,
          color: Colors.green,
        ),
      ],
      'dinner': [
        FoodItemModel(
          id: 'd1',
          name: 'Salmon with Vegetables',
          calories: 520,
          weight: '400g',
          date: parsedDate,
          time: '19:30',
          mealType: 'dinner',
          protein: 40,
          carbs: 25,
          fat: 28,
          color: Colors.orange,
        ),
      ],
      'snacks': [
        FoodItemModel(
          id: 's1',
          name: 'Apple',
          calories: 95,
          weight: '182g',
          date: parsedDate,
          time: '16:00',
          mealType: 'snacks',
          protein: 0,
          carbs: 25,
          fat: 0,
          color: Colors.red,
        ),
        FoodItemModel(
          id: 's2',
          name: 'Almonds',
          calories: 160,
          weight: '28g',
          date: parsedDate,
          time: '11:00',
          mealType: 'snacks',
          protein: 6,
          carbs: 6,
          fat: 14,
          color: Colors.brown,
        ),
      ],
    };
  }

  String _getMockFoodScore() {
    // Generate a random score between 70 and 95
    return (70 + Random().nextInt(26)).toString();
  }

  List<FoodItemModel> _getMockPopularFoods() {
    final today = DateTime.now();
    
    return [
      FoodItemModel(
        id: 'p1',
        name: 'Avocado Toast',
        calories: 280,
        weight: '150g',
        date: today,
        time: '08:00',
        mealType: 'breakfast',
        protein: 8,
        carbs: 30,
        fat: 15,
        color: Colors.green,
      ),
      FoodItemModel(
        id: 'p2',
        name: 'Chicken Breast',
        calories: 165,
        weight: '100g',
        date: today,
        time: '13:00',
        mealType: 'lunch',
        protein: 31,
        carbs: 0,
        fat: 3,
        color: Colors.amber,
      ),
      FoodItemModel(
        id: 'p3',
        name: 'Quinoa Bowl',
        calories: 340,
        weight: '250g',
        date: today,
        time: '13:00',
        mealType: 'lunch',
        protein: 12,
        carbs: 60,
        fat: 6,
        color: Colors.amber.shade700,
      ),
      FoodItemModel(
        id: 'p4',
        name: 'Banana',
        calories: 105,
        weight: '118g',
        date: today,
        time: '10:30',
        mealType: 'snacks',
        protein: 1,
        carbs: 27,
        fat: 0,
        color: Colors.yellow,
      ),
      FoodItemModel(
        id: 'p5',
        name: 'Salmon Fillet',
        calories: 206,
        weight: '100g',
        date: today,
        time: '19:00',
        mealType: 'dinner',
        protein: 22,
        carbs: 0,
        fat: 13,
        color: Colors.deepOrange,
      ),
      FoodItemModel(
        id: 'p6',
        name: 'Greek Salad',
        calories: 180,
        weight: '200g',
        date: today,
        time: '13:00',
        mealType: 'lunch',
        protein: 5,
        carbs: 10,
        fat: 16,
        color: Colors.lightGreen,
      ),
    ];
  }

  NutritionDataModel _getMockNutritionData(DateTime date) {
    // Generate slightly different data based on the day of the month
    final dayFactor = date.day / 30.0; // 0.0 to 1.0 based on day of month
    
    return NutritionDataModel(
      totalNutrition: '${450 + (date.day * 2)}.${date.day}',
      proteins: '${45 + (date.day ~/ 2)}g',
      macro: '${14 + (date.day ~/ 10)}g',
      fiber: '${65 + (date.day ~/ 3)}g',
      blueProgress: 0.5 + (dayFactor * 0.3),
      lightBlueProgress: 0.3,
      redProgress: 0.3 + (dayFactor * 0.2),
      pinkProgress: 0.5 + (dayFactor * 0.1),
      navyProgress: 0.7 + (dayFactor * 0.2),
      grayProgress: 0.2,
      date: date,
    );
  }
}
