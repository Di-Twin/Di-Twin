import 'package:dartz/dartz.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/features/activity_management/domain/repositories/step_activity_repository.dart';

class GetWeeklyProgressUseCase {
  final StepActivityRepository repository;

  GetWeeklyProgressUseCase(this.repository);

  Future<Either<Failure, List<double>>> execute(DateTime weekStart) {
    return repository.getWeeklyProgress(weekStart);
  }
}
