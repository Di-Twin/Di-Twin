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
  bool _hasInitialLoadCompleted = false;

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
      final activities = await ActivityRemoteDataSource.fetchTopActivities(
        DateTime.now(),
      );
      
      // Process and validate activities before setting state
      final processedActivities = _processActivities(activities ?? []);
      
      setState(() {
        _topActivities = processedActivities;
        _totalActivities = _topActivities.length;
        _isLoading = false;
        _hasInitialLoadCompleted = true;
        _errorMessage = '';
      });
      
      print('Fetched and processed ${_topActivities.length} activities');
      
    } catch (e) {
      print('Error in _fetchActivities: $e');
      setState(() {
        _errorMessage = 'Failed to load activities';
        _isLoading = false;
        _hasInitialLoadCompleted = true;
        // Only clear activities if this is the initial load
        if (!_hasInitialLoadCompleted) {
          _topActivities = [];
          _totalActivities = 0;
        }
      });
    }
  }

  List<Map<String, dynamic>> _processActivities(List<Map<String, dynamic>> rawActivities) {
    final activityTypes = ActivityType.getActivityTypes();
    final processedActivities = <Map<String, dynamic>>[];

    for (final activity in rawActivities) {
      try {
        // Extract activity type from the raw data
        final activityTypeString = activity['activity_type']?.toString() ?? 
                                 activity['type']?.toString() ?? 
                                 activity['label']?.toString() ?? '';

        if (activityTypeString.isEmpty) {
          print('Skipping activity with no type: $activity');
          continue; // Skip activities without a type
        }

        // Find matching activity type
        ActivityType? matchingType;
        try {
          matchingType = activityTypes.firstWhere(
            (type) => type.type.toLowerCase() == activityTypeString.toLowerCase() ||
                     type.label.toLowerCase() == activityTypeString.toLowerCase(),
          );
        } catch (e) {
          // If no exact match, try partial matching
          try {
            matchingType = activityTypes.firstWhere(
              (type) => activityTypeString.toLowerCase().contains(type.type.toLowerCase()) ||
                       type.type.toLowerCase().contains(activityTypeString.toLowerCase()),
            );
          } catch (e) {
            print('No matching activity type found for: $activityTypeString');
            continue; // Skip this activity if no match found
          }
        }

        if (matchingType == null) {
          continue; // Skip if no matching type found
        }

        // Calculate duration in minutes
        final durationSeconds = activity['duration_seconds'] as int? ?? 
                              activity['duration'] as int? ?? 0;
        final minutes = durationSeconds > 0 ? (durationSeconds / 60).round() : 
                       int.tryParse(activity['minutes']?.toString() ?? '0') ?? 0;

        if (minutes <= 0) {
          print('Skipping activity with invalid duration: $activity');
          continue; // Skip activities with no duration
        }

        // Create processed activity
        final processedActivity = {
          'minutes': minutes.toString(),
          'label': matchingType.label,
          'color': matchingType.color,
          'icon': matchingType.icon,
          'calories': activity['calories'] ?? _calculateCalories(matchingType.type, minutes),
          'distance': activity['distance'] ?? _calculateDistance(matchingType.type, minutes),
          'heart_rate_avg': activity['heart_rate_avg'] ?? 120,
          'start_time': activity['start_time'] ?? '',
          'end_time': activity['end_time'] ?? '',
          'source_device': activity['source_device'] ?? 'Unknown Device',
          'activity_type': matchingType.type,
        };

        processedActivities.add(processedActivity);
        
      } catch (e) {
        print('Error processing activity $activity: $e');
        // Skip malformed activities
        continue;
      }
    }

    return processedActivities;
  }

  Future<void> _fetchActivityScore() async {
    try {
      final score = await ActivityRemoteDataSource.fetchDailyActivityScore(
        DateTime.now(),
      );
      setState(() {
        _activityScore = score ?? 0;
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
      _fetchActivities();
      _fetchActivityScore();
    });
  }

  void _openManualEntryDrawer() {
    setState(() {
      isManualEntryOpen = true;
      currentStep = 0;
      selectedActivityType = null;
      activityDuration = 30;
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
    if (selectedActivityType == null || activityDuration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an activity and duration'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final activityTypes = ActivityType.getActivityTypes();
    
    if (activityTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No activity types available'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ActivityType activityData;
    try {
      activityData = activityTypes.firstWhere(
        (element) => element.label == selectedActivityType,
      );
    } catch (e) {
      activityData = activityTypes.first;
      print('Activity type not found, using fallback: ${activityData.label}');
    }

    setModalState(() {
      _isAddingActivity = true;
    });

    try {
      final activityType = activityData.type;
      final now = DateTime.now();
      final endTime = now;
      final startTime = now.subtract(Duration(minutes: activityDuration));
      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

      final payload = [
        {
          'activity_type': activityType,
          'start_time': formatter.format(startTime),
          'end_time': formatter.format(endTime),
          'duration_seconds': activityDuration * 60,
          'source_device': 'Manual Entry',
        },
      ];

      final response = await ActivityRemoteDataSource.addManualActivity(payload);
      print('Add activity response: $response');

      if (response != null && response['success'] == true) {
        final newActivity = {
          'minutes': activityDuration.toString(),
          'label': selectedActivityType!,
          'color': activityData.color,
          'icon': activityData.icon,
          'calories': _calculateCalories(activityType, activityDuration),
          'distance': _calculateDistance(activityType, activityDuration),
          'heart_rate_avg': 120,
          'start_time': formatter.format(startTime),
          'end_time': formatter.format(endTime),
          'source_device': 'Manual Entry',
          'activity_type': activityType,
        };

        Navigator.pop(context);

        setState(() {
          _topActivities.add(newActivity);
          _totalActivities = _topActivities.length;
          _activityScore += 1;
        });

        _fetchActivities();
        _fetchActivityScore();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$selectedActivityType added for $activityDuration minutes',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?['message'] ?? 'Failed to add activity. Please try again.',
            ),
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
      setModalState(() {
        _isAddingActivity = false;
      });
    }
  }

  int _calculateCalories(String activityType, int duration) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return duration * 10;
      case 'cycling':
        return duration * 8;
      case 'walking':
        return duration * 5;
      case 'swimming':
        return duration * 12;
      case 'yoga':
        return duration * 3;
      case 'weightlifting':
        return duration * 6;
      default:
        return duration * 7;
    }
  }

  int _calculateDistance(String activityType, int duration) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return duration * 160;
      case 'cycling':
        return duration * 400;
      case 'walking':
        return duration * 80;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight = 370.h;

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
      },
    );
  }

  Widget _buildActivityContent() {
    if (_isLoading && !_hasInitialLoadCompleted) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _topActivities.isEmpty) {
      return ErrorMessageWidget(
        errorMessage: _errorMessage,
        onRetry: _fetchActivities,
      );
    }

    if (_topActivities.isEmpty && _hasInitialLoadCompleted) {
      return EmptyActivityState(onAddActivity: _openManualEntryDrawer);
    }

    final maxMinutesValue = _topActivities.fold(0.0, (max, activity) {
      final minutes = double.tryParse(activity['minutes']?.toString() ?? '0') ?? 0.0;
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
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
          child: _buildActivityBars(maxMinutesValue),
        ),
      ],
    );
  }

  Widget _buildActivityBars(double maxMinutesValue) {
    if (_topActivities.isEmpty) {
      return Center(
        child: Text(
          'No activities yet. Add one to get started!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    if (_topActivities.length == 1) {
      final activity = _topActivities[0];
      return Center(
        child: SizedBox(
          width: 160.w,
          child: ActivityBar(
            minutes: activity['minutes']?.toString() ?? '0',
            label: activity['label']?.toString() ?? 'Activity',
            color: activity['color'] as Color,
            icon: activity['icon'] as IconData,
            maxMinutes: double.tryParse(activity['minutes']?.toString() ?? '0') ?? 0.0,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: (_topActivities.length / 3).ceil(),
      itemBuilder: (context, rowIndex) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (colIndex) {
              final index = rowIndex * 3 + colIndex;
              if (index < _topActivities.length) {
                final activity = _topActivities[index];
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 48.w) / 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ActivityBar(
                      minutes: activity['minutes']?.toString() ?? '0',
                      label: activity['label']?.toString() ?? 'Activity',
                      color: activity['color'] as Color,
                      icon: activity['icon'] as IconData,
                      maxMinutes: maxMinutesValue,
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 48.w) / 3,
                );
              }
            },
          ),
        );
      },
    );
  }
}