import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:dartz/dartz.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<MedicationSchedule>>> getMedicationSchedules();
  Future<Either<Failure, MedicationSchedule>> getMedicationScheduleForDate(String date);
  Future<Either<Failure, bool>> updateMedicationStatus(String medicationId, bool taken);
  Future<Either<Failure, bool>> addMedication(Medication medication, String date, String time);
}
