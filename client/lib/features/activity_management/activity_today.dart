import 'dart:convert';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math' show max, pow;

// API Service for fetching activity data
class ActivityService {
  static const String baseUrl = 'http://192.168.11.196:6000/'; 
  
  static Future<List<Map<String, dynamic>>> fetchTopActivities(DateTime date) async {
    try {
      // Format the date as YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-M-d').format(date);
      
      // Get the access token from secure storage or state management solution
      final accessToken = await _getAccessToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/activity/top-activities/$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return _transformActivities(responseData['data']);
        } else {
          throw Exception('Failed to load activities: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching activities: $e');
    }
  }
  
  // Transform API data to the format used by UI
  static List<Map<String, dynamic>> _transformActivities(List<dynamic> apiActivities) {
    final List<Map<String, dynamic>> transformedActivities = [];
    
    // Define icon and color mappings for different activity types
    final Map<String, IconData> activityIcons = {
      'running': FontAwesomeIcons.personRunning,
      'cycling': FontAwesomeIcons.bicycle,
      'walking': FontAwesomeIcons.personWalking,
      'swimming': FontAwesomeIcons.personSwimming,
      'yoga': Icons.spa,
      'weightlifting': FontAwesomeIcons.dumbbell,
      // Add more mappings as needed
    };
    
    final Map<String, Color> activityColors = {
      'running': Colors.redAccent,
      'cycling': const Color(0xFF0066FF),
      'walking': const Color(0xFF1E293B),
      'swimming': Colors.blueAccent,
      'yoga': Colors.purpleAccent,
      'weightlifting': Colors.orangeAccent,
      // Add more mappings as needed
    };
    
    for (var activity in apiActivities) {
      // Convert seconds to minutes for display
      final int durationMinutes = (activity['duration_seconds'] / 60).round();
      
      transformedActivities.add({
        'minutes': durationMinutes.toString(),
        'label': _capitalizeFirstLetter(activity['activity_type']),
        'color': activityColors[activity['activity_type']] ?? Colors.grey,
        'icon': activityIcons[activity['activity_type']] ?? Icons.fitness_center,
        'id': activity['id'],
        'calories': activity['calories_burned'],
        'distance': activity['distance_meters'],
        'heart_rate_avg': activity['heart_rate_avg'],
      });
    }
    
    return transformedActivities;
  }
  
  // Helper function to capitalize first letter of activity type
  static String _capitalizeFirstLetter(String text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }
  
  // Get access token from secure storage or state management
  static Future<String> _getAccessToken() async {
    // Replace this with your actual method to retrieve the stored access token
    // For example, using Flutter Secure Storage or a state management solution
    
    // Placeholder implementation
    return 'YOUR_ACCESS_TOKEN'; // dart(TODO:) Replace with actual token retrieval logic
  }
}

class ActivityToday extends StatefulWidget {
  const ActivityToday({super.key});

  @override
  _ActivityTodayState createState() => _ActivityTodayState();
}

class _ActivityTodayState extends State<ActivityToday> {
  double x = 165;
  double y = 275;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _topActivities = [];
  String _errorMessage = '';
  int _totalActivities = 0;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch today's activities or use a specific date
      final activities = await ActivityService.fetchTopActivities(DateTime.now());
      
      setState(() {
        _topActivities = activities;
        _totalActivities = activities.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load activities: $e';
        _isLoading = false;
        
        // Fallback to dummy data for testing
        _topActivities = [
          {
            'minutes': '60',
            'label': 'Cycling',
            'color': const Color(0xFF0066FF),
            'icon': FontAwesomeIcons.bicycle,
          },
          {
            'minutes': '30',
            'label': 'Running',
            'color': Colors.redAccent,
            'icon': FontAwesomeIcons.personRunning,
          },
        ];
        _totalActivities = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: _buildHeader(constraints),
                  ),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator()),
                  if (!_isLoading && _errorMessage.isNotEmpty)
                    Center(child: _buildErrorMessage()),
                  if (!_isLoading && _errorMessage.isEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildMostminutesSection(_topActivities, constraints),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchActivities,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh activities',
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            _errorMessage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _fetchActivities,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BoxConstraints constrains) {
    return SizedBox(
      height: constrains.maxHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomActivityHeader(
            title: 'Activities',
            badgeText: 'Normal',
            score: _totalActivities.toString(),
            subtitle: 'Activities Today.',
            buttonImage: 'images/SignInAddIcon.png',
            onButtonTap: () {},
            backgroundColor: Color(0xFFD0E4FF),
            backgroundImagePath: 'images/activity_header_background.png',
            buttonColor: Color(0xFF242E49),
            buttonShadowColor: Color(0xFF242E49),
            titleTextColor: Color(0xFF242E49),
            scoreTextColor: Color(0xFF242E49),
            subtitleTextColor: Color(0xFF242E49),
            backButtonBorderColor: Color(0xFF242E49),
            badgeBackgroundColor: Color(0xFF0F67FE),
            badgeTextColor: Color(0xFF0F67FE),
          ),
        ],
      ),
    );
  }

  Widget _buildMostminutesSection(List<Map<String, dynamic>> activityData, constraints) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.06;
    final double barWidth = screenSize.width * 0.24;
    
    double sectionHeightRatio;
    
    bool isTablet = screenSize.width > 600;
    bool isLandscape = screenSize.width > screenSize.height;
    
    if (isTablet) {
      sectionHeightRatio = isLandscape ? 0.38 : 0.45;
    } else {
      sectionHeightRatio = isLandscape ? 0.32 : 0.42;
    }
    
    if (screenSize.height < 600) {
      sectionHeightRatio *= 0.85;
    } else if (screenSize.height > 1200) {
      sectionHeightRatio *= 1.1;
    }

    double maxminutesValue = 0;
    for (var activity in activityData) {
      double minutes = double.parse(activity['minutes'].toString());
      if (minutes > maxminutesValue) {
        maxminutesValue = minutes;
      }
    }
    
    // If there's no data, show a message
    if (activityData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32.h),
        child: Center(
          child: Text(
            'No activities recorded for today',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              'Most minutes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: constraints.maxHeight * sectionHeightRatio,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  activityData.length,
                  (index) => SizedBox(
                    width: barWidth,
                    child: _buildActivityBar(
                      minutes: activityData[index]['minutes'] as String,
                      label: activityData[index]['label'] as String,
                      color: activityData[index]['color'] as Color,
                      icon: activityData[index]['icon'] as IconData,
                      index: index,
                      maxminutes: maxminutesValue,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
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
    double maxBarHeight = 400.h;
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
                child: Container(
                  height: coloredBarHeight,
                  color: color,
                ),
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
                      color: (minutesValue > 0 && coloredBarHeight > 80.h) ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: (minutesValue > 0 && coloredBarHeight > 80.h) ? Colors.white : Colors.grey[600],
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