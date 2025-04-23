// lib/features/food_management/domain/usecases/get_nutrition_data_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../entities/nutrition_data.dart';
import '../../../../core/errors/failures.dart';

class GetNutritionDataUseCase {
  final FoodRepository repository;

  GetNutritionDataUseCase(this.repository);

  Future<Either<Failure, NutritionData>> call(DateTime date) {
    return repository.getNutritionData(date);
  }
}
