import '../../domain/entities/weight_entity.dart';

class WeightModel extends WeightEntity {
  const WeightModel({
    required super.value,
    required super.date,
    super.bmi,
  });

  factory WeightModel.fromJson(Map<String, dynamic> json) {
    return WeightModel(
      value: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': value,
      'date': date.toIso8601String(),
      if (bmi != null) 'bmi': bmi,
    };
  }

  factory WeightModel.fromEntity(WeightEntity entity) {
    return WeightModel(
      value: entity.value,
      date: entity.date,
      bmi: entity.bmi,
    );
  }
}