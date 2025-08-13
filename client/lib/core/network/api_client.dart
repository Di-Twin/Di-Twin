import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:math' as Math;

class ApiClient {
  final String baseUrl;
  final http.Client httpClient;

  ApiClient({required this.baseUrl, required this.httpClient});

  // Helper method to get the auth token
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        developer.log(
          'API Client - Token retrieved, length: ${token.length}',
          name: 'ApiClient',
        );
        developer.log(
          'API Client - Token prefix: ${token.substring(0, Math.min(5, token.length))}...',
          name: 'ApiClient',
        );
      } else {
        developer.log(
          'API Client - No token found in storage',
          name: 'ApiClient',
        );
      }

      return token;
    } catch (e, stackTrace) {
      developer.log(
        'API Client - Error retrieving token: $e',
        name: 'ApiClient',
      );
      developer.log('API Client - Stack trace: $stackTrace', name: 'ApiClient');
      return null;
    }
  }

  // Helper method to create headers with auth token
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        developer.log(
          'API Client - Using token: ${token.substring(0, Math.min(5, token.length))}...',
          name: 'ApiClient',
        );
      } else {
        developer.log(
          'API Client - Warning: No auth token available for API request',
          name: 'ApiClient',
        );
      }
    }

    developer.log('API Client - Headers: $headers', name: 'ApiClient');
    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      developer.log('API Client - GET Request: $uri', name: 'ApiClient');

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      developer.log(
        'API Client - Request Headers: $headers',
        name: 'ApiClient',
      );

      final response = await httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 60));

      developer.log(
        'API Client - Response Status: ${response.statusCode}',
        name: 'ApiClient',
      );

      if (response.statusCode == 401) {
        developer.log('API Client - 401 Unauthorized Error', name: 'ApiClient');
        developer.log(
          'API Client - Response Body: ${response.body}',
          name: 'ApiClient',
        );

        // Check if token is expired or invalid
        final responseBody = response.body;
        try {
          final errorData = json.decode(responseBody);
          developer.log(
            'API Client - Error message: ${errorData['message'] ?? 'No error message'}',
            name: 'ApiClient',
          );
          developer.log(
            'API Client - Error details: ${errorData['error'] ?? 'No error details'}',
            name: 'ApiClient',
          );
        } catch (e) {
          developer.log(
            'API Client - Could not parse error response: $e',
            name: 'ApiClient',
          );
        }

        throw ApiException(
          'Authentication failed: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        developer.log(
          'API Client - Response Size: ${responseBody.length} bytes',
          name: 'ApiClient',
        );
        return json.decode(responseBody);
      } else {
        developer.log(
          'API Client - Error Response: ${response.body}',
          name: 'ApiClient',
        );
        throw ApiException(
          'Failed to load data: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      developer.log(
        'API Client - Network Error: No internet connection',
        name: 'ApiClient',
      );
      throw ApiException('No internet connection', 0);
    } on TimeoutException {
      developer.log('API Client - Request Timeout', name: 'ApiClient');
      throw ApiException('Request timeout', 408);
    } on FormatException {
      developer.log('API Client - Invalid Response Format', name: 'ApiClient');
      throw ApiException('Invalid response format', 0);
    } catch (e, stackTrace) {
      developer.log('API Client - Unexpected Error: $e', name: 'ApiClient');
      developer.log('API Client - Stack trace: $stackTrace', name: 'ApiClient');
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 POST Request: $uri');

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await httpClient
          .post(uri, headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to post data: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout', 408);
    } on FormatException {
      throw ApiException('Invalid response format', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 PUT Request: $uri');
      print('📤 Request Body: ${json.encode(body)}');

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await httpClient
          .put(uri, headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 60));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        print('📦 Response Size: ${responseBody.length} bytes');
        return json.decode(responseBody);
      } else {
        print('❌ Error Response: ${response.body}');
        throw ApiException(
          'Failed to update data: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      print('🔌 Network Error: No internet connection');
      throw ApiException('No internet connection', 0);
    } on TimeoutException {
      print('⏱️ Request Timeout');
      throw ApiException('Request timeout', 408);
    } on FormatException {
      print('🔄 Invalid Response Format');
      throw ApiException('Invalid response format', 0);
    } catch (e) {
      print('💥 Unexpected Error: $e');
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 DELETE Request: $uri');

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await httpClient
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 60));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('❌ Error Response: ${response.body}');
        throw ApiException(
          'Failed to delete data: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      print('🔌 Network Error: No internet connection');
      throw ApiException('No internet connection', 0);
    } on TimeoutException {
      print('⏱️ Request Timeout');
      throw ApiException('Request timeout', 408);
    } on FormatException {
      print('🔄 Invalid Response Format');
      throw ApiException('Invalid response format', 0);
    } catch (e) {
      print('💥 Unexpected Error: $e');
      throw ApiException('Unexpected error: $e', 0);
    }
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
