import '../../data/models/monthly_medication_model.dart';

abstract class MedicationMonthlyRepository {
  Future<MonthlyMedicationModel> getMonthlyMedicationData(int year, int month);
}
