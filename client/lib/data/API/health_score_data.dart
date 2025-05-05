import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HealthScoreService {
  final String _endpoint =
      'https://test-prod-f427.onrender.com/api/profiles/health-score';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<int> getHealthScore() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('No access token found. Please log in.');
      }

      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Health score response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load health score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching health score: $e');
    }
  }
}
