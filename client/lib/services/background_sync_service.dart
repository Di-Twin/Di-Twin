import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/services/cache_service.dart';
import 'package:client/features/wearable_integration/fitbit_appauth_service.dart';
import 'dart:developer' as developer;

class BackgroundSyncService {
  static BackgroundSyncService? _instance;
  static BackgroundSyncService get instance => _instance ??= BackgroundSyncService._();

  BackgroundSyncService._();

  Timer? _syncTimer;
  bool _isSyncing = false;
  final String _baseUrl = 'https://test-prod-f427.onrender.com/api';
  final FitbitAppAuthService _fitbitService = FitbitAppAuthService();

  /// Start background sync with periodic updates
  void startBackgroundSync() {
    // Cancel existing timer
    _syncTimer?.cancel();

    // Start immediate sync
    _performBackgroundSync();

    // Schedule periodic sync every 15 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _performBackgroundSync();
    });

    developer.log('✅ Background sync started', name: 'BackgroundSync');
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    developer.log('🛑 Background sync stopped', name: 'BackgroundSync');
  }

  /// Perform background sync
  Future<void> _performBackgroundSync() async {
    if (_isSyncing) {
      developer.log('⚠️ Sync already in progress, skipping', name: 'BackgroundSync');
      return;
    }

    _isSyncing = true;
    developer.log('🔄 Starting background sync', name: 'BackgroundSync');

    try {
      // Check if we need to refresh data
      final needsRefresh = await CacheService.needsRefresh();
      if (!needsRefresh) {
        developer.log('✅ Data is fresh, skipping sync', name: 'BackgroundSync');
        return;
      }

      // Get access token
      final token = await _getAccessToken();
      if (token == null) {
        developer.log('⚠️ No access token, skipping sync', name: 'BackgroundSync');
        return;
      }

      // Sync different data types in parallel
      final futures = <Future>[];

      // 1. Sync health metrics
      futures.add(_syncHealthMetrics(token));

      // 2. Sync dashboard data
      futures.add(_syncDashboardData(token));

      // 3. Sync Fitbit data if connected
      final watchType = await _getConnectedWatchType();
      if (watchType == 'Fitbit') {
        futures.add(_syncFitbitData());
      }

      // Wait for all syncs to complete
      await Future.wait(futures);

      // Update last sync time
      await CacheService.updateLastSyncTime();

      developer.log('✅ Background sync completed successfully', name: 'BackgroundSync');
    } catch (e) {
      developer.log('❌ Background sync failed: $e', name: 'BackgroundSync');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync health metrics data
  Future<void> _syncHealthMetrics(String token) async {
    try {
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse('$_baseUrl/health-metrics/scores?date=$dateStr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await CacheService.saveDashboardData(data['data']);
          developer.log('✅ Health metrics synced', name: 'BackgroundSync');
        }
      }
    } catch (e) {
      developer.log('❌ Health metrics sync failed: $e', name: 'BackgroundSync');
    }
  }

  /// Sync dashboard data
  Future<void> _syncDashboardData(String token) async {
    try {
      // Sync multiple dashboard endpoints
      final futures = <Future>[];

      // Health score
      futures.add(_syncHealthScore(token));

      // Food score
      futures.add(_syncFoodScore(token));

      // Activity data
      futures.add(_syncActivityData(token));

      await Future.wait(futures);
      developer.log('✅ Dashboard data synced', name: 'BackgroundSync');
    } catch (e) {
      developer.log('❌ Dashboard data sync failed: $e', name: 'BackgroundSync');
    }
  }

  /// Sync health score
  Future<void> _syncHealthScore(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health-score/today'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['score'] != null) {
          final score = (data['data']['score'] as num).toInt();
          await CacheService.saveHealthScore(score);
        }
      }
    } catch (e) {
      developer.log('❌ Health score sync failed: $e', name: 'BackgroundSync');
    }
  }

  /// Sync food score
  Future<void> _syncFoodScore(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/food/score/today'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache food score data
        // Implementation depends on your food score caching strategy
      }
    } catch (e) {
      developer.log('❌ Food score sync failed: $e', name: 'BackgroundSync');
    }
  }

  /// Sync activity data
  Future<void> _syncActivityData(String token) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$_baseUrl/activity/today?date=$today'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache activity data
        // Implementation depends on your activity caching strategy
      }
    } catch (e) {
      developer.log('❌ Activity data sync failed: $e', name: 'BackgroundSync');
    }
  }

  /// Sync Fitbit data
  Future<void> _syncFitbitData() async {
    try {
      final isAuth = await _fitbitService.isAuthenticated();
      if (!isAuth) return;

      // Perform daily sync
      await _fitbitService.syncDailyData();

      // Get health data summary
      final healthSummary = await _fitbitService.getHealthDataSummary();
      if (healthSummary != null && healthSummary['data'] != null) {
        await CacheService.saveFitbitData(healthSummary['data']);
      }

      developer.log('✅ Fitbit data synced', name: 'BackgroundSync');
    } catch (e) {
      developer.log('❌ Fitbit data sync failed: $e', name: 'BackgroundSync');
    }
  }

  /// Force immediate sync
  Future<void> forceSyncNow() async {
    developer.log('🔄 Force sync requested', name: 'BackgroundSync');
    await _performBackgroundSync();
  }

  /// Get access token
  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      return null;
    }
  }

  /// Get connected watch type
  Future<String?> _getConnectedWatchType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('watch_type');
    } catch (e) {
      return null;
    }
  }

  /// Check sync status
  bool get isSyncing => _isSyncing;

  /// Get sync timer status
  bool get isRunning => _syncTimer?.isActive ?? false;
}
