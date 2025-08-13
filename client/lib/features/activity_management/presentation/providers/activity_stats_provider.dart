import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_activity_stats_usecase.dart';
import '../../../activity_management/data/models/activity_stat_model.dart';

enum ActivityStatsStatus { initial, loading, loaded, error }

class ActivityStatsProvider extends ChangeNotifier {
  final GetActivityStatsUseCase getActivityStatsUseCase;
  
  ActivityStatsStatus _status = ActivityStatsStatus.initial;
  List<ActivityStatModel> _stats = [];
  String _errorMessage = '';
  
  ActivityStatsStatus get status => _status;
  List<ActivityStatModel> get stats => _stats;
  String get errorMessage => _errorMessage;
  
  ActivityStatsProvider({required this.getActivityStatsUseCase});
  
  Future<void> loadActivityStats() async {
    _status = ActivityStatsStatus.loading;
    notifyListeners();
    
    final result = await getActivityStatsUseCase();
    
    result.fold(
      (failure) {
        _status = ActivityStatsStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
      },
      (stats) {
        _status = ActivityStatsStatus.loaded;
        _stats = stats.map((stat) {
          if (stat is ActivityStatModel) {
            return stat;
          } else {
            // This shouldn't happen in practice since our repository returns ActivityStatModel
            // But we handle it just in case
            return ActivityStatModel(
              name: stat.name,
              value: stat.value,
              color: Colors.grey,
            );
          }
        }).toList();
      },
    );
    
    notifyListeners();
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case NetworkFailure:
        return 'No internet connection';
      default:
        return 'Unexpected error';
    }
  }
}
