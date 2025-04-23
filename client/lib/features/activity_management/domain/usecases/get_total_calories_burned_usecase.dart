import 'package:client/features/activity_management/domain/repositories/activity_calories_repository.dart';

class GetTotalCaloriesBurnedUseCase {
  final ActivityCaloriesRepository repository;

  GetTotalCaloriesBurnedUseCase(this.repository);

  Future<double> execute(String date) async {
    return await repository.getTotalCaloriesBurned(date);
  }
}
