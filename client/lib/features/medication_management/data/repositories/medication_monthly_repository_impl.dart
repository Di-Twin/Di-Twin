import '../datasources/medication_monthly_remote_datasource.dart';
import '../models/monthly_medication_model.dart';
import '../../domain/repositories/medication_monthly_repository.dart';

class MedicationMonthlyRepositoryImpl implements MedicationMonthlyRepository {
  final MedicationMonthlyRemoteDataSource remoteDataSource;

  MedicationMonthlyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MonthlyMedicationModel> getMonthlyMedicationData(int year, int month) async {
    try {
      return await remoteDataSource.getMonthlyMedicationData(year, month);
    } catch (e) {
      throw Exception('Failed to get monthly medication data: $e');
    }
  }
}
