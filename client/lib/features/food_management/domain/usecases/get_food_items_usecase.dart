// Create a new use case file for getting food items
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../entities/food_item.dart';
import '../../../../core/errors/failures.dart';

class GetFoodItemsUseCase {
  final FoodRepository repository;

  GetFoodItemsUseCase(this.repository);

  Future<Either<Failure, List<FoodItem>>> call(String accessToken) {
    return repository.getFoodItems(accessToken);
  }
}
