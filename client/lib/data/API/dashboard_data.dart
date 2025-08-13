class HealthMetricsScores {
  final double? activityScore;
  final double? sleepScore;
  final double? healthScore;
  final double? foodScore;
  final double? metabolicScore;

  HealthMetricsScores({
    this.activityScore,
    this.sleepScore,
    this.healthScore,
    this.foodScore,
    this.metabolicScore,
  });

  factory HealthMetricsScores.fromJson(Map<String, dynamic> json) {
    return HealthMetricsScores(
      activityScore: json['activity_score']?.toDouble(),
      sleepScore: json['sleep_score'] ?.toDouble(),
      healthScore: json['health_score'] ?.toDouble(),
      foodScore: json['food_score'] ?.toDouble(),
      metabolicScore: json['metabolic_score'] ?.toDouble(),
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