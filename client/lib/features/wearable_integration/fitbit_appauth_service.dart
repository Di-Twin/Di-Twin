import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FitbitAppAuthService {
  // AppAuth instance
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  
  // Constants for Fitbit OAuth
  static const String _fitbitClientId = '23QCF6';
  static const String _fitbitClientSecret = '8cc16a3e8b2888f4edb86558c08d62d0';
  static const String _redirectUrl = 'http://localhost:4000/api/connect/fitbit/callback';
  static const String _discoveryUrl = 'https://www.fitbit.com/.well-known/openid-configuration';
  static const String _baseApiUrl = 'https://test-prod-f427.onrender.com/api/connect';
  
  // Updated scopes based on API documentation
  static const List<String> _scopes = [
    'activity',
    'heartrate',
    'location',
    'nutrition',
    'profile',
    'settings',
    'sleep',
    'social',
    'weight',
    'oxygen_saturation',
    'temperature',
    'respiratory_rate',
    'cardio_fitness'
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
      try {
        return await _refreshToken();
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
      
      // Initialize backend connection
      await _initiateBackendConnection(result.accessToken!);
      
      return true;
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
      
      if (refreshToken == null) return false;
      
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
      
      return true;
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

  // Initialize backend connection
  Future<void> _initiateBackendConnection(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/fitbit/authorize'),
        headers: _buildHeaders(accessToken),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to initiate backend connection: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error initiating backend connection: $e');
      rethrow;
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
      final bool refreshed = await _refreshToken();
      return refreshed ? prefs.getString(_storageKeyAccessToken) : null;
    }
    
    return accessToken;
  }

  // Log out / disconnect
  Future<bool> disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
          await http.get(
            Uri.parse('$_baseApiUrl/fitbit/disconnect'),
            headers: _buildHeaders(accessToken),
          );
        } catch (e) {
          debugPrint('Error disconnecting from backend: $e');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during disconnect: $e');
      return false;
    }
  }

  // Sync all daily data
  Future<Map<String, dynamic>> syncDailyData() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.get(
      Uri.parse('$_baseApiUrl/fitbit/daily-sync'),
      headers: _buildHeaders(accessToken),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to sync daily data: ${response.statusCode}');
    }
    
    _updateLastSyncTime();
    return json.decode(response.body);
  }

  // Sync specific data type
  Future<Map<String, dynamic>> syncDataType(String type) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.get(
      Uri.parse('$_baseApiUrl/fitbit/$type/sync'),
      headers: _buildHeaders(accessToken),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to sync $type data: ${response.statusCode}');
    }
    
    _updateLastSyncTime();
    return json.decode(response.body);
  }

  // Initial sync for past 30 days
  Future<Map<String, dynamic>> initialSync() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.get(
      Uri.parse('$_baseApiUrl/fitbit/monthly-sync'),
      headers: _buildHeaders(accessToken),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to perform initial sync: ${response.statusCode}');
    }
    
    _updateLastSyncTime();
    return json.decode(response.body);
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastSyncString = prefs.getString(_storageKeyLastSync);
    
    if (lastSyncString == null) return null;
    
    try {
      return DateTime.parse(lastSyncString);
    } catch (e) {
      debugPrint('Error parsing last sync time: $e');
      return null;
    }
  }

  // Update last sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKeyLastSync, DateTime.now().toIso8601String());
  }

  // Build headers with authorization
  Map<String, String> _buildHeaders(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  // Check session with backend
  Future<bool> checkSession() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/fitbit/session'),
        headers: _buildHeaders(accessToken),
      );
      
      if (response.statusCode != 200) return false;
      
      final data = json.decode(response.body);
      return data['authenticated'] == true;
    } catch (e) {
      debugPrint('Error checking session: $e');
      return false;
    }
  }

  // Get frontend data (triggers sync and returns data)
  Future<Map<String, dynamic>> getFrontendData() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');
    
    final response = await http.get(
      Uri.parse('$_baseApiUrl/fitbit/data'),
      headers: _buildHeaders(accessToken),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to get frontend data: ${response.statusCode}');
    }
    
    return json.decode(response.body);
  }

  // Acknowledge data receipt (no-op)
  Future<void> acknowledgeDataReceipt() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');
    
    await http.post(
      Uri.parse('$_baseApiUrl/fitbit/save'),
      headers: _buildHeaders(accessToken),
    );
  }
}