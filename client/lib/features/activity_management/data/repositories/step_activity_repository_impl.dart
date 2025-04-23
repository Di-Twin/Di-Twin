import 'package:dartz/dartz.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/activity_management/data/datasources/step_activity_remote_datasource.dart';
import 'package:client/features/activity_management/domain/entities/step_activity.dart';
import 'package:client/features/activity_management/domain/repositories/step_activity_repository.dart';

class StepActivityRepositoryImpl implements StepActivityRepository {
  final StepActivityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StepActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, StepActivity>> getStepActivity(DateTime date) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStepActivity = await remoteDataSource.getStepActivity(date);
        return Right(remoteStepActivity);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<double>>> getWeeklyProgress(DateTime weekStart) async {
    if (await networkInfo.isConnected) {
      try {
        final weeklyProgress = await remoteDataSource.getWeeklyProgress(weekStart);
        return Right(weeklyProgress);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
