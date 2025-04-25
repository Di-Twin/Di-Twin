
class ActivityDetail {
  final String id;
  final String activityType;
  final double caloriesBurned;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // in kilometers
  final int steps;
  final double averageHeartRate;
  final double maxHeartRate;
  
  ActivityDetail({
    required this.id,
    required this.activityType,
    required this.caloriesBurned,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    this.distance = 0.0,
    this.steps = 0,
    this.averageHeartRate = 0.0,
    this.maxHeartRate = 0.0,
  });

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  String get capitalizedActivityType {
    return activityType
        .split(' ')
        .map(
          (word) => word.isNotEmpty 
              ? word[0].toUpperCase() + word.substring(1) 
              : '',
        )
        .join(' ');
  }
}
