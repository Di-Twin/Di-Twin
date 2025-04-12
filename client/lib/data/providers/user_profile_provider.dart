import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:client/data/API/user_profile_data.dart';

class UserProvider {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';
  // Token stored directly in the class (for testing only)
  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJkYjJhMGI0YS1kYTNjLTRiNjQtOTYxNS0yYmIwOTBmYzg1OTEiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0Mzk4NzE0LCJleHAiOjE3NDQ0MDIzMTR9.QzEYp3l_awC6x2NcATWzBcWCMbU8p_bTWnH_kvOp01o';

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