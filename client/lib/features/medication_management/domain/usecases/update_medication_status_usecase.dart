import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateMedicationStatusUseCase {
  final MedicationRepository repository;

  UpdateMedicationStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(String medicationId, bool taken) async {
    return await repository.updateMedicationStatus(medicationId, taken);
  }
}
