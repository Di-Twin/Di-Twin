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
  }

  static Future<List<Map<String, dynamic>>> fetchTopActivities(
    DateTime date,
  ) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      // Use hardcoded access token for testing
      final accessToken = await _getStoredAccessToken() ?? '';

      // Try GET method instead of POST since we're fetching data
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
          // Handle both cases where data might be a Map or List
          final dynamic data = responseData['data'];

          if (data is List) {
            return _transformActivities(data);
          } else if (data is Map) {
            // If the API returns a single activity as Map, wrap it in a List
            return _transformActivities([data]);
          } else {
            return []; // Return empty list for unexpected formats
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
      // Use hardcoded access token for testing
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
          // Safely handle the case where data or activity_score might be null
          final data = responseData['data'];
          if (data != null && data['activity_score'] != null) {
            return data['activity_score'] as int;
          }
          // Return default value if no score is available
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

  // static Future<bool> addActivity(Map<String, dynamic> activityData) async {
  //   try {
  //     // Use hardcoded access token for testing
  //     final accessToken = await _getStoredAccessToken() ?? '';

  //     // Send request to API
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/api/activity/add'),
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(activityData),
  //     );

  //     // Handle response
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       print('Failed to add activity: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error adding activity: $e');
  //     throw Exception('Error adding activity: $e');
  //   }
  // }

  // Method to add to ActivityRemoteDataSource class
  static Future<Map<String, dynamic>> addManualActivity(
    Map<String, dynamic> payload,
  ) async {
    try {
      final accessToken = await _getStoredAccessToken() ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/connect/manual-entry/activity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);
      debugPrint('API Response: $responseData');
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Activity added successfully: ${responseData['message']}');
        return responseData;
      } else {
        debugPrint(
          'Failed to add activity. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to add activity: ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Error adding manual activity: $e');
    }
  }

  static List<Map<String, dynamic>> _transformActivities(
    List<dynamic> apiActivities,
  ) {
    // Check if the list is empty and return an empty list
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
      // Convert duration from seconds to minutes
      final int durationMinutes = (activity['duration_seconds'] / 60).round();

      transformedActivities.add({
        'minutes': durationMinutes.toString(),
        'label': _capitalizeFirstLetter(activity['activity_type']),
        'color': activityColors[activity['activity_type']] ?? Colors.grey,
        'icon':
            activityIcons[activity['activity_type']] ?? Icons.fitness_center,
        'id': activity['id'],
        'calories': activity['calories_burned'],
        'distance': activity['distance_meters'],
        'heart_rate_avg': activity['heart_rate_avg'],
        'start_time': activity['start_time'],
        'end_time': activity['end_time'],
        'source_device': activity['source_device'],
      });
    }

    return transformedActivities;
  }

  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  // Keep this method for future use, but not using it currently
  static Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }
    return token;
  }
}
