import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:client/widgets/dashboard/app_header.dart';
import 'package:client/widgets/dashboard/health_score_card.dart';
import 'package:client/widgets/dashboard/health_metrics_section.dart';
import 'package:client/widgets/dashboard/fitness_tracker_section.dart';
import 'package:client/widgets/dashboard/bottom_navigation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import for Clipboard
import 'package:provider/provider.dart';
// Import notification services
import '../notification/services/socket_services.dart';
import '../notification/services/helper_services.dart';

// Import the FitbitCallbackNotification from main.dart
import 'package:client/main.dart';
// Add the import for the FitbitConnectionDrawer at the top of the file
import 'package:client/features/wearable_integration/fitbit_appauth_service.dart';
import 'package:client/widgets/dashboard/fitbit_connection_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  final FitbitAppAuthService _fitbitService = FitbitAppAuthService();

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

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _drawerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // Load any saved manual entry data
    _loadManualEntryData();

    // Check if watch is already connected
    _checkWatchConnection().then((_) {
      // Check if connection was completed before
      _checkConnectionCompleted().then((completed) {
        if (!completed && !_isWatchDrawerShowing) {
          // Show the watch connection drawer after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            _showWatchConnectionDrawer();
          });
        } else if (_isWatchConnected) {
          // Watch is connected, fetch health data
          _fetchFitbitData();
        }
      });
    });

    // Check if there's a pending Fitbit callback URI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingFitbitUri != null) {
        // Process the Fitbit OAuth callback directly
        _processFitbitCallback(pendingFitbitUri!);
        pendingFitbitUri = null; // Clear the pending URI
      }

      // Initialize notification services
      _initializeNotificationServices();
    });
  }

  // Initialize notification services
  Future<void> _initializeNotificationServices() async {
    try {
      // Get access token and user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userId = prefs.getString('user_id');

      if (accessToken != null && userId != null) {
        // Initialize socket service
        final socketService = Provider.of<SocketService>(context, listen: false);
        if (!socketService.isConnected) {
          socketService.initSocket(
            userId,
            accessToken: accessToken,
          );
        }

        // Initialize notification helper service
        await NotificationHelperService().initialize(
          accessToken: accessToken,
          userId: userId,
        );

        print('✅ Notification services initialized with user credentials');
      } else {
        print('⚠️ Cannot initialize notification services: Missing user credentials');
      }
    } catch (e) {
      print('❌ Error initializing notification services: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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

    // If Fitbit is connected, check authentication status
    if (_connectedWatchType == 'Fitbit') {
      final isAuth = await _fitbitService.isAuthenticated();
      if (!isAuth) {
        // Connection lost, reset status
        setState(() {
          _isWatchConnected = false;
          _connectedWatchType = '';
        });
        await prefs.setBool('watch_connected', false);
        await prefs.remove('watch_type');
      }
    }

    // If manual entry is selected, update health data with manual values
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
        'BLOOD_PRESSURE_SYSTOLIC': '0 mmHg', // Not in manual entry
        'BLOOD_PRESSURE_DIASTOLIC': '0 mmHg', // Not in manual entry
      };
    });
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

    // If manual entry is selected, update health data with manual values
    // and don't fetch any additional data
    if (watchType == 'Manual') {
      _updateHealthDataFromManualEntry();
    } else if (watchType == 'Fitbit') {
      // Fetch Fitbit data
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

    // If manual entry is selected, update health data with manual values
    // and don't fetch any additional data
    if (_connectedWatchType == 'Manual') {
      _updateHealthDataFromManualEntry();

      // Log when the data was last updated
      final lastUpdated = prefs.getInt('manual_entry_last_updated');
      if (lastUpdated != null) {
        final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
        print("📅 Manual entry data last updated: $lastUpdateTime");
      }
    }
  }

  /// **Save manual entry data to shared preferences**
  Future<void> _saveManualEntryData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save all manual entry data to cache
    await prefs.setInt('manual_steps', _manualEntryData['steps']);
    await prefs.setInt('manual_heart_rate', _manualEntryData['heartRate']);
    await prefs.setInt('manual_calories', _manualEntryData['calories']);
    await prefs.setDouble('manual_sleep_hours', _manualEntryData['sleepHours']);

    // Also save the last update timestamp
    await prefs.setInt('manual_entry_last_updated', DateTime.now().millisecondsSinceEpoch);

    // Update health data with manual values
    _updateHealthDataFromManualEntry();

    // Save to backend
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

      print("✅ Manual entry data saved to backend and cache");
    } catch (e) {
      print("⚠️ Failed to save to backend, data saved to cache only: $e");
    }
  }

  /// **Show Watch Connection Drawer**
  void _showWatchConnectionDrawer() {
    // Check if a drawer is already showing to prevent duplicate drawers
    if (_isWatchDrawerShowing) return;

    setState(() {
      _isWatchDrawerShowing = true;
    });

    // Use the FitbitConnectionDrawer from widgets/dashboard/fitbit_connection_drawer.dart
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // Allow dismissing by tapping outside
      enableDrag: true, // Allow dismissing by dragging
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return FitbitConnectionDrawer(
              scrollController: scrollController,
              onFitbitConnect: () async {
                // Close the drawer first
                Navigator.pop(context);

                // Show loading and initiate Fitbit OAuth
                await _initiateFitbitOAuth();
              },
              onManualEntry: () {
                // Set default values for manual entry
                _manualEntryData = {
                  'steps': 0,
                  'heartRate': 0,
                  'calories': 0,
                  'sleepHours': 0,
                };

                // Save to shared preferences (cache)
                _saveManualEntryData();

                // Set as connected with manual entry
                _setWatchConnected('Manual');

                // Close drawer
                Navigator.pop(context);

                // Show success message
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
      // Reset the flag when the drawer is closed
      setState(() {
        _isWatchDrawerShowing = false;
      });
    });
  }

  /// **Fetch Fitbit Data**
  Future<void> _fetchFitbitData() async {
    if (_connectedWatchType != 'Fitbit') return;

    setState(() {
      _isLoadingData = true;
    });

    try {
      // Check if initial sync is needed
      final hasInitialSync = await _fitbitService.hasCompletedInitialSync();

      if (!hasInitialSync) {
        // Perform initial sync (30 days)
        await _fitbitService.initialSync();
        await _fitbitService.markInitialSyncCompleted();
      } else {
        // Perform daily sync
        await _fitbitService.syncDailyData();
      }

      // Get health data summary
      final healthSummary = await _fitbitService.getHealthDataSummary();

      if (healthSummary != null && healthSummary['data'] != null) {
        _updateHealthDataFromFitbit(healthSummary['data']);
      }

    } catch (e) {
      print('❌ Error fetching Fitbit data: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync Fitbit data: ${e.toString()}'),
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
      // Parse Fitbit data and update healthData
      // This is a simplified example - adjust based on actual API response structure

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
  }

  /// Process Fitbit OAuth callback
  Future<void> _processFitbitCallback(Uri uri) async {
    try {
      // Show loading indicator
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

      // Extract code and state from URI
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code != null && state != null) {
        // Process the callback
        final success = await _fitbitService.processCallback(code, state);

        // Close loading overlay
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (success) {
          // Set watch as connected
          await _setWatchConnected('Fitbit');

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully connected to Fitbit'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Fetch health data
          _fetchFitbitData();
        } else {
          throw Exception('Failed to complete Fitbit authentication');
        }
      } else {
        throw Exception('Invalid callback parameters');
      }
    } catch (e) {
      // Reset loading state
      setState(() {
        _isConnectingFitbit = false;
      });

      // Close loading overlay if it's still showing
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Error completing Fitbit connection: $e');

      // Show error message using a dialog
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
    // Show loading overlay
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

      // Use the backend service for authentication
      final success = await _fitbitService.authenticate(context);

      // Close loading overlay
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (success) {
        // Show message that user should complete OAuth in browser
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete the authorization in your browser'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('Failed to initiate Fitbit OAuth');
      }
    } catch (e) {
      // Reset loading state
      setState(() {
        _isConnectingFitbit = false;
      });

      // Close loading overlay if it's still showing
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Error connecting to Fitbit: $e');

      // Show error message using a dialog
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

  // Rest of the existing methods remain the same...
  /// **Show Manual Entry Drawer**
  void _showManualEntryDrawer() {
    // Create controllers for text fields
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
          onWillPop: () async => false, // Prevent back button from closing
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
                    // Handle bar
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

                    // Header
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

                    // Form fields
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // Steps
                            _buildManualEntryField(
                              icon: Icons.directions_walk,
                              label: 'Steps',
                              hint: 'Enter steps count',
                              controller: stepsController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12.h),

                            // Heart Rate
                            _buildManualEntryField(
                              icon: Icons.favorite,
                              label: 'Heart Rate (BPM)',
                              hint: 'Enter heart rate',
                              controller: heartRateController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12.h),

                            // Calories
                            _buildManualEntryField(
                              icon: Icons.local_fire_department,
                              label: 'Calories Burned',
                              hint: 'Enter calories',
                              controller: caloriesController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12.h),

                            // Sleep Hours
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

                    // Save button
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () {
                            // Update manual entry data
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

                            // Save to shared preferences (cache)
                            _saveManualEntryData();

                            // Set as connected with manual entry
                            _setWatchConnected('Manual');

                            // Close drawer
                            Navigator.pop(context);

                            // Show success message using the global ScaffoldMessenger
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Manual data saved to cache'),
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
            // Icon container
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

            // Text field
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

  // Listen for Fitbit callback notifications
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [SliverToBoxAdapter(child: SafeArea(child: AppHeader()))];
        },
        body:
        _isLoadingData
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
          ],
        ),
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
    );
  }

  /// **Build Loading State**
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F67FE)),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading health data...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
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
