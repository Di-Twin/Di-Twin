import 'package:client/features/activity_management/activity_my_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';

class ActivityToday extends StatefulWidget {
  const ActivityToday({super.key});

  @override
  _ActivityTodayState createState() => _ActivityTodayState();
}

class _ActivityTodayState extends State<ActivityToday> {
  double x = 165;
  double y = 275;
  bool isWatchConnected = true; // Track if watch is connected
  bool isManualEntryOpen = false; // Track if manual entry drawer is open
  int currentStep = 0; // 0 for activity selection, 1 for duration entry
  String? selectedActivityType;
  int activityDuration = 30; // Default duration in minutes

  List<Map<String, dynamic>> allActivities = [
    {
      'minutes': '130',
      'label': 'Jogging',
      'color': const Color(0xFF1E293B),
      'icon': FontAwesomeIcons.personRunning,
    },
    {
      'minutes': '100',
      'label': 'Yoga',
      'color': const Color(0xFF0066FF),
      'icon': Icons.spa,
    },
    {
      'minutes': '200',
      'label': 'Biking',
      'color': Colors.redAccent,
      'icon': FontAwesomeIcons.bicycle,
    },
  ];

  // Available activity types for manual entry
  final List<Map<String, dynamic>> activityTypes = [
    {
      'label': 'Jogging',
      'icon': FontAwesomeIcons.personRunning,
      'color': const Color(0xFF1E293B),
    },
    {
      'label': 'Running',
      'icon': FontAwesomeIcons.personRunning,
      'color': const Color(0xFF0066FF),
    },
    {
      'label': 'Walking',
      'icon': FontAwesomeIcons.personWalking,
      'color': const Color(0xFF4CAF50),
    },
    {
      'label': 'Outdoor Sport',
      'icon': FontAwesomeIcons.baseball,
      'color': const Color(0xFFFF9800),
    },
    {
      'label': 'Elliptical',
      'icon': FontAwesomeIcons.personWalking,
      'color': const Color(0xFF9C27B0),
    },
    {
      'label': 'Strength Training',
      'icon': FontAwesomeIcons.dumbbell,
      'color': const Color(0xFF795548),
    },
    {
      'label': 'Treadmill',
      'icon': FontAwesomeIcons.personRunning,
      'color': const Color(0xFF607D8B),
    },
    {
      'label': 'Cycling',
      'icon': FontAwesomeIcons.bicycle,
      'color': const Color(0xFFE91E63),
    },
    {
      'label': 'Bike',
      'icon': FontAwesomeIcons.bicycle,
      'color': const Color(0xFF3F51B5),
    },
    {
      'label': 'Swimming',
      'icon': FontAwesomeIcons.personSwimming,
      'color': const Color(0xFF00BCD4),
    },
    {
      'label': 'Boxing',
      'icon': FontAwesomeIcons.handFist,
      'color': const Color(0xFFFF5722),
    },
    {
      'label': 'Skipping',
      'icon': FontAwesomeIcons.arrowDown,
      'color': const Color(0xFF8BC34A),
    },
    {
      'label': 'Table Tennis',
      'icon': FontAwesomeIcons.tableTennisPaddleBall,
      'color': const Color(0xFF673AB7),
    },
    {
      'label': 'Badminton',
      'icon': FontAwesomeIcons.locationArrow,
      'color': const Color(0xFFCDDC39),
    },
    {'label': 'Yoga', 'icon': Icons.spa, 'color': const Color(0xFF009688)},
    {
      'label': 'Skating',
      'icon': FontAwesomeIcons.personSkating,
      'color': const Color(0xFF2196F3),
    },
  ];

  List<Map<String, dynamic>> getTopActivities() {
    if (allActivities.isEmpty) {
      return [];
    }

    final sortedActivities = List<Map<String, dynamic>>.from(allActivities);

    sortedActivities.sort(
      (a, b) => double.parse(
        b['minutes'].toString(),
      ).compareTo(double.parse(a['minutes'].toString())),
    );

    return sortedActivities.take(3).toList();
  }

  void _navigateToMyActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MyActivitiesScreen(userJoinDate: DateTime(2025, 4, 1)),
      ),
    );
  }

  void _openManualEntryDrawer() {
    setState(() {
      isManualEntryOpen = true;
      currentStep = 0;
      selectedActivityType = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // Allow dismissing by tapping outside
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return GestureDetector(
                // Prevent taps from closing the modal when tapping inside it
                onTap: () {},
                child: _buildManualEntryDrawer(setModalState),
              );
            },
          ),
    ).then((_) {
      // Force a rebuild when the modal is closed
      setState(() {
        isManualEntryOpen = false;
      });
    });
  }

  void _addActivity(StateSetter setModalState) {
    if (selectedActivityType != null && activityDuration > 0) {
      // Find the activity color and icon
      final activityData = activityTypes.firstWhere(
        (element) => element['label'] == selectedActivityType,
        orElse: () => activityTypes[0],
      );

      // Create the new activity
      final newActivity = {
        'minutes': activityDuration.toString(),
        'label': selectedActivityType!,
        'color': activityData['color'] as Color,
        'icon': activityData['icon'] as IconData,
      };

      // Add the activity to the list and update state
      setState(() {
        allActivities.add(newActivity);
      });

      // Close the drawer
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$selectedActivityType added for $activityDuration minutes',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topActivities = getTopActivities();

    // Fixed header height
    final double headerHeight = 370.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard appears
      body: Column(
        children: [
          // Static header section with fixed height
          SizedBox(
            height: headerHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomActivityHeader(
                  title: 'Activities',
                  badgeText: isWatchConnected ? 'Normal' : 'Disconnected',
                  score: isWatchConnected ? '16' : '0',
                  subtitle: 'Activities Today.',
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: _navigateToMyActivities,
                  backgroundColor: Color(0xFFD0E4FF),
                  backgroundImagePath: 'images/activity_header_background.png',
                  buttonColor: Color(0xFF242E49),
                  buttonShadowColor: Color(0xFF242E49),
                  titleTextColor: Color(0xFF242E49),
                  scoreTextColor: Color(0xFF242E49),
                  subtitleTextColor: Color(0xFF242E49),
                  backButtonBorderColor: Color(0xFF242E49),
                  badgeBackgroundColor:
                      isWatchConnected
                          ? Color(0xFF0F67FE)
                          : Color(0xFFFF5252).withOpacity(0.1),
                  badgeTextColor:
                      isWatchConnected ? Color(0xFF0F67FE) : Color(0xFFFF5252),
                  backButtonBorderWidth: 1.0,
                  bottomLeftRadius: 30,
                  bottomRightRadius: 30,
                  buttonShadowSpread: 4,
                  headerHeight: headerHeight,
                  showBadge: true,
                  showMenu: false,
                ),
              ],
            ),
          ),

          // Add padding to prevent overlap with header
          SizedBox(height: 40.h),

          // Content area - either activity charts or empty state
          Expanded(
            child:
                isWatchConnected
                    ? _buildActivityContent(topActivities)
                    : SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: _buildEmptyState(),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent(List<Map<String, dynamic>> topActivities) {
    // Check if there are activities to display
    if (topActivities.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated container with gradient background
            Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFFE6F0FF), Color(0xFFD0E4FF)],
                  radius: 0.8,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0F67FE).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative circles
                  Positioned(
                    top: 30.h,
                    right: 40.w,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Color(0xFF0F67FE).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50.h,
                    left: 35.w,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: Color(0xFF0F67FE).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Center icon with shadow
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.directions_run,
                      size: 50.sp,
                      color: Color(0xFF0F67FE),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'No activities yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Start tracking your fitness journey by adding your first activity',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E293B).withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            // Improved button with gradient and animation
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0F67FE).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openManualEntryDrawer,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Your First Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If there are activities, display an enhanced chart
    return Column(
      children: [
        // Bottom section with title and button moved to the top
        Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            16.h,
            24.w,
            16.h,
          ), // Changed from (24.w, 0, 24.w, 16.h)
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title "Most Minutes"
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Color(0xFF0F67FE),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Most Minutes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              // Add Manually button
              GestureDetector(
                onTap: _openManualEntryDrawer,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0F67FE).withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Add Manually',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8.h), // Changed from 16.h
        // Activity bars section - with increased height
        Container(
          height: 300.h, // Increased from 220.h
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              topActivities.length,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _buildEnhancedActivityBar(
                    minutes: topActivities[index]['minutes'] as String,
                    label: topActivities[index]['label'] as String,
                    color: topActivities[index]['color'] as Color,
                    icon: topActivities[index]['icon'] as IconData,
                    index: index,
                    maxminutes: topActivities
                        .map((e) => double.parse(e['minutes'].toString()))
                        .reduce((a, b) => a > b ? a : b),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Add this new enhanced activity bar method
  Widget _buildEnhancedActivityBar({
    required String minutes,
    required String label,
    required Color color,
    required IconData icon,
    required int index,
    required double maxminutes,
  }) {
    double minutesValue = double.parse(minutes);
    double maxBarHeight = 300.h; // Further reduced from 300.h to 200.h
    double coloredBarHeight;

    if (minutesValue <= 0) {
      coloredBarHeight = 0;
    } else {
      double ratio = minutesValue / maxminutes;
      coloredBarHeight = maxBarHeight * ratio;
    }

    return Container(
      height: maxBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background pattern for visual interest
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/pattern.png'),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Colored bar with gradient
          if (minutesValue > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: coloredBarHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.white, 0.3)!],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                // Add subtle pattern overlay
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/pattern.png'),
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Minutes and label text
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    minutes,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          (minutesValue > 0 && coloredBarHeight > 80.h)
                              ? Colors.white
                              : Colors.grey[600],
                      shadows:
                          (minutesValue > 0 && coloredBarHeight > 80.h)
                              ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          (minutesValue > 0 && coloredBarHeight > 80.h)
                              ? Colors.white
                              : Colors.grey[600],
                      shadows:
                          (minutesValue > 0 && coloredBarHeight > 80.h)
                              ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icon at the top with enhanced styling
          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.2), width: 2),
                ),
                child: Icon(icon, size: 18.sp, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated illustration container
          Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              color: Color(0xFFEEF6FF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFD0E4FF),
                    shape: BoxShape.circle,
                  ),
                ),
                // Inner circle with icon
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.watch_outlined,
                    size: 50.sp,
                    color: Color(0xFFFF5252),
                  ),
                ),
                // Small decorative circles
                Positioned(
                  top: 30.h,
                  right: 30.w,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF5252).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40.h,
                  left: 25.w,
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF5252).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Watch Not Connected',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'Connect your watch to automatically track your activities or add them manually.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E293B).withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          // Improved button with icon
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0F67FE).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openManualEntryDrawer,
                borderRadius: BorderRadius.circular(16.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Add Activity Manually',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryDrawer(StateSetter setModalState) {
    // Calculate the fixed height for the drawer (50% of screen height)
    final double drawerHeight = MediaQuery.of(context).size.height * 0.50;

    return Container(
      height: drawerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drawer handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          // Title
          Text(
            currentStep == 0 ? 'Select Activity Type' : 'Set Duration',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          // Stepper indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color:
                      currentStep >= 0 ? Color(0xFF0F67FE) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color:
                      currentStep >= 1 ? Color(0xFF0F67FE) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Content based on current step - this is the scrollable part
          Expanded(
            child:
                currentStep == 0
                    ? _buildActivityTypeSelection(setModalState)
                    : _buildDurationSelection(setModalState),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTypeSelection(StateSetter setModalState) {
    return Column(
      children: [
        // Scrollable activities grid
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: activityTypes.length,
                itemBuilder: (context, index) {
                  final activity = activityTypes[index];
                  final bool isSelected =
                      selectedActivityType == activity['label'];

                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        selectedActivityType = activity['label'] as String;
                        currentStep =
                            1; // Directly go to next step when activity is selected
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? (activity['color'] as Color).withOpacity(0.1)
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? activity['color'] as Color
                                  : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? activity['color'] as Color
                                      : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity['icon'] as IconData,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : activity['color'] as Color,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              activity['label'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? activity['color'] as Color
                                        : Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelection(StateSetter setModalState) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Use minimum space needed
      children: [
        // Activity info section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: activityTypes
                      .firstWhere(
                        (element) => element['label'] == selectedActivityType,
                        orElse: () => activityTypes[0],
                      )['color']
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activityTypes.firstWhere(
                        (element) => element['label'] == selectedActivityType,
                        orElse: () => activityTypes[0],
                      )['icon']
                      as IconData,
                  color:
                      activityTypes.firstWhere(
                            (element) =>
                                element['label'] == selectedActivityType,
                            orElse: () => activityTypes[0],
                          )['color']
                          as Color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  selectedActivityType ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  setModalState(() {
                    currentStep = 0;
                  });
                },
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F67FE),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),

        // Duration content - no longer in a scrollable container
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duration (minutes)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDurationButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (activityDuration > 5) {
                        setModalState(() {
                          activityDuration -= 5;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 24.w),
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      '$activityDuration',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 24.w),
                  _buildDurationButton(
                    icon: Icons.add,
                    onPressed: () {
                      setModalState(() {
                        activityDuration += 5;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Quick duration buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickDurationButton(15, setModalState),
                  _buildQuickDurationButton(30, setModalState),
                  _buildQuickDurationButton(45, setModalState),
                  _buildQuickDurationButton(60, setModalState),
                ],
              ),
            ],
          ),
        ),

        // Spacer to push buttons to the bottom
        Spacer(),

        // Fixed buttons at the bottom
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setModalState(() {
                      currentStep = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF0F67FE)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F67FE),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addActivity(setModalState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0F67FE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Add Activity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: Color(0xFF1E293B), size: 24.sp),
      ),
    );
  }

  Widget _buildQuickDurationButton(int minutes, StateSetter setModalState) {
    final bool isSelected = activityDuration == minutes;

    return InkWell(
      onTap: () {
        setModalState(() {
          activityDuration = minutes;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0F67FE) : Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '$minutes min',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityBar({
    required String minutes,
    required String label,
    required Color color,
    required IconData icon,
    required int index,
    required double maxminutes,
  }) {
    double minutesValue = double.parse(minutes);
    double maxBarHeight = 300.h; // Changed from 400.h to 200.h
    double coloredBarHeight;

    if (minutesValue <= 0) {
      coloredBarHeight = 0;
    } else {
      double ratio = minutesValue / maxminutes;
      coloredBarHeight = maxBarHeight * ratio;
    }

    return Container(
      height: maxBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (minutesValue > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(height: coloredBarHeight, color: color),
              ),
            ),

          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    minutes,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          (minutesValue > 0 && coloredBarHeight > 80.h)
                              ? Colors.white
                              : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          (minutesValue > 0 && coloredBarHeight > 80.h)
                              ? Colors.white
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 16.sp, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
