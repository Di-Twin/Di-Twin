import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:client/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:dartz/dartz.dart';

class GetMedicationSchedulesUseCase {
  final MedicationRepository repository;

  GetMedicationSchedulesUseCase(this.repository);

  Future<Either<Failure, List<MedicationSchedule>>> call() async {
    return await repository.getMedicationSchedules();
  }
}
