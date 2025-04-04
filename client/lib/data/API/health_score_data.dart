// lib/services/health_score_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthScoreService {
  Future<int> getHealthScore() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.196:6000/api/profile/users/health-score'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyZDBmMDkwZS05YzA2LTRmYTQtOTYwNy0yMzY2MGRhYzVmNTEiLCJlbWFpbCI6bnVsbCwiaWF0IjoxNzQzNTg4OTA0LCJleHAiOjE3NDM1OTI1MDR9.YoUdm9I1ys7bUZgtclE0Asx8EKtSXlP_A09-kICCy0Q'
        },
      );
      print("response: $response.statusCode");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Assuming your successResponse format includes a 'data' field
      } else {
        throw Exception('Failed to load health score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching health score: $e');
    }
  }
}