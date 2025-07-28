import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:dartz/dartz.dart';

class GetUserMedicationsUseCase {
  final MedicationRemoteDataSource remoteDataSource;

  GetUserMedicationsUseCase({required this.remoteDataSource});

  Future<Either<Failure, List<ApiMedicationModel>>> call() async {
    try {
      final result = await remoteDataSource.getUserMedications();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user medications: $e'));
    }
  }
}
