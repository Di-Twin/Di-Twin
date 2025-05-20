import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_manager.dart';
import '../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final String _baseUrl;
  
  AuthService({
    required ApiClient apiClient,
    required String baseUrl,
  }) : _apiClient = apiClient,
       _baseUrl = baseUrl;
  
  // Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final accessToken = response['data']['access_token'];
        final refreshToken = response['data']['refresh_token'];
        final expiresIn = response['data']['expires_in'] ?? 3600;
        
        // Save tokens
        await TokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
        );
        
        // Extract and save user ID if available
        if (response['data']['userId'] != null) {
          await TokenManager.saveUserId(response['data']['userId']);
        }
        
        return response;
      } else {
        throw ApiException(
          response['message'] ?? 'Authentication failed',
          401,
        );
      }
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }
  
  // Sign up with email and password
  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: userData,
        requiresAuth: false,
      );
      
      if (response['success'] == true) {
        return response;
      } else {
        throw ApiException(
          response['message'] ?? 'Registration failed',
          400,
        );
      }
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      // Call logout endpoint if available
      await _apiClient.post('/auth/logout', body: {});
    } catch (e) {
      print('Error during logout API call: $e');
      // Continue with local logout even if API call fails
    } finally {
      // Clear tokens regardless of API call result
      await TokenManager.clearTokens();
    }
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await TokenManager.getAccessToken();
    if (token == null) {
      return false;
    }
    
    // Check if token is expired
    final isExpired = await TokenManager.isTokenExpired();
    if (isExpired) {
      // Try to refresh token
      final refreshed = await refreshToken();
      return refreshed;
    }
    
    return true;
  }
  
  // Refresh the access token
  Future<bool> refreshToken() async {
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final newAccessToken = data['data']['access_token'];
          final newRefreshToken = data['data']['refresh_token'] ?? refreshToken;
          final expiresIn = data['data']['expires_in'] ?? 3600;
          
          await TokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiresIn: expiresIn,
          );
          
          return true;
        }
      }
      
      // If refresh failed, clear tokens
      await TokenManager.clearTokens();
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      await TokenManager.clearTokens();
      return false;
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get('/profiles');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw ApiException(
          response['message'] ?? 'Failed to get user profile',
          response['status'] ?? 400,
        );
      }
    } catch (e) {
      print('Get user profile error: $e');
      rethrow;
    }
  }
}
