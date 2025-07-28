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

  factory StepActivityModel.fromApiResponse(Map<String, dynamic> apiData, DateTime date) {
    final totalSteps = apiData['total_steps'] ?? 0;
    final distanceCovered = apiData['distance_covered'] ?? 0.0;
    final caloriesBurnt = apiData['total_calories_burnt'] ?? 0;
    final targetCalories = apiData['target_calories'] ?? 2000;

    // Calculate duration based on steps (rough estimation: 1000 steps ≈ 10 minutes)
    final durationMinutes = (totalSteps / 100).round();
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    final durationString = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return StepActivityModel(
      currentSteps: totalSteps,
      goalSteps: 2000, // Default goal, could be made configurable
      calories: '${caloriesBurnt}kcal',
      distance: '${distanceCovered.toStringAsFixed(1)}km',
      duration: durationString,
      weeklyProgress: [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9], // Will be updated by weekly progress call
      date: date,
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
