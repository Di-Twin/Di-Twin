class ActivityScore {
  final int dayNumber;
  final int activityScore;

  ActivityScore({
    required this.dayNumber,
    required this.activityScore,
  });

  factory ActivityScore.fromJson(Map<String, dynamic> json) {
    return ActivityScore(
      dayNumber: json['dayNumber'],
      activityScore: json['activityScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'activityScore': activityScore,
    };
  }
}
