import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/data/API/dashboard_data.dart';

class DashboardProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<HealthMetricsResponse> getHealthMetricsScores(String date) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('No access token found. Please log in.');
      }

      final urls = Uri.parse('$baseUrl/health-metrics/scores?date=$date');

      final response = await http.get(
        urls,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonData = jsonDecode(response.body);

      // Debug logging
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint("URL: $urls");

      if (response.statusCode == 200) {
        return HealthMetricsResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load health metrics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching health metrics: $e');
    }
  }
}
