// lib/features/food_management/domain/usecases/add_food_item_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../entities/food_item.dart';
import '../../../../core/errors/failures.dart';

class AddFoodItemUseCase {
  final FoodRepository repository;

  AddFoodItemUseCase(this.repository);

  Future<Either<Failure, void>> call(FoodItem foodItem) {
    return repository.addFoodItem(foodItem);
  }
}
