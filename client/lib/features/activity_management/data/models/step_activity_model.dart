import 'package:client/features/activity_management/domain/entities/step_activity.dart';

class StepActivityModel extends StepActivity {
  StepActivityModel({
    required super.currentSteps,
    required super.goalSteps,
    required super.calories,
    required super.distance,
    required super.duration,
    required super.weeklyProgress,
    required super.date,
  });

  factory StepActivityModel.fromJson(Map<String, dynamic> json) {
    return StepActivityModel(
      currentSteps: json['currentSteps'] ?? 0,
      goalSteps: json['goalSteps'] ?? 2000,
      calories: json['calories'] ?? '0kcal',
      distance: json['distance'] ?? '0km',
      duration: json['duration'] ?? '0h',
      weeklyProgress: List<double>.from(json['weeklyProgress'] ?? [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9]),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentSteps': currentSteps,
      'goalSteps': goalSteps,
      'calories': calories,
      'distance': distance,
      'duration': duration,
      'weeklyProgress': weeklyProgress,
      'date': date.toIso8601String(),
    };
  }

  // Create a dummy model for testing or placeholder data
  factory StepActivityModel.dummy() {
    return StepActivityModel(
      currentSteps: 1542,
      goalSteps: 2000,
      calories: '500kcal',
      distance: '51km',
      duration: '1h',
      weeklyProgress: [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9],
      date: DateTime.now(),
    );
  }
}
