import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/daily_food.dart';

abstract class DailyFoodRepository {
  Future<Either<Failure, DailyFood>> getDailyFood(String date);
}
