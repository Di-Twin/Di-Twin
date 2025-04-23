import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ActivityProvider {
  static final ActivityProvider _instance = ActivityProvider._internal();

  factory ActivityProvider() {
    return _instance;
  }

  ActivityProvider._internal();

  final String _baseUrl = 'https://test-prod-f427.onrender.com';

  /// Get monthly activity score
  Future<double> getMonthlyActivityScore(int year, int month) async {
    try {
      final token = await _getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activity/monthly-score/$year/$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return responseData['data']['monthly_activity_score'].toDouble();
        } else {
          return 70.0; // Default value if success is false
        }
      } else {
        print('Failed to fetch activity score. Status: ${response.statusCode}');
        return 70.0; // Default value on error
      }
    } catch (error) {
      print('Error fetching activity score: $error');
      return 70.0; // Default value on exception
    }
  }

  /// Get hours since last activity
  Future<double> getLastActivityHours(String date) async {
    try {
      final token = await _getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activity/lastActivity/$date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Convert string to double
          return double.parse(responseData['data']);
        } else {
          return 4.0; // Default value if success is false
        }
      } else {
        print('Failed to fetch last activity hours. Status: ${response.statusCode}');
        return 4.0; // Default value on error
      }
    } catch (error) {
      print('Error fetching last activity hours: $error');
      return 4.0; // Default value on exception
    }
  }

  /// Get top activities for a specific date
  Future<List<Map<String, dynamic>>> getTopActivities(DateTime date) async {
    try {
      final token = await _getAccessToken();
      final formattedDate = DateFormat('yyyy-M-d').format(date);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activity/top-activities/$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data'].map((x) => Map<String, dynamic>.from(x)));
        } else {
          print('Failed to fetch top activities: ${responseData['message']}');
          return []; // Empty list if success is false
        }
      } else {
        print('Failed to fetch top activities. Status: ${response.statusCode}');
        return []; // Empty list on error
      }
    } catch (error) {
      print('Error fetching top activities: $error');
      return []; // Empty list on exception
    }
  }

  /// Get daily activity score
  Future<int> getDailyActivityScore(DateTime date) async {
    try {
      final token = await _getAccessToken();
      final formattedDate = DateFormat('yyyy-M-d').format(date);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activity/daily-score/$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['activity_score'] as int;
        } else {
          print('Failed to fetch daily activity score: ${responseData['message']}');
          return 0; // Default value if success is false
        }
      } else {
        print('Failed to fetch daily activity score. Status: ${response.statusCode}');
        return 0; // Default value on error
      }
    } catch (error) {
      print('Error fetching daily activity score: $error');
      return 0; // Default value on exception
    }
  }

  /// Add a new activity
  Future<bool> addActivity(Map<String, dynamic> activityData) async {
    try {
      final token = await _getAccessToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activity/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(activityData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        print('Failed to add activity. Status: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error adding activity: $error');
      return false;
    }
  }

  /// Helper method to get access token
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('No access token found. Please log in.');
    }
    return token;
  }

 /// Get monthly activity data
 Future<List<Map<String, dynamic>>> getMonthlyActivityData(int year, int month) async {
   try {
     final token = await _getAccessToken();
     
     final response = await http.get(
       Uri.parse('$_baseUrl/api/activity/monthly-data/$year/$month'),
       headers: {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer $token',
       },
     );

     if (response.statusCode == 200) {
       final responseData = json.decode(response.body);

       if (responseData['success'] == true && responseData['data'] != null) {
         return List<Map<String, dynamic>>.from(responseData['data'].map((x) => Map<String, dynamic>.from(x)));
       } else {
         print('Failed to fetch monthly activity data: ${responseData['message']}');
         return []; // Empty list if success is false
       }
     } else {
       print('Failed to fetch monthly activity data. Status: ${response.statusCode}');
       return []; // Empty list on error
     }
   } catch (e) {
     print('Error fetching monthly activity data: $e');
     return []; // Empty list on exception
   }
}
}
