import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class DeleteMedicationUseCase {
  final MedicationRemoteDataSource remoteDataSource;

  DeleteMedicationUseCase({required this.remoteDataSource});

  Future<Either<Failure, bool>> call(String medicationId) async {
    try {
      final result = await remoteDataSource.deleteMedication(medicationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete medication: $e'));
    }
  }
}
