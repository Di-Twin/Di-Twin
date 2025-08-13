import 'package:client/features/activity_management/presentation/widgets/calories_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Activity {
  final String id;
  final String userId;
  final String dayId;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final String sourceDevice;
  final int durationSeconds;
  final double caloriesBurned;
  final double? distanceMeters;
  final int? stepsCount;
  final int? heartRateAvg;
  final int? heartRateMax;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.dayId,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.sourceDevice,
    required this.durationSeconds,
    required this.caloriesBurned,
    this.distanceMeters,
    this.stepsCount,
    this.heartRateAvg,
    this.heartRateMax,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      dayId: json['dayId'] ?? '',
      activityType: json['activity_type'] ?? 'Unknown',
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toString()),
      endTime: DateTime.parse(json['end_time'] ?? DateTime.now().toString()),
      sourceDevice: json['source_device'] ?? 'Unknown device',
      durationSeconds: json['duration_seconds']?.toInt() ?? 0,
      caloriesBurned: json['calories_burned']?.toDouble() ?? 0.0,
      distanceMeters: json['distance_meters']?.toDouble(),
      stepsCount: json['steps_count']?.toInt(),
      heartRateAvg: json['heart_rate_avg']?.toInt(),
      heartRateMax: json['heart_rate_max']?.toInt(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}

class ActivityCaloriesProvider extends ChangeNotifier {
  static const String baseUrl = 'https://test-prod-f427.onrender.com';

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;
  double _totalCaloriesBurned = 0.0;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalCaloriesBurned => _totalCaloriesBurned;

  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      print('Error getting access token from SharedPreferences: $e');
      return null;
    }
  }

  Future<void> loadActivities({String? accessToken, DateTime? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = accessToken ?? await _getAccessToken();
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final targetDate = date ?? DateTime.now();
      final dateString =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final url = Uri.parse('$baseUrl/api/activity/top-activities/$dateString?all=true');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> activitiesData = jsonData['data'] ?? [];
          _activities = activitiesData.map((json) => Activity.fromJson(json)).toList();
          _totalCaloriesBurned = _activities.fold(0.0, (sum, activity) => sum + activity.caloriesBurned);
          _error = null;
        } else {
          _error = jsonData['message'] ?? 'No activities found';
          _activities = [];
          _totalCaloriesBurned = 0.0;
        }
      } else if (response.statusCode == 404) {
        // Handle 404 specifically as no data rather than error
        _activities = [];
        _totalCaloriesBurned = 0.0;
        _error = null;
      } else {
        _error = 'Server error: ${response.statusCode}';
        _activities = [];
        _totalCaloriesBurned = 0.0;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _activities = [];
      _totalCaloriesBurned = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshActivities({String? accessToken}) async {
    await loadActivities(accessToken: accessToken);
  }
}

class ActivityCaloriesTrackerPage extends StatelessWidget {
  final String? accessToken;

  const ActivityCaloriesTrackerPage({super.key, this.accessToken});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ActivityCaloriesProvider>(
      create: (context) => ActivityCaloriesProvider(),
      child: _ActivityCaloriesTrackerContent(accessToken: accessToken),
    );
  }
}

class _ActivityCaloriesTrackerContent extends StatefulWidget {
  final String? accessToken;

  const _ActivityCaloriesTrackerContent({this.accessToken});

  @override
  State<_ActivityCaloriesTrackerContent> createState() =>
      _ActivityCaloriesTrackerContentState();
}

class _ActivityCaloriesTrackerContentState
    extends State<_ActivityCaloriesTrackerContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCaloriesProvider>().loadActivities(
        accessToken: widget.accessToken,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: Consumer<ActivityCaloriesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return _buildLoader();
            }

            if (provider.error != null) {
              return _buildErrorWidget(provider.error!, provider);
            }

            return Column(
              children: [
                // Fixed header section
                _buildHeader(),
                // Scrollable content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.refreshActivities(
                      accessToken: widget.accessToken,
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),
                                _buildCaloriesSummary(provider.totalCaloriesBurned),
                                SizedBox(height: 24.h),
                                FunctionalCaloriesChartWidget(
                                  caloriesBurned: provider.totalCaloriesBurned,
                                  targetCalories: 2000,
                                ),
                                SizedBox(height: 24.h),
                              ],
                            ),
                          ),
                          _buildActivitiesSection(provider.activities),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF0F3F8),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          Text(
            'Calories',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1F36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String error, ActivityCaloriesProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.w, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Error loading data',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => provider.loadActivities(accessToken: widget.accessToken),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSummary(double totalCaloriesBurned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today, you just burned',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
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
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(List<Activity> activities) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 244, 244, 244),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              activities.isEmpty ? 'No Activities Today' : 'Activities',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: const Color(0xFFEEEEEE)),
          if (activities.isEmpty)
            _buildEmptyActivities()
          else
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: activities.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return _buildActivityItem(activities[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            "No activities recorded today",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start moving to see your activities here!",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                activity.activityType.isNotEmpty
                    ? activity.activityType[0].toUpperCase() +
                        activity.activityType.substring(1).toLowerCase()
                    : 'Activity',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0066FF),
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${activity.caloriesBurned.toStringAsFixed(0)} kcal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 16.w, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '${(activity.durationSeconds / 60).toStringAsFixed(0)} min',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: 16.w),
              if (activity.distanceMeters != null) ...[
                Icon(Icons.straighten, size: 16.w, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  '${(activity.distanceMeters! / 1000).toStringAsFixed(1)} km',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Device: ${activity.sourceDevice}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}