import 'package:client/features/activity_management/activity_my_stats.dart';
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
      final formattedDate = DateFormat('yyyy-M-d').format(date);
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

  static Future<int> fetchDailyActivityScore(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-M-d').format(date);
      final accessToken = await _getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/activity/daily-score/$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['activity_score'] as int;
        } else {
          throw Exception('Failed to load activity score: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load activity score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching activity score: $e');
    }
  }
  
  static List<Map<String, dynamic>> _transformActivities(List<dynamic> apiActivities) {
    final List<Map<String, dynamic>> transformedActivities = [];
    
    final Map<String, IconData> activityIcons = {
      'running': FontAwesomeIcons.personRunning,
      'cycling': FontAwesomeIcons.bicycle,
      'walking': FontAwesomeIcons.personWalking,
      'swimming': FontAwesomeIcons.personSwimming,
      'yoga': Icons.spa,
      'weightlifting': FontAwesomeIcons.dumbbell,
    };
    
    final Map<String, Color> activityColors = {
      'running': Colors.redAccent,
      'cycling': const Color(0xFF0066FF),
      'walking': const Color(0xFF1E293B),
      'swimming': Colors.blueAccent,
      'yoga': Colors.purpleAccent,
      'weightlifting': Colors.orangeAccent,
    };
    
    for (var activity in apiActivities) {
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
  
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
  
  static Future<String> _getAccessToken() async {
    return 'YOUR_ACCESS_TOKEN'; // TODO: Replace with actual token retrieval
  }
}

class ActivityToday extends StatefulWidget {
  const ActivityToday({super.key});

  @override
  _ActivityTodayState createState() => _ActivityTodayState();
}

class _ActivityTodayState extends State<ActivityToday> {
  bool isWatchConnected = true;
  bool isManualEntryOpen = false;
  int currentStep = 0;
  String? selectedActivityType;
  int activityDuration = 30;
  bool _isLoading = true;
  List<Map<String, dynamic>> _topActivities = [];
  String _errorMessage = '';
  int _totalActivities = 0;
  int _activityScore = 0;

  final List<Map<String, dynamic>> activityTypes = [
    {'label': 'Jogging', 'icon': FontAwesomeIcons.personRunning, 'color': const Color(0xFF1E293B)},
    {'label': 'Running', 'icon': FontAwesomeIcons.personRunning, 'color': const Color(0xFF0066FF)},
    {'label': 'Walking', 'icon': FontAwesomeIcons.personWalking, 'color': const Color(0xFF4CAF50)},
    {'label': 'Outdoor Sport', 'icon': FontAwesomeIcons.baseball, 'color': const Color(0xFFFF9800)},
    {'label': 'Elliptical', 'icon': FontAwesomeIcons.personWalking, 'color': const Color(0xFF9C27B0)},
    {'label': 'Strength Training', 'icon': FontAwesomeIcons.dumbbell, 'color': const Color(0xFF795548)},
    {'label': 'Treadmill', 'icon': FontAwesomeIcons.personRunning, 'color': const Color(0xFF607D8B)},
    {'label': 'Cycling', 'icon': FontAwesomeIcons.bicycle, 'color': const Color(0xFFE91E63)},
    {'label': 'Bike', 'icon': FontAwesomeIcons.bicycle, 'color': const Color(0xFF3F51B5)},
    {'label': 'Swimming', 'icon': FontAwesomeIcons.personSwimming, 'color': const Color(0xFF00BCD4)},
    {'label': 'Boxing', 'icon': FontAwesomeIcons.handFist, 'color': const Color(0xFFFF5722)},
    {'label': 'Skipping', 'icon': FontAwesomeIcons.arrowDown, 'color': const Color(0xFF8BC34A)},
    {'label': 'Table Tennis', 'icon': FontAwesomeIcons.tableTennisPaddleBall, 'color': const Color(0xFF673AB7)},
    {'label': 'Badminton', 'icon': FontAwesomeIcons.locationArrow, 'color': const Color(0xFFCDDC39)},
    {'label': 'Yoga', 'icon': Icons.spa, 'color': const Color(0xFF009688)},
    {'label': 'Skating', 'icon': FontAwesomeIcons.personSkating, 'color': const Color(0xFF2196F3)},
  ];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
    _fetchActivityScore();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
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

  Future<void> _fetchActivityScore() async {
    try {
      final score = await ActivityService.fetchDailyActivityScore(DateTime.now());
      setState(() {
        _activityScore = score;
      });
    } catch (e) {
      setState(() {
        _activityScore = 0;
      });
    }
  }

  void _navigateToMyActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyActivitiesScreen(userJoinDate: DateTime(2025, 4, 1)),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return GestureDetector(
            onTap: () {},
            child: _buildManualEntryDrawer(setModalState),
          );
        },
      ),
    ).then((_) {
      setState(() {
        isManualEntryOpen = false;
      });
    });
  }

  void _addActivity(StateSetter setModalState) {
    if (selectedActivityType != null && activityDuration > 0) {
      final activityData = activityTypes.firstWhere(
        (element) => element['label'] == selectedActivityType,
        orElse: () => activityTypes[0],
      );

      final newActivity = {
        'minutes': activityDuration.toString(),
        'label': selectedActivityType!,
        'color': activityData['color'] as Color,
        'icon': activityData['icon'] as IconData,
      };

      setState(() {
        _topActivities.add(newActivity);
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$selectedActivityType added for $activityDuration minutes'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = 370.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SizedBox(
            height: headerHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomActivityHeader(
                  title: 'Activities',
                  badgeText: isWatchConnected ? 'Normal' : 'Disconnected',
                  score: isWatchConnected ? _activityScore.toString() : '0',
                  subtitle: 'Activities Today.',
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: _navigateToMyActivities,
                  backgroundColor: const Color(0xFFD0E4FF),
                  backgroundImagePath: 'images/activity_header_background.png',
                  buttonColor: const Color(0xFF242E49),
                  buttonShadowColor: const Color(0xFF242E49),
                  titleTextColor: const Color(0xFF242E49),
                  scoreTextColor: const Color(0xFF242E49),
                  subtitleTextColor: const Color(0xFF242E49),
                  backButtonBorderColor: const Color(0xFF242E49),
                  badgeBackgroundColor: isWatchConnected 
                      ? const Color(0xFF0F67FE) 
                      : const Color(0xFFFF5252).withOpacity(0.1),
                  badgeTextColor: isWatchConnected 
                      ? const Color(0xFF0F67FE) 
                      : const Color(0xFFFF5252),
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
          SizedBox(height: 40.h),
          Expanded(
            child: isWatchConnected
                ? _buildActivityContent()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildEmptyState(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchActivities,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh activities',
      ),
    );
  }

  Widget _buildActivityContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorMessage();
    }

    if (_topActivities.isEmpty) {
      return _buildEmptyActivityState();
    }

    final maxMinutesValue = _topActivities.fold(0.0, (max, activity) {
      final minutes = double.parse(activity['minutes'].toString());
      return minutes > max ? minutes : max;
    });

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: const Color(0xFF0F67FE),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Most Minutes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _openManualEntryDrawer,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F67FE).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
        SizedBox(height: 8.h),
        Container(
          height: 300.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _topActivities.map((activity) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _buildActivityBar(
                  minutes: activity['minutes'] as String,
                  label: activity['label'] as String,
                  color: activity['color'] as Color,
                  icon: activity['icon'] as IconData,
                  maxMinutes: maxMinutesValue,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
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
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFFE6F0FF), Color(0xFFD0E4FF)],
                radius: 0.8,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F67FE).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 30.h,
                  right: 40.w,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F67FE).withOpacity(0.2),
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
                      color: const Color(0xFF0F67FE).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
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
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_run,
                    size: 50.sp,
                    color: const Color(0xFF0F67FE),
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
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'Start tracking your fitness journey by adding your first activity',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1E293B).withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F67FE).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF6FF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0E4FF),
                    shape: BoxShape.circle,
                  ),
                ),
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
                    color: const Color(0xFFFF5252),
                  ),
                ),
                Positioned(
                  top: 30.h,
                  right: 30.w,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withOpacity(0.2),
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
                      color: const Color(0xFFFF5252).withOpacity(0.3),
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
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'Connect your watch to automatically track your activities or add them manually.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1E293B).withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F67FE).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
    final double drawerHeight = MediaQuery.of(context).size.height * 0.50;

    return Container(
      height: drawerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(
            currentStep == 0 ? 'Select Activity Type' : 'Set Duration',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: currentStep >= 0 ? const Color(0xFF0F67FE) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: currentStep >= 1 ? const Color(0xFF0F67FE) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: currentStep == 0 
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
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: activityTypes.length,
                itemBuilder: (context, index) {
                  final activity = activityTypes[index];
                  final bool isSelected = selectedActivityType == activity['label'];

                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        selectedActivityType = activity['label'] as String;
                        currentStep = 1;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (activity['color'] as Color).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
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
                              color: isSelected
                                  ? activity['color'] as Color
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity['icon'] as IconData,
                              color: isSelected
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
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? activity['color'] as Color
                                    : const Color(0xFF1E293B),
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
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  )['icon'] as IconData,
                  color: activityTypes.firstWhere(
                    (element) => element['label'] == selectedActivityType,
                    orElse: () => activityTypes[0],
                  )['color'] as Color,
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
                    color: const Color(0xFF1E293B),
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
                    color: const Color(0xFF0F67FE),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
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
                  color: const Color(0xFF1E293B),
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
                        color: const Color(0xFF1E293B),
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
        const Spacer(),
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
                    side: const BorderSide(color: Color(0xFF0F67FE)),
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
                      color: const Color(0xFF0F67FE),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addActivity(setModalState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F67FE),
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
          color: const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: const Color(0xFF1E293B), size: 24.sp),
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
          color: isSelected ? const Color(0xFF0F67FE) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '$minutes min',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
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
    required double maxMinutes,
  }) {
    final minutesValue = double.parse(minutes);
    final maxBarHeight = 300.h;
    final coloredBarHeight = minutesValue <= 0 ? 0 : maxBarHeight * (minutesValue / maxMinutes);

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
                      color: (minutesValue > 0 && coloredBarHeight > 80.h)
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
                      color: (minutesValue > 0 && coloredBarHeight > 80.h)
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