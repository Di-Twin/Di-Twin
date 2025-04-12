import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/data/API/dashboard_data.dart';

class DashboardProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';
  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJkYjJhMGI0YS1kYTNjLTRiNjQtOTYxNS0yYmIwOTBmYzg1OTEiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0Mzk4NzE0LCJleHAiOjE3NDQ0MDIzMTR9.QzEYp3l_awC6x2NcATWzBcWCMbU8p_bTWnH_kvOp01o'; 

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