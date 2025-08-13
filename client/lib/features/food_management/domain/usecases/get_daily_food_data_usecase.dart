// lib/features/food_management/domain/usecases/get_daily_food_data_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../entities/food_item.dart';
import '../../../../core/errors/failures.dart';

class GetDailyFoodDataUseCase {
  final FoodRepository repository;

  GetDailyFoodDataUseCase(this.repository);

  Future<Either<Failure, Map<String, List<FoodItem>>>> call(String date) {
    return repository.getDailyFoodData(date);
  }
}