import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/data/API/health_metrics_data.dart';

class HealthMetricsProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<HealthMetricsResponse> getHealthMetrics(String date) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('No access token found. Please log in.');
      }

      final url = Uri.parse('$baseUrl/health-metrics?date=$date');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint("URL: $url");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Add additional debug logging to inspect the response structure
        debugPrint('Response data type: ${jsonData.runtimeType}');
        if (jsonData is Map) {
          debugPrint('Response keys: ${jsonData.keys}');
        }

        return HealthMetricsResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load health metrics: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error stack trace: $stackTrace');
      throw Exception('Error fetching health metrics: $e');
    }
  }
}
