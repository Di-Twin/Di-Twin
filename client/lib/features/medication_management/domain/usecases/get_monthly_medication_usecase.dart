import '../repositories/medication_monthly_repository.dart';
import '../../data/models/monthly_medication_model.dart';

class GetMonthlyMedicationUseCase {
  final MedicationMonthlyRepository repository;

  GetMonthlyMedicationUseCase({required this.repository});

  Future<MonthlyMedicationModel> call(int year, int month) async {
    return await repository.getMonthlyMedicationData(year, month);
  }
}
