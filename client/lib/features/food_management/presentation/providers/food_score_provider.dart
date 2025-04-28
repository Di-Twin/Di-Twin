import 'package:flutter/material.dart';
import 'package:client/features/food_management/domain/usecases/get_daily_food_score_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_food_score_usecase.dart';

class FoodScoreProvider extends ChangeNotifier {
  final GetDailyFoodScoreUseCase getDailyFoodScoreUseCase;
  final GetFoodScoreUseCase getFoodScoreUseCase;

  String dailyFoodScore = '0';
  bool isLoading = false;
  String error = '';

  FoodScoreProvider({
    required this.getDailyFoodScoreUseCase,
    required this.getFoodScoreUseCase,
  });

  Future<void> getFoodScore() async {
  isLoading = true;
  error = '';
  notifyListeners();

  final result = await getFoodScoreUseCase();
  
  result.fold(
    (failure) {
      error = failure.toString();
      dailyFoodScore = '0';
    },
    (score) {
      dailyFoodScore = score.toString();
    },
  );

  isLoading = false;
  notifyListeners();
}

  Future<void> getDailyFoodScore({String? date}) async {
  isLoading = true;
  error = '';
  notifyListeners();

  // Get current date in YYYY-MM-DD format if not provided
  final today = date ?? DateTime.now().toString().substring(0, 10);
  
  // Assuming we need an access token - use a placeholder or get it from a secure storage
  final accessToken = "placeholder-token"; // Replace with actual token retrieval
  
  final result = await getDailyFoodScoreUseCase(accessToken, today);
  
  result.fold(
    (failure) {
      error = failure.toString();
      dailyFoodScore = '0';
    },
    (score) {
      dailyFoodScore = score.toString();
    },
  );

  isLoading = false;
  notifyListeners();
}
}
