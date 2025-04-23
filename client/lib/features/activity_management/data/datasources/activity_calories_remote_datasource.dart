import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/features/activity_management/data/models/activity_calories_model.dart';

abstract class ActivityCaloriesRemoteDataSource {
  Future<List<ActivityCaloriesModel>> getActivities(String date);
  Future<double> getTotalCaloriesBurned(String date);
}

class ActivityCaloriesRemoteDataSourceImpl implements ActivityCaloriesRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ActivityCaloriesRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://test-prod-f427.onrender.com',
  });

  @override
  Future<List<ActivityCaloriesModel>> getActivities(String date) async {
    try {
      final token = await _getAccessToken();
      
      final response = await client.post(
        Uri.parse('$baseUrl/api/activity/top-activities/$date?all=true'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return List<ActivityCaloriesModel>.from(
            responseData['data'].map(
              (x) => ActivityCaloriesModel.fromMap(Map<String, dynamic>.from(x)),
            ),
          );
        } else {
          return _getDefaultActivities();
        }
      } else {
        return _getDefaultActivities();
      }
    } catch (e) {
      return _getDefaultActivities();
    }
  }

  @override
  Future<double> getTotalCaloriesBurned(String date) async {
    try {
      final activities = await getActivities(date);
      
      if (activities.isEmpty) {
        return 1542.0; // Default value
      }
      
      return activities.fold<double>(
        0.0,
        (double sum, activity) => sum + activity.caloriesBurned,
      );
    } catch (e) {
      return 1542.0; // Default value
    }
  }

  List<ActivityCaloriesModel> _getDefaultActivities() {
    return [
      ActivityCaloriesModel.fromMap({'activity_type': 'cardio workout', 'calories_burned': 154.0}),
      ActivityCaloriesModel.fromMap({'activity_type': 'hiking', 'calories_burned': 854.0}),
      ActivityCaloriesModel.fromMap({'activity_type': 'biking', 'calories_burned': 224.0}),
      ActivityCaloriesModel.fromMap({'activity_type': 'cardio workout', 'calories_burned': 154.0}),
      ActivityCaloriesModel.fromMap({'activity_type': 'hiking', 'calories_burned': 156.0}),
    ];
  }

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('No access token found. Please log in.');
    }
    return token;
  }
}
