import 'package:client/features/activity_management/domain/entities/activity_calories.dart';
import 'package:client/features/activity_management/domain/repositories/activity_calories_repository.dart';

class GetActivitiesUseCase {
  final ActivityCaloriesRepository repository;

  GetActivitiesUseCase(this.repository);

  Future<List<ActivityCalories>> execute(String date) async {
    return await repository.getActivities(date);
  }
}
