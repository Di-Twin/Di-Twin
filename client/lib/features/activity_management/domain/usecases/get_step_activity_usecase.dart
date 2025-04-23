import 'package:dartz/dartz.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/features/activity_management/domain/entities/step_activity.dart';
import 'package:client/features/activity_management/domain/repositories/step_activity_repository.dart';

class GetStepActivityUseCase {
  final StepActivityRepository repository;

  GetStepActivityUseCase(this.repository);

  Future<Either<Failure, StepActivity>> execute(DateTime date) {
    return repository.getStepActivity(date);
  }
}
