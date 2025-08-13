import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:dartz/dartz.dart';

class SkipMedicationUseCase {
  final MedicationRemoteDataSource remoteDataSource;

  SkipMedicationUseCase({required this.remoteDataSource});

  Future<Either<Failure, MedicationActionResponseModel>> call(SkipMedicationParams params) async {
    try {
      final result = await remoteDataSource.skipMedication(
        params.medicationId,
        params.date,
        params.time,
        params.reason,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark medication as skipped: $e'));
    }
  }
}

class SkipMedicationParams {
  final String medicationId;
  final String date;
  final String time;
  final String? reason;

  SkipMedicationParams({
    required this.medicationId,
    required this.date,
    required this.time,
    this.reason,
  });
}
