class SleepEntry {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String sourceDevice;
  final int? durationSeconds;
  final bool isCompleted;

  SleepEntry({
    required this.id,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.sourceDevice,
    this.durationSeconds,
    required this.isCompleted,
  });

  String get formattedDuration {
    if (durationSeconds == null) return 'N/A';

    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedStartTime {
    final hour = startTime.hour == 0 ? 12 : (startTime.hour > 12 ? startTime.hour - 12 : startTime.hour);
    final period = startTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedEndTime {
    if (endTime == null) return 'N/A';
    final hour = endTime!.hour == 0 ? 12 : (endTime!.hour > 12 ? endTime!.hour - 12 : endTime!.hour);
    final period = endTime!.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')} $period';
  }

  bool get isActive => !isCompleted && endTime == null;
}
