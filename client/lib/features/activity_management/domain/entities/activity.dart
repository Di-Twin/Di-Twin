import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String minutes;
  final String label;
  final Color color;
  final IconData icon;
  final int calories;
  final double distance;
  final int heartRateAvg;
  final String startTime;
  final String endTime;
  final String sourceDevice;

  Activity({
    required this.id,
    required this.minutes,
    required this.label,
    required this.color,
    required this.icon,
    required this.calories,
    required this.distance,
    required this.heartRateAvg,
    required this.startTime,
    required this.endTime,
    required this.sourceDevice,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      minutes: map['minutes'] ?? '0',
      label: map['label'] ?? '',
      color: map['color'] ?? Colors.grey,
      icon: map['icon'] ?? Icons.fitness_center,
      calories: map['calories'] ?? 0,
      distance: map['distance'] ?? 0.0,
      heartRateAvg: map['heart_rate_avg'] ?? 0,
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      sourceDevice: map['source_device'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'minutes': minutes,
      'label': label,
      'color': color,
      'icon': icon,
      'calories': calories,
      'distance': distance,
      'heart_rate_avg': heartRateAvg,
      'start_time': startTime,
      'end_time': endTime,
      'source_device': sourceDevice,
    };
  }
}
