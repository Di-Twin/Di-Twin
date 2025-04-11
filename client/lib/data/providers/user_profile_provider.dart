import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:client/data/API/user_profile_data.dart';

class UserProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';
  // Token stored directly in the class (for testing only)
  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4ZjgyMTA1ZS1iNWJhLTQwNmUtOTFkNi1hMTlkMmU5ODk0YzgiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0MzA5ODc0LCJleHAiOjE3NDQzMTM0NzR9.rEHxrfyDKb2-xj-v-STcraeAI2hLE5hvKTt8pI_4EyA';

  Future<UserResponse> getUser() async {
    try {
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