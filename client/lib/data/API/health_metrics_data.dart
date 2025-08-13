class HealthMetrics {
  final String id;
  final String userId;
  final String dayId;
  final int? targetCalories;
  final double? activityScore;
  final double? foodScore;
  final double? healthScore;
  final int? bp;
  final int? spo2Avg;
  final int? spo2Min;
  final int? spo2Max;
  final int? totalSteps;
  final double? distanceCovered;
  final List<dynamic>? waterIntake;
  final int? totalWaterTaken;
  final double? sleepScore;
  final double? sleepHours;
  final List<dynamic>? activityScoreArray;
  final List<dynamic>? foodScoreArray;
  final int? totalCaloriesBurnt;
  final dynamic nutritionTaken;
  final double? metabolicScore;
  final int? vo2Max;
  final dynamic medicationData;
  final dynamic medicationNotifications;
  final double? weight;
  final String createdAt;

  HealthMetrics({
    required this.id,
    required this.userId,
    required this.dayId,
    this.targetCalories,
    this.activityScore,
    this.foodScore,
    this.healthScore,
    this.bp,
    this.spo2Avg,
    this.spo2Min,
    this.spo2Max,
    this.totalSteps,
    this.distanceCovered,
    this.waterIntake,
    this.totalWaterTaken,
    this.sleepScore,
    this.sleepHours,
    this.activityScoreArray,
    this.foodScoreArray,
    this.totalCaloriesBurnt,
    this.nutritionTaken,
    this.metabolicScore,
    this.vo2Max,
    this.medicationData,
    this.medicationNotifications,
    this.weight,
    required this.createdAt,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      id: json['id'],
      userId: json['userId'],
      dayId: json['dayId'],
      targetCalories: json['target_calories'] as int?,
      activityScore: (json['activity_score'] as num?)?.toDouble(),
      foodScore: (json['food_score'] as num?)?.toDouble(),
      healthScore: (json['health_score'] as num?)?.toDouble(),
      bp: json['bp'] as int?,
      spo2Avg: json['spo2_avg'] as int?,
      spo2Min: json['spo2_min'] as int?,
      spo2Max: json['spo2_max'] as int?,
      totalSteps: json['total_steps'] as int?,
      distanceCovered: (json['distance_covered'] as num?)?.toDouble(),
      waterIntake: json['water_intake'] as List<dynamic>?,
      totalWaterTaken: json['total_water_taken'] as int?,
      sleepScore: (json['sleep_score'] as num?)?.toDouble(),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      activityScoreArray: json['activity_score_array'] as List<dynamic>?,
      foodScoreArray:
          (json['food_score_array'] as List<dynamic>?)
              ?.where((e) => e != null)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      totalCaloriesBurnt: json['total_calories_burnt'] as int?,
      nutritionTaken: json['nutrition_taken'],
      metabolicScore: (json['metabolic_score'] as num?)?.toDouble(),
      vo2Max: json['vo2Max'] as int?,
      medicationData:
          json['medication_data'], // Note: Typo here? Should it be 'medication_data'?
      medicationNotifications: json['medication_notifications'],
      weight: (json['weight'] as num?)?.toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class HealthMetricsResponse {
  final bool success;
  final String message;
  final HealthMetrics data;

  HealthMetricsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HealthMetricsResponse.fromJson(Map<String, dynamic> json) {
    return HealthMetricsResponse(
      success: json['success'],
      message: json['message'],
      data: HealthMetrics.fromJson(json['data']),
    );
  }
}
