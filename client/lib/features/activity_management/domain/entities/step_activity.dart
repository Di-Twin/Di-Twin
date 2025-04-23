class StepActivity {
  final int currentSteps;
  final int goalSteps;
  final String calories;
  final String distance;
  final String duration;
  final List<double> weeklyProgress;
  final DateTime date;

  StepActivity({
    required this.currentSteps,
    required this.goalSteps,
    required this.calories,
    required this.distance,
    required this.duration,
    required this.weeklyProgress,
    required this.date,
  });
}
