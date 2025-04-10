import 'package:client/features/activity_management/activity_calories.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/CustomCalander.dart';
import 'package:client/widgets/CustomDrawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyActivitiesScreen extends StatefulWidget {
  final DateTime userJoinDate;

  const MyActivitiesScreen({super.key, required this.userJoinDate});

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen>
    with TickerProviderStateMixin {
  // Class variables
  List<int> _availableYears = [];
  List<DateTime> _availableMonths = [];
  DateTime _today = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate = DateTime.now(); // Default to today
  bool _isLoading = false;

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
  final Map<int, bool> _activityRegularity = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: true,
    8: false,
    9: false,
    10: false,
    11: false,
    13: false,
    14: false,
    15: false,
    16: false,
    17: false,
    18: false,
    23: false,
    24: false,
    25: false,
    26: false,
    28: false,
    12: false,
    19: false,
    20: false,
    21: false,
    22: false,
    27: false,
    29: false,
    30: false,
  };

  // Default activity data
  final List<Map<String, dynamic>> _defaultActivityHistory = [
    {
      'name': 'Weightlifting at Home',
      'calories': 241,
      'icon': Icons.fitness_center,
      'color': Color(0xFF5D6B89),
      'date': DateTime(2025, 3, 21),
    },
    {
      'name': 'Jogging',
      'calories': 112,
      'icon': Icons.directions_run,
      'color': Color(0xFFFF5A5A),
      'date': DateTime.now().subtract(Duration(days: 1)),
      'duration': '30 min',
      'distance': '3.2 km',
    },
    {
      'name': 'Biking',
      'calories': 241,
      'icon': Icons.directions_bike,
      'color': Color(0xFF1976D2),
      'date': DateTime.now().subtract(Duration(days: 3)),
      'duration': '60 min',
      'distance': '12.5 km',
    },
    {
      'name': 'Yoga',
      'calories': 241,
      'icon': Icons.self_improvement,
      'color': Color(0xFF66BB6A),
      'date': DateTime.now().subtract(Duration(days: 4)),
      'duration': '40 min',
      'distance': null,
    },
    {
      'name': 'Hiking',
      'calories': 241,
      'icon': Icons.hiking,
      'color': Color(0xFF9C27B0),
      'date': DateTime(2025, 3, 24),
    },
  ];

  // List to store actual API fetched activities
  List<Map<String, dynamic>> _activityHistory = [];
  List<DateTime> _last5Days = [];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedMonth = DateTime(_today.year, _today.month, 1);
    _selectedYear = _today.year;

    // Generate last 5 days for default view
    _generateLast5Days();

    // Initialize the collections
    _generateAvailableYears();
    _generateAvailableMonths();

    // Initialize animation controller for page transition
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

    _pageTransitionController.forward();
    
    // Initialize with default data
    _activityHistory = List.from(_defaultActivityHistory);
    
    // Fetch activities for the selected date
    _fetchActivities();
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

  // Method to fetch activities from the API
  Future<void> _fetchActivities() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });

    // Format the date for the API call
    String formattedDate = DateFormat('yyyy-M-d').format(_selectedDate!);
    
    try {
      // Get the access token (in a real app, this would come from your auth service)
      String accessToken = "YOUR_ACCESS_TOKEN"; // Replace with actual token retrieval
      
      // Create the API endpoint URL
      final url = Uri.parse('/api/activity/top-activities/$formattedDate?all=true');
      
      // Make the API call
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // Convert API data to the format used by our UI
          List<Map<String, dynamic>> fetchedActivities = [];
          
          for (var activity in responseData['data']) {
            // Map activity types to corresponding icons
            IconData activityIcon;
            Color activityColor;
            
            switch (activity['activity_type'].toString().toLowerCase()) {
              case 'cycling':
              case 'bike':
                activityIcon = Icons.directions_bike;
                activityColor = Color(0xFF1976D2);
                break;
              case 'running':
                activityIcon = Icons.directions_run;
                activityColor = Color(0xFFFF5A5A);
                break;
              case 'strength training':
              case 'weightlifting':
                activityIcon = Icons.fitness_center;
                activityColor = Color(0xFF5D6B89);
                break;
              case 'yoga':
                activityIcon = Icons.self_improvement;
                activityColor = Color(0xFF66BB6A);
                break;
              case 'hiking':
                activityIcon = Icons.hiking;
                activityColor = Color(0xFF9C27B0);
                break;
              default:
                activityIcon = Icons.directions_run;
                activityColor = Color(0xFFFF5A5A);
            }
            
            // Format the activity data
            fetchedActivities.add({
              'name': _capitalizeActivityType(activity['activity_type']),
              'calories': activity['calories_burned'] ?? 0,
              'icon': activityIcon,
              'color': activityColor,
              'date': DateTime.parse(activity['start_time']),
              'duration': activity['duration_seconds'] ?? 0,
              'heart_rate_avg': activity['heart_rate_avg'] ?? 0,
              'heart_rate_max': activity['heart_rate_max'] ?? 0,
              'distance': activity['distance_meters'] ?? 0,
              'source': activity['source_device'] ?? 'Unknown',
            });
          }
          
          setState(() {
            _activityHistory = fetchedActivities;
            _isLoading = false;
          });
        } else {
          // If the API returns a success:false or no data, use default data
          setState(() {
            _activityHistory = List.from(_defaultActivityHistory);
            _isLoading = false;
          });
        }
      } else {
        // If the API call fails, use default data
        setState(() {
          _activityHistory = List.from(_defaultActivityHistory);
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's an exception, use default data
      setState(() {
        _activityHistory = List.from(_defaultActivityHistory);
        _isLoading = false;
      });
    }
  }

  // Helper method to capitalize activity type
  String _capitalizeActivityType(String activityType) {
    // Split by space to capitalize each word
    List<String> words = activityType.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
    return words.join(' ');
  }

  void _handleDateSelection(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
    
    // Fetch activities when a new date is selected
    _fetchActivities();
  }

  List<Map<String, dynamic>> _getFilteredActivities() {
    if (_selectedDate == null) {
      // Show last 5 days activities by default
      return _activityHistory.where((activity) {
        if (activity['date'] == null) return false;

        final activityDate = activity['date'] as DateTime;
        return _last5Days.any(
          (date) =>
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(activityDate),
        );
      }).toList();
    }

    return _activityHistory.where((activity) {
      if (activity['date'] == null) return false;

      return DateFormat('yyyy-MM-dd').format(activity['date'] as DateTime) ==
          DateFormat('yyyy-MM-dd').format(_selectedDate!);
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

  // Update the _showMonthYearPicker method to create a more impressive and professional UI

  // Replace the _showMonthYearPicker method with this enhanced version:
  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle and header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Title with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Month & Year',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current selection display
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF0F67FE).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('MMMM').format(_selectedMonth),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _selectedYear.toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Year selector
                          Text(
                            'Year',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Improved year selector with animation
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableYears.length,
                              itemBuilder: (context, index) {
                                final year = _availableYears[index];
                                final isSelected = year == _selectedYear;
                                final isFutureYear = year > _today.year;

                        return GestureDetector(
                          onTap:
                              isFutureYear
                                  ? null // Disable future years
                                  : () {
                                      setState(() {
                                        _selectedYear = year;

                                        // Get months available in the selected year
                                        List<DateTime> monthsInYear =
                                            _availableMonths
                                                .where(
                                                  (month) => month.year == year,
                                                )
                                                .toList();

                                        if (monthsInYear.isNotEmpty) {
                                          // If current year, default to current month; otherwise, use first available
                                          _selectedMonth =
                                              (year == _today.year)
                                                  ? DateTime(
                                                    year,
                                                    _today.month,
                                                    1,
                                                  )
                                                  : monthsInYear.first;
                                        }
                                      });
                                    },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : (isFutureYear
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                year.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : (isFutureYear
                                              ? Colors.grey
                                              : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                          SizedBox(height: 24),

                          // Month selector
                          Text(
                            'Month',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Improved month selector with animation
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1.2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: 12,
                              itemBuilder: (context, index) {
                                final monthNum = index + 1;
                                final monthDate = DateTime(
                                  _selectedYear,
                                  monthNum,
                                  1,
                                );
                                final monthName = DateFormat(
                                  'MMM',
                                ).format(monthDate);

                                // Check if the month should be disabled
                                bool isAvailable = _isMonthAvailable(monthDate);
                                bool isSelected =
                                    _selectedMonth.month == monthNum &&
                                    _selectedMonth.year == _selectedYear;

                        return GestureDetector(
                          onTap:
                              isAvailable
                                  ? () {
                                      setState(() {
                                        _selectedMonth = DateTime(
                                          _selectedYear,
                                          monthNum,
                                          1,
                                        );
                                      });
                                    }
                                  : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : (isAvailable
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('MMM').format(monthDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : (isAvailable
                                              ? Colors.black87
                                              : Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                          SizedBox(height: 20),

                          // Apply button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0F67FE),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                // Determine slide direction based on month comparison
                                DateTime oldMonth = _selectedMonth;
                                DateTime newMonth = DateTime(
                                  _selectedYear,
                                  _selectedMonth.month,
                                  1,
                                );

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
                                  this.setState(() {
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
                                this.setState(() {
                                  _selectedMonth = newMonth;
                                });

                                // Start animation
                                _pageTransitionController.forward();

                                // Restart score animation
                                _scoreAnimationController.reset();
                                Future.delayed(Duration(milliseconds: 300), () {
                                  _scoreAnimationController.forward();
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Apply Selection',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to check if a month is available
  bool _isMonthAvailable(DateTime monthDate) {
    // Month should be after or same as join date
    bool isAfterJoinDate =
        !monthDate.isBefore(
          DateTime(widget.userJoinDate.year, widget.userJoinDate.month, 1),
        );

    // Month should not be in the future
    bool isNotInFuture =
        !monthDate.isAfter(DateTime(_today.year, _today.month, 1));

    return isAfterJoinDate && isNotInFuture;
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

    // Restart score animation
    _scoreAnimationController.reset();
    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
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
                        mainAxisAlignment:
                            MainAxisAlignment
                                .start, // Aligns the back button to the left
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

                      // Reduced height monthly score card
                      _buildMonthlyScoreCard(),

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
                      Text(
                        'AI Activity Suggestions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 16),

                  // Suggestion card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Morning Jog',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '12+ AI Suggestions',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Activity History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Activity History',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (_selectedDate != null)
                        Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate!),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Loading indicator
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_getFilteredActivities().isEmpty)
                    // No activities found message
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_gymnastics,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No activities found for this date',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Activity list
                    ..._getFilteredActivities().map(
                      (activity) => _buildActivityItem(activity),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to ActivityCalories instead of showing modal
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityCalories()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Activity icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        activity['color'],
                        Color.lerp(activity['color'], Colors.white, 0.3)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(activity['icon'], color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),

                // Activity details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey.shade500,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(activity['date']),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.grey.shade500,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity['duration'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Calories
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFFF5A5A),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${activity['calories']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Activity header
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activity['color'],
                      Color.lerp(activity['color'], Colors.white, 0.3)!,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            activity['icon'],
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'EEEE, MMM d, yyyy',
                              ).format(activity['date']),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailStat(
                          Icons.local_fire_department,
                          '${activity['calories']}',
                          'Calories',
                        ),
                        _buildDetailStat(
                          Icons.timer,
                          activity['duration'],
                          'Duration',
                        ),
                        if (activity['distance'] != null)
                          _buildDetailStat(
                            Icons.straighten,
                            activity['distance'],
                            'Distance',
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Additional content would go here
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Summary',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'You completed ${activity['name']} on ${DateFormat('EEEE, MMM d').format(activity['date'])}. This activity burned ${activity['calories']} calories and lasted for ${activity['duration']}.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 24),

                      // Placeholder for a chart or additional stats
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Activity Chart',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
