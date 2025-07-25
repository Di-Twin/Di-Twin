import 'package:client/features/weight_management/domain/entities/weight_range_entity.dart';

class WeightProgressEntity {
  final double? currentWeight;
  final double? startWeight;
  final WeightRangeEntity? targetRange;
  final Map<String, double> weightHistory;
  final Map<String, double> bmiHistory;
  final bool isTargetAchieved;

  const WeightProgressEntity({
    this.currentWeight,
    this.startWeight,
    this.targetRange,
    required this.weightHistory,
    required this.bmiHistory,
    required this.isTargetAchieved,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightProgressEntity &&
        other.currentWeight == currentWeight &&
        other.startWeight == startWeight &&
        other.targetRange == targetRange &&
        other.isTargetAchieved == isTargetAchieved;
  }

  @override
  int get hashCode {
    return currentWeight.hashCode ^
        startWeight.hashCode ^
        targetRange.hashCode ^
        isTargetAchieved.hashCode;
  }
}