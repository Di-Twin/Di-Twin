import 'dart:convert';
import 'package:client/core/errors/failures.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/features/activity_management/data/models/step_activity_model.dart';

abstract class StepActivityRemoteDataSource {
  /// Calls the /api/health-metrics?date={date} endpoint.
  ///
  /// Throws a [ServerFailure] for all error codes.
  Future<StepActivityModel> getStepActivity(DateTime date);

  /// Calls the /api/health-metrics/steps/{year}/{month} endpoint.
  ///
  /// Throws a [ServerFailure] for all error codes.
  Future<List<double>> getWeeklyProgress(DateTime weekStart);
}

class StepActivityRemoteDataSourceImpl implements StepActivityRemoteDataSource {
  final ApiClient apiClient;

  StepActivityRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<StepActivityModel> getStepActivity(DateTime date) async {
    try {
      final formattedDate = "${date.year}-${date.month}-${date.day}";
      final response = await apiClient.get(
        '/api/health-metrics?date=$formattedDate',
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        return StepActivityModel.fromApiResponse(data, date);
      } else {
        throw ApiException('Failed to fetch step activity data', 400);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  @override
  Future<List<double>> getWeeklyProgress(DateTime weekStart) async {
    try {
      final year = weekStart.year;
      final month = weekStart.month;

      final response = await apiClient.get(
        '/api/health-metrics/steps/$year/$month',
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final days = data['days'] as List<dynamic>;

        // Calculate weekly progress for the specific week
        final weekProgress = _calculateWeeklyProgress(days, weekStart);
        return weekProgress;
      } else {
        throw ApiException('Failed to fetch weekly progress data', 400);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  List<double> _calculateWeeklyProgress(List<dynamic> monthlyData, DateTime weekStart) {
    final weekProgress = <double>[];

    for (int i = 0; i < 7; i++) {
      final currentDate = weekStart.add(Duration(days: i));
      final dateString = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

      // Find data for this specific date
      final dayData = monthlyData.firstWhere(
            (day) => day['date'] == dateString,
        orElse: () => null,
      );

      if (dayData != null) {
        final steps = dayData['total_steps'] ?? 0;
        final goalSteps = 2000; // Default goal, could be made configurable
        final progress = (steps / goalSteps).clamp(0.0, 1.0);
        weekProgress.add(progress);
      } else {
        weekProgress.add(0.0);
      }
    }

    return weekProgress;
  }
}
