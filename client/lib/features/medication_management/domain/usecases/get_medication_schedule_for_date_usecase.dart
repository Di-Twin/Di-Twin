import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:client/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:dartz/dartz.dart';

class GetMedicationScheduleForDateUseCase {
  final MedicationRepository repository;

  GetMedicationScheduleForDateUseCase(this.repository);

  Future<Either<Failure, MedicationSchedule>> call(String date) async {
    return await repository.getMedicationScheduleForDate(date);
  }
}
