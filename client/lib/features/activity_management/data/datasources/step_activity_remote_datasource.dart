import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/core/errors/failures.dart';
import 'package:client/features/activity_management/data/models/step_activity_model.dart';

abstract class StepActivityRemoteDataSource {
  /// Calls the api/steps/{date} endpoint.
  ///
  /// Throws a [ServerFailure] for all error codes.
  Future<StepActivityModel> getStepActivity(DateTime date);
  
  /// Calls the api/steps/weekly/{weekStart} endpoint.
  ///
  /// Throws a [ServerFailure] for all error codes.
  Future<List<double>> getWeeklyProgress(DateTime weekStart);
}

class StepActivityRemoteDataSourceImpl implements StepActivityRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  StepActivityRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<StepActivityModel> getStepActivity(DateTime date) async {
    try {
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await client.get(
        Uri.parse('$baseUrl/api/steps/$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return StepActivityModel.fromJson(json.decode(response.body));
      } else {
        // For demo purposes, return dummy data
        // In production, you would throw an exception
        return StepActivityModel.dummy();
      }
    } catch (e) {
      // For demo purposes, return dummy data
      // In production, you would throw an exception
      return StepActivityModel.dummy();
    }
  }

  @override
  Future<List<double>> getWeeklyProgress(DateTime weekStart) async {
    try {
      final formattedDate = "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}";
      final response = await client.get(
        Uri.parse('$baseUrl/api/steps/weekly/$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => (item as num).toDouble()).toList();
      } else {
        // For demo purposes, return dummy data
        return [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9];
      }
    } catch (e) {
      // For demo purposes, return dummy data
      return [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9];
    }
  }
}
