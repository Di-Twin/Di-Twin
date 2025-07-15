import '../../domain/entities/weight_progress_entity.dart';
import '../../domain/entities/weight_range_entity.dart';
import '../../domain/repositories/weight_repository.dart';
import '../datasources/weight_local_datasource.dart';
import '../datasources/weight_remote_datasource.dart';
import '../models/weight_range_model.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightRemoteDataSource remoteDataSource;
  final WeightLocalDataSource localDataSource;

  WeightRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<WeightProgressEntity> getWeightProgress() async {
    final currentWeight = await localDataSource.getCurrentWeight();
    final startWeight = await remoteDataSource.getStartWeight();
    final targetRangeModel = await remoteDataSource.getTargetWeightRange();
    final weightHistory = await remoteDataSource.getWeightDataForPeriod('Week');
    
    WeightRangeEntity? targetRange;
    if (targetRangeModel != null) {
      targetRange = WeightRangeEntity(
        min: targetRangeModel.min,
        max: targetRangeModel.max,
      );
      // Save to local storage
      await localDataSource.saveTargetWeightRange(targetRange.min, targetRange.max);
    }

    final isTargetAchieved = currentWeight != null && 
        targetRange != null && 
        targetRange.contains(currentWeight);

    return WeightProgressEntity(
      currentWeight: currentWeight,
      startWeight: startWeight,
      targetRange: targetRange,
      weightHistory: weightHistory,
      bmiHistory: {}, // TODO: Implement BMI history
      isTargetAchieved: isTargetAchieved,
    );
  }

  @override
  Future<Map<String, double>> getWeightData(String period) async {
    return await remoteDataSource.getWeightDataForPeriod(period);
  }

  @override
  Future<void> updateCurrentWeight(double weight) async {
    await remoteDataSource.updateWeight(weight);
    
    // Also update for next 2 days
    for (int i = 1; i <= 2; i++) {
      final futureDate = DateTime.now().add(Duration(days: i));
      await remoteDataSource.updateWeight(weight, date: futureDate);
    }
  }

  @override
  Future<WeightRangeEntity?> getTargetWeightRange() async {
    final rangeModel = await remoteDataSource.getTargetWeightRange();
    if (rangeModel != null) {
      return WeightRangeEntity(min: rangeModel.min, max: rangeModel.max);
    }
    return null;
  }

  @override
  Future<double?> getStartWeight() async {
    return await remoteDataSource.getStartWeight();
  }

  @override
  Future<void> saveWeightLocally(double weight) async {
    await localDataSource.saveCurrentWeight(weight);
  }

  @override
  Future<double?> getLocalWeight() async {
    return await localDataSource.getCurrentWeight();
  }

  @override
  Future<bool> shouldShowWeightPopup() async {
    return await localDataSource.shouldShowWeightPopup();
  }

  @override
  Future<void> updateWeightPopupSchedule() async {
    await localDataSource.saveWeightUpdateSchedule();
  }
}