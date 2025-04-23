import 'package:dartz/dartz.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/features/activity_management/domain/entities/step_activity.dart';

abstract class StepActivityRepository {
  Future<Either<Failure, StepActivity>> getStepActivity(DateTime date);
  Future<Either<Failure, List<double>>> getWeeklyProgress(DateTime weekStart);
}
