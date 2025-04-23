import 'package:client/features/activity_management/data/datasources/activity_remote_datasource.dart';
import 'package:client/features/activity_management/domain/entities/activity_type.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_bar.dart';
import 'package:client/features/activity_management/presentation/widgets/empty_activity_state.dart';
import 'package:client/features/activity_management/presentation/pages/my_activities_page.dart';
import 'package:client/features/activity_management/presentation/widgets/error_message_widget.dart';
import 'package:client/features/activity_management/presentation/widgets/manual_entry_drawer.dart';
import 'package:client/features/activity_management/presentation/widgets/watch_disconnected_state.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ActivityTodayPage extends StatefulWidget {
  const ActivityTodayPage({super.key});

  @override
  _ActivityTodayPageState createState() => _ActivityTodayPageState();
}

class _ActivityTodayPageState extends State<ActivityTodayPage> {
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
  bool _isAddingActivity = false;

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
      final activities = await ActivityRemoteDataSource.fetchTopActivities(DateTime.now());
      setState(() {
        _topActivities = activities;
        _totalActivities = activities.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _fetchActivities: $e');
      setState(() {
        _errorMessage = 'Failed to load activities: $e';
        _isLoading = false;
        // Fallback data in case of error
        _topActivities = [
          {
            'minutes': '60',
            'label': 'Cycling',
            'color': const Color(0xFF0066FF),
            'icon': Icons.directions_bike,
          },
          {
            'minutes': '30',
            'label': 'Running',
            'color': Colors.redAccent,
            'icon': Icons.directions_run,
          },
        ];
        _totalActivities = 2;
      });
    }
  }

  Future<void> _fetchActivityScore() async {
    try {
      final score = await ActivityRemoteDataSource.fetchDailyActivityScore(DateTime.now());
      setState(() {
        _activityScore = score;
      });
    } catch (e) {
      print('Error in _fetchActivityScore: $e');
      setState(() {
        _activityScore = 0;
      });
    }
  }

  void _navigateToMyActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyActivitiesPage(userJoinDate: DateTime(2025, 4, 1)),
      ),
    ).then((_) {
      // Refresh data when returning from MyActivitiesScreen
      _fetchActivities();
      _fetchActivityScore();
    });
  }

  void _openManualEntryDrawer() {
    setState(() {
      isManualEntryOpen = true;
      currentStep = 0;
      selectedActivityType = null;
      activityDuration = 30; // Reset to default
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return GestureDetector(
            onTap: () {},
            child: ManualEntryDrawer(
              currentStep: currentStep,
              selectedActivityType: selectedActivityType,
              activityDuration: activityDuration,
              onActivitySelected: (activityType) {
                setModalState(() {
                  selectedActivityType = activityType;
                  currentStep = 1;
                });
              },
              onStepBack: () {
                setModalState(() {
                  currentStep = 0;
                });
              },
              onDurationChanged: (duration) {
                setModalState(() {
                  activityDuration = duration;
                });
              },
              onAddActivity: () => _addActivity(setModalState),
              isAddingActivity: _isAddingActivity,
            ),
          );
        },
      ),
    ).then((_) {
      setState(() {
        isManualEntryOpen = false;
      });
    });
  }

  Future<void> _addActivity(StateSetter setModalState) async {
    if (selectedActivityType != null && activityDuration > 0) {
      final activityTypes = ActivityType.getActivityTypes();
      final activityData = activityTypes.firstWhere(
        (element) => element.label == selectedActivityType,
        orElse: () => activityTypes[0],
      );

      // Set loading state
      setModalState(() {
        _isAddingActivity = true;
      });

      try {
        // Get the activity type from the mapping
        final activityType = activityData.type;
        
        // Calculate start and end times
        final now = DateTime.now();
        final endTime = now;
        final startTime = now.subtract(Duration(minutes: activityDuration));
        
        // Format times for API
        final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        
        // Create activity payload
        final payload = {
          'activity_type': activityType,
          'start_time': formatter.format(startTime),
          'end_time': formatter.format(endTime),
          'duration_seconds': activityDuration * 60,
          'source_device': 'Manual Entry',
          // Estimate calories based on duration and activity type
          'calories_burned': activityDuration * (activityType == 'running' ? 10 : 
                                               activityType == 'cycling' ? 8 : 
                                               activityType == 'walking' ? 5 : 7),
          // Add other fields as needed
          'distance_meters': activityType == 'running' ? activityDuration * 160 : 
                            activityType == 'cycling' ? activityDuration * 400 : 
                            activityType == 'walking' ? activityDuration * 80 : 0,
          'heart_rate_avg': 120,
          'heart_rate_max': 140,
        };
        
        // Send request to API
        final success = await ActivityRemoteDataSource.addActivity(payload);
        
        // Handle response
        if (success) {
          // Success - add to local state and close drawer
          final newActivity = {
            'minutes': activityDuration.toString(),
            'label': selectedActivityType!,
            'color': activityData.color,
            'icon': activityData.icon,
            'calories': payload['calories_burned'],
            'distance': payload['distance_meters'],
            'heart_rate_avg': payload['heart_rate_avg'],
          };

          Navigator.pop(context);
          
          setState(() {
            _topActivities.add(newActivity);
            _totalActivities = _topActivities.length;
          });
          
          // Refresh data from server
          _fetchActivities();
          _fetchActivityScore();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$selectedActivityType added for $activityDuration minutes'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add activity. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print('Error adding activity: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding activity: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        // Reset loading state
        setModalState(() {
          _isAddingActivity = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight = 370.h; // Adjust this value as needed
        
        return Scaffold(
          backgroundColor: Colors.grey[100],
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomActivityHeader(
                      title: 'Activities',
                      badgeText: isWatchConnected ? 'Normal' : 'Disconnected',
                      score: isWatchConnected ? _activityScore.toString() : '0',
                      subtitle: 'Activities Today',
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
                          ? Colors.white 
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
                        child: WatchDisconnectedState(
                          onAddActivity: _openManualEntryDrawer,
                        ),
                      ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActivityContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return ErrorMessageWidget(
        errorMessage: _errorMessage,
        onRetry: _fetchActivities,
      );
    }

    if (_topActivities.isEmpty) {
      return EmptyActivityState(
        onAddActivity: _openManualEntryDrawer,
      );
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
                child: ActivityBar(
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
}
