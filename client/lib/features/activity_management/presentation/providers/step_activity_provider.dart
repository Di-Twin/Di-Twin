import 'package:flutter/material.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/features/activity_management/domain/entities/step_activity.dart';
import 'package:client/features/activity_management/domain/usecases/get_step_activity_usecase.dart';
import 'package:client/features/activity_management/domain/usecases/get_weekly_progress_usecase.dart';

enum StepActivityStatus { initial, loading, loaded, error }

class StepActivityProvider extends ChangeNotifier {
  final GetStepActivityUseCase getStepActivityUseCase;
  final GetWeeklyProgressUseCase getWeeklyProgressUseCase;

  StepActivityStatus _status = StepActivityStatus.initial;
  StepActivity? _stepActivity;
  String _errorMessage = '';
  DateTime _selectedMonth = DateTime.now();
  int _selectedWeek = 1; // Week number in the month

  StepActivityStatus get status => _status;
  StepActivity? get stepActivity => _stepActivity;
  String get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;
  int get selectedWeek => _selectedWeek;

  StepActivityProvider({
    required this.getStepActivityUseCase,
    required this.getWeeklyProgressUseCase,
  });

  Future<void> loadStepActivity() async {
    _status = StepActivityStatus.loading;
    notifyListeners();

    final result = await getStepActivityUseCase.execute(DateTime.now());

    result.fold(
      (failure) {
        _status = StepActivityStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
      },
      (stepActivity) {
        _status = StepActivityStatus.loaded;
        _stepActivity = stepActivity;
      },
    );

    notifyListeners();
  }

  Future<void> loadWeeklyProgress() async {
    _status = StepActivityStatus.loading;
    notifyListeners();

    // Calculate the start date of the selected week
    final DateTime weekStart = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1 + ((_selectedWeek - 1) * 7),
    );

    final result = await getWeeklyProgressUseCase.execute(weekStart);

    result.fold(
      (failure) {
        _status = StepActivityStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
      },
      (weeklyProgress) {
        _status = StepActivityStatus.loaded;
        if (_stepActivity != null) {
          // Update the weekly progress in the existing step activity
          _stepActivity = StepActivity(
            currentSteps: _stepActivity!.currentSteps,
            goalSteps: _stepActivity!.goalSteps,
            calories: _stepActivity!.calories,
            distance: _stepActivity!.distance,
            duration: _stepActivity!.duration,
            weeklyProgress: weeklyProgress,
            date: _stepActivity!.date,
          );
        }
      },
    );

    notifyListeners();
  }

  void selectMonth(DateTime month) {
    _selectedMonth = month;
    _selectedWeek = 1; // Reset to first week when month changes
    loadWeeklyProgress();
    notifyListeners();
  }

  void selectWeek(int week) {
    _selectedWeek = week;
    loadWeeklyProgress();
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case NetworkFailure:
        return 'No internet connection. Please check your connection and try again.';
      default:
        return 'Unexpected error occurred. Please try again later.';
    }
  }
}
