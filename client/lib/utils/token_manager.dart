import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  // Save authentication tokens
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    int expiresIn = 3600, // Default 1 hour
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Calculate expiry time
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    await prefs.setInt(_tokenExpiryKey, expiryTime);
    
    print('✅ Tokens saved successfully');
  }

  // Get the access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get the refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Check if the access token is expired
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = prefs.getInt(_tokenExpiryKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Token is expired if current time is past expiry time
    return now > expiryTime;
  }

  // Clear all authentication tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_userIdKey);
    
    print('🗑️ Tokens cleared');
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Parse JWT token to get payload
  static Map<String, dynamic>? parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      // Get payload part (second part)
      final payload = parts[1];
      
      // Add padding if needed
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      
      return json.decode(resp);
    } catch (e) {
      print('Error parsing JWT: $e');
      return null;
    }
  }

  // Extract expiry time from JWT token
  static DateTime? getTokenExpiry(String token) {
    final payload = parseJwt(token);
    if (payload != null && payload.containsKey('exp')) {
      return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    }
    return null;
  }
}
