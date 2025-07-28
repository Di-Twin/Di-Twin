import 'package:client/core/errors/failures.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:dartz/dartz.dart';

class GetDailyMedicationUseCase {
  final MedicationRemoteDataSource remoteDataSource;

  GetDailyMedicationUseCase({required this.remoteDataSource});

  Future<Either<Failure, DailyMedicationResponseModel>> call(String date) async {
    try {
      final result = await remoteDataSource.getDailyMedicationData(date);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get daily medication data: $e'));
    }
  }
}
