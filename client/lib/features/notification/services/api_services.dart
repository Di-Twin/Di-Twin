import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  // Base URL for API
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';
  
  // Default headers with authentication
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };
  
  String? _accessToken;
  String? _userId;
  
  ApiService._internal();
  
  // Initialize with access token
  void initialize({required String accessToken, required String userId}) {
    _accessToken = accessToken;
    _userId = userId;
    _headers['Authorization'] = 'Bearer $accessToken';

    debugPrint('API Service initialized with user ID: $userId');

    // Decode and print JWT payload
    try {
      final decodedPayload = _decodeJwtPayload(accessToken);
      debugPrint('Decoded JWT payload: $decodedPayload');
    } catch (e) {
      debugPrint('Error decoding JWT: $e');
    }
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }
  
  // Check if initialized
  bool get isInitialized => _accessToken != null && _userId != null;
  
  // Get user ID
  String? get userId => _userId;
  
  // Update push notification token
  Future<Map<String, dynamic>> updatePushToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/token'),
        headers: _headers,
        body: json.encode({'token': token}),
      );
      
      debugPrint('Update token response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update push token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating push token: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Send test notification via FCM
  Future<Map<String, dynamic>> sendTestNotificationFCM() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/test'),
        headers: _headers,
        body: json.encode({'message': 'Test notification'}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send test notification');
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Send notification via API (which will use FCM)
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
    String? recipientId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: _headers,
        body: json.encode({
          'title': title,
          'message': message,
          'type': type,
          'data': data ?? {},
          'userId': recipientId ?? _userId,
        }),
      );
      
      debugPrint('Send notification response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
