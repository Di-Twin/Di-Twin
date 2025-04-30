import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActivityType {
  final String label;
  final IconData icon;
  final Color color;
  final String type;

  ActivityType({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });

  static List<ActivityType> getActivityTypes() {
    return [
      ActivityType(
        label: 'Jogging',
        icon: FontAwesomeIcons.personRunning,
        color: const Color(0xFF1E293B),
        type: 'jogging',
      ),
      ActivityType(
        label: 'Running',
        icon: FontAwesomeIcons.personRunning,
        color: const Color(0xFF0066FF),
        type: 'running',
      ),
      ActivityType(
        label: 'Walking',
        icon: FontAwesomeIcons.personWalking,
        color: const Color(0xFF4CAF50),
        type: 'walking',
      ),
      ActivityType(
        label: 'Outdoor Sport',
        icon: FontAwesomeIcons.baseball,
        color: const Color(0xFFFF9800),
        type: 'outdoor sport',
      ),
      ActivityType(
        label: 'Elliptical',
        icon: FontAwesomeIcons.personWalking,
        color: const Color(0xFF9C27B0),
        type: 'elliptical',
      ),
      ActivityType(
        label: 'Strength Training',
        icon: FontAwesomeIcons.dumbbell,
        color: const Color(0xFF795548),
        type: 'weightlifting',
      ),
      ActivityType(
        label: 'Treadmill',
        icon: FontAwesomeIcons.personRunning,
        color: const Color(0xFF607D8B),
        type: 'treadmill',
      ),
      ActivityType(
        label: 'Cycling',
        icon: FontAwesomeIcons.bicycle,
        color: const Color(0xFFE91E63),
        type: 'cycling',
      ),
      ActivityType(
        label: 'Bike',
        icon: FontAwesomeIcons.bicycle,
        color: const Color(0xFF3F51B5),
        type: 'bike',
      ),
      ActivityType(
        label: 'Swimming',
        icon: FontAwesomeIcons.personSwimming,
        color: const Color(0xFF00BCD4),
        type: 'swimming',
      ),
      ActivityType(
        label: 'Boxing',
        icon: FontAwesomeIcons.handFist,
        color: const Color(0xFFFF5722),
        type: 'boxing',
      ),
      ActivityType(
        label: 'Skipping',
        icon: FontAwesomeIcons.arrowDown,
        color: const Color(0xFF8BC34A),
        type: 'skipping',
      ),
      ActivityType(
        label: 'Table Tennis',
        icon: FontAwesomeIcons.tableTennisPaddleBall,
        color: const Color(0xFF673AB7),
        type: 'table tennis',
      ),
      ActivityType(
        label: 'Badminton',
        icon: FontAwesomeIcons.locationArrow,
        color: const Color(0xFFCDDC39),
        type: 'badminton',
      ),
      ActivityType(
        label: 'Yoga',
        icon: Icons.spa,
        color: const Color(0xFF009688),
        type: 'yoga',
      ),
      ActivityType(
        label: 'Skating',
        icon: FontAwesomeIcons.personSkating,
        color: const Color(0xFF2196F3),
        type: 'skating',
      ),
    ];
  }
}
