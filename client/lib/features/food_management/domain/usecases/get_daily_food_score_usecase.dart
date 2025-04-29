import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../../../../core/errors/failures.dart';

class GetDailyFoodScoreUseCase {
  final FoodRepository repository;

  GetDailyFoodScoreUseCase(this.repository);

  Future<Either<Failure, String>> call(String date) {
    return repository.getDailyFoodScore(date);
  }
}
