class SleepLogModel {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  
  SleepLogModel({
    required this.sessionId,
    required this.startTime,
    this.endTime,
  });
  
  // Calculate duration in minutes
  int get durationInMinutes {
    if (endTime == null) {
      return 0;
    }
    return endTime!.difference(startTime).inMinutes;
  }
  
  // Calculate duration in hours (with decimal)
  double get durationInHours {
    if (endTime == null) {
      return 0;
    }
    return endTime!.difference(startTime).inMinutes / 60;
  }
  
  // Format duration as string (e.g., "8h 30m")
  String get formattedDuration {
    if (endTime == null) {
      return "0h 0m";
    }
    
    final int totalMinutes = endTime!.difference(startTime).inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    
    return "${hours}h ${minutes}m";
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationInMinutes': durationInMinutes,
    };
  }
  
  // Create from JSON
  factory SleepLogModel.fromJson(Map<String, dynamic> json) {
    return SleepLogModel(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}
