import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class ActivityRemoteDataSource {
  static const String baseUrl = 'https://test-prod-f427.onrender.com';

  static Future<List<Map<String, dynamic>>> fetchTopActivities(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-M-d').format(date);
      final accessToken = await _getAccessToken();
      
      // Using POST method as specified in the API documentation
      final response = await http.post(
        Uri.parse('$baseUrl/api/activity/top-activities/$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // The API returns an array of activity objects
          return _transformActivities(responseData['data']);
        } else {
          print('Failed to load activities: ${responseData['message']}');
          throw Exception('Failed to load activities: ${responseData['message']}');
        }
      } else {
        print('Failed to load activities. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching activities: $e');
      throw Exception('Error fetching activities: $e');
    }
  }

  static Future<int> fetchDailyActivityScore(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-M-d').format(date);
      final accessToken = await _getAccessToken();
      
      // Using GET method as specified in the API documentation
      final response = await http.get(
        Uri.parse('$baseUrl/api/activity/daily-score/$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // The API returns an object with activity_score property
          return responseData['data']['activity_score'] as int;
        } else {
          print('Failed to load activity score: ${responseData['message']}');
          throw Exception('Failed to load activity score: ${responseData['message']}');
        }
      } else {
        print('Failed to load activity score. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load activity score: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching activity score: $e');
      throw Exception('Error fetching activity score: $e');
    }
  }

  static Future<bool> addActivity(Map<String, dynamic> activityData) async {
    try {
      final accessToken = await _getAccessToken();
      
      // Send request to API
      final response = await http.post(
        Uri.parse('$baseUrl/api/activity/add'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(activityData),
      );
      
      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add activity: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding activity: $e');
      throw Exception('Error adding activity: $e');
    }
  }
  
  static List<Map<String, dynamic>> _transformActivities(List<dynamic> apiActivities) {
    final List<Map<String, dynamic>> transformedActivities = [];
    
    final Map<String, IconData> activityIcons = {
      'running': FontAwesomeIcons.personRunning,
      'cycling': FontAwesomeIcons.bicycle,
      'walking': FontAwesomeIcons.personWalking,
      'swimming': FontAwesomeIcons.personSwimming,
      'yoga': Icons.spa,
      'weightlifting': FontAwesomeIcons.dumbbell,
      // Add more activity types as needed
    };
    
    final Map<String, Color> activityColors = {
      'running': Colors.redAccent,
      'cycling': const Color(0xFF0066FF),
      'walking': const Color(0xFF1E293B),
      'swimming': Colors.blueAccent,
      'yoga': Colors.purpleAccent,
      'weightlifting': Colors.orangeAccent,
      // Add more activity types as needed
    };
    
    for (var activity in apiActivities) {
      // Convert duration from seconds to minutes
      final int durationMinutes = (activity['duration_seconds'] / 60).round();
      
      transformedActivities.add({
        'minutes': durationMinutes.toString(),
        'label': _capitalizeFirstLetter(activity['activity_type']),
        'color': activityColors[activity['activity_type']] ?? Colors.grey,
        'icon': activityIcons[activity['activity_type']] ?? Icons.fitness_center,
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
  
  static Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }
    return token;
  }
}
