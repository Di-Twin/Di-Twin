import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/data/API/dashboard_data.dart';

class DashboardProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';
  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4ZjgyMTA1ZS1iNWJhLTQwNmUtOTFkNi1hMTlkMmU5ODk0YzgiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0MzA5ODc0LCJleHAiOjE3NDQzMTM0NzR9.rEHxrfyDKb2-xj-v-STcraeAI2hLE5hvKTt8pI_4EyA'; 

  Future<HealthMetricsResponse> getHealthMetricsScores(String date) async {
    try {
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
        throw Exception('Failed to load health metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching health metrics: $e');
    }
  }
}