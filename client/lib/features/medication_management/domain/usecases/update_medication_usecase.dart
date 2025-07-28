import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:dartz/dartz.dart';

class UpdateMedicationUseCase {
  final MedicationRemoteDataSource remoteDataSource;

  UpdateMedicationUseCase({required this.remoteDataSource});

  Future<Either<Failure, ApiMedicationModel>> call(UpdateMedicationParams params) async {
    try {
      final medicationData = {
        'id': params.id,
        'medicationName': params.medicationName,
        'afterFood': params.afterFood,
        'frequency': params.frequency,
        'timings': params.timings,
        'reminder': params.reminder,
        'dose': params.dose,
        'startDate': params.startDate,
        'endDate': params.endDate,
      };

      final result = await remoteDataSource.createOrUpdateMedication(medicationData);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update medication: $e'));
    }
  }
}

class UpdateMedicationParams {
  final String id;
  final String medicationName;
  final bool afterFood;
  final String frequency;
  final List<String> timings;
  final bool reminder;
  final String dose;
  final String startDate;
  final String endDate;

  UpdateMedicationParams({
    required this.id,
    required this.medicationName,
    required this.afterFood,
    required this.frequency,
    required this.timings,
    required this.reminder,
    required this.dose,
    required this.startDate,
    required this.endDate,
  });
}
