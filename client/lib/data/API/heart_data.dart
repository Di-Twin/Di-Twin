class HeartRateDataPoint {
  final String time;
  final int value;

  HeartRateDataPoint({
    required this.time,
    required this.value,
  });

  factory HeartRateDataPoint.fromJson(Map<String, dynamic> json) {
    return HeartRateDataPoint(
      time: json['time'],
      value: json['value'],
    );
  }
}

class HeartRateZone {
  final int min;
  final int max;
  final int minutes;

  HeartRateZone({
    required this.min,
    required this.max,
    required this.minutes,
  });

  factory HeartRateZone.fromJson(Map<String, dynamic> json) {
    return HeartRateZone(
      min: json['min'],
      max: json['max'],
      minutes: json['minutes'],
    );
  }
}

class HeartRateZones {
  final HeartRateZone fatBurn;
  final HeartRateZone cardio;
  final HeartRateZone peak;

  HeartRateZones({
    required this.fatBurn,
    required this.cardio,
    required this.peak,
  });

  factory HeartRateZones.fromJson(Map<String, dynamic> json) {
    return HeartRateZones(
      fatBurn: HeartRateZone.fromJson(json['fat_burn']),
      cardio: HeartRateZone.fromJson(json['cardio']),
      peak: HeartRateZone.fromJson(json['peak']),
    );
  }
}

class HeartRateData {
  final String id;
  final String userId;
  final String dayId;
  final int? restingHeartRate;
  final int? minHeartRate;
  final int? maxHeartRate;
  final List<HeartRateDataPoint>? heartRateData;
  final HeartRateZones? heartRateZones;
  final String? hrv;
  final String createdAt;
  final String updatedAt;

  HeartRateData({
    required this.id,
    required this.userId,
    required this.dayId,
    this.restingHeartRate,
    this.minHeartRate,
    this.maxHeartRate,
    this.heartRateData,
    this.heartRateZones,
    this.hrv,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      id: json['id'],
      userId: json['userId'],
      dayId: json['dayId'],
      restingHeartRate: json['resting_heart_rate'],
      minHeartRate: json['min_heart_rate'],
      maxHeartRate: json['max_heart_rate'],
      heartRateData: json['heart_rate_data'] != null 
          ? (json['heart_rate_data'] as List)
              .map((item) => HeartRateDataPoint.fromJson(item))
              .toList()
          : null,
      heartRateZones: json['heart_rate_zones'] != null 
          ? HeartRateZones.fromJson(json['heart_rate_zones'])
          : null,
      hrv: json['hrv'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
class HeartRateResponse {
  final bool success;
  final String message;
  final HeartRateData data;

  HeartRateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HeartRateResponse.fromJson(Map<String, dynamic> json) {
    return HeartRateResponse(
      success: json['success'],
      message: json['message'],
      data: HeartRateData.fromJson(json['data']),
    );
  }
}