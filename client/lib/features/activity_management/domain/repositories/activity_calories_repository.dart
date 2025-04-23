import 'package:client/features/activity_management/domain/entities/activity_calories.dart';

abstract class ActivityCaloriesRepository {
  Future<List<ActivityCalories>> getActivities(String date);
  Future<double> getTotalCaloriesBurned(String date);
}
