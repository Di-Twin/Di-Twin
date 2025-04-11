class HealthMetrics {
  final String id;
  final String userId;
  final String dayId;
  final int? targetCalories;
  final int? activityScore;
  final int? foodScore;
  final int? healthScore;
  final int? bp;
  final int? spo2Avg;
  final int? spo2Min;
  final int? spo2Max;
  final int? totalSteps;
  final double? distanceCovered;
  final int? waterIntake;
  final int? totalWaterTaken;
  final int? sleepScore;
  final double? sleepHours;
  final List<dynamic>? activityScoreArray;
  final List<dynamic>? foodScoreArray;
  final int? totalCaloriesBurnt;
  final dynamic nutritionTaken;
  final int? metabolicScore;
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
      targetCalories: json['target_calories'],
      activityScore: json['activity_score'],
      foodScore: json['food_score'],
      healthScore: json['health_score'],
      bp: json['bp'],
      spo2Avg: json['spo2_avg'],
      spo2Min: json['spo2_min'],
      spo2Max: json['spo2_max'],
      totalSteps: json['total_steps'],
      distanceCovered: json['distance_covered']?.toDouble(),
      waterIntake: json['water_intake'],
      totalWaterTaken: json['total_water_taken'],
      sleepScore: json['sleep_score'],
      sleepHours: json['sleep_hours']?.toDouble(),
      activityScoreArray: json['activity_score_array'],
      foodScoreArray: json['food_score_array'],
      totalCaloriesBurnt: json['total_calories_burnt'],
      nutritionTaken: json['nutrition_taken'],
      metabolicScore: json['metabolic_score'],
      vo2Max: json['vo2Max'],
      medicationData: json['medication_data'],
      medicationNotifications: json['medication_notifications'],
      weight: json['weight']?.toDouble(),
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