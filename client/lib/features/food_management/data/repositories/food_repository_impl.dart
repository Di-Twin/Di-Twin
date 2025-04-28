import 'dart:ui';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_remote_datasource.dart';
import 'package:client/features/food_management/data/models/food_item_model.dart';
import 'package:client/features/food_management/domain/entities/nutrition_data.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FoodRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, List<FoodItem>>>> getDailyFoodData(String date) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getDailyFoodData(date);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> getFoodScore() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getFoodScore();
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> getDailyFoodScore(String accessToken, String date) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getDailyFoodScore(accessToken, date);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getPopularFoods() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getPopularFoods();
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, NutritionData>> getNutritionData(DateTime date) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getNutritionData(date);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> addFoodItem(FoodItem foodItem) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.addFoodItem(foodItem);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFoodItem(FoodItem foodItem) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert FoodItem to FoodItemModel
        final foodItemModel = _convertToFoodItemModel(foodItem);
        await remoteDataSource.updateFoodItem(foodItemModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // Helper method to convert FoodItem to FoodItemModel
  FoodItemModel _convertToFoodItemModel(FoodItem foodItem) {
    // If it's already a FoodItemModel, just return it
    if (foodItem is FoodItemModel) {
      return foodItem;
    }
    
    // Otherwise, create a new FoodItemModel with the properties from FoodItem
    return FoodItemModel(
      id: foodItem.id,
      name: foodItem.name,
      calories: foodItem.calories,
      weight: foodItem.weight,
      date: foodItem.date,
      time: foodItem.time,
      mealType: foodItem.mealType,
      protein: foodItem.protein,
      carbs: foodItem.carbs,
      fat: foodItem.fat,
      color: foodItem.color,
    );
  }

  @override
  Future<Either<Failure, void>> deleteFoodItem(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteFoodItem(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> logFoodItems(String accessToken, String date, List<Map<String, dynamic>> foodItems) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.logFoodItems(accessToken, date, foodItems);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
