import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/CustomCalander.dart';
import 'package:client/widgets/CustomDrawer.dart';

class MySleepScreen extends StatefulWidget {
  final DateTime userJoinDate;

  const MySleepScreen({super.key, required this.userJoinDate});

  @override
  State<MySleepScreen> createState() => _MySleepScreenState();
}

class _MySleepScreenState extends State<MySleepScreen>
    with SingleTickerProviderStateMixin {
  // Class variables
  List<int> _availableYears = [];
  List<DateTime> _availableMonths = [];
  DateTime _today = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate = DateTime.now(); // Default to today

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controller for page transition - add 'late' keyword to fix initialization error
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Offset _slideDirection = const Offset(1.0, 0.0);

  DateTime fromDate = DateTime.now().subtract(Duration(days: 5));
  DateTime toDate = DateTime.now();
  String activityType = 'Jogging';
  double duration = 2.5;

  // Sample data for activities
  final Map<int, bool> _activityRegularity = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: true,
    8: true,
    9: true,
    10: true,
    11: true,
    13: true,
    14: true,
    15: true,
    16: true,
    17: true,
    18: true,
    24: true,
    25: true,
    26: true,
    28: true,
    12: false,
    19: false,
    20: false,
    21: false,
    22: false,
    27: false,
    29: false,
    30: false,
  };

  final List<Map<String, dynamic>> _sleepHistory = [
    {
      'day': 31,
      'duration': '4.2h',
      'quality': 'Deep',
      'date': DateTime(2025, 3, 31),
    },
    {
      'day': 30,
      'duration': '7.8h',
      'quality': 'Light',
      'date': DateTime(2025, 3, 30),
    },
    {
      'day': 29,
      'duration': '6.5h',
      'quality': 'Deep',
      'date': DateTime(2025, 3, 29),
    },
    {
      'day': 28,
      'duration': '8.1h',
      'quality': 'Light',
      'date': DateTime(2025, 3, 28),
    },
    {
      'day': 27,
      'duration': '5.7h',
      'quality': 'Deep',
      'date': DateTime(2025, 3, 27),
    },
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

    // Initialize animation controller
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

    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _handleDateSelection(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
  }

  List<Map<String, dynamic>> _getFilteredSleepRecords() {
    if (_selectedDate == null) {
      return _sleepHistory; // Show all if no date is selected
    }

    List<Map<String, dynamic>> records =
        _sleepHistory.where((sleep) {
          if (sleep['date'] == null) return false; // Handle missing date safely

          return DateFormat('yyyy-MM-dd').format(sleep['date'] as DateTime) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate!);
        }).toList();

    print('Found ${records.length} sleep records for ${_selectedDate}');
    return records;
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Select Month & Year',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Year selector
                  Text(
                    'Year',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 50,
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

                  const SizedBox(height: 20),

                  // Month selector
                  Text(
                    'Month',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final monthDate = DateTime(_selectedYear, monthNum, 1);

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

                  const SizedBox(height: 20),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                          _selectedYear = newMonth.year;
                        });

                        // Start animation
                        _pageTransitionController.forward();
                      },
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
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
    bool isAfterJoinDate = monthDate.isAfter(
      DateTime(widget.userJoinDate.year, widget.userJoinDate.month - 1, 1),
    );

    // Month should not be in the future
    bool isNotInFuture = monthDate.isBefore(
      DateTime(_today.year, _today.month + 1, 1),
    );

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
          child: SingleChildScrollView(
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
                      GestureDetector(
                        onTap: _showMonthYearPicker,
                        child: Row(
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(_selectedMonth),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: const Color(0xFF1E293B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sleep score this month card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('😴', style: TextStyle(fontSize: 40)),
                            const SizedBox(width: 8),
                            Text(
                              '25',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your Sleep Score this month',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                        onDateSelected:
                            _handleDateSelection, // Pass the callback
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sleep History Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sleep History',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Check if sleep history is empty
                  if (_getFilteredSleepRecords().isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No sleep records for this period',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                  // Sleep records list
                  Column(
                    children:
                        _getFilteredSleepRecords()
                            .map((sleep) => _buildSleepItem(sleep))
                            .toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepItem(Map<String, dynamic> sleep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MAR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  sleep['day'].toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You slept for ${sleep['duration']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'No Suggestions',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  sleep['quality'] == 'Deep'
                      ? Colors.grey.shade200
                      : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sleep['quality'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    sleep['quality'] == 'Deep'
                        ? Colors.grey.shade700
                        : Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
