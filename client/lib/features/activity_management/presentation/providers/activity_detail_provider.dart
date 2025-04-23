import 'package:flutter/material.dart';
import 'package:client/features/activity_management/domain/entities/activity_detail.dart';
import 'package:client/features/activity_management/domain/usecases/get_activity_detail_usecase.dart';

class ActivityDetailProvider extends ChangeNotifier {
  final GetActivityDetailUseCase getActivityDetailUseCase;

  ActivityDetailProvider({
    required this.getActivityDetailUseCase,
  });

  bool _isLoading = true;
  ActivityDetail? _activityDetail;
  String? _error;

  bool get isLoading => _isLoading;
  ActivityDetail? get activityDetail => _activityDetail;
  String? get error => _error;

  Future<void> loadActivityDetail(String activityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detail = await getActivityDetailUseCase.execute(activityId);
      _activityDetail = detail;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
