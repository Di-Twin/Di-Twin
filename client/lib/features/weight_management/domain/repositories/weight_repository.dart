import '../entities/weight_entity.dart';
import '../entities/weight_range_entity.dart';
import '../entities/weight_progress_entity.dart';

abstract class WeightRepository {
  Future<WeightProgressEntity> getWeightProgress();
  Future<Map<String, double>> getWeightData(String period);
  Future<void> updateCurrentWeight(double weight);
  Future<WeightRangeEntity?> getTargetWeightRange();
  Future<double?> getStartWeight();
  Future<void> saveWeightLocally(double weight);
  Future<double?> getLocalWeight();
  Future<bool> shouldShowWeightPopup();
  Future<void> updateWeightPopupSchedule();
}