import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FitbitAppAuthService {
  // Base URL for the backend API
  static const String _baseApiUrl = 'https://test-prod-f427.onrender.com/api/connect';

  // Token storage keys
  static const String _storageKeyAccessToken = 'fitbit_access_token';
  static const String _storageKeyRefreshToken = 'fitbit_refresh_token';
  static const String _storageKeyFitbitUserId = 'fitbit_user_id';
  static const String _storageKeyLastSync = 'fitbit_last_sync';
  static const String _storageKeyConnectionStatus = 'fitbit_connection_status';

  /// Get the user's JWT token for API authentication
  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Build headers for API requests
  Future<Map<String, String>> _buildHeaders() async {
    final jwtToken = await _getJwtToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }

  /// Check if user is authenticated with Fitbit
  Future<bool> isAuthenticated() async {
    try {
      final headers = await _buildHeaders();
      final response = await http.get(
        Uri.parse('$_baseApiUrl/fitbit/session'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isAuthenticated = data['authenticated'] == true;

        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_storageKeyConnectionStatus, isAuthenticated);

        return isAuthenticated;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking authentication status: $e');
      return false;
    }
  }

  /// Initiate Fitbit OAuth flow
  Future<bool> authenticate(BuildContext context) async {
    try {
      // Step 1: Get authorization URL from backend
      final headers = await _buildHeaders();
      final response = await http.get(
        Uri.parse('$_baseApiUrl/fitbit/authorize'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final authUrl = data['authUrl'];
          final userId = data['userId'];

          // Store user ID for later use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('backend_user_id', userId);

          // Step 2: Launch browser for OAuth
          final uri = Uri.parse(authUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );

            // Return true to indicate the process started
            // The actual authentication will be completed via callback
            return true;
          } else {
            throw Exception('Could not launch authorization URL');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to get authorization URL');
        }
      } else {
        throw Exception('Failed to initiate OAuth: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }

  /// Process OAuth callback (called when user returns from Fitbit)
  Future<bool> processCallback(String code, String state) async {
    try {
      // The callback is handled by the backend automatically
      // We just need to check if the authentication was successful
      await Future.delayed(const Duration(seconds: 2)); // Give backend time to process

      final isAuth = await isAuthenticated();
      if (isAuth) {
        await _updateLastSyncTime();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error processing callback: $e');
      return false;
    }
  }

  /// Sync all daily data
  Future<Map<String, dynamic>> syncDailyData() async {
    try {
      final headers = await _buildHeaders();
      final response = await http.get(
        Uri.parse('$_baseApiUrl/fitbit/data'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _updateLastSyncTime();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Sync failed');
        }
      } else {
        throw Exception('Failed to sync data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error syncing daily data: $e');
      rethrow;
    }
  }

  /// Perform initial sync (30 days of data)
  Future<Map<String, dynamic>> initialSync() async {
    try {
      final headers = await _buildHeaders();
      final response = await http.get(
        Uri.parse('$_baseApiUrl/fitbit/monthly-sync'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _updateLastSyncTime();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Initial sync failed');
        }
      } else {
        throw Exception('Failed to perform initial sync: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during initial sync: $e');
      rethrow;
    }
  }

  /// Sync specific data type
  Future<Map<String, dynamic>> syncDataType(String dataType) async {
    try {
      final headers = await _buildHeaders();
      String endpoint;

      switch (dataType.toLowerCase()) {
        case 'activity':
          endpoint = '$_baseApiUrl/fitbit/activity/sync';
          break;
        case 'sleep':
          endpoint = '$_baseApiUrl/fitbit/sleep/sync';
          break;
        case 'steps':
          endpoint = '$_baseApiUrl/fitbit/sync/steps';
          break;
        case 'distance':
          endpoint = '$_baseApiUrl/fitbit/sync/distance';
          break;
        case 'heartrate':
        case 'heart-rate':
          endpoint = '$_baseApiUrl/fitbit/sync/heart-rate';
          break;
        case 'spo2':
          endpoint = '$_baseApiUrl/fitbit/sync/spo2';
          break;
        case 'hrv':
          endpoint = '$_baseApiUrl/fitbit/hrv/sync-daily';
          break;
        case 'cardio':
        case 'cardio-score':
          endpoint = '$_baseApiUrl/fitbit/cardio-score/sync';
          break;
        case 'breathing':
        case 'breathing-rate':
          endpoint = '$_baseApiUrl/fitbit/breathing-rate/sync';
          break;
        case 'temperature':
        case 'skin-temperature':
          endpoint = '$_baseApiUrl/fitbit/skin-temperature/sync';
          break;
        case 'activity-summary':
          endpoint = '$_baseApiUrl/fitbit/activity-summary/sync';
          break;
        default:
          throw Exception('Unknown data type: $dataType');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _updateLastSyncTime();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Sync failed for $dataType');
        }
      } else {
        throw Exception('Failed to sync $dataType: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error syncing $dataType: $e');
      rethrow;
    }
  }

  /// Sync initial data for specific type (30 days)
  Future<Map<String, dynamic>> syncInitialDataType(String dataType) async {
    try {
      final headers = await _buildHeaders();
      String endpoint;

      switch (dataType.toLowerCase()) {
        case 'activity':
          endpoint = '$_baseApiUrl/fitbit/activity/initial';
          break;
        case 'sleep':
          endpoint = '$_baseApiUrl/fitbit/sleep/initial';
          break;
        case 'steps':
          endpoint = '$_baseApiUrl/fitbit/steps/initial';
          break;
        case 'distance':
          endpoint = '$_baseApiUrl/fitbit/distance/initial';
          break;
        case 'heartrate':
        case 'heart-rate':
          endpoint = '$_baseApiUrl/fitbit/heart-rate/initial';
          break;
        case 'spo2':
          endpoint = '$_baseApiUrl/fitbit/spo2/initial';
          break;
        case 'hrv':
          endpoint = '$_baseApiUrl/fitbit/hrv/initial';
          break;
        case 'cardio':
        case 'cardio-score':
          endpoint = '$_baseApiUrl/fitbit/cardio-score/initial';
          break;
        case 'breathing':
        case 'breathing-rate':
          endpoint = '$_baseApiUrl/fitbit/breathing-rate/initial';
          break;
        case 'temperature':
        case 'skin-temperature':
          endpoint = '$_baseApiUrl/fitbit/skin-temperature/initial';
          break;
        case 'activity-summary':
          endpoint = '$_baseApiUrl/fitbit/activity-summary/initial';
          break;
        default:
          throw Exception('Unknown data type: $dataType');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _updateLastSyncTime();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Initial sync failed for $dataType');
        }
      } else {
        throw Exception('Failed to sync initial $dataType: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error syncing initial $dataType: $e');
      rethrow;
    }
  }

  /// Save manual activity data
  Future<Map<String, dynamic>> saveManualActivityData(Map<String, dynamic> activityData) async {
    try {
      final headers = await _buildHeaders();
      final response = await http.post(
        Uri.parse('$_baseApiUrl/manual-entry/activity'),
        headers: headers,
        body: json.encode(activityData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _updateLastSyncTime();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to save manual activity data');
        }
      } else {
        throw Exception('Failed to save manual activity data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving manual activity data: $e');
      rethrow;
    }
  }

  /// Save manual sleep data
  Future<Map<String, dynamic>> saveManualSleepData(Map<String, dynamic> sleepData) async {
    try {
      final headers = await _buildHeaders();
      final response = await http.post(
        Uri.parse('$_baseApiUrl/manual-entry/sleep'),
        headers: headers,
        body: json.encode(sleepData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _updateLastSyncTime();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to save manual sleep data');
        }
      } else {
        throw Exception('Failed to save manual sleep data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving manual sleep data: $e');
      rethrow;
    }
  }

  /// Acknowledge data receipt
  Future<void> acknowledgeDataReceipt() async {
    try {
      final headers = await _buildHeaders();
      await http.post(
        Uri.parse('$_baseApiUrl/fitbit/save'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error acknowledging data receipt: $e');
      // Don't throw here as this is not critical
    }
  }

  /// Disconnect from Fitbit
  Future<bool> disconnect() async {
    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKeyAccessToken);
      await prefs.remove(_storageKeyRefreshToken);
      await prefs.remove(_storageKeyFitbitUserId);
      await prefs.remove(_storageKeyLastSync);
      await prefs.setBool(_storageKeyConnectionStatus, false);

      // Note: The backend doesn't have a specific disconnect endpoint
      // The user would need to revoke access through Fitbit's website

      return true;
    } catch (e) {
      debugPrint('Error during disconnect: $e');
      return false;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_storageKeyLastSync);

    if (lastSyncString == null) return null;

    try {
      return DateTime.parse(lastSyncString);
    } catch (e) {
      debugPrint('Error parsing last sync time: $e');
      return null;
    }
  }

  /// Update last sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKeyLastSync, DateTime.now().toIso8601String());
  }

  /// Get connection status from local storage
  Future<bool> getConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storageKeyConnectionStatus) ?? false;
  }

  /// Check if initial sync has been completed
  Future<bool> hasCompletedInitialSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fitbit_initial_sync_completed') ?? false;
  }

  /// Mark initial sync as completed
  Future<void> markInitialSyncCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitbit_initial_sync_completed', true);
  }

  /// Get comprehensive health data summary
  Future<Map<String, dynamic>?> getHealthDataSummary() async {
    try {
      // Sync latest data first
      final syncResult = await syncDailyData();

      if (syncResult['success'] == true) {
        return {
          'lastSync': DateTime.now().toIso8601String(),
          'data': syncResult['data'],
          'metadata': syncResult['metadata'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting health data summary: $e');
      return null;
    }
  }

  /// Batch sync multiple data types
  Future<Map<String, dynamic>> batchSync(List<String> dataTypes) async {
    final results = <String, dynamic>{};
    final errors = <String, String>{};

    for (final dataType in dataTypes) {
      try {
        final result = await syncDataType(dataType);
        results[dataType] = result;
      } catch (e) {
        errors[dataType] = e.toString();
      }

      // Add small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return {
      'success': errors.isEmpty,
      'results': results,
      'errors': errors,
      'syncedCount': results.length,
      'errorCount': errors.length,
    };
  }

  /// Get sync status for UI display
  Future<Map<String, dynamic>> getSyncStatus() async {
    final lastSync = await getLastSyncTime();
    final isConnected = await getConnectionStatus();
    final hasInitialSync = await hasCompletedInitialSync();

    return {
      'isConnected': isConnected,
      'lastSync': lastSync?.toIso8601String(),
      'hasInitialSync': hasInitialSync,
      'needsSync': lastSync == null ||
          DateTime.now().difference(lastSync).inHours > 24,
    };
  }
}