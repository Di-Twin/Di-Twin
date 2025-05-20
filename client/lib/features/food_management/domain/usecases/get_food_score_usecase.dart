// lib/features/food_management/domain/usecases/get_food_score_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../../../../core/errors/failures.dart';

class GetFoodScoreUseCase {
  final FoodRepository repository;

  GetFoodScoreUseCase(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.getFoodScore();
  }
}
