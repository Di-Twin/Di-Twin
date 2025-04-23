import 'package:flutter/material.dart';

class ActivityHistory {
  final String name;
  final int calories;
  final IconData icon;
  final Color color;
  final DateTime date;
  final String duration;
  final String? distance;

  ActivityHistory({
    required this.name,
    required this.calories,
    required this.icon,
    required this.color,
    required this.date,
    required this.duration,
    this.distance,
  });
}
