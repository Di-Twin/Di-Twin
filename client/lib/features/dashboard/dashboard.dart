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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:provider/provider.dart';
// Import notification services
import '../notification/services/socket_services.dart';
import '../notification/services/helper_services.dart';

// Import the FitbitCallbackNotification from main.dart
import 'package:client/main.dart';

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
      if (!_isWatchConnected) {
        // Show the watch connection drawer after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _showWatchConnectionDrawer();
        });
      } else {
        // Watch is connected, fetch health data
        fetchHealthData();
      }
    });
    
    // Check if there's a pending Fitbit callback URI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingFitbitUri != null) {
        handleFitbitOAuthCallback(pendingFitbitUri!);
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

  /// **Check if watch is connected**
  Future<void> _checkWatchConnection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isWatchConnected = prefs.getBool('watch_connected') ?? false;
      _connectedWatchType = prefs.getString('watch_type') ?? '';
    });

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
    setState(() {
      _isWatchConnected = true;
      _connectedWatchType = watchType;
    });

    // If manual entry is selected, update health data with manual values
    // and don't fetch any additional data
    if (watchType == 'Manual') {
      _updateHealthDataFromManualEntry();
    } else {
      // Only fetch data for non-manual entry types
      fetchHealthData();
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
    
    print("✅ Manual entry data saved to cache");
  }

  /// **Show Watch Connection Drawer**
  void _showWatchConnectionDrawer() {
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
            builder: (context, setState) {
              return _buildWatchConnectionDrawer(context);
            },
          ),
        );
      },
    );

    // Start the animation
    _animationController.forward();
  }

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

  /// **Request Health Permissions**
  Future<void> requestHealthPermissions() async {
    var status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      print("✅ Health permissions granted");
      fetchHealthData();
    } else {
      print("❌ Health permissions denied.");
      // If permissions denied, still show zeros instead of error
      // No need to do anything as healthData is already initialized with zeros
    }
  }

  /// **Fetch Health Data**
  Future<void> fetchHealthData() async {
    if (health == null) return;

    setState(() {
      _isLoadingData = true;
    });

    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ];

    try {
      bool requested = await health!.requestAuthorization(types);

      if (requested) {
        try {
          List<HealthDataPoint> data = await health!.getHealthDataFromTypes(
            types: types,
            startTime: DateTime.now().subtract(const Duration(days: 1)),
            endTime: DateTime.now(),
          );

          Map<String, dynamic> parsedData = {
            // Initialize with zeros for all metrics
            'HEART_RATE': '0 BPM',
            'STEPS': '0 steps',
            'ACTIVE_ENERGY_BURNED': '0 kcal',
            'SLEEP_ASLEEP': '0 min',
            'BLOOD_PRESSURE_SYSTOLIC': '0 mmHg',
            'BLOOD_PRESSURE_DIASTOLIC': '0 mmHg',
          };

          // Only update values that are actually present in the data
          for (var point in data) {
            parsedData[point.typeString] = "${point.value} ${point.unit}";
            print("🩺 ${point.typeString}: ${point.value} ${point.unit}");
          }

          setState(() {
            healthData = parsedData;
            _isLoadingData = false;
          });
        } catch (e) {
          print("❌ Error fetching health data: $e");
          // No need to update healthData as it's already initialized with zeros
          setState(() {
            _isLoadingData = false;
          });
        }
      } else {
        print("❌ Authorization not granted.");
        // No need to update healthData as it's already initialized with zeros
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print("❌ Error requesting health permissions: $e");
      // No need to update healthData as it's already initialized with zeros
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  /// **Fetch Data from API**
  Future<void> fetchDataFromApi() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Example API call - replace with your actual API endpoints
      final response = await http.get(Uri.parse('$_baseUrl/health-data'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update health data with API response
        setState(() {
          // Parse API data and update healthData
          // This is just an example - adjust according to your API response structure
          if (data['heartRate'] != null) {
            healthData['HEART_RATE'] = '${data['heartRate']} BPM';
          }
          if (data['steps'] != null) {
            healthData['STEPS'] = '${data['steps']} steps';
          }
          if (data['calories'] != null) {
            healthData['ACTIVE_ENERGY_BURNED'] = '${data['calories']} kcal';
          }
          if (data['sleep'] != null) {
            healthData['SLEEP_ASLEEP'] = '${data['sleep']} min';
          }

          _isLoadingData = false;
        });
      } else {
        print('❌ Failed to load data: ${response.statusCode}');
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching data from API: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  /// **Initiate Fitbit OAuth**
  Future<void> _initiateFitbitOAuth(BuildContext bottomSheetContext) async {
    // First close the bottom sheet to avoid context issues
    Navigator.pop(bottomSheetContext);
    
    // Now show loading overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });

    try {
      setState(() {
        _isConnectingFitbit = true;
      });

      // Get the access token - replace this with your actual token retrieval logic
      final String accessToken = await _getAccessToken();
    
      // Make API request to get the authorization URL
      final response = await http.get(
        Uri.parse('$_baseUrl/api/connect/fitbit/authorize'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get Fitbit authorization URL: ${response.statusCode}');
      }

      // Parse the response
      final data = json.decode(response.body);
    
      if (!data['success']) {
        throw Exception('API returned error: ${data['message']}');
      }
    
      // Get the authorization URL from the response
      final String authUrl = data['authUrl'];
    
      // Store the access token in SharedPreferences for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fitbit_access_token', accessToken);
    
      print('Launching Fitbit auth URL from API: $authUrl');

      // Close loading overlay before launching URL
      Navigator.of(context, rootNavigator: true).pop();

      // Launch the authorization URL
      final Uri fitbitAuthUri = Uri.parse(authUrl);
    
      // Try multiple approaches to launch the URL
      bool launched = false;
    
      // First try: Launch in external application
      try {
        launched = await launchUrl(
          fitbitAuthUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('Failed to launch URL in external app: $e');
      }
    
      // Second try: Launch in external non-browser app
      if (!launched) {
        try {
          launched = await launchUrl(
            fitbitAuthUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        } catch (e) {
          print('Failed to launch URL in external non-browser app: $e');
        }
      }
    
      // Third try: Launch in platform default browser
      if (!launched) {
        try {
          launched = await launchUrl(
            fitbitAuthUri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          print('Failed to launch URL in platform default: $e');
        }
      }
    
      // Fourth try: Launch in in-app webview
      if (!launched) {
        try {
          launched = await launchUrl(
            fitbitAuthUri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        } catch (e) {
          print('Failed to launch URL in in-app webview: $e');
        }
      }

      if (!launched) {
        // Show a dialog with the URL for the user to copy manually
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Cannot Open URL Automatically'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Please copy and open this URL in your browser:'),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      authUrl,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: authUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL copied to clipboard')),
                    );
                  },
                  child: Text('Copy URL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
        throw Exception('Could not launch Fitbit auth URL');
      }

      // The user will now be redirected to the authorization page
      // We'll need to handle the redirect back to our app via AppLinks
      // which is set up in the main.dart file
    } catch (e) {
      // Reset loading state
      setState(() {
        _isConnectingFitbit = false;
      });

      // Close loading overlay if it's still showing
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Error connecting to Fitbit: $e');
    
      // Show error message using a dialog instead of SnackBar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Failed to connect to Fitbit: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  /// **Get Access Token**
  Future<String> _getAccessToken() async {
    // Implement your token retrieval logic here
    // This could be from secure storage, a provider, or another service
    
    // For example, from SharedPreferences:
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null || token.isEmpty) {
      // For testing purposes, return a dummy token
      // In production, you should throw an exception or handle this case properly
      return 'dummy_token';
    }
    
    return token;
  }

  // Handle Fitbit OAuth callback
  void handleFitbitOAuthCallback(Uri uri) {
    print('HomeScreen handling Fitbit OAuth callback: $uri');
    
    // Extract the authorization code
    final code = uri.queryParameters['code'];
    if (code == null) {
      print('❌ No authorization code found in callback URI');
      return;
    }
    
    // Call the callback endpoint to complete the OAuth flow
    _completeFitbitOAuth(code);
  }

  // Complete the Fitbit OAuth flow
  Future<void> _completeFitbitOAuth(String code) async {
    // Show loading overlay
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
  
    try {
      setState(() {
        _isConnectingFitbit = true;
      });
    
      // Get the access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('fitbit_access_token') ?? await _getAccessToken();
    
      // Make the API request to complete the OAuth flow
      final response = await http.post(
        Uri.parse('$_baseUrl/api/connect/fitbit/callback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'code': code,
          // No userId needed, we're passing the access token instead
        }),
      );
    
      // Close loading overlay
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
      
        if (data['success'] == true) {
          // Set watch as connected
          await _setWatchConnected('Fitbit');
        
          // Show success message using a dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text(data['message'] ?? 'Successfully connected Fitbit'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        
          // Fetch health data
          fetchHealthData();
        } else {
          throw Exception(data['message'] ?? 'Failed to complete Fitbit connection');
        }
      } else {
        throw Exception('Failed to complete Fitbit connection: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error completing Fitbit OAuth: $e');
    
      // Show error message using a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Failed to complete Fitbit connection: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isConnectingFitbit = false;
      });
    }
  }

  // Listen for Fitbit callback notifications
  @override
  Widget build(BuildContext context) {
    return NotificationListener<FitbitCallbackNotification>(
      onNotification: (notification) {
        // Process the Fitbit callback
        handleFitbitOAuthCallback(notification.uri);
        return true; // Stop notification propagation
      },
      child: Scaffold(
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
          onPressed: () {},
          backgroundColor: const Color(0xFF2563EB),
          child: Icon(
            _connectedWatchType == 'Manual' ? Icons.camera : Icons.refresh,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
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

  /// **Build Watch Connection Drawer**
  Widget _buildWatchConnectionDrawer(BuildContext bottomSheetContext) {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _drawerAnimation.value) * 200),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6, // Reduced height
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

                // Header with illustration
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      // Illustration
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFEBF5FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.watch,
                              size: 24.sp,
                              color: Color(0xFF0F67FE),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Title and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connect Your Device',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Choose how you want to track your health',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Connection options
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Fitbit option
                        _buildConnectionOption(
                          title: 'Connect Fitbit',
                          description:
                              'Sync data automatically from your Fitbit device',
                          icon: Icons.watch,
                          color: Color(0xFF00B0B9),
                          isLoading: _isConnectingFitbit,
                          onTap: _isConnectingFitbit 
                              ? null 
                              : () => _initiateFitbitOAuth(bottomSheetContext),
                        ),

                        SizedBox(height: 12.h),

                        // Manual entry option
                        _buildConnectionOption(
                          title: 'Manual Entry',
                          description: 'Enter your health metrics manually',
                          icon: Icons.edit,
                          color: Color(0xFFFF6700),
                          isLoading: false,
                          onTap: () {
                            // Set default values for manual entry
                            setState(() {
                              _manualEntryData = {
                                'steps': 0,
                                'heartRate': 0,
                                'calories': 0,
                                'sleepHours': 0,
                              };
                            });
                            
                            // Save to shared preferences (cache)
                            _saveManualEntryData();
                            
                            // Set as connected with manual entry
                            _setWatchConnected('Manual');
                            
                            // Close drawer
                            Navigator.pop(bottomSheetContext);
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Manual tracking enabled with default values'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Note at the bottom
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Center(
                    child: Text(
                      'You need to select an option to continue',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// **Build Connection Option**
  Widget _buildConnectionOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback? onTap,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child:
                      isLoading
                          ? Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                              ),
                            ),
                          )
                          : Icon(icon, color: color, size: 20.sp),
                ),

                SizedBox(width: 12.w),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon or loading indicator
                isLoading
                    ? Container(width: 14.w) // Placeholder for spacing
                    : Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF64748B),
                      size: 14.sp,
                    ),
              ],
            ),
          ),
        ),
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
