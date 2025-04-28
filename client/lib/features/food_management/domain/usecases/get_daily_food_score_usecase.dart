// lib/features/food_management/domain/usecases/get_daily_food_score_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/food_repository.dart';
import '../../../../core/errors/failures.dart';

class GetDailyFoodScoreUseCase {
  final FoodRepository repository;

  GetDailyFoodScoreUseCase(this.repository);

  Future<Either<Failure, String>> call(String accessToken, String date) {
    return repository.getDailyFoodScore(accessToken, date);
  }
}
