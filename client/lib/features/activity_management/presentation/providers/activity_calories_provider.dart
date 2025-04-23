import 'package:flutter/material.dart';
import 'package:client/features/activity_management/domain/entities/activity_calories.dart';
import 'package:client/features/activity_management/domain/usecases/get_activities_usecase.dart';
import 'package:client/features/activity_management/domain/usecases/get_total_calories_burned_usecase.dart';

class ActivityCaloriesProvider extends ChangeNotifier {
  final GetActivitiesUseCase getActivitiesUseCase;
  final GetTotalCaloriesBurnedUseCase getTotalCaloriesBurnedUseCase;

  ActivityCaloriesProvider({
    required this.getActivitiesUseCase,
    required this.getTotalCaloriesBurnedUseCase,
  });

  bool _isLoading = true;
  List<ActivityCalories> _activities = [];
  double _totalCaloriesBurned = 0;
  String _currentDate = DateTime.now().toString().split(' ')[0];

  bool get isLoading => _isLoading;
  List<ActivityCalories> get activities => _activities;
  double get totalCaloriesBurned => _totalCaloriesBurned;
  String get currentDate => _currentDate;

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      final activities = await getActivitiesUseCase.execute(_currentDate);
      final totalCalories = await getTotalCaloriesBurnedUseCase.execute(_currentDate);

      _activities = activities;
      _totalCaloriesBurned = totalCalories;
    } catch (e) {
      // Handle error
      print('Error loading activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDate(String date) {
    _currentDate = date;
    loadActivities();
  }
}
