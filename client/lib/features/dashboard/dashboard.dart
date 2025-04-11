import 'package:flutter/material.dart';
import 'package:health/health.dart'; // Import Health package
import 'package:permission_handler/permission_handler.dart';
import 'package:client/widgets/dashboard/app_header.dart';
import 'package:client/widgets/dashboard/health_score_card.dart';
import 'package:client/widgets/dashboard/health_metrics_section.dart';
import 'package:client/widgets/dashboard/fitness_tracker_section.dart';
import 'package:client/widgets/dashboard/medication_section.dart';
import 'package:client/widgets/dashboard/bottom_navigation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Health? health; // Changed from HealthFactory to Health
  Map<String, dynamic> healthData = {}; // Store fetched health data
  bool _isFirstLaunch = true;
  late AnimationController _animationController;
  late Animation<double> _drawerAnimation;
  int? healthScore;

  @override
  void initState() {
    super.initState();
    health = Health(); // Changed from HealthFactory() to Health()

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _drawerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // Check if this is the first launch
    _checkFirstLaunch().then((_) {
      if (_isFirstLaunch) {
        // Show the watch connection drawer after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _showWatchConnectionDrawer();
        });
      } else {
        // If not first launch, request health permissions directly
        requestHealthPermissions();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// **Check if this is the first launch**
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstLaunch = prefs.getBool('first_launch') ?? true;
    });
  }

  /// **Mark first launch as completed**
  Future<void> _setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
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
        return StatefulBuilder(
          builder: (context, setState) {
            return _buildWatchConnectionDrawer();
          },
        );
      },
    );

    // Start the animation
    _animationController.forward();
  }

  /// **Request Health Permissions**
  Future<void> requestHealthPermissions() async {
    var status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      print("✅ Health permissions granted");
      fetchHealthData();
    } else {
      print("❌ Health permissions denied.");
    }
  }

  /// **Fetch Health Data**
  Future<void> fetchHealthData() async {
    if (health == null) return;

    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ];

    bool requested = await health!.requestAuthorization(types);

    if (requested) {
      try {
        // Using named parameters instead of positional parameters
        List<HealthDataPoint> data = await health!.getHealthDataFromTypes(
          types: types,
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now(),
        );

        Map<String, dynamic> parsedData = {};
        for (var point in data) {
          parsedData[point.typeString] = "${point.value} ${point.unit}";
          print("🩺 ${point.typeString}: ${point.value} ${point.unit}");
        }

        setState(() {
          healthData = parsedData;
        });
      } catch (e) {
        print("❌ Error fetching health data: $e");
      }
    } else {
      print("❌ Authorization not granted.");
    }
  }

  /// **Connect Watch and Continue**
  void _connectWatchAndContinue(String watchType) async {
    // Close the drawer
    Navigator.pop(context);

    // Mark first launch as completed
    await _setFirstLaunchCompleted();

    // Request health permissions
    requestHealthPermissions();

    // Show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to $watchType...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void updateHealthScore(int score) {
    setState(() {
      healthScore = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SafeArea(
                child: AppHeader(), // Prevents merging with the status bar
              ),
            ),
          ];
        },
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 20),
            HealthScoreCard(onScoreUpdated: updateHealthScore), // Removed trailing comma
            const SizedBox(height: 20),
            const HealthMetricsSection(),
            const SizedBox(height: 20),
            const FitnessTrackerSection(),
            const SizedBox(height: 20),
            // Uncomment if you want to use MedicationSection
            // const MedicationSection(),
            // const SizedBox(height: 20),
          ],
        ),
      ),

      /// **Bottom Navigation Bar**
      bottomNavigationBar: const BottomNavigation(),

      /// **Custom Floating Action Button for Refreshing Data**
      floatingActionButton: FloatingActionButton(
        onPressed: fetchHealthData,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// **Build Watch Connection Drawer**
  Widget _buildWatchConnectionDrawer() {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _drawerAnimation.value) * 200),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
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
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Header with illustration
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Animated illustration
                      Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFEBF5FF),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle pulse animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 160.w,
                                    height: 160.w,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD0E4FF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                              child: Container(),
                            ),

                            // Inner circle with watch icon
                            Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.watch,
                                size: 60.sp,
                                color: Color(0xFF0F67FE),
                              ),
                            ),

                            // Decorative elements
                            Positioned(
                              top: 40.h,
                              right: 50.w,
                              child: Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0F67FE).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 60.h,
                              left: 40.w,
                              child: Container(
                                width: 15.w,
                                height: 15.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0F67FE).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        'Connect Your Watch',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12.h),

                      // Description
                      Text(
                        'Track your health metrics automatically by connecting your fitness watch or health app',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Watch options
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.r),
                  child: Text(
                    'Select your device',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Watch company options
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.r),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildWatchOption(
                          name: 'Fitbit',
                          icon: Icons.watch,
                          color: Color(0xFF00B0B9),
                          onTap: () => _connectWatchAndContinue('Fitbit'),
                        ),
                        SizedBox(height: 16.h),
                        _buildWatchOption(
                          name: 'Garmin',
                          icon: Icons.watch_outlined,
                          color: Color(0xFF006CFF),
                          onTap: () => _connectWatchAndContinue('Garmin'),
                        ),
                        SizedBox(height: 16.h),
                        _buildWatchOption(
                          name: 'Google Health Connect',
                          icon: Icons.health_and_safety,
                          color: Color(0xFF34A853),
                          onTap: () => _connectWatchAndContinue('Google Health Connect'),
                        ),
                        SizedBox(height: 16.h),
                        _buildWatchOption(
                          name: 'Apple Health',
                          icon: Icons.favorite,
                          color: Color(0xFFFF2D55),
                          onTap: () => _connectWatchAndContinue('Apple Health'),
                        ),
                        SizedBox(height: 16.h),
                        _buildWatchOption(
                          name: 'Samsung Health',
                          icon: Icons.monitor_heart,
                          color: Color(0xFF1428A0),
                          onTap: () => _connectWatchAndContinue('Samsung Health'),
                        ),
                        SizedBox(height: 16.h),
                        _buildWatchOption(
                          name: 'Mi Fit',
                          icon: Icons.fitness_center,
                          color: Color(0xFFFF6700),
                          onTap: () => _connectWatchAndContinue('Mi Fit'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue without connecting button
                Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () => _connectWatchAndContinue('Manual Tracking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F67FE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _setFirstLaunchCompleted();
                        },
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// **Build Watch Option Item**
  Widget _buildWatchOption({
    required String name,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),

                SizedBox(width: 16.w),

                // Watch name
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF64748B),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}