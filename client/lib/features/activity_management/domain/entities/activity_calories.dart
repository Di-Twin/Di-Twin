import 'package:flutter/material.dart';

class ActivityCalories {
  final String activityType;
  final double caloriesBurned;
  
  // Optional fields for UI representation
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;

  ActivityCalories({
    required this.activityType,
    required this.caloriesBurned,
    this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  factory ActivityCalories.fromMap(Map<String, dynamic> map) {
    return ActivityCalories(
      activityType: map['activity_type'] ?? '',
      caloriesBurned: (map['calories_burned'] is int) 
          ? (map['calories_burned'] as int).toDouble() 
          : (map['calories_burned'] ?? 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activity_type': activityType,
      'calories_burned': caloriesBurned,
    };
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
