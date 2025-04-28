import 'package:dartz/dartz.dart';
import '../repositories/daily_food_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/daily_food.dart';

class GetDailyFoodUseCase {
  final DailyFoodRepository repository;

  GetDailyFoodUseCase(this.repository);

  Future<Either<Failure, DailyFood>> call(String date) {
    return repository.getDailyFood(date);
  }
}
