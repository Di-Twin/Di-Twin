class SleepEntryModel {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String sourceDevice;
  final int? durationSeconds;
  final bool isCompleted;

  SleepEntryModel({
    required this.id,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.sourceDevice,
    this.durationSeconds,
    required this.isCompleted,
  });

  factory SleepEntryModel.fromJson(Map<String, dynamic> json) {
    return SleepEntryModel(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      sourceDevice: json['sourceDevice'] ?? 'Manual Entry',
      durationSeconds: json['durationSeconds'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
      'sourceDevice': sourceDevice,
      'durationSeconds': durationSeconds,
      'isCompleted': isCompleted,
    };
  }

  SleepEntryModel copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? sourceDevice,
    int? durationSeconds,
    bool? isCompleted,
  }) {
    return SleepEntryModel(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

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
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedEndTime {
    if (endTime == null) return 'N/A';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')} ${endTime!.hour >= 12 ? 'PM' : 'AM'}';
  }
}
