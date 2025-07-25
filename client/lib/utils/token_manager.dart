import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  // Get access token
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_accessTokenKey);

      if (token != null) {
        // Check if token is expired
        final expiry = prefs.getInt(_tokenExpiryKey);
        if (expiry != null) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry);
          if (DateTime.now().isAfter(expiryDate)) {
            developer.log('⚠️ Access token expired', name: 'TokenManager');
            return null;
          }
        }

        developer.log('✅ Retrieved access token', name: 'TokenManager');
        return token;
      }

      developer.log('⚠️ No access token found', name: 'TokenManager');
      return null;
    } catch (e) {
      developer.log('❌ Error getting access token: $e', name: 'TokenManager');
      return null;
    }
  }

  // Save access token
  static Future<void> saveAccessToken(String token, {int? expiryInSeconds}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);

      if (expiryInSeconds != null) {
        final expiryTime = DateTime.now().add(Duration(seconds: expiryInSeconds));
        await prefs.setInt(_tokenExpiryKey, expiryTime.millisecondsSinceEpoch);
      }

      developer.log('✅ Saved access token', name: 'TokenManager');
    } catch (e) {
      developer.log('❌ Error saving access token: $e', name: 'TokenManager');
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      developer.log('❌ Error getting refresh token: $e', name: 'TokenManager');
      return null;
    }
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, token);
      developer.log('✅ Saved refresh token', name: 'TokenManager');
    } catch (e) {
      developer.log('❌ Error saving refresh token: $e', name: 'TokenManager');
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      developer.log('❌ Error getting user ID: $e', name: 'TokenManager');
      return null;
    }
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      developer.log('✅ Saved user ID', name: 'TokenManager');
    } catch (e) {
      developer.log('❌ Error saving user ID: $e', name: 'TokenManager');
    }
  }

  // Clear all tokens
  static Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_userIdKey);
      developer.log('✅ Cleared all tokens', name: 'TokenManager');
    } catch (e) {
      developer.log('❌ Error clearing tokens: $e', name: 'TokenManager');
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Save complete auth data
  static Future<void> saveAuthData({
    required String accessToken,
    String? refreshToken,
    required String userId,
    int? expiryInSeconds,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken, expiryInSeconds: expiryInSeconds),
      if (refreshToken != null) saveRefreshToken(refreshToken),
      saveUserId(userId),
    ]);
  }
}
