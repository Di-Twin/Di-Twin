import 'package:client/features/activity_management/domain/entities/activity_detail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActivityDetailModel extends ActivityDetail {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  ActivityDetailModel({
    required super.id,
    required super.activityType,
    required super.caloriesBurned,
    required super.durationMinutes,
    required super.startTime,
    required super.endTime,
    super.distance,
    super.steps,
    super.averageHeartRate,
    super.maxHeartRate,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  factory ActivityDetailModel.fromMap(Map<String, dynamic> map) {
    final activityType = map['activity_type'] ?? '';
    
    return ActivityDetailModel(
      id: map['id'] ?? '',
      activityType: activityType,
      caloriesBurned: (map['calories_burned'] is int) 
          ? (map['calories_burned'] as int).toDouble() 
          : (map['calories_burned'] ?? 0.0),
      durationMinutes: map['duration_minutes'] ?? 0,
      startTime: map['start_time'] != null 
          ? DateTime.parse(map['start_time']) 
          : DateTime.now(),
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time']) 
          : DateTime.now().add(const Duration(minutes: 30)),
      distance: (map['distance'] is int) 
          ? (map['distance'] as int).toDouble() 
          : (map['distance'] ?? 0.0),
      steps: map['steps'] ?? 0,
      averageHeartRate: (map['average_heart_rate'] is int) 
          ? (map['average_heart_rate'] as int).toDouble() 
          : (map['average_heart_rate'] ?? 0.0),
      maxHeartRate: (map['max_heart_rate'] is int) 
          ? (map['max_heart_rate'] as int).toDouble() 
          : (map['max_heart_rate'] ?? 0.0),
      icon: _getIconForActivityType(activityType),
      backgroundColor: _getColorForActivityType(activityType),
      iconColor: _getIconColorForActivityType(activityType),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType,
      'calories_burned': caloriesBurned,
      'duration_minutes': durationMinutes,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'distance': distance,
      'steps': steps,
      'average_heart_rate': averageHeartRate,
      'max_heart_rate': maxHeartRate,
    };
  }

  static IconData _getIconForActivityType(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return FontAwesomeIcons.personRunning;
      case 'cycling':
      case 'bike':
      case 'biking':
        return FontAwesomeIcons.bicycle;
      case 'strength training':
        return FontAwesomeIcons.dumbbell;
      case 'hiking':
        return FontAwesomeIcons.personHiking;
      case 'cardio workout':
        return FontAwesomeIcons.heartPulse;
      case 'swimming':
        return FontAwesomeIcons.personSwimming;
      case 'yoga':
        return FontAwesomeIcons.handsPraying;
      case 'walking':
        return FontAwesomeIcons.personWalking;
      default:
        return FontAwesomeIcons.heartPulse;
    }
  }

  static Color _getColorForActivityType(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return const Color(0xFFE6DBFF);
      case 'cycling':
      case 'bike':
      case 'biking':
        return const Color(0xFFFFE4E4);
      case 'strength training':
        return const Color(0xFFD9E4F5);
      case 'hiking':
        return const Color(0xFFD9E4F5);
      case 'cardio workout':
        return const Color(0xFFE6DBFF);
      case 'swimming':
        return const Color(0xFFD9F5F0);
      case 'yoga':
        return const Color(0xFFF5E6D9);
      case 'walking':
        return const Color(0xFFE6F5D9);
      default:
        return const Color(0xFFE6DBFF);
    }
  }

  static Color _getIconColorForActivityType(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return const Color(0xFF9747FF);
      case 'cycling':
      case 'bike':
      case 'biking':
        return const Color(0xFFFF5A5F);
      case 'strength training':
        return const Color(0xFF0066FF);
      case 'hiking':
        return const Color(0xFF0066FF);
      case 'cardio workout':
        return const Color(0xFF9747FF);
      case 'swimming':
        return const Color(0xFF00B8A9);
      case 'yoga':
        return const Color(0xFFFF9A00);
      case 'walking':
        return const Color(0xFF7ED321);
      default:
        return const Color(0xFF9747FF);
    }
  }
}
