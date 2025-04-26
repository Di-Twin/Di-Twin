// lib/features/food_management/data/repositories/food_repository_impl.dart
import 'package:client/features/food_management/data/models/food_item_model.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/nutrition_data.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_remote_datasource.dart';
import '../datasources/food_local_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;
  final FoodLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FoodRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, List<FoodItem>>>> getDailyFoodData(String date) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getDailyFoodData(date);
        await localDataSource.cacheDailyFoodData(date, remoteData);
        return Right(remoteData);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localData = await localDataSource.getDailyFoodData(date);
        return Right(localData);
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, String>> getFoodScore() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteScore = await remoteDataSource.getFoodScore();
        await localDataSource.cacheFoodScore(remoteScore);
        return Right(remoteScore);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localScore = await localDataSource.getFoodScore();
        return Right(localScore);
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getPopularFoods() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFoods = await remoteDataSource.getPopularFoods();
        await localDataSource.cachePopularFoods(remoteFoods);
        return Right(remoteFoods);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localFoods = await localDataSource.getPopularFoods();
        return Right(localFoods);
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NutritionData>> getNutritionData(DateTime date) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getNutritionData(date);
        await localDataSource.cacheNutritionData(remoteData);
        return Right(remoteData);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localData = await localDataSource.getNutritionData(date);
        return Right(localData);
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> addFoodItem(FoodItem foodItem) async {
    if (await networkInfo.isConnected) {
      try {
        // We need to cast FoodItem to FoodItemModel
        // This is a simplification - in a real app, you'd use a proper mapper
        final foodItemModel = foodItem as FoodItemModel;
        await remoteDataSource.addFoodItem(foodItemModel);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateFoodItem(FoodItem foodItem) async {
    if (await networkInfo.isConnected) {
      try {
        // We need to cast FoodItem to FoodItemModel
        // This is a simplification - in a real app, you'd use a proper mapper
        final foodItemModel = foodItem as FoodItemModel;
        await remoteDataSource.updateFoodItem(foodItemModel);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFoodItem(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteFoodItem(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
