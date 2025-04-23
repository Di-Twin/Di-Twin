import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/activity_stats_repository.dart';
import '../datasources/activity_stats_remote_datasource.dart';
import '../../domain/entities/activity_stat.dart';

class ActivityStatsRepositoryImpl implements ActivityStatsRepository {
  final ActivityStatsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  ActivityStatsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<ActivityStat>>> getActivityStats() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStats = await remoteDataSource.getActivityStats();
        return Right(remoteStats);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
