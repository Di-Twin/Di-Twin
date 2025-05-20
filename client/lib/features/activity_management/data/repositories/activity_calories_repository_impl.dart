import 'package:client/features/activity_management/data/datasources/activity_calories_remote_datasource.dart';
import 'package:client/features/activity_management/domain/entities/activity_calories.dart';
import 'package:client/features/activity_management/domain/repositories/activity_calories_repository.dart';

class ActivityCaloriesRepositoryImpl implements ActivityCaloriesRepository {
  final ActivityCaloriesRemoteDataSource remoteDataSource;

  ActivityCaloriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ActivityCalories>> getActivities(String date) async {
    return await remoteDataSource.getActivities(date);
  }

  @override
  Future<double> getTotalCaloriesBurned(String date) async {
    return await remoteDataSource.getTotalCaloriesBurned(date);
  }
}
