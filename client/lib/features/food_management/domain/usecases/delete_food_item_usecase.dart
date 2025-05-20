// lib/features/food_management/domain/usecases/delete_food_item_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../../../../core/errors/failures.dart';

class DeleteFoodItemUseCase {
  final FoodRepository repository;

  DeleteFoodItemUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteFoodItem(id);
  }
}
