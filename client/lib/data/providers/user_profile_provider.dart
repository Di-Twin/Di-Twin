import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/data/API/user_profile_data.dart';

class UserProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<UserResponse> getUser() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('No access token found. Please log in.');
      }

      final url = Uri.parse('$baseUrl/users');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonData = jsonDecode(response.body);

      // Debug logging
      debugPrint('User response status: ${response.statusCode}');
      debugPrint('User response body: ${response.body}');

      if (response.statusCode == 200) {
        return UserResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }
}
