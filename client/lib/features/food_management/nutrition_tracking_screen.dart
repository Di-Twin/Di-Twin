import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NutritionTrackingScreen extends StatefulWidget {
  const NutritionTrackingScreen({super.key});

  @override
  State<NutritionTrackingScreen> createState() =>
      _NutritionTrackingScreenState();
}

class _NutritionTrackingScreenState extends State<NutritionTrackingScreen>
    with SingleTickerProviderStateMixin {
  // Date tracking
  DateTime _selectedDate = DateTime.now();

  // Sample data for different days
  final Map<String, Map<String, dynamic>> _nutritionData = {
    'today': {
      'totalNutrition': '501,81',
      'proteins': '510g',
      'macro': '16g',
      'fiber': '70g',
      'blueProgress': 0.7,
      'lightBlueProgress': 0.3,
      'redProgress': 0.4,
      'pinkProgress': 0.6,
      'navyProgress': 0.8,
      'grayProgress': 0.2,
      'date': DateTime.now(),
    },
    'yesterday': {
      'totalNutrition': '423,45',
      'proteins': '480g',
      'macro': '12g',
      'fiber': '65g',
      'blueProgress': 0.6,
      'lightBlueProgress': 0.3,
      'redProgress': 0.3,
      'pinkProgress': 0.6,
      'navyProgress': 0.7,
      'grayProgress': 0.2,
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    '2days_ago': {
      'totalNutrition': '550,20',
      'proteins': '530g',
      'macro': '18g',
      'fiber': '75g',
      'blueProgress': 0.8,
      'lightBlueProgress': 0.3,
      'redProgress': 0.5,
      'pinkProgress': 0.6,
      'navyProgress': 0.9,
      'grayProgress': 0.2,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
  };

  // Current data
  late Map<String, dynamic> _currentData;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Page transition
  late PageController _pageController;
  int _currentPage = 0;

  // For month selection in drawer
  late DateTime _selectedMonth;
  late int _selectedYear;
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize date variables
    _selectedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _selectedYear = _selectedDate.year;

    // Initialize current data
    _currentData = _nutritionData['today']!;

    // Set up animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // Start the animation
    _animationController.forward();

    // Initialize page controller
    _pageController = PageController(initialPage: 1); // Start in the middle
    _currentPage = 1;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Change to previous day
  void _goToPreviousDay() {
    // Get the previous day data
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));

      // Update current data based on selected date
      _updateDataForSelectedDate();
    });

    // First reset to middle page if we're at the end
    if (_currentPage == 2) {
      _pageController.jumpToPage(1);
      _currentPage = 1;
    }

    // Then animate to the "previous" page
    _pageController.animateToPage(
      _currentPage - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // Change to next day
  void _goToNextDay() {
    if (_selectedDate.isAtSameMomentAs(DateTime.now())) {
      // Already at today, don't go forward
      return;
    }

    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));

      // Update current data based on selected date
      _updateDataForSelectedDate();
    });

    // First reset to middle page if we're at the beginning
    if (_currentPage == 0) {
      _pageController.jumpToPage(1);
      _currentPage = 1;
    }

    // Then animate to the "next" page
    _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // Update data based on selected date
  void _updateDataForSelectedDate() {
    // Calculate difference in days from today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = _selectedDate.difference(today).inDays;

    // Update current data based on difference
    if (difference == 0) {
      _currentData = _nutritionData['today']!;
    } else if (difference == -1) {
      _currentData = _nutritionData['yesterday']!;
    } else if (difference == -2) {
      _currentData = _nutritionData['2days_ago']!;
    } else {
      // For any other day, use either yesterday or 2days_ago data as fallback
      _currentData =
          difference > 0
              ? _nutritionData['today']!
              : _nutritionData['yesterday']!;
    }

    // Reset and restart animation
    _animationController.reset();
    _animationController.forward();
  }

  // Show date picker drawer
  void _showDatePickerDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _buildDatePickerDrawer(context, setState);
          },
        );
      },
    );
  }

  // Build date picker drawer
  Widget _buildDatePickerDrawer(
    BuildContext context,
    StateSetter drawerSetState,
  ) {
    // Get available years (current year and previous year)
    final List<int> availableYears = [
      DateTime.now().year - 1,
      DateTime.now().year,
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle and header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                SizedBox(height: 20),

                // Title with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
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

          // Current selection display
          Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A73E8), Color(0xFF4D8EFF)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1A73E8).withOpacity(0.25),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Calendar icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 20),

                // Date display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(_selectedDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, y').format(_selectedDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick shortcuts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Select',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickDateButton(
                      'Today',
                      DateTime.now(),
                      drawerSetState,
                    ),
                    SizedBox(width: 12),
                    _buildQuickDateButton(
                      'Yesterday',
                      DateTime.now().subtract(Duration(days: 1)),
                      drawerSetState,
                    ),
                    SizedBox(width: 12),
                    _buildQuickDateButton(
                      'Last Week',
                      DateTime.now().subtract(Duration(days: 7)),
                      drawerSetState,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Month and year selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                // Year selector
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF1A73E8),
                            ),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                drawerSetState(() {
                                  _selectedYear = newValue;
                                  // Update selected date
                                  _selectedDate = DateTime(
                                    _selectedYear,
                                    _selectedDate.month,
                                    _selectedDate.day,
                                  );
                                });
                              }
                            },
                            items:
                                availableYears.map<DropdownMenuItem<int>>((
                                  int value,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16),

                // Month selector
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedDate.month,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF1A73E8),
                            ),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                drawerSetState(() {
                                  // Update selected date
                                  _selectedDate = DateTime(
                                    _selectedYear,
                                    newValue,
                                    _selectedDate.day,
                                  );
                                });
                              }
                            },
                            items:
                                List.generate(
                                  12,
                                  (index) => index + 1,
                                ).map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(_monthNames[value - 1]),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Calendar days grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(child: _buildCalendarDaysGrid(drawerSetState)),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Color(0xFF1A73E8).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  // Update the selected date and data
                  setState(() {
                    _updateDataForSelectedDate();
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
          ),
        ],
      ),
    );
  }

  // Build calendar days grid
  Widget _buildCalendarDaysGrid(StateSetter setState) {
    // Get days in month
    final daysInMonth = DateTime(_selectedYear, _selectedDate.month + 1, 0).day;

    // Get first day of month
    final firstDayOfMonth = DateTime(_selectedYear, _selectedDate.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;

    // Adjust for Sunday start (1-7 to 0-6)
    final firstWeekdayAdjusted = (firstWeekdayOfMonth % 7);

    // Create list of day widgets
    List<Widget> dayWidgets = [];

    // Add weekday headers
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var weekday in weekdays) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            weekday,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    // Add empty spaces for days before first day of month
    for (var i = 0; i < firstWeekdayAdjusted; i++) {
      dayWidgets.add(Container());
    }

    // Add days of month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedYear, _selectedDate.month, day);
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isFutureDate = date.isAfter(DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap:
              isFutureDate
                  ? null
                  : () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A73E8), Color(0xFF4D8EFF)],
                      )
                      : null,
              color: isToday && !isSelected ? Colors.grey.shade200 : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Color(0xFF1A73E8).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight:
                      isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected
                          ? Colors.white
                          : (isFutureDate
                              ? Colors.grey.shade400
                              : Color(0xFF1E293B)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  // Helper method for quick date selection buttons
  Widget _buildQuickDateButton(
    String label,
    DateTime date,
    StateSetter setState,
  ) {
    final isSelected =
        _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedDate = date;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xFF1A73E8) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Color(0xFF1E293B),
          elevation: isSelected ? 2 : 0,
          shadowColor:
              isSelected
                  ? Color(0xFF1A73E8).withOpacity(0.3)
                  : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive sizes
    final headerHeight = screenHeight * 0.08;
    final mainContentHeight = screenHeight * 0.7;
    final bottomNavHeight = screenHeight * 0.08;
    final buttonHeight = screenHeight * 0.06; // Reduced button height

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(
              height: headerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button with shadow and animation
                    Hero(
                      tag: 'back_button',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white, Color(0xFFF8FAFC)],
                              ),
                              border: Border.all(
                                color: const Color(0xFF1E293B).withOpacity(0.1),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Text(
                            'Nutrition',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        );
                      },
                    ),

                    // Needs More badge with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Needs More',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Main content with PageView for transitions
            SizedBox(
              height: mainContentHeight,
              width: screenWidth, // Ensure full width
              child: PageView(
                controller: _pageController,
                physics:
                    const BouncingScrollPhysics(), // Allow bouncing but not free scrolling
                onPageChanged: (index) {
                  setState(() {
                    // When page changes, we need to update _currentPage
                    if (_currentPage < index) {
                      // Moving forward in time (right to left)
                      _goToNextDay();
                    } else if (_currentPage > index) {
                      // Moving backward in time (left to right)
                      _goToPreviousDay();
                    }
                    _currentPage = index;
                  });
                },
                children: [
                  // Previous day page
                  _buildNutritionPage(screenWidth),

                  // Current day page
                  _buildNutritionPage(screenWidth),

                  // Next day page (if applicable)
                  _buildNutritionPage(screenWidth),
                ],
              ),
            ),

            // Date navigation
            Container(
              height: bottomNavHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFF8FAFC)],
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _goToNextDay(),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: const Color(0xFF1E293B).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showDatePickerDrawer(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A73E8).withOpacity(0.1),
                            Color(0xFF4D8EFF).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF1A73E8).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: const Color(0xFF1A73E8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate.isAtSameMomentAs(
                                  DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                  ),
                                )
                                ? 'Today'
                                : DateFormat('MMM d').format(_selectedDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A73E8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _goToPreviousDay(),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF1E293B).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Add Food button with animation (smaller size)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0xFF1A73E8).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add Food',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build nutrition content page
  Widget _buildNutritionPage(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Your Nutrition section with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuad,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    'Your Nutrition',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Large nutrition value with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutQuad,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _currentData['totalNutrition'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'mg',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Progress bars with animation
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  // First row
                  Row(
                    children: [
                      // Blue progress bar (longer)
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0E2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Foreground (animated)
                            Container(
                              height: 40,
                              width:
                                  screenWidth *
                                  0.7 *
                                  _currentData['blueProgress'] *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF1A73E8),
                                    Color(0xFF4D8EFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1A73E8,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Light blue progress bar (shorter)
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0E2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Foreground (animated)
                            Container(
                              height: 40,
                              width:
                                  screenWidth *
                                  0.3 *
                                  _currentData['lightBlueProgress'] *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF4D8EFF),
                                    Color(0xFF81ACFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4D8EFF,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Second row
                  Row(
                    children: [
                      // Red progress bar (shorter)
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD0D0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Foreground (animated)
                            Container(
                              height: 40,
                              width:
                                  screenWidth *
                                  0.4 *
                                  _currentData['redProgress'] *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF8E8E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pink progress bar (longer)
                      Expanded(
                        flex: 6,
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD0D0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Foreground (animated)
                            Container(
                              height: 40,
                              width:
                                  screenWidth *
                                  0.6 *
                                  _currentData['pinkProgress'] *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFFF8E8E),
                                    Color(0xFFFFC0C0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF8E8E,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Third row
                  Row(
                    children: [
                      // Navy progress bar (longer)
                      Expanded(
                        flex: 8,
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Foreground (animated)
                            Container(
                              height: 40,
                              width:
                                  screenWidth *
                                  0.8 *
                                  _currentData['navyProgress'] *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF1E293B),
                                    Color(0xFF334155),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1E293B,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Gray progress bar (shorter)
                      Expanded(
                        flex: 2,
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Foreground (animated)
                            Container(
                              height: 40,
                              width:
                                  screenWidth *
                                  0.2 *
                                  _currentData['grayProgress'] *
                                  _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF64748B),
                                    Color(0xFF94A3B8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF64748B,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Legend with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuad,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Target legend
                      Row(
                        children: [
                          _buildLegendDot(const Color(0xFFD0E2FF)),
                          _buildLegendDot(const Color(0xFFFFD0D0)),
                          _buildLegendDot(Colors.grey.shade300),
                          const SizedBox(width: 8),
                          Text(
                            'Target',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),

                      // Taken legend
                      Row(
                        children: [
                          _buildLegendDot(const Color(0xFF1A73E8)),
                          _buildLegendDot(const Color(0xFFFF6B6B)),
                          _buildLegendDot(const Color(0xFF1E293B)),
                          const SizedBox(width: 8),
                          Text(
                            'Taken',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Nutrition metrics with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutQuad,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFF8FAFC)],
                      ),
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
                        // Proteins
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A73E8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Proteins',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentData['proteins'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical divider
                        Container(
                          width: 1,
                          height: 70,
                          color: Colors.grey.shade300,
                        ),

                        // Macro
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B6B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Macro',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentData['macro'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical divider
                        Container(
                          width: 1,
                          height: 70,
                          color: Colors.grey.shade300,
                        ),

                        // Fiber
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fiber',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentData['fiber'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
