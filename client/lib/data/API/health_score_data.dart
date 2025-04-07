// lib/services/health_score_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthScoreService {
  Future<int> getHealthScore() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.196:4000/api/profile/health-score'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyNzEzNzA0Zi0wZTk2LTQxY2ItYjhlNC04NDMwOTVlMjg5MDMiLCJlbWFpbCI6bnVsbCwiaWF0IjoxNzQ0MDE5Njc0LCJleHAiOjE3NDQwMjMyNzR9.LfaL3AqoTHJ6oCqfLHbG88m10YjV9vCw48ayRGAvWlc'
        },
      );
      print("response: $response.statusCode");

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