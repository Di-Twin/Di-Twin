// lib/features/food_management/domain/usecases/update_food_item_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../entities/food_item.dart';
import '../../../../core/errors/failures.dart';

class UpdateFoodItemUseCase {
  final FoodRepository repository;

  UpdateFoodItemUseCase(this.repository);

  Future<Either<Failure, void>> call(FoodItem foodItem) {
    return repository.updateFoodItem(foodItem);
  }
}
