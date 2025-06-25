import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class CacheService {
  static const String _healthDataKey = 'cached_health_data';
  static const String _healthScoreKey = 'cached_health_score';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _dashboardDataKey = 'cached_dashboard_data';
  static const String _fitbitDataKey = 'cached_fitbit_data';

  // Cache duration in milliseconds (30 minutes)
  static const int _cacheValidityDuration = 30 * 60 * 1000;

  /// Save health data to cache
  static Future<void> saveHealthData(Map<String, dynamic> healthData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cacheData = {
        'data': healthData,
        'timestamp': timestamp,
      };

      await prefs.setString(_healthDataKey, json.encode(cacheData));
      developer.log('✅ Health data cached successfully', name: 'CacheService');
    } catch (e) {
      developer.log('❌ Error caching health data: $e', name: 'CacheService');
    }
  }

  /// Get cached health data
  static Future<Map<String, dynamic>?> getHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_healthDataKey);

      if (cachedString != null) {
        final cacheData = json.decode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        // Check if cache is still valid (within 30 minutes)
        if (currentTime - timestamp < _cacheValidityDuration) {
          developer.log('✅ Retrieved valid cached health data', name: 'CacheService');
          return Map<String, dynamic>.from(cacheData['data']);
        } else {
          developer.log('⚠️ Cached health data expired', name: 'CacheService');
        }
      }
    } catch (e) {
      developer.log('❌ Error retrieving cached health data: $e', name: 'CacheService');
    }
    return null;
  }

  /// Save health score to cache
  static Future<void> saveHealthScore(int healthScore) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cacheData = {
        'score': healthScore,
        'timestamp': timestamp,
      };

      await prefs.setString(_healthScoreKey, json.encode(cacheData));
      developer.log('✅ Health score cached: $healthScore', name: 'CacheService');
    } catch (e) {
      developer.log('❌ Error caching health score: $e', name: 'CacheService');
    }
  }

  /// Get cached health score
  static Future<int?> getHealthScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_healthScoreKey);

      if (cachedString != null) {
        final cacheData = json.decode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        // Check if cache is still valid
        if (currentTime - timestamp < _cacheValidityDuration) {
          developer.log('✅ Retrieved cached health score: ${cacheData['score']}', name: 'CacheService');
          return cacheData['score'] as int;
        }
      }
    } catch (e) {
      developer.log('❌ Error retrieving cached health score: $e', name: 'CacheService');
    }
    return null;
  }

  /// Save dashboard data to cache
  static Future<void> saveDashboardData(Map<String, dynamic> dashboardData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cacheData = {
        'data': dashboardData,
        'timestamp': timestamp,
      };

      await prefs.setString(_dashboardDataKey, json.encode(cacheData));
      developer.log('✅ Dashboard data cached successfully', name: 'CacheService');
    } catch (e) {
      developer.log('❌ Error caching dashboard data: $e', name: 'CacheService');
    }
  }

  /// Get cached dashboard data
  static Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_dashboardDataKey);

      if (cachedString != null) {
        final cacheData = json.decode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        // Check if cache is still valid
        if (currentTime - timestamp < _cacheValidityDuration) {
          developer.log('✅ Retrieved valid cached dashboard data', name: 'CacheService');
          return Map<String, dynamic>.from(cacheData['data']);
        }
      }
    } catch (e) {
      developer.log('❌ Error retrieving cached dashboard data: $e', name: 'CacheService');
    }
    return null;
  }

  /// Save Fitbit data to cache
  static Future<void> saveFitbitData(Map<String, dynamic> fitbitData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cacheData = {
        'data': fitbitData,
        'timestamp': timestamp,
      };

      await prefs.setString(_fitbitDataKey, json.encode(cacheData));
      developer.log('✅ Fitbit data cached successfully', name: 'CacheService');
    } catch (e) {
      developer.log('❌ Error caching Fitbit data: $e', name: 'CacheService');
    }
  }

  /// Get cached Fitbit data
  static Future<Map<String, dynamic>?> getFitbitData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_fitbitDataKey);

      if (cachedString != null) {
        final cacheData = json.decode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        // Check if cache is still valid
        if (currentTime - timestamp < _cacheValidityDuration) {
          developer.log('✅ Retrieved valid cached Fitbit data', name: 'CacheService');
          return Map<String, dynamic>.from(cacheData['data']);
        }
      }
    } catch (e) {
      developer.log('❌ Error retrieving cached Fitbit data: $e', name: 'CacheService');
    }
    return null;
  }

  /// Update last sync timestamp
  static Future<void> updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      developer.log('✅ Last sync timestamp updated', name: 'CacheService');
    } catch (e) {
      developer.log('❌ Error updating last sync timestamp: $e', name: 'CacheService');
    }
  }

  /// Get last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      developer.log('❌ Error retrieving last sync timestamp: $e', name: 'CacheService');
    }
    return null;
  }

  /// Check if data needs refresh (older than 15 minutes)
  static Future<bool> needsRefresh() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final timeDiff = DateTime.now().difference(lastSync).inMinutes;
    return timeDiff > 15; // Refresh if older than 15 minutes
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_healthDataKey);
      await prefs.remove(_healthScoreKey);
      await prefs.remove(_dashboardDataKey);
      await prefs.remove(_fitbitDataKey);
      await prefs.remove(_lastSyncKey);
      developer.log('✅ All cache cleared', name: 'CacheService');
    } catch (e) {
      developer.log('❌ Error clearing cache: $e', name: 'CacheService');
    }
  }

  /// Get cache size information
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final healthData = prefs.getString(_healthDataKey);
      final healthScore = prefs.getString(_healthScoreKey);
      final dashboardData = prefs.getString(_dashboardDataKey);
      final fitbitData = prefs.getString(_fitbitDataKey);
      final lastSync = await getLastSyncTime();

      return {
        'hasHealthData': healthData != null,
        'hasHealthScore': healthScore != null,
        'hasDashboardData': dashboardData != null,
        'hasFitbitData': fitbitData != null,
        'lastSync': lastSync?.toIso8601String(),
        'needsRefresh': await needsRefresh(),
      };
    } catch (e) {
      developer.log('❌ Error getting cache info: $e', name: 'CacheService');
      return {};
    }
  }
}
