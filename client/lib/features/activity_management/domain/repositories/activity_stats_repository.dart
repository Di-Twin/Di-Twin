import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/activity_stat.dart';

abstract class ActivityStatsRepository {
  Future<Either<Failure, List<ActivityStat>>> getActivityStats();
}
