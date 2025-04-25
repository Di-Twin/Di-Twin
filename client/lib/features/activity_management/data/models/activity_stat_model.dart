import 'package:flutter/material.dart';
import '../../domain/entities/activity_stat.dart';

class ActivityStatModel extends ActivityStat {
  final Color color;
  
  ActivityStatModel({
    required super.name,
    required super.value,
    required this.color,
  });
  
  factory ActivityStatModel.fromJson(Map<String, dynamic> json) {
    return ActivityStatModel(
      name: json['name'],
      value: json['value'],
      color: Color(json['color']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'color': color.value,
    };
  }
}
