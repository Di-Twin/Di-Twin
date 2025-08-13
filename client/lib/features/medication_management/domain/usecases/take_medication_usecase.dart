import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:dartz/dartz.dart';

class TakeMedicationUseCase {
  final MedicationRemoteDataSource remoteDataSource;

  TakeMedicationUseCase({required this.remoteDataSource});

  Future<Either<Failure, MedicationActionResponseModel>> call(TakeMedicationParams params) async {
    try {
      final result = await remoteDataSource.takeMedication(
        params.medicationId,
        params.date,
        params.time,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark medication as taken: $e'));
    }
  }
}

class TakeMedicationParams {
  final String medicationId;
  final String date;
  final String time;

  TakeMedicationParams({
    required this.medicationId,
    required this.date,
    required this.time,
  });
}
