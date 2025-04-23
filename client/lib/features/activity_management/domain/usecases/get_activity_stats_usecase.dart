import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/activity_stat.dart';
import '../repositories/activity_stats_repository.dart';

class GetActivityStatsUseCase {
  final ActivityStatsRepository repository;
  
  GetActivityStatsUseCase(this.repository);
  
  Future<Either<Failure, List<ActivityStat>>> call() async {
    return await repository.getActivityStats();
  }
}
