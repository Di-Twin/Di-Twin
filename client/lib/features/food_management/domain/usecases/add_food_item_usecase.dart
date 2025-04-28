import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/food_item.dart';
import '../repositories/food_repository.dart';

class AddFoodItemUseCase {
  final FoodRepository repository;

  AddFoodItemUseCase(this.repository);

  Future<Either<Failure, bool>> call(FoodItem foodItem) async {
    return await repository.addFoodItem(foodItem);
  }
}
