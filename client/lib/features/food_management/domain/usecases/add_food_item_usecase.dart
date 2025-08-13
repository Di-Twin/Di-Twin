import 'package:dartz/dartz.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/domain/repositories/food_repository.dart';

class AddFoodItemUseCase {
  final FoodRepository repository;

  AddFoodItemUseCase(this.repository);

  Future<Either<Failure, void>> call(FoodItem foodItem) async {
    return await repository.addFoodItem(foodItem);
  }
}
