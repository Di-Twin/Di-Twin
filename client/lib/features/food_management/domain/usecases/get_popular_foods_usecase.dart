// lib/features/food_management/domain/usecases/get_popular_foods_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../entities/food_item.dart';
import '../../../../core/errors/failures.dart';

class GetPopularFoodsUseCase {
  final FoodRepository repository;

  GetPopularFoodsUseCase(this.repository);

  Future<Either<Failure, List<FoodItem>>> call() {
    return repository.getPopularFoods();
  }
}
