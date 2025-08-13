import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class ActivityRemoteDataSource {
  static const String baseUrl = 'https://test-prod-f427.onrender.com';

  static Future<String?> _getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
    // return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlODE0NDQ3NS0yY2E1LTQ3YTQtOTUwOS1mMDhjYWZlNWYwZjUiLCJtb2JpbGUiOiIrOTE5ODc2NTQzMjEwIiwiaWF0IjoxNzUyNTcyODU2LCJleHAiOjE3NTI2NTkyNTZ9.QqRPEJWYOrvXA_wuOxWR7FhGIG0IzXUXLXy6pGKyiI4";
  }

  static Future<List<Map<String, dynamic>>> fetchTopActivities(
    DateTime date,
  ) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final accessToken = await _getStoredAccessToken() ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/activity/top-activities/$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final dynamic data = responseData['data'];

          if (data is List) {
            return _transformActivities(data);
          } else if (data is Map) {
            return _transformActivities([data]);
          } else {
            return [];
          }
        } else {
          print('Failed to load activities: ${responseData['message']}');
          throw Exception(
            'Failed to load activities: ${responseData['message']}',
          );
        }
      } else {
        print(
          'Failed to load activities. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching activities: $e');
      throw Exception('Error fetching activities: $e');
    }
  }

  static Future<int> fetchDailyActivityScore(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final accessToken = await _getStoredAccessToken() ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/activity/daily-score/$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data != null && data['activity_score'] != null) {
            return data['activity_score'] as int;
          }
          return 0;
        } else {
          print('Failed to load activity score: ${responseData['message']}');
          return 0;
        }
      } else {
        print(
          'Failed to load activity score. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return 0;
      }
    } catch (e) {
      print('Error fetching activity score: $e');
      return 0;
    }
  }

  static Future<Map<String, dynamic>> addManualActivity(
    List<Map<String, dynamic>> payload,
  ) async {
    final accessToken = await _getStoredAccessToken() ?? '';

    final response = await http.post(
      Uri.parse(
        'https://test-prod-f427.onrender.com/api/connect/manual-entry/activity',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Server returned status ${response.statusCode}',
      };
    }
  }

  static List<Map<String, dynamic>> _transformActivities(
    List<dynamic> apiActivities,
  ) {
    if (apiActivities.isEmpty) {
      print('No activities found to transform');
      return [];
    }

    final List<Map<String, dynamic>> transformedActivities = [];

    final Map<String, IconData> activityIcons = {
      'jogging': FontAwesomeIcons.personRunning,
      'running': FontAwesomeIcons.personRunning,
      'walking': FontAwesomeIcons.personWalking,
      'outdoor sport': FontAwesomeIcons.volleyball,
      'elliptical': FontAwesomeIcons.personWalking,
      'strength training': FontAwesomeIcons.dumbbell,
      'treadmill': FontAwesomeIcons.personRunning,
      'cycling': FontAwesomeIcons.bicycle,
      'bike': FontAwesomeIcons.bicycle,
      'swimming': FontAwesomeIcons.personSwimming,
      'boxing': FontAwesomeIcons.handFist,
      'skipping': FontAwesomeIcons.personSkating,
      'table tennis': FontAwesomeIcons.tableTennisPaddleBall,
      'badminton': Icons.sports_tennis,
      'yoga': Icons.spa,
      'skating': FontAwesomeIcons.skating,
    };

    final Map<String, Color> activityColors = {
      'jogging': Colors.black,
      'running': Colors.blue,
      'walking': Colors.green,
      'outdoor sport': Colors.orange,
      'elliptical': Colors.purple,
      'strength training': Colors.brown,
      'treadmill': Colors.grey,
      'cycling': Colors.pink,
      'bike': Colors.pink,
      'swimming': Colors.cyan,
      'boxing': Colors.deepOrange,
      'skipping': Colors.lightGreen,
      'table tennis': Color(0xFF558B2F),
      'badminton': Color(0xFF1976D2),
      'yoga': Colors.deepPurple,
      'skating': Colors.indigo,
    };

    for (var activity in apiActivities) {
      try {
        // Safely handle duration_seconds - check for null and provide default
        final dynamic durationSecondsRaw = activity['duration_seconds'];
        int durationSeconds;

        if (durationSecondsRaw == null) {
          // If duration_seconds is null, try to calculate from start_time and end_time
          final String? startTimeStr = activity['start_time'];
          final String? endTimeStr = activity['end_time'];

          if (startTimeStr != null && endTimeStr != null) {
            try {
              final DateTime startTime = DateTime.parse(startTimeStr);
              final DateTime endTime = DateTime.parse(endTimeStr);
              durationSeconds = endTime.difference(startTime).inSeconds;
            } catch (e) {
              print('Error parsing dates for activity ${activity['id']}: $e');
              durationSeconds = 1800; // Default to 30 minutes
            }
          } else {
            durationSeconds = 1800; // Default to 30 minutes if no time data
          }
        } else {
          // Convert to int safely
          durationSeconds =
              (durationSecondsRaw is int)
                  ? durationSecondsRaw
                  : (durationSecondsRaw as num).toInt();
        }

        // Convert duration from seconds to minutes
        final int durationMinutes = (durationSeconds / 60).round();

        // Safely handle other potentially null fields
        final String activityType =
            activity['activity_type']?.toString() ?? 'unknown';
        final int calories = activity['calories_burned']?.toInt() ?? 0;
        final double distance =
            (activity['distance_meters']?.toDouble() ?? 0.0);
        final int heartRate = activity['heart_rate_avg']?.toInt() ?? 0;

        transformedActivities.add({
          'minutes': durationMinutes.toString(),
          'label': _capitalizeFirstLetter(activityType),
          'color': activityColors[activityType] ?? Colors.grey,
          'icon': activityIcons[activityType] ?? Icons.fitness_center,
          'id': activity['id'],
          'calories': calories,
          'distance': distance,
          'heart_rate_avg': heartRate,
          'start_time': activity['start_time'],
          'end_time': activity['end_time'],
          'source_device': activity['source_device'] ?? 'Unknown',
        });
      } catch (e) {
        print('Error transforming activity ${activity['id']}: $e');
        // Skip this activity and continue with the next one
        continue;
      }
    }

    return transformedActivities;
  }

  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  static Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }
    return token;
  }
}
