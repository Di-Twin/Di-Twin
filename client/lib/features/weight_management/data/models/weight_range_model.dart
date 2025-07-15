import '../../domain/entities/weight_range_entity.dart';

class WeightRangeModel extends WeightRangeEntity {
  const WeightRangeModel({
    required super.min,
    required super.max,
  });

  factory WeightRangeModel.fromJson(List<dynamic> json) {
    return WeightRangeModel(
      min: (json[0] as num).toDouble(),
      max: (json[1] as num).toDouble(),
    );
  }

  List<double> toJson() {
    return [min, max];
  }

  factory WeightRangeModel.fromEntity(WeightRangeEntity entity) {
    return WeightRangeModel(
      min: entity.min,
      max: entity.max,
    );
  }
}