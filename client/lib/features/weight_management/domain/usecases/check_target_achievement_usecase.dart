import '../entities/weight_range_entity.dart';

class CheckTargetAchievementUseCase {
  bool call(double currentWeight, WeightRangeEntity targetRange) {
    return targetRange.contains(currentWeight);
  }
}