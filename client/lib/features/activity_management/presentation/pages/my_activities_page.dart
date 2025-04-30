import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/CustomCalander.dart';
import 'package:client/widgets/CustomDrawer.dart';
import 'package:client/data/providers/activity_provider.dart';
import 'package:client/features/activity_management/domain/entities/activity_history.dart';
import 'package:client/features/activity_management/presentation/widgets/monthly_score_card.dart';
import 'package:client/features/activity_management/presentation/widgets/ai_suggestion_card.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_item.dart';
import 'package:client/features/activity_management/presentation/widgets/month_year_picker.dart';
import 'package:client/features/activity_management/presentation/widgets/suggestion_details_sheet.dart';

class MyActivitiesPage extends StatefulWidget {
  final DateTime userJoinDate;

  const MyActivitiesPage({super.key, required this.userJoinDate});

  @override
  State<MyActivitiesPage> createState() => _MyActivitiesPageState();
}

class _MyActivitiesPageState extends State<MyActivitiesPage>
    with TickerProviderStateMixin {
  // Class variables
  List<int> _availableYears = [];
  List<DateTime> _availableMonths = [];
  DateTime _today = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate;
  List<DateTime> _last5Days = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controller for page transition
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Offset _slideDirection = const Offset(1.0, 0.0);

  // Animation controllers for score popup
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;
  late Animation<double> _scoreOpacityAnimation;
  late Animation<double> _scoreRotationAnimation;

  // Sample data for activities
  final Map<int, bool> _activityRegularity = {};

  final List<ActivityHistory> _activityHistory = [
    ActivityHistory(
      name: 'Weightlifting at Home',
      calories: 241,
      icon: Icons.fitness_center,
      color: Color(0xFF5D6B89),
      date: DateTime.now().subtract(Duration(days: 2)),
      duration: '45 min',
    ),
    ActivityHistory(
      name: 'Jogging',
      calories: 112,
      icon: Icons.directions_run,
      color: Color(0xFFFF5A5A),
      date: DateTime.now().subtract(Duration(days: 1)),
      duration: '30 min',
      distance: '3.2 km',
    ),
    ActivityHistory(
      name: 'Biking',
      calories: 241,
      icon: Icons.directions_bike,
      color: Color(0xFF1976D2),
      date: DateTime.now().subtract(Duration(days: 3)),
      duration: '60 min',
      distance: '12.5 km',
    ),
    ActivityHistory(
      name: 'Yoga',
      calories: 241,
      icon: Icons.self_improvement,
      color: Color(0xFF66BB6A),
      date: DateTime.now().subtract(Duration(days: 4)),
      duration: '40 min',
    ),
    ActivityHistory(
      name: 'Hiking',
      calories: 241,
      icon: Icons.hiking,
      color: Color(0xFF9C27B0),
      date: DateTime.now().subtract(Duration(days: 5)),
      duration: '120 min',
      distance: '5.8 km',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedMonth = DateTime(_today.year, _today.month, 1);
    _selectedYear = _today.year;

    // Initialize the collections
    _generateAvailableYears();
    _generateAvailableMonths();

    // Initialize animation controllers
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOut),
    );

    // Initialize animation controller for score popup
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _scoreOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scoreRotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fetchMonthlyActivityData();

    _pageTransitionController.forward();

    // Start score animation after a short delay
    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  void _generateLast5Days() {
    _last5Days = [];
    for (int i = 0; i < 5; i++) {
      _last5Days.add(DateTime.now().subtract(Duration(days: i)));
    }
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _handleDateSelection(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
  }

  List<ActivityHistory> _getFilteredActivities() {
    if (_selectedDate == null) {
      // Sort by date (newest first) and take the first 5
      _activityHistory.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort descending (newest first)
      return _activityHistory
          .take(5) // Take the first 5 (most recent)
          .toList();
    }

    // Filter activities for the selected date
    return _activityHistory.where((activity) {
      return activity.date.year == _selectedDate!.year &&
          activity.date.month == _selectedDate!.month &&
          activity.date.day == _selectedDate!.day;
    }).toList();
  }

  void _generateAvailableYears() {
    _availableYears = [];

    // Start from the user's join year
    int startYear = widget.userJoinDate.year;
    int endYear = _today.year;

    for (int year = startYear; year <= endYear; year++) {
      _availableYears.add(year);
    }

    // Sort in descending order (newest first)
    _availableYears.sort((a, b) => b.compareTo(a));
  }

  void _generateAvailableMonths() {
    _availableMonths = [];

    // Start from the user's join date
    DateTime startDate = DateTime(
      widget.userJoinDate.year,
      widget.userJoinDate.month,
      1,
    );

    // Go up to the current month
    DateTime endDate = DateTime(_today.year, _today.month, 1);

    // Generate a list of all months between start and end date
    while (startDate.isBefore(endDate) ||
        (startDate.year == endDate.year && startDate.month == endDate.month)) {
      _availableMonths.add(DateTime(startDate.year, startDate.month, 1));
      startDate = DateTime(startDate.year, startDate.month + 1, 1);
    }

    // Sort in descending order (newest first)
    _availableMonths.sort((a, b) => b.compareTo(a));
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MonthYearPicker(
          selectedMonth: _selectedMonth,
          selectedYear: _selectedYear,
          availableYears: _availableYears,
          availableMonths: _availableMonths,
          today: _today,
          onMonthSelected: (DateTime newMonth) {
            // Determine slide direction based on month comparison
            DateTime oldMonth = _selectedMonth;

            if (newMonth.isBefore(oldMonth)) {
              _slideDirection = const Offset(
                -1.0,
                0.0,
              ); // Right slide (newer to older)
            } else if (newMonth.isAfter(oldMonth)) {
              _slideDirection = const Offset(
                1.0,
                0.0,
              ); // Left slide (older to newer)
            } else {
              // Same month, no animation needed
              setState(() {
                _selectedMonth = newMonth;
              });
              return;
            }

            // Update the slide animation with new direction
            _slideAnimation = Tween<Offset>(
              begin: _slideDirection,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _pageTransitionController,
                curve: Curves.easeOut,
              ),
            );

            // Reset animation
            _pageTransitionController.reset();

            // Update state with the new selected month
            setState(() {
              _selectedMonth = newMonth;
              _selectedYear = newMonth.year;
            });

            // Start animation
            _pageTransitionController.forward();

            // Restart score animation
            _scoreAnimationController.reset();
            Future.delayed(Duration(milliseconds: 300), () {
              _scoreAnimationController.forward();
            });
            _fetchMonthlyActivityData();
          },
        );
      },
    );
  }

  // Method to handle month changes from the drawer
  void _handleMonthChange(DateTime newMonth) {
    // Determine slide direction based on month comparison
    if (newMonth.isBefore(_selectedMonth)) {
      _slideDirection = const Offset(-1.0, 0.0); // Right slide (newer to older)
    } else if (newMonth.isAfter(_selectedMonth)) {
      _slideDirection = const Offset(1.0, 0.0); // Left slide (older to newer)
    } else {
      // Same month, no animation needed
      return;
    }

    // Update the slide animation with new direction
    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOut),
    );

    // Reset animation
    _pageTransitionController.reset();

    // Update state with the new selected month
    setState(() {
      _selectedMonth = newMonth;
      _selectedYear = newMonth.year;
    });

    // Start animation
    _pageTransitionController.forward();

    _fetchMonthlyActivityData();

    // Restart score animation
    _scoreAnimationController.reset();
    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  void _showSuggestionDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SuggestionDetailsSheet(onClose: () => Navigator.pop(context));
      },
    );
  }

  void _showActivityDetails(ActivityHistory activity) {
    // Implementation for showing activity details
  }

  @override
  Widget build(BuildContext context) {
    // Create a text theme using Google Fonts
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FA),
        drawer: CustomDrawer(
          onMonthChanged: _handleMonthChange,
          selectedMonth: _selectedMonth,
          userJoinDate: widget.userJoinDate,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Back button and drawer button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Header with year selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Activities',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),

                          // Combined month and year selector
                          InkWell(
                            onTap: _showMonthYearPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat(
                                      'MMM yyyy',
                                    ).format(_selectedMonth),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Monthly score card
                      MonthlyScoreCard(
                        activitiesCount: _totalActivities,
                        caloriesBurned: _totalCalories,
                        totalTimeSpent: _totalMinutes,
                      ),

                      const SizedBox(height: 24),

                      // Calendar with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ActivityCalendar(
                            selectedMonth: _selectedMonth,
                            today: _today,
                            activityRegularity: _activityRegularity,
                            userJoinedDate: widget.userJoinDate,
                            onMonthChanged: _handleMonthChange,
                            onDateSelected: _handleDateSelection,
                            selectedDate: _selectedDate,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // AI Activity Suggestions
                      // Text(
                      //   'AI Activity Suggestions',
                      //   style: GoogleFonts.plusJakartaSans(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //     color: const Color(0xFF1E293B),
                      //   ),
                      // ),

                      // const SizedBox(height: 16),

                      // // Enhanced suggestion card
                      // AISuggestionCard(
                      //   onViewSuggestion: _showSuggestionDetails,
                      // ),

                      const SizedBox(height: 32),

                      // Activity History - removed filter button
                      Text(
                        _selectedDate != null
                            ? 'Activity on ${DateFormat('MMM d, yyyy').format(_selectedDate!)}'
                            : 'Recent Activities',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Activity list - filtered by selected date or showing last 5 days
                      ..._getFilteredActivities().map(
                        (activity) => ActivityItem(
                          activity: activity,
                          onTap: () => _showActivityDetails(activity),
                        ),
                      ),

                      // Show message if no activities
                      if (_getFilteredActivities().isEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No activities found',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _totalActivities = 0;
  int _totalCalories = 0;
  int _totalMinutes = 0;

  Future<void> _fetchMonthlyActivityData() async {
    final activityProvider = ActivityProvider();
    try {
      final response = await activityProvider.getMonthlyActivityData(
        _selectedYear,
        _selectedMonth.month,
      );

      // Clear existing data
      setState(() {
        _activityRegularity.clear();
        _activityHistory.clear();
        _totalActivities = 0;
        _totalCalories = 0;
        _totalMinutes = 0;
      });

      int totalCalories = 0;
      int totalMinutes = 0;

      setState(() {
        _totalActivities = response.totalActivities;
      });

      // Process each day's activities
      for (var dayData in response.days) {
        final dayNumber = dayData['dayNumber'] as int;
        final activities = (dayData['activities'] as List<dynamic>?) ?? [];

        _activityRegularity[dayNumber] = activities.isNotEmpty;

        for (var activity in activities) {
          final activityMap = activity as Map<String, dynamic>;
          final startTime = DateTime.parse(activityMap['startTime'] as String);
          final endTime = DateTime.parse(activityMap['endTime'] as String);
          final duration = endTime.difference(startTime);

          // Map activity type
          var iconData = Icons.fitness_center;
          var color = const Color(0xFF5D6B89);
          String displayName = 'Activity';

          switch (activityMap['activityType'] as String) {
            case 'jogging':
              iconData = Icons.directions_run;
              color = Colors.black;
              displayName = 'Jogging';
              break;
            case 'running':
              iconData = Icons.directions_run;
              color = Colors.blue;
              displayName = 'Running';
              break;
            case 'walking':
              iconData = Icons.directions_walk;
              color = Colors.green;
              displayName = 'Walking';
              break;
            case 'outdoor sport':
              iconData = Icons.sports_soccer;
              color = Colors.orange;
              displayName = 'Outdoor Sport';
              break;
            case 'elliptical':
              iconData = Icons.fitness_center;
              color = Colors.purple;
              displayName = 'Elliptical';
              break;
            case 'weightlifting':
              iconData = Icons.fitness_center_rounded;
              color = Colors.brown;
              displayName = 'Strength Training';
              break;
            case 'treadmill':
              iconData = Icons.directions_run;
              color = Colors.grey;
              displayName = 'Treadmill';
              break;
            case 'cycling':
              iconData = Icons.directions_bike;
              color = Colors.pink;
              displayName = 'Cycling';
              break;
            case 'bike':
              iconData = Icons.directions_bike;
              color = Colors.indigo;
              displayName = 'Bike';
              break;
            case 'swimming':
              iconData = Icons.pool;
              color = Colors.cyan; // sky blue
              displayName = 'Swimming';
              break;
            case 'boxing':
              iconData = Icons.sports_mma;
              color = Colors.deepOrange; // reddish orange
              displayName = 'Boxing';
              break;
            case 'skipping':
              iconData = Icons.sports;
              color = Colors.lightGreen;
              displayName = 'Skipping';
              break;
            case 'table tennis':
              iconData = Icons.sports_tennis;
              color = Color(0xFF558B2F); // leaf green
              displayName = 'Table Tennis';
              break;
            case 'badminton':
              iconData = Icons.sports_tennis;
              color = Color(0xFF1976D2); // slightly darker blue
              displayName = 'Badminton';
              break;
            case 'yoga':
              iconData = Icons.self_improvement;
              color = Colors.deepPurple;
              displayName = 'Yoga';
              break;
            case 'skating':
              iconData = Icons.sports;
              color = Colors.indigo;
              displayName = 'Skating';
              break;
            default:
              iconData = Icons.help_outline;
              color = Colors.grey;
              displayName = 'Other';
              break;
          }

          final caloriesBurned = activityMap['caloriesBurned'];
          final calories =
              caloriesBurned != null
                  ? (caloriesBurned is double
                      ? caloriesBurned.toInt()
                      : caloriesBurned as int)
                  : 0;

          final distance = activityMap['distance']?.toString();

          // Track totals
          totalCalories += calories;
          totalMinutes += duration.inMinutes;

          final activityHistory = ActivityHistory(
            name: displayName,
            calories: calories,
            icon: iconData,
            color: color,
            date: startTime,
            duration: '${duration.inMinutes} min',
            distance: distance != null ? '$distance km' : null,
          );

          setState(() {
            _activityHistory.add(activityHistory);
          });
        }
      }

      // Final setState for totals
      setState(() {
        _totalCalories = totalCalories;
        _totalMinutes = totalMinutes;
      });
    } catch (e) {
      print('Error fetching monthly activity data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load activity data')),
        );
      }
    }
  }
}
