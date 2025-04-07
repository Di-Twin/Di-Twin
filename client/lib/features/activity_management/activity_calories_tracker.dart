import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/widgets/ActivityHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCaloriesTracker extends StatefulWidget {
  const ActivityCaloriesTracker({super.key});

  @override
  State<ActivityCaloriesTracker> createState() => _ActivityCaloriesTrackerState();
}

class _ActivityCaloriesTrackerState extends State<ActivityCaloriesTracker> {
  List<dynamic> activities = [];
  bool isLoading = true;
  double totalCaloriesBurned = 0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startTimeoutTimer();
    fetchActivities();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
          // Set default values after timeout
          totalCaloriesBurned = 1542; // Default value from original UI
          // activities = _getDefaultActivities(); // Default activities
          // Cancel the timer to prevent it from running again
        });
      }
    });
  }

  List<dynamic> _getDefaultActivities() {
    return [
      {
        'activity_type': 'cardio workout',
        'calories_burned': 154.0,
      },
      {
        'activity_type': 'hiking',
        'calories_burned': 854.0,
      },
      {
        'activity_type': 'biking',
        'calories_burned': 224.0,
      },
      {
        'activity_type': 'cardio workout',
        'calories_burned': 154.0,
      },
      {
        'activity_type': 'hiking',
        'calories_burned': 156.0,
      },
    ];
  }

  Future<void> fetchActivities() async {
    try {
      final String date = DateTime.now().toString().split(' ')[0];
      final Uri url = Uri.parse('/api/activity/top-activities/$date?all=true');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyNzEzNzA0Zi0wZTk2LTQxY2ItYjhlNC04NDMwOTVlMjg5MDMiLCJlbWFpbCI6bnVsbCwiaWF0IjoxNzQ0MDIwMDU1LCJleHAiOjE3NDQwMjM2NTV9.YKwd2fTkMrETa7QePt3eZ9H82XF3cv6ORUhOXc-gw9Y',
          'Content-Type': 'application/json',
        },
      );

      // Cancel the timeout timer if we get a response
      _timeoutTimer?.cancel();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          setState(() {
            activities = responseData['data'];
            // Calculate total calories burned
            totalCaloriesBurned = activities.fold(0, (sum, activity) => 
                sum + (activity['calories_burned'] as double));
            isLoading = false;
          });
        } else {
          _setDefaultValues();
        }
      } else {
        _setDefaultValues();
      }
    } catch (e) {
      _setDefaultValues();
      print('Error fetching activities: $e');
    }
  }

  void _setDefaultValues() {
    setState(() {
      isLoading = false;
      totalCaloriesBurned = 1542; // Default value
      // activities = _getDefaultActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: isLoading 
          ? _buildLoader()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    ActivityHeader(
                      name: 'Calories',
                      onTrack: 'On Track',
                      onBackPressed: () {
                        // Handle back button press
                      }
                    ),
                    SizedBox(height: 24.h),
                    _buildCaloriesSummary(),
                    SizedBox(height: 24.h),
                    _buildCaloriesChart(),
                    SizedBox(height: 8.h),
                    _buildChartLegend(),
                    SizedBox(height: 24.h),
                    _buildActivitiesSection(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading activities...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today, you just burned',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalCaloriesBurned.toStringAsFixed(0),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'kcal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesChart() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Target section
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E4F5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            // Taken section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A5F),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            // Burned section
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(const Color(0xFFD9E4F5), 'Target'),
          _buildLegendItem(const Color(0xFFFF5A5F), 'Taken'),
          _buildLegendItem(const Color(0xFF0066FF), 'Burned'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildActivitiesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.r),
          ),
        ),
        color: Colors.white,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 200.h, // Set a minimum height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Activities',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: activities.isEmpty 
                  ? Center(
                      child: Text(
                        "No activities found",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Column(
                      children: activities.map((activity) {
                        return Column(
                          children: [
                            _buildActivityItem(
                              iconData: _getIconForActivityType(activity['activity_type']),
                              title: _capitalizeActivityType(activity['activity_type']),
                              calories: activity['calories_burned'].toInt(),
                              color: _getColorForActivityType(activity['activity_type']),
                            ),
                            SizedBox(height: 12.h),
                          ],
                        );
                      }).toList(),
                    ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  IconData _getIconForActivityType(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return FontAwesomeIcons.personRunning;
      case 'cycling':
      case 'bike':
        return FontAwesomeIcons.bicycle;
      case 'strength training':
        return FontAwesomeIcons.dumbbell;
      case 'hiking':
        return FontAwesomeIcons.personHiking;
      case 'cardio workout':
        return FontAwesomeIcons.heartPulse;
      default:
        return FontAwesomeIcons.heartPulse;
    }
  }

  Color _getColorForActivityType(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return const Color(0xFFE6DBFF);
      case 'cycling':
      case 'bike':
        return const Color(0xFFFFE4E4);
      case 'strength training':
        return const Color(0xFFD9E4F5);
      case 'hiking':
        return const Color(0xFFD9E4F5);
      case 'cardio workout':
        return const Color(0xFFE6DBFF);
      default:
        return const Color(0xFFE6DBFF);
    }
  }

  String _capitalizeActivityType(String activityType) {
    return activityType.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }

  Widget _buildActivityItem({
    required IconData iconData,
    required String title,
    required int calories,
    required Color color,
  }) {
    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: FaIcon(
                iconData,
                size: 20.sp,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$calories Calories Burned',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}