import 'package:client/features/activity_management/domain/entities/activity_calories.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActivityCaloriesModel extends ActivityCalories {
  ActivityCaloriesModel({
    required super.activityType,
    required super.caloriesBurned,
    super.icon,
    super.backgroundColor,
    super.iconColor,
  });

  factory ActivityCaloriesModel.fromMap(Map<String, dynamic> map) {
    final activityType = map['activity_type'] ?? '';
    
    return ActivityCaloriesModel(
      activityType: activityType,
      caloriesBurned: (map['calories_burned'] is int) 
          ? (map['calories_burned'] as int).toDouble() 
          : (map['calories_burned'] ?? 0.0),
      icon: _getIconForActivityType(activityType),
      backgroundColor: _getColorForActivityType(activityType),
      iconColor: _getIconColorForActivityType(activityType),
    );
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
      default:
        return const Color(0xFF9747FF);
    }
  }
}
