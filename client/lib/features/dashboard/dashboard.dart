import 'package:client/widgets/dashboard/medication_section.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:client/widgets/dashboard/app_header.dart';
import 'package:client/widgets/dashboard/health_score_card.dart';
import 'package:client/widgets/dashboard/health_metrics_section.dart';
import 'package:client/widgets/dashboard/fitness_tracker_section.dart';
import 'package:client/widgets/dashboard/bottom_navigation.dart';
import 'package:client/widgets/dashboard/smart_water_intake_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart' as provider;
// Import notification services - FCM only
import '../notification/services/helper_services.dart';
// Import cache and sync services
import 'package:client/services/cache_service.dart';
import 'package:client/services/background_sync_service.dart';
import 'package:client/features/water_intake/presentation/widgets/water_intake_popup_manager.dart';
// Import the FitbitCallbackNotification from main.dart
import 'package:client/main.dart';
// Add the import for the FitbitConnectionDrawer at the top of the file
import 'package:client/features/wearable_integration/fitbit_appauth_service.dart';
import 'package:client/widgets/dashboard/fitbit_connection_drawer.dart';
// Import water intake components
import 'package:client/features/water_intake/data/providers/water_intake_provider.dart';
import 'package:client/features/water_intake/presentation/widgets/water_intake_drawer.dart';
import 'dart:developer' as developer;

// Import weight management components
import 'package:client/features/weight_management/presentation/widgets/weight_input_dialog.dart';
import 'package:client/features/weight_management/presentation/providers/weight_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  Health? health;
  Map<String, dynamic> healthData = {
    // Initialize with zeros for all metrics
    'HEART_RATE': '0 BPM',
    'STEPS': '0 steps',
    'ACTIVE_ENERGY_BURNED': '0 kcal',
    'SLEEP_ASLEEP': '0 min',
    'BLOOD_PRESSURE_SYSTOLIC': '0 mmHg',
    'BLOOD_PRESSURE_DIASTOLIC': '0 mmHg',
  };
  bool _isWatchConnected = false;
  String _connectedWatchType = '';
  late AnimationController _animationController;
  late Animation<double> _drawerAnimation;
  int? healthScore = 0; // Initialize with zero
  bool _isConnectingFitbit = false;
  bool _isLoadingData = false; // Track loading state
  bool _isWatchDrawerShowing = false;
  bool _isCheckingConnection = false;
  bool _hasLoadedCachedData = false;
  bool _isRefreshing = false;
  final FitbitAppAuthService _fitbitService = FitbitAppAuthService();

  // Water intake drawer variables
  bool _showWaterIntakeDrawer = false;
  String? _currentWaterSlot;
  late AnimationController _waterDrawerAnimationController;
  late Animation<double> _waterDrawerAnimation;

  // Weight input drawer variables
  bool _showWeightInputDrawer = false;
  bool _isWeightInputRequired = false; // Flag to track if weight input is required
  DateTime? _lastWeightEntry;
  static const int _weightReminderIntervalDays = 3;

  // Manual entry data
  Map<String, dynamic> _manualEntryData = {
    'steps': 0,
    'heartRate': 0,
    'calories': 0,
    'sleepHours': 0,
  };

  // Base URL for API
  final String _baseUrl = 'https://test-prod-f427.onrender.com';

  // Loading overlay key
  final GlobalKey<_LoadingOverlayState> _loadingOverlayKey = GlobalKey<_LoadingOverlayState>();

  @override
  void initState() {
    super.initState();
    health = Health();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _drawerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // Initialize water intake drawer animation controller
    _waterDrawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _waterDrawerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waterDrawerAnimationController,
      curve: Curves.easeInOut,
    ));

    // Load cached data immediately for instant rendering
    _loadCachedDataFirst();

    // Then perform full initialization
    _initializeApp();
  }

  /// Load cached data first for instant rendering
  Future<void> _loadCachedDataFirst() async {
    developer.log('🚀 Loading cached data for instant rendering', name: 'Dashboard');

    try {
      // Load cached health data
      final cachedHealthData = await CacheService.getHealthData();
      if (cachedHealthData != null) {
        setState(() {
          healthData = Map<String, dynamic>.from(cachedHealthData);
          _hasLoadedCachedData = true;
        });
        developer.log('✅ Cached health data loaded', name: 'Dashboard');
      }

      // Load cached health score
      final cachedHealthScore = await CacheService.getHealthScore();
      if (cachedHealthScore != null) {
        setState(() {
          healthScore = cachedHealthScore;
        });
        developer.log('✅ Cached health score loaded: $cachedHealthScore', name: 'Dashboard');
      }

      // Load manual entry data
      await _loadManualEntryData();

      // Check watch connection status
      await _checkWatchConnection();

      // If we have cached data, show it immediately
      if (_hasLoadedCachedData) {
        developer.log('✅ Dashboard rendered with cached data', name: 'Dashboard');
      }
    } catch (e) {
      developer.log('❌ Error loading cached data: $e', name: 'Dashboard');
    }
  }

  /// Initialize app with fresh data
  Future<void> _initializeApp() async {
    developer.log('🔄 Initializing app with fresh data', name: 'Dashboard');

    // Start background sync service
    BackgroundSyncService.instance.startBackgroundSync();

    // Initialize weight tracking first (higher priority)
    await _initializeWeightTracking();

    // Initialize water intake and check for drawer trigger
    await _initializeWaterIntake();

    // Check if we need to refresh data
    final needsRefresh = await CacheService.needsRefresh();

    if (needsRefresh || !_hasLoadedCachedData) {
      // Fetch fresh data in background
      _fetchFreshDataInBackground();
    }

    // Check connection status and show drawer if needed
    final completed = await _checkConnectionCompleted();
    if (!completed && !_isWatchDrawerShowing && !_isWeightInputRequired) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _showWatchConnectionDrawer();
      });
    } else if (_isWatchConnected) {
      // Watch is connected, sync data if needed
      if (needsRefresh) {
        _syncConnectedDeviceData();
      }
    }

    // Check for OAuth return
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingFitbitUri != null) {
        _processFitbitCallback(pendingFitbitUri!);
        pendingFitbitUri = null;
      } else {
        _checkForRecentOAuthReturn();
      }

      // Initialize FCM notification services only
      _initializeNotificationServices();
    });
  }

  /// Initialize water intake and check for drawer trigger
  Future<void> _initializeWaterIntake() async {
    try {
      final waterProvider = provider.Provider.of<WaterIntakeProvider>(context, listen: false);
      await waterProvider.initialize();

      // Only check water intake drawer if weight input is not required
      if (!_isWeightInputRequired) {
        _checkWaterIntakeDrawer();
        _startWaterIntakeTimer();
      }
    } catch (e) {
      developer.log('❌ Error initializing water intake: $e', name: 'Dashboard');
    }
  }

  /// Initialize weight tracking and check for drawer trigger
  Future<void> _initializeWeightTracking() async {
    try {
      // Load last weight entry date
      await _loadLastWeightEntryDate();

      // Check if we should show the weight input drawer
      _checkWeightInputDrawer();

      // Set up periodic checks for weight input drawer
      _startWeightTrackingTimer();
    } catch (e) {
      developer.log('❌ Error initializing weight tracking: $e', name: 'Dashboard');
    }
  }

  /// Load last weight entry date from shared preferences
  Future<void> _loadLastWeightEntryDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastEntryTimestamp = prefs.getInt('last_weight_entry_timestamp');
      if (lastEntryTimestamp != null) {
        _lastWeightEntry = DateTime.fromMillisecondsSinceEpoch(lastEntryTimestamp);
        developer.log('📅 Last weight entry: ${_lastWeightEntry.toString()}', name: 'Dashboard');
      } else {
        developer.log('📅 No previous weight entry found', name: 'Dashboard');
      }
    } catch (e) {
      developer.log('❌ Error loading last weight entry date: $e', name: 'Dashboard');
    }
  }

  /// Check if weight input drawer should be shown
  void _checkWeightInputDrawer() {
    final now = DateTime.now();

    bool shouldShow = false;

    if (_lastWeightEntry == null) {
      // First time user - show weight input
      shouldShow = true;
      developer.log('👋 First time user, showing weight input', name: 'Dashboard');
    } else {
      // Check if 3 days have passed since last entry
      final daysSinceLastEntry = now.difference(_lastWeightEntry!).inDays;
      developer.log('📊 Days since last weight entry: $daysSinceLastEntry', name: 'Dashboard');

      if (daysSinceLastEntry >= _weightReminderIntervalDays) {
        shouldShow = true;
        developer.log('⚖️ $daysSinceLastEntry days passed, weight input required', name: 'Dashboard');
      }
    }

    if (shouldShow) {
      setState(() {
        _isWeightInputRequired = true;
        _showWeightInputDrawer = true;
      });

      developer.log('🔔 Weight input drawer activated', name: 'Dashboard');
    }
  }

  /// Start weight tracking timer
  void _startWeightTrackingTimer() {
    // Check every hour for weight input drawer trigger
    Future.delayed(const Duration(hours: 1), () {
      if (mounted) {
        // Only check if weight input is not already required
        if (!_isWeightInputRequired) {
          _checkWeightInputDrawer();
        }
        _startWeightTrackingTimer();
      }
    });
  }

  /// Handle weight input
  Future<void> _onWeightSaved(double weight) async {
    try {
      developer.log('💾 Saving weight: $weight kg', name: 'Dashboard');

      // Save weight using the weight controller
      final weightController = ref.read(weightControllerProvider.notifier);
      await weightController.updateWeight(weight);

      // Update last weight entry timestamp
      final prefs = await SharedPreferences.getInstance();
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('last_weight_entry_timestamp', currentTimestamp);

      setState(() {
        _lastWeightEntry = DateTime.now();
        _showWeightInputDrawer = false;
        _isWeightInputRequired = false; // Reset the requirement flag
      });

      // Now that weight is entered, check for water intake drawer
      _checkWaterIntakeDrawer();
      _startWaterIntakeTimer();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Weight updated successfully: ${weight.toStringAsFixed(1)} kg',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      developer.log('✅ Weight saved successfully: $weight kg', name: 'Dashboard');
    } catch (e) {
      developer.log('❌ Error saving weight: $e', name: 'Dashboard');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save weight. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _checkWaterIntakeDrawer() {
    // Don't show water intake drawer if weight input is required
    if (_isWeightInputRequired) {
      developer.log('⚖️ Weight input required, skipping water intake drawer', name: 'Dashboard');
      return;
    }

    final waterProvider = provider.Provider.of<WaterIntakeProvider>(context, listen: false);

    // Get current time and check if it's within active hours (7 AM to 10 PM)
    final now = DateTime.now();
    if (now.hour < 7 || now.hour > 22) {
      developer.log('⏰ Outside active hours, not showing water drawer', name: 'Dashboard');
      return;
    }

    // Check if goal is already achieved
    if (waterProvider.todayIntake.progressPercentage >= 100) {
      developer.log('🎉 Water goal already achieved, not showing drawer', name: 'Dashboard');
      return;
    }

    // Get current incomplete slot
    final currentSlot = waterProvider.getCurrentIncompleteSlot();

    // Check if enough time has passed since last intake
    final lastIntakeTime = waterProvider.todayIntake.entries.isNotEmpty
        ? waterProvider.todayIntake.entries.last.timestamp
        : null;

    bool shouldShow = false;

    if (currentSlot != null) {
      // If there's a current slot that needs completion
      shouldShow = true;
      developer.log('📋 Current incomplete slot: $currentSlot', name: 'Dashboard');
    } else if (lastIntakeTime != null) {
      // Check if it's been more than 2 hours since last intake
      final timeSinceLastIntake = now.difference(lastIntakeTime);
      if (timeSinceLastIntake.inHours >= 2) {
        shouldShow = true;
        developer.log('⏱️ 2+ hours since last intake, showing reminder', name: 'Dashboard');
      }
    } else if (waterProvider.todayIntake.totalAmount == 0 && now.hour >= 9) {
      // No water logged today and it's past 9 AM
      shouldShow = true;
      developer.log('🌅 No water logged today, showing morning reminder', name: 'Dashboard');
    }

    if (shouldShow && !_showWaterIntakeDrawer) {
      developer.log('🔔 Showing water intake drawer for slot: $currentSlot', name: 'Dashboard');

      setState(() {
        _currentWaterSlot = currentSlot ?? 'Hydration Reminder';
        _showWaterIntakeDrawer = true;
      });

      _waterDrawerAnimationController.forward();
    }
  }

  void _startWaterIntakeTimer() {
    // Check every 30 minutes for water intake drawer trigger
    Future.delayed(const Duration(minutes: 30), () {
      if (mounted) {
        _checkWaterIntakeDrawer();
        _startWaterIntakeTimer();
      }
    });
  }

  void _closeWaterIntakeDrawer() {
    _waterDrawerAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showWaterIntakeDrawer = false;
          _currentWaterSlot = null;
        });
      }
    });
  }

  void _onWaterAdded(double amount) {
    // Refresh the fitness tracker section to update progress
    setState(() {});

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Great! ${amount.toInt()}ml added to your daily intake',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Fetch fresh data in background without blocking UI
  Future<void> _fetchFreshDataInBackground() async {
    developer.log('🔄 Fetching fresh data in background', name: 'Dashboard');

    try {
      // Don't show loading if we already have cached data
      if (!_hasLoadedCachedData) {
        setState(() {
          _isLoadingData = true;
        });
      }

      // Force background sync
      await BackgroundSyncService.instance.forceSyncNow();

      // Reload data from cache (now updated)
      await _reloadDataFromCache();

    } catch (e) {
      developer.log('❌ Error fetching fresh data: $e', name: 'Dashboard');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// Reload data from cache after background sync
  Future<void> _reloadDataFromCache() async {
    try {
      // Reload health data
      final cachedHealthData = await CacheService.getHealthData();
      if (cachedHealthData != null) {
        setState(() {
          healthData = Map<String, dynamic>.from(cachedHealthData);
        });
      }

      // Reload health score
      final cachedHealthScore = await CacheService.getHealthScore();
      if (cachedHealthScore != null) {
        setState(() {
          healthScore = cachedHealthScore;
        });
      }

      developer.log('✅ Data reloaded from updated cache', name: 'Dashboard');
    } catch (e) {
      developer.log('❌ Error reloading data from cache: $e', name: 'Dashboard');
    }
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        developer.log('📱 App resumed, checking for data refresh', name: 'Dashboard');
        _handleAppResume();
        break;
      case AppLifecycleState.paused:
        developer.log('📱 App paused', name: 'Dashboard');
        break;
      case AppLifecycleState.detached:
        BackgroundSyncService.instance.stopBackgroundSync();
        break;
      default:
        break;
    }
  }

  /// Handle app resume
  Future<void> _handleAppResume() async {
    // Check if data needs refresh
    final needsRefresh = await CacheService.needsRefresh();

    if (needsRefresh) {
      developer.log('🔄 Data needs refresh, syncing...', name: 'Dashboard');
      _fetchFreshDataInBackground();
    }

    // Check for OAuth return
    _checkForRecentOAuthReturn();

    // Check for weight input drawer first (higher priority)
    if (!_isWeightInputRequired) {
      _checkWeightInputDrawer();
    }

    // Check for water intake drawer only if weight is not required
    if (!_isWeightInputRequired) {
      _checkWaterIntakeDrawer();
    }
  }

  /// Pull to refresh functionality
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      developer.log('🔄 Manual refresh triggered', name: 'Dashboard');

      // Force sync
      await BackgroundSyncService.instance.forceSyncNow();

      // Reload from cache
      await _reloadDataFromCache();

      // Sync device data if connected
      if (_isWatchConnected) {
        await _syncConnectedDeviceData();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Data refreshed successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Manual refresh failed: $e', name: 'Dashboard');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// Sync connected device data
  Future<void> _syncConnectedDeviceData() async {
    if (_connectedWatchType == 'Fitbit') {
      await _fetchFitbitData();
    } else if (_connectedWatchType == 'Manual') {
      _updateHealthDataFromManualEntry();
    }
  }

  /// Check if user just returned from OAuth
  Future<void> _checkForRecentOAuthReturn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastOAuthAttempt = prefs.getInt('last_oauth_attempt');

      if (lastOAuthAttempt != null) {
        final timeDiff = DateTime.now().millisecondsSinceEpoch - lastOAuthAttempt;

        if (timeDiff < 300000) { // 5 minutes
          setState(() {
            _isCheckingConnection = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Checking Fitbit connection...'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );

          final isConnected = await _fitbitService.checkConnectionAfterRedirect();

          if (isConnected) {
            await _setWatchConnected('Fitbit');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Successfully connected to Fitbit!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            _fetchFitbitData();
          }

          await prefs.remove('last_oauth_attempt');

          setState(() {
            _isCheckingConnection = false;
          });
        }
      }
    } catch (e) {
      developer.log('❌ Error checking for recent OAuth return: $e', name: 'Dashboard');
      setState(() {
        _isCheckingConnection = false;
      });
    }
  }

  // Initialize FCM notification services only
  Future<void> _initializeNotificationServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userId = prefs.getString('user_id');

      if (accessToken != null && userId != null) {
        // Initialize only FCM notification services
        await NotificationHelperService().initialize(
          accessToken: accessToken,
          userId: userId,
        );

        developer.log('✅ FCM notification services initialized', name: 'Dashboard');
      }
    } catch (e) {
      developer.log('❌ Error initializing FCM notification services: $e', name: 'Dashboard');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _waterDrawerAnimationController.dispose();
    BackgroundSyncService.instance.stopBackgroundSync();
    super.dispose();
  }

  /// **Check if connection was completed**
  Future<bool> _checkConnectionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fitbit_connection_completed') ?? false;
  }

  /// **Check if watch is connected**
  Future<void> _checkWatchConnection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isWatchConnected = prefs.getBool('watch_connected') ?? false;
      _connectedWatchType = prefs.getString('watch_type') ?? '';
    });

    if (_connectedWatchType == 'Fitbit') {
      final isAuth = await _fitbitService.isAuthenticated();
      if (!isAuth) {
        setState(() {
          _isWatchConnected = false;
          _connectedWatchType = '';
        });
        await prefs.setBool('watch_connected', false);
        await prefs.remove('watch_type');
      }
    }

    if (_connectedWatchType == 'Manual') {
      _updateHealthDataFromManualEntry();
    }
  }

  /// **Update health data from manual entry**
  void _updateHealthDataFromManualEntry() {
    setState(() {
      healthData = {
        'HEART_RATE': '${_manualEntryData['heartRate']} BPM',
        'STEPS': '${_manualEntryData['steps']} steps',
        'ACTIVE_ENERGY_BURNED': '${_manualEntryData['calories']} kcal',
        'SLEEP_ASLEEP': '${(_manualEntryData['sleepHours'] * 60).toInt()} min',
        'BLOOD_PRESSURE_SYSTOLIC': '0 mmHg',
        'BLOOD_PRESSURE_DIASTOLIC': '0 mmHg',
      };
    });

    // Cache the manual entry data
    CacheService.saveHealthData(healthData);
  }

  /// **Set watch as connected**
  Future<void> _setWatchConnected(String watchType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('watch_connected', true);
    await prefs.setString('watch_type', watchType);
    await prefs.setBool('fitbit_connection_completed', true);

    setState(() {
      _isWatchConnected = true;
      _connectedWatchType = watchType;
    });

    if (watchType == 'Manual') {
      _updateHealthDataFromManualEntry();
    } else if (watchType == 'Fitbit') {
      _fetchFitbitData();
    }
  }

  /// **Load manual entry data from shared preferences**
  Future<void> _loadManualEntryData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _manualEntryData = {
        'steps': prefs.getInt('manual_steps') ?? 0,
        'heartRate': prefs.getInt('manual_heart_rate') ?? 0,
        'calories': prefs.getInt('manual_calories') ?? 0,
        'sleepHours': prefs.getDouble('manual_sleep_hours') ?? 0,
      };
    });

    if (_connectedWatchType == 'Manual') {
      _updateHealthDataFromManualEntry();
    }
  }

  /// **Save manual entry data to shared preferences**
  Future<void> _saveManualEntryData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('manual_steps', _manualEntryData['steps']);
    await prefs.setInt('manual_heart_rate', _manualEntryData['heartRate']);
    await prefs.setInt('manual_calories', _manualEntryData['calories']);
    await prefs.setDouble('manual_sleep_hours', _manualEntryData['sleepHours']);
    await prefs.setInt('manual_entry_last_updated', DateTime.now().millisecondsSinceEpoch);

    _updateHealthDataFromManualEntry();

    try {
      await _fitbitService.saveManualActivityData({
        'steps': _manualEntryData['steps'],
        'heartRate': _manualEntryData['heartRate'],
        'calories': _manualEntryData['calories'],
        'date': DateTime.now().toIso8601String().split('T')[0],
      });

      await _fitbitService.saveManualSleepData({
        'sleepHours': _manualEntryData['sleepHours'],
        'date': DateTime.now().toIso8601String().split('T')[0],
      });

      developer.log("✅ Manual entry data saved", name: 'Dashboard');
    } catch (e) {
      developer.log("⚠️ Failed to save to backend: $e", name: 'Dashboard');
    }
  }

  /// **Show Watch Connection Drawer**
  void _showWatchConnectionDrawer() {
    if (_isWatchDrawerShowing) return;

    setState(() {
      _isWatchDrawerShowing = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return FitbitConnectionDrawer(
              scrollController: scrollController,
              onFitbitConnect: () async {
                Navigator.pop(context);
                await _initiateFitbitOAuth();
              },
              onManualEntry: () {
                _manualEntryData = {
                  'steps': 0,
                  'heartRate': 0,
                  'calories': 0,
                  'sleepHours': 0,
                };

                _saveManualEntryData();
                _setWatchConnected('Manual');
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Manual tracking enabled'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onClose: () {
                Navigator.pop(context);
              },
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _isWatchDrawerShowing = false;
      });
    });
  }

  /// **Fetch Fitbit Data**
  Future<void> _fetchFitbitData() async {
    if (_connectedWatchType != 'Fitbit') return;

    // Don't show loading if we have cached data
    if (!_hasLoadedCachedData) {
      setState(() {
        _isLoadingData = true;
      });
    }

    try {
      // Check cached Fitbit data first
      final cachedFitbitData = await CacheService.getFitbitData();
      if (cachedFitbitData != null) {
        _updateHealthDataFromFitbit(cachedFitbitData);
        developer.log('✅ Using cached Fitbit data', name: 'Dashboard');
      }

      // Sync fresh data in background
      final hasInitialSync = await _fitbitService.hasCompletedInitialSync();

      if (!hasInitialSync) {
        await _fitbitService.initialSync();
        await _fitbitService.markInitialSyncCompleted();
      } else {
        await _fitbitService.syncDailyData();
      }

      final healthSummary = await _fitbitService.getHealthDataSummary();

      if (healthSummary != null && healthSummary['data'] != null) {
        _updateHealthDataFromFitbit(healthSummary['data']);
        // Cache the fresh data
        await CacheService.saveFitbitData(healthSummary['data']);
      }

    } catch (e) {
      developer.log('❌ Error fetching Fitbit data: $e', name: 'Dashboard');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync Fitbit data'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  /// **Update health data from Fitbit response**
  void _updateHealthDataFromFitbit(Map<String, dynamic> fitbitData) {
    setState(() {
      if (fitbitData['summary'] != null) {
        final summary = fitbitData['summary'];
        healthData['STEPS'] = '${summary['steps'] ?? 0} steps';
        healthData['ACTIVE_ENERGY_BURNED'] = '${summary['caloriesOut'] ?? 0} kcal';
      }

      if (fitbitData['heartRate'] != null) {
        final heartRate = fitbitData['heartRate'];
        healthData['HEART_RATE'] = '${heartRate['resting_heart_rate'] ?? 0} BPM';
      }

      if (fitbitData['sleep'] != null) {
        final sleep = fitbitData['sleep'];
        if (sleep.isNotEmpty) {
          healthData['SLEEP_ASLEEP'] = '${sleep[0]['minutesAsleep'] ?? 0} min';
        }
      }
    });

    // Cache the updated health data
    CacheService.saveHealthData(healthData);
  }

  /// Process Fitbit OAuth callback
  Future<void> _processFitbitCallback(Uri uri) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingOverlay(
            key: _loadingOverlayKey,
            message: 'Completing Fitbit connection...',
          );
        },
      );

      setState(() {
        _isConnectingFitbit = true;
      });

      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code != null && state != null) {
        final success = await _fitbitService.processCallback(code, state);

        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (success) {
          await _setWatchConnected('Fitbit');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully connected to Fitbit'),
                backgroundColor: Colors.green,
              ),
            );
          }

          _fetchFitbitData();
        } else {
          throw Exception('Failed to complete Fitbit authentication');
        }
      } else {
        throw Exception('Invalid callback parameters');
      }
    } catch (e) {
      setState(() {
        _isConnectingFitbit = false;
      });

      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log('❌ Error completing Fitbit connection: $e', name: 'Dashboard');

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Error'),
              content: Text('Failed to complete Fitbit connection: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _isConnectingFitbit = false;
      });
    }
  }

  /// **Initiate Fitbit OAuth**
  Future<void> _initiateFitbitOAuth() async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingOverlay(
            key: _loadingOverlayKey,
            message: 'Connecting to Fitbit...',
          );
        },
      );
    }

    try {
      setState(() {
        _isConnectingFitbit = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_oauth_attempt', DateTime.now().millisecondsSinceEpoch);

      final success = await _fitbitService.authenticate(context);

      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete the authorization in your browser. The app will automatically detect when you return.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 8),
            ),
          );
        }
      } else {
        throw Exception('Failed to initiate Fitbit OAuth');
      }
    } catch (e) {
      setState(() {
        _isConnectingFitbit = false;
      });

      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log('❌ Error connecting to Fitbit: $e', name: 'Dashboard');

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Error'),
              content: Text('Failed to connect to Fitbit: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _isConnectingFitbit = false;
      });
    }
  }

  /// **Show Manual Entry Drawer**
  void _showManualEntryDrawer() {
    final stepsController = TextEditingController(
      text: _manualEntryData['steps'].toString(),
    );
    final heartRateController = TextEditingController(
      text: _manualEntryData['heartRate'].toString(),
    );
    final caloriesController = TextEditingController(
      text: _manualEntryData['calories'].toString(),
    );
    final sleepHoursController = TextEditingController(
      text: _manualEntryData['sleepHours'].toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 8.h),
                        width: 32.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Health Entry',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Enter your health metrics manually',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildManualEntryField(
                              icon: Icons.directions_walk,
                              label: 'Steps',
                              hint: 'Enter steps count',
                              controller: stepsController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12.h),

                            _buildManualEntryField(
                              icon: Icons.favorite,
                              label: 'Heart Rate (BPM)',
                              hint: 'Enter heart rate',
                              controller: heartRateController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12.h),

                            _buildManualEntryField(
                              icon: Icons.local_fire_department,
                              label: 'Calories Burned',
                              hint: 'Enter calories',
                              controller: caloriesController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12.h),

                            _buildManualEntryField(
                              icon: Icons.nightlight_round,
                              label: 'Sleep Hours',
                              hint: 'Enter sleep hours',
                              controller: sleepHoursController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _manualEntryData = {
                                'steps':
                                int.tryParse(stepsController.text) ?? 0,
                                'heartRate':
                                int.tryParse(heartRateController.text) ?? 0,
                                'calories':
                                int.tryParse(caloriesController.text) ?? 0,
                                'sleepHours':
                                double.tryParse(
                                  sleepHoursController.text,
                                ) ??
                                    0,
                              };
                            });

                            _saveManualEntryData();
                            _setWatchConnected('Manual');
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Manual data saved successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F67FE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save & Continue',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// **Build Manual Entry Field**
  Widget _buildManualEntryField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Color(0xFF0F67FE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: Color(0xFF0F67FE), size: 18.sp),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          // Initialize weight controller if needed
          ref.watch(weightControllerInitProvider);

          return WaterIntakePopupManager(
            child: Scaffold(
              backgroundColor: const Color(0xFFF0F2F5),
              body: Stack(
                children: [
                  // Main content
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF0F67FE),
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: SafeArea(
                              child: Column(
                                children: [
                                  AppHeader(),
                                  // Show sync status indicator
                                  if (BackgroundSyncService.instance.isSyncing)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0F67FE)),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Syncing data...',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ];
                      },
                      body: _isLoadingData && !_hasLoadedCachedData || _isCheckingConnection
                          ? _buildLoadingState()
                          : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          const SizedBox(height: 20),
                          HealthScoreCard(),
                          const SizedBox(height: 20),
                          const HealthMetricsSection(),
                          const SizedBox(height: 20),
                          const FitnessTrackerSection(),
                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          const MedicationSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Weight Input Drawer Overlay (Highest Priority)
                  if (_showWeightInputDrawer)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: WeightInputDialog(
                            onWeightSaved: _onWeightSaved,
                          ),
                        ),
                      ),
                    ),

                  // Water Intake Drawer Overlay (Lower Priority)
                  if (_showWaterIntakeDrawer && _currentWaterSlot != null && !_showWeightInputDrawer)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _waterDrawerAnimation,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              // Semi-transparent overlay
                              GestureDetector(
                                onTap: () {
                                  // Show confirmation dialog when tapping overlay
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      title: Text(
                                        'Skip Hydration?',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to skip your hydration reminder?',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('Stay & Hydrate'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _closeWaterIntakeDrawer();
                                          },
                                          child: Text('Skip for Now'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.black.withOpacity(0.5 * _waterDrawerAnimation.value),
                                ),
                              ),

                              // Drawer positioned at bottom with proper sizing
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                                  ),
                                  child: WaterIntakeDrawer(
                                    currentSlot: _currentWaterSlot!,
                                    onClose: _closeWaterIntakeDrawer,
                                    onWaterAdded: _onWaterAdded,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
              bottomNavigationBar: const BottomNavigation(),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (_connectedWatchType == 'Manual') {
                    _showManualEntryDrawer();
                  } else if (_connectedWatchType == 'Fitbit') {
                    _fetchFitbitData();
                  }
                },
                backgroundColor: const Color(0xFF2563EB),
                child: Icon(
                  _connectedWatchType == 'Manual' ? Icons.edit : Icons.refresh,
                  color: Colors.white,
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            ),
          );
        }
    );
  }

  /// **Build Loading State**
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0F67FE)),
          ),
          SizedBox(height: 16.h),
          Text(
            _isCheckingConnection
                ? 'Checking Fitbit connection...'
                : 'Loading health data...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading overlay widget
class LoadingOverlay extends StatefulWidget {
  final String message;

  const LoadingOverlay({
    super.key,
    required this.message,
  });

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  String _message;

  _LoadingOverlayState() : _message = '';

  @override
  void initState() {
    super.initState();
    _message = widget.message;
  }

  void updateMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              _message,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
