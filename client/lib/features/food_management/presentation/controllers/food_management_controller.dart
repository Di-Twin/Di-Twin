import 'package:get/get.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/domain/entities/nutrition_data.dart';
import 'package:client/features/food_management/domain/usecases/get_daily_food_data_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_food_score_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_popular_foods_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_nutrition_data_usecase.dart';
import 'package:client/features/food_management/domain/usecases/add_food_item_usecase.dart';
import 'package:client/features/food_management/domain/usecases/update_food_item_usecase.dart';
import 'package:client/features/food_management/domain/usecases/delete_food_item_usecase.dart';

class FoodManagementController extends GetxController {
  final GetDailyFoodDataUseCase getDailyFoodDataUseCase;
  final GetFoodScoreUseCase getFoodScoreUseCase;
  final GetPopularFoodsUseCase getPopularFoodsUseCase;
  final GetNutritionDataUseCase getNutritionDataUseCase;
  final AddFoodItemUseCase addFoodItemUseCase;
  final UpdateFoodItemUseCase updateFoodItemUseCase;
  final DeleteFoodItemUseCase deleteFoodItemUseCase;

  FoodManagementController({
    required this.getDailyFoodDataUseCase,
    required this.getFoodScoreUseCase,
    required this.getPopularFoodsUseCase,
    required this.getNutritionDataUseCase,
    required this.addFoodItemUseCase,
    required this.updateFoodItemUseCase,
    required this.deleteFoodItemUseCase,
  });

  // State variables
  final Rx<Map<String, List<FoodItem>>> foodData = Rx<Map<String, List<FoodItem>>>({});
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString foodScore = '0'.obs;
  final RxList<FoodItem> popularFoods = <FoodItem>[].obs;
  final Rx<NutritionData?> nutritionData = Rx<NutritionData?>(null);

  // Get daily food data
  Future<void> getDailyFoodData(String date) async {
    isLoading.value = true;
    error.value = '';

    final result = await getDailyFoodDataUseCase(date);
    
    result.fold(
      (failure) {
        error.value = 'Failed to load food data';
        isLoading.value = false;
      },
      (data) {
        foodData.value = data;
        isLoading.value = false;
      },
    );
  }

  // Get food score
  Future<void> getFoodScore() async {
    final result = await getFoodScoreUseCase();
    
    result.fold(
      (failure) {
        error.value = 'Failed to load food score';
      },
      (score) {
        foodScore.value = score;
      },
    );
  }

  // Get popular foods
  Future<void> getPopularFoods() async {
    final result = await getPopularFoodsUseCase();
    
    result.fold(
      (failure) {
        error.value = 'Failed to load popular foods';
      },
      (foods) {
        popularFoods.value = foods;
      },
    );
  }

  // Get nutrition data
  Future<void> getNutritionData(DateTime date) async {
    final result = await getNutritionDataUseCase(date);
    
    result.fold(
      (failure) {
        error.value = 'Failed to load nutrition data';
      },
      (data) {
        nutritionData.value = data;
      },
    );
  }

  // Add food item
  Future<bool> addFoodItem(FoodItem foodItem) async {
    final result = await addFoodItemUseCase(foodItem);
    
    return result.fold(
      (failure) {
        error.value = 'Failed to add food item';
        return false;
      },
      (_) {
        // Refresh food data for the day
        getDailyFoodData(foodItem.date.split('T')[0]);
        return true;
      },
    );
  }

  // Update food item
  Future<bool> updateFoodItem(FoodItem foodItem) async {
    final result = await updateFoodItemUseCase(foodItem);
    
    return result.fold(
      (failure) {
        error.value = 'Failed to update food item';
        return false;
      },
      (_) {
        // Refresh food data for the day
        getDailyFoodData(foodItem.date.split('T')[0]);
        return true;
      },
    );
  }

  // Delete food item
  Future<bool> deleteFoodItem(String id, DateTime date) async {
    final result = await deleteFoodItemUseCase(id);
    
    return result.fold(
      (failure) {
        error.value = 'Failed to delete food item';
        return false;
      },
      (_) {
        // Refresh food data for the day
        getDailyFoodData(date.toIso8601String().split('T')[0]);
        return true;
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with today's data
    final today = DateTime.now().toIso8601String().split('T')[0];
    getDailyFoodData(today);
    getFoodScore();
    getPopularFoods();
    getNutritionData(DateTime.now());
  }
}
