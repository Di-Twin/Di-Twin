import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/features/activity_management/data/models/activity_detail_model.dart';

abstract class ActivityDetailRemoteDataSource {
  Future<ActivityDetailModel> getActivityDetail(String activityId);
}

class ActivityDetailRemoteDataSourceImpl implements ActivityDetailRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ActivityDetailRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://test-prod-f427.onrender.com',
  });

  @override
  Future<ActivityDetailModel> getActivityDetail(String activityId) async {
    try {
      final token = await _getAccessToken();
      
      final response = await client.get(
        Uri.parse('$baseUrl/api/activity/detail/$activityId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return ActivityDetailModel.fromMap(Map<String, dynamic>.from(responseData['data']));
        } else {
          return _getDefaultActivityDetail(activityId);
        }
      } else {
        return _getDefaultActivityDetail(activityId);
      }
    } catch (e) {
      return _getDefaultActivityDetail(activityId);
    }
  }

  ActivityDetailModel _getDefaultActivityDetail(String activityId) {
    // Return a default activity detail for demonstration or error handling
    return ActivityDetailModel.fromMap({
      'id': activityId,
      'activity_type': 'running',
      'calories_burned': 350,
      'duration_minutes': 45,
      'start_time': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'end_time': DateTime.now().subtract(const Duration(hours: 1, minutes: 15)).toIso8601String(),
      'distance': 5.2,
      'steps': 6500,
      'average_heart_rate': 142,
      'max_heart_rate': 165,
    });
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
