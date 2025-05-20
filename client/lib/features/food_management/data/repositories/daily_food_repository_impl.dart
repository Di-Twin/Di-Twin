import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/daily_food.dart';
import '../../domain/repositories/daily_food_repository.dart';
import '../datasources/daily_food_remote_datasource.dart';

class DailyFoodRepositoryImpl implements DailyFoodRepository {
  final DailyFoodRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DailyFoodRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DailyFood>> getDailyFood(String date) async {
    if (await networkInfo.isConnected) {
      try {
        final dailyFood = await remoteDataSource.getDailyFood(date);
        return Right(dailyFood);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
