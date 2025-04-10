class HealthMetricsScores {
  final int? activityScore;
  final int? sleepScore;
  final int? healthScore;
  final int? foodScore;
  final int? metabolicScore;

  HealthMetricsScores({
    this.activityScore,
    this.sleepScore,
    this.healthScore,
    this.foodScore,
    this.metabolicScore,
  });

  factory HealthMetricsScores.fromJson(Map<String, dynamic> json) {
    return HealthMetricsScores(
      activityScore: json['activity_score'],
      sleepScore: json['sleep_score'],
      healthScore: json['health_score'],
      foodScore: json['food_score'],
      metabolicScore: json['metabolic_score'],
    );
  }
}

class HealthMetricsResponse {
  final bool success;
  final String message;
  final HealthMetricsScores data;

  HealthMetricsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HealthMetricsResponse.fromJson(Map<String, dynamic> json) {
    return HealthMetricsResponse(
      success: json['success'],
      message: json['message'],
      data: HealthMetricsScores.fromJson(json['data']),
    );
  }
}