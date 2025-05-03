import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FitbitAppAuthService {
  // AppAuth instance
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  
  // Constants for Fitbit OAuth
  static const String _fitbitClientId = 'YOUR_FITBIT_CLIENT_ID'; // Replace with your actual client ID
  static const String _fitbitClientSecret = 'YOUR_FITBIT_CLIENT_SECRET'; // Replace with your actual client secret
  static const String _redirectUrl = 'com.ditwin.app://fitbit/callback';
  static const String _discoveryUrl = 'https://www.fitbit.com/.well-known/openid-configuration';
  static const String _baseApiUrl = 'https://deployed-api-url.com/api/connect/fitbit';
  static const List<String> _scopes = [
    'activity',
    'heartrate',
    'location',
    'nutrition',
    'profile',
    'settings',
    'sleep',
    'social',
    'weight'
  ];
  
  // Token storage keys
  static const String _storageKeyRefreshToken = 'fitbit_refresh_token';
  static const String _storageKeyAccessToken = 'fitbit_access_token';
  static const String _storageKeyIdToken = 'fitbit_id_token';
  static const String _storageKeyExpirationDate = 'fitbit_token_expiration';
  static const String _storageKeyLastSync = 'fitbit_last_sync';
  static const String _storageKeyUserId = 'fitbit_user_id';

  // Check if user is authenticated with Fitbit
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? accessToken = prefs.getString(_storageKeyAccessToken);
    final String? refreshToken = prefs.getString(_storageKeyRefreshToken);
    final String? expirationDateString = prefs.getString(_storageKeyExpirationDate);
    
    if (accessToken == null || refreshToken == null || expirationDateString == null) {
      return false;
    }
    
    final DateTime expirationDate = DateTime.parse(expirationDateString);
    if (expirationDate.isBefore(DateTime.now())) {
      // Try to refresh the token if it's expired
      try {
        final bool refreshed = await _refreshToken();
        return refreshed;
      } catch (e) {
        debugPrint('Error refreshing token: $e');
        return false;
      }
    }
    
    return true;
  }

  // Authenticate with Fitbit
  Future<bool> authenticate(BuildContext context) async {
    try {
      // Start the authorization request
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _fitbitClientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
          clientSecret: _fitbitClientSecret,
        ),
      );
      
      // Save the tokens
      await _saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken!,
        idToken: result.idToken,
        expiresIn: result.accessTokenExpirationDateTime!,
      );
      
      // Update the backend if needed
      await _updateBackend(result.accessToken!);
      
      return true;
          
      return false;
    } catch (e, s) {
      debugPrint('Error during Fitbit authorization: $e');
      debugPrint('Stack trace: $s');
      return false;
    }
  }

  // Refresh the auth token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString(_storageKeyRefreshToken);
      
      if (refreshToken == null) {
        return false;
      }
      
      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          _fitbitClientId,
          _redirectUrl,
          refreshToken: refreshToken,
          discoveryUrl: _discoveryUrl,
          clientSecret: _fitbitClientSecret,
        ),
      );
      
      await _saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? refreshToken,
        idToken: result.idToken,
        expiresIn: result.accessTokenExpirationDateTime!,
      );
      
      // Update the backend if needed
      await _updateBackend(result.accessToken!);
      
      return true;
          
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  // Save tokens to shared preferences
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresIn,
    String? idToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_storageKeyAccessToken, accessToken);
    await prefs.setString(_storageKeyRefreshToken, refreshToken);
    await prefs.setString(_storageKeyExpirationDate, expiresIn.toIso8601String());
    
    if (idToken != null) {
      await prefs.setString(_storageKeyIdToken, idToken);
    }
    
    // Parse the access token to get the user ID
    try {
      final parts = accessToken.split('.');
      if (parts.length > 1) {
        final payload = parts[1];
        final normalized = base64.normalize(payload);
        final payloadJson = utf8.decode(base64.decode(normalized));
        final payloadMap = json.decode(payloadJson);
        
        if (payloadMap.containsKey('user_id')) {
          await prefs.setString(_storageKeyUserId, payloadMap['user_id']);
        }
      }
    } catch (e) {
      debugPrint('Error parsing token payload: $e');
    }
    
    // Update last sync time
    await prefs.setString(_storageKeyLastSync, DateTime.now().toIso8601String());
  }

  // Update backend with token
  Future<void> _updateBackend(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseApiUrl/update-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode != 200) {
        debugPrint('Failed to update backend: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating backend: $e');
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString(_storageKeyAccessToken);
    final String? expirationDateString = prefs.getString(_storageKeyExpirationDate);
    
    if (accessToken == null || expirationDateString == null) {
      return null;
    }
    
    final DateTime expirationDate = DateTime.parse(expirationDateString);
    if (expirationDate.isBefore(DateTime.now())) {
      // Try to refresh the token
      final bool refreshed = await _refreshToken();
      if (!refreshed) {
        return null;
      }
      
      // Get the new access token
      return prefs.getString(_storageKeyAccessToken);
    }
    
    return accessToken;
  }

  // Log out / disconnect
  Future<bool> disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get access token for backend call
      final String? accessToken = await getAccessToken();
      
      // Clear local token storage
      await prefs.remove(_storageKeyAccessToken);
      await prefs.remove(_storageKeyRefreshToken);
      await prefs.remove(_storageKeyIdToken);
      await prefs.remove(_storageKeyExpirationDate);
      await prefs.remove(_storageKeyLastSync);
      await prefs.remove(_storageKeyUserId);
      
      // Notify backend if we have a token
      if (accessToken != null) {
        try {
          await http.post(
            Uri.parse('$_baseApiUrl/disconnect'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );
        } catch (e) {
          debugPrint('Error disconnecting from backend: $e');
          // Continue with local logout even if backend call fails
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during disconnect: $e');
      return false;
    }
  }

  // Sync data with Fitbit
  Future<bool> syncData() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        return false;
      }
      
      // Sync different data types
      final Map<String, Future<http.Response>> syncRequests = {
        'activity': http.post(
          Uri.parse('$_baseApiUrl/sync/activity'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        'sleep': http.post(
          Uri.parse('$_baseApiUrl/sync/sleep'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        'heartrate': http.post(
          Uri.parse('$_baseApiUrl/sync/heartrate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      };
      
      // Wait for all sync requests to complete
      final results = await Future.wait(syncRequests.values);
      
      // Check if any request failed
      final allSuccessful = results.every((response) => response.statusCode == 200);
      
      if (allSuccessful) {
        // Update last sync time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKeyLastSync, DateTime.now().toIso8601String());
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error syncing data: $e');
      return false;
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastSyncString = prefs.getString(_storageKeyLastSync);
    
    if (lastSyncString == null) {
      return null;
    }
    
    try {
      return DateTime.parse(lastSyncString);
    } catch (e) {
      debugPrint('Error parsing last sync time: $e');
      return null;
    }
  }
}
