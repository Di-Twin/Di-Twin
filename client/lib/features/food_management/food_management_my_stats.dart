import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/CustomCalander.dart';
import 'package:client/widgets/CustomDrawer.dart';

class FoodManagementStatsScreen extends StatefulWidget {
  final DateTime userJoinDate;

  const FoodManagementStatsScreen({super.key, required this.userJoinDate});

  @override
  State<FoodManagementStatsScreen> createState() =>
      _FoodManagementStatsScreenState();
}

class _FoodManagementStatsScreenState extends State<FoodManagementStatsScreen>
    with TickerProviderStateMixin {
  // Class variables
  List<int> _availableYears = [];
  List<DateTime> _availableMonths = [];
  DateTime _today = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate;
  List<DateTime> _last5Days = [];
  int? _expandedFoodIndex; // Track which food item is expanded

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

  // Sample data for nutrition tracking
  final Map<int, bool> _nutritionRegularity = {
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
    23: true,
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

  // Enhanced food history with meal type
  final List<Map<String, dynamic>> _foodHistory = [
    {
      'name': 'Dosa',
      'calories': 241,
      'image': 'images/dosa.png',
      'color': Color(0xFF5D6B89),
      'date': DateTime.now().subtract(Duration(days: 0)),
      'time': '9:00 AM',
      'weight': '500g',
      'mealType': 'breakfast',
      'protein': 8,
      'carbs': 45,
      'fat': 5,
    },
    {
      'name': 'Salad Bowl',
      'calories': 112,
      'image': 'images/salad.png',
      'color': Color(0xFF4CAF50),
      'date': DateTime.now().subtract(Duration(days: 1)),
      'time': '1:30 PM',
      'weight': '350g',
      'mealType': 'lunch',
      'protein': 5,
      'carbs': 12,
      'fat': 6,
    },
    {
      'name': 'Grilled Chicken',
      'calories': 320,
      'image': 'images/chicken.png',
      'color': Color(0xFF1976D2),
      'date': DateTime.now().subtract(Duration(days: 2)),
      'time': '7:15 PM',
      'weight': '250g',
      'mealType': 'dinner',
      'protein': 35,
      'carbs': 2,
      'fat': 15,
    },
    {
      'name': 'Smoothie Bowl',
      'calories': 180,
      'image': 'images/smoothie.png',
      'color': Color(0xFF9C27B0),
      'date': DateTime.now().subtract(Duration(days: 3)),
      'time': '8:45 AM',
      'weight': '400g',
      'mealType': 'breakfast',
      'protein': 6,
      'carbs': 30,
      'fat': 4,
    },
    {
      'name': 'Pasta',
      'calories': 420,
      'image': 'images/pasta.png',
      'color': Color(0xFFFF5722),
      'date': DateTime.now().subtract(Duration(days: 4)),
      'time': '6:30 PM',
      'weight': '350g',
      'mealType': 'dinner',
      'protein': 15,
      'carbs': 65,
      'fat': 10,
    },
    {
      'name': 'Avocado Toast',
      'calories': 280,
      'image': 'images/avocado_toast.png',
      'color': Color(0xFF8BC34A),
      'date': DateTime.now(),
      'time': '10:30 AM',
      'weight': '200g',
      'mealType': 'breakfast',
      'protein': 8,
      'carbs': 30,
      'fat': 15,
    },
    {
      'name': 'Quinoa Bowl',
      'calories': 350,
      'image': 'images/quinoa.png',
      'color': Color(0xFFFF9800),
      'date': DateTime.now(),
      'time': '1:00 PM',
      'weight': '300g',
      'mealType': 'lunch',
      'protein': 12,
      'carbs': 45,
      'fat': 8,
    },
    {
      'name': 'Salmon Fillet',
      'calories': 380,
      'image': 'images/salmon.png',
      'color': Color(0xFFE91E63),
      'date': DateTime.now(),
      'time': '7:30 PM',
      'weight': '220g',
      'mealType': 'dinner',
      'protein': 40,
      'carbs': 0,
      'fat': 20,
    },
  ];

  // Food being edited
  Map<String, dynamic>? _foodBeingEdited;

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
      _expandedFoodIndex = null; // Reset expanded food when date changes
    });
  }

  List<Map<String, dynamic>> _getFilteredFoods() {
    if (_selectedDate == null) {
      // Show last 5 days foods by default
      return _foodHistory.where((food) {
        if (food['date'] == null) return false;

        final foodDate = food['date'] as DateTime;
        return _last5Days.any(
          (date) =>
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(foodDate),
        );
      }).toList();
    }

    return _foodHistory.where((food) {
      if (food['date'] == null) return false;

      return DateFormat('yyyy-MM-dd').format(food['date'] as DateTime) ==
          DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }).toList();
  }

  // Get foods categorized by meal type
  Map<String, List<Map<String, dynamic>>> _getCategorizedFoods() {
    final filteredFoods = _getFilteredFoods();

    // Initialize with empty lists for each meal type
    final Map<String, List<Map<String, dynamic>>> categorized = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    // Categorize foods by meal type
    for (var food in filteredFoods) {
      final mealType = food['mealType'] as String? ?? 'snack';
      if (categorized.containsKey(mealType)) {
        categorized[mealType]!.add(food);
      } else {
        categorized['snack']!.add(food);
      }
    }

    return categorized;
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

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Color(0xFF0F67FE)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: Color(
                                                    0xFF0F67FE,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 4,
                                                  spreadRadius: 0,
                                                  offset: Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap:
                                            isFutureYear
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _selectedYear = year;

                                                    // Get months available in the selected year
                                                    List<DateTime>
                                                    monthsInYear =
                                                        _availableMonths
                                                            .where(
                                                              (month) =>
                                                                  month.year ==
                                                                  year,
                                                            )
                                                            .toList();

                                                    if (monthsInYear
                                                        .isNotEmpty) {
                                                      // If current year, default to current month; otherwise, use first available
                                                      _selectedMonth =
                                                          (year == _today.year)
                                                              ? DateTime(
                                                                year,
                                                                _today.month,
                                                                1,
                                                              )
                                                              : monthsInYear
                                                                  .first;
                                                    }
                                                  });
                                                },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Center(
                                          child: Text(
                                            year.toString(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : (isFutureYear
                                                          ? Colors.grey.shade400
                                                          : Color(0xFF1E293B)),
                                            ),
                                          ),
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

                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    gradient:
                                        isSelected
                                            ? LinearGradient(
                                              colors: [
                                                Color(0xFF0F67FE),
                                                Color(0xFF4D8EFF),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                            : null,
                                    color:
                                        isSelected
                                            ? null
                                            : (isAvailable
                                                ? Colors.white
                                                : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: Color(
                                                  0xFF0F67FE,
                                                ).withOpacity(0.2),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                    border:
                                        !isSelected && isAvailable
                                            ? Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            )
                                            : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
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
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            monthName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : (isAvailable
                                                          ? Color(0xFF1E293B)
                                                          : Colors
                                                              .grey
                                                              .shade400),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.transparent,
                                            ),
                                          ),
                                        ],
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
                                  _expandedFoodIndex =
                                      null; // Reset expanded food
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
      _expandedFoodIndex = null; // Reset expanded food when month changes
    });

    // Start animation
    _pageTransitionController.forward();

    // Restart score animation
    _scoreAnimationController.reset();
    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  // Show food edit drawer
  void _showFoodEditDrawer(Map<String, dynamic> food) {
    setState(() {
      _foodBeingEdited = Map<String, dynamic>.from(food);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Edit Food',
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

                  // Food edit form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food name
                          Text(
                            'Food Name',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            initialValue: _foodBeingEdited!['name'],
                            decoration: InputDecoration(
                              hintText: 'Enter food name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _foodBeingEdited!['name'] = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),

                          // Calories
                          Text(
                            'Calories',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                _foodBeingEdited!['calories'].toString(),
                            decoration: InputDecoration(
                              hintText: 'Enter calories',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixText: 'kcal',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _foodBeingEdited!['calories'] =
                                    int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                          SizedBox(height: 20),

                          // Weight
                          Text(
                            'Weight',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            initialValue: _foodBeingEdited!['weight'],
                            decoration: InputDecoration(
                              hintText: 'Enter weight (e.g. 250g)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _foodBeingEdited!['weight'] = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),

                          // Time
                          Text(
                            'Time',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              // Parse current time
                              final timeStr =
                                  _foodBeingEdited!['time'] as String;
                              final format = DateFormat('h:mm a');
                              final time = format.parse(timeStr);
                              final initialTime = TimeOfDay(
                                hour: time.hour,
                                minute: time.minute,
                              );

                              final TimeOfDay? selectedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: initialTime,
                                  );

                              if (selectedTime != null) {
                                setState(() {
                                  final hour = selectedTime.hourOfPeriod;
                                  final minute = selectedTime.minute;
                                  final period =
                                      selectedTime.period == DayPeriod.am
                                          ? 'AM'
                                          : 'PM';
                                  _foodBeingEdited!['time'] =
                                      '$hour:${minute.toString().padLeft(2, '0')} $period';
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _foodBeingEdited!['time'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Meal Type
                          Text(
                            'Meal Type',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _foodBeingEdited!['mealType'] as String,
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                    value: 'breakfast',
                                    child: Text('Breakfast'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'lunch',
                                    child: Text('Lunch'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'dinner',
                                    child: Text('Dinner'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'snack',
                                    child: Text('Snack'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _foodBeingEdited!['mealType'] = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Macronutrients
                          Text(
                            'Macronutrients',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Protein, Carbs, Fat
                          Row(
                            children: [
                              // Protein
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Protein (g)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    TextFormField(
                                      initialValue:
                                          _foodBeingEdited!['protein']
                                              .toString(),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _foodBeingEdited!['protein'] =
                                              int.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),

                              // Carbs
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carbs (g)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    TextFormField(
                                      initialValue:
                                          _foodBeingEdited!['carbs'].toString(),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _foodBeingEdited!['carbs'] =
                                              int.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),

                              // Fat
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fat (g)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    TextFormField(
                                      initialValue:
                                          _foodBeingEdited!['fat'].toString(),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _foodBeingEdited!['fat'] =
                                              int.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save button
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
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
                        ),
                        onPressed: () {
                          // Update food item
                          final index = _foodHistory.indexWhere(
                            (item) =>
                                item['name'] == food['name'] &&
                                item['date'] == food['date'] &&
                                item['time'] == food['time'],
                          );

                          if (index != -1) {
                            this.setState(() {
                              _foodHistory[index] = _foodBeingEdited!;
                            });
                          }

                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Food updated successfully'),
                              backgroundColor: Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  // Show delete confirmation dialog
  void _showDeleteConfirmation(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFF44336),
                    size: 30,
                  ),
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  'Delete Food',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 8),

                // Message
                Text(
                  'Are you sure you want to delete ${food['name']}? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF64748B),
                          side: BorderSide(color: Color(0xFFE2E8F0)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Delete button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF44336),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Delete food item
                          setState(() {
                            _foodHistory.removeWhere(
                              (item) =>
                                  item['name'] == food['name'] &&
                                  item['date'] == food['date'] &&
                                  item['time'] == food['time'],
                            );
                            _expandedFoodIndex = null; // Reset expanded food
                          });

                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Food deleted successfully'),
                              backgroundColor: Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Delete',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a text theme using Google Fonts
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen =
        screenSize.width < 380; // Adjusted threshold for better responsiveness

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
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Back button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Header with month selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Nutrition Tracking',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isSmallScreen ? 20 : 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Month selector
                          InkWell(
                            onTap: _showMonthYearPicker,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 16,
                                vertical: isSmallScreen ? 6 : 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: isSmallScreen ? 14 : 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM').format(_selectedMonth),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 12 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: isSmallScreen ? 14 : 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Monthly score card
                      _buildMonthlyScoreCard(isSmallScreen),

                      const SizedBox(height: 24),

                      // Calendar with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildNutritionCalendar(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Food Intake section
                      Text(
                        'Food Intake',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Build categorized food sections
                      _buildCategorizedFoodSections(isSmallScreen),

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

  Widget _buildNutritionCalendar() {
    return ActivityCalendar(
      selectedMonth: _selectedMonth,
      today: _today,
      activityRegularity:
          _nutritionRegularity, // We'll reuse the same data structure
      userJoinedDate: widget.userJoinDate,
      onMonthChanged: _handleMonthChange,
      onDateSelected: _handleDateSelection,
      selectedDate: _selectedDate,
    );
  }

  Widget _buildMonthlyScoreCard(bool isSmallScreen) {
    // Reduced height monthly score card with different color scheme
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 10 : 16,
        horizontal: isSmallScreen ? 12 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF66BB6A),
          ], // Green color scheme for nutrition
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left side - Score and title
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '🥗',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 20),
                  ), // Food emoji
                ),
                SizedBox(width: isSmallScreen ? 6 : 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '78',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'This month Metabolic score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 10 : 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right side - Stats in a row
          Row(
            children: [
              _buildCompactStatItem(
                Icons.local_fire_department,
                '2,450',
                'kcal',
                isSmallScreen,
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              _buildCompactStatItem(
                Icons.restaurant,
                '32',
                'meals',
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(
    IconData icon,
    String value,
    String label,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: isSmallScreen ? 12 : 16),
            SizedBox(width: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 10 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 8 : 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Build categorized food sections
  Widget _buildCategorizedFoodSections(bool isSmallScreen) {
    final categorizedFoods = _getCategorizedFoods();
    final filteredFoods = _getFilteredFoods();

    if (filteredFoods.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.restaurant, size: 48, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No food entries found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Build sections for each meal type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breakfast section
        if (categorizedFoods['breakfast']!.isNotEmpty)
          _buildMealTypeSection(
            'Breakfast',
            categorizedFoods['breakfast']!,
            Color(0xFF4CAF50),
            Icons.breakfast_dining,
            isSmallScreen,
          ),

        // Lunch section
        if (categorizedFoods['lunch']!.isNotEmpty)
          _buildMealTypeSection(
            'Lunch',
            categorizedFoods['lunch']!,
            Color(0xFFFFA726),
            Icons.lunch_dining,
            isSmallScreen,
          ),

        // Dinner section
        if (categorizedFoods['dinner']!.isNotEmpty)
          _buildMealTypeSection(
            'Dinner',
            categorizedFoods['dinner']!,
            Color(0xFFEC407A),
            Icons.dinner_dining,
            isSmallScreen,
          ),

        // Snack section
        if (categorizedFoods['snack']!.isNotEmpty)
          _buildMealTypeSection(
            'Snack',
            categorizedFoods['snack']!,
            Color(0xFF7E57C2),
            Icons.restaurant,
            isSmallScreen,
          ),
      ],
    );
  }

  // Build meal type section
  Widget _buildMealTypeSection(
    String title,
    List<Map<String, dynamic>> foods,
    Color color,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        // Food items
        ...foods.asMap().entries.map((entry) {
          final index = entry.key;
          final food = entry.value;
          return _buildFoodItem(food, index, isSmallScreen);
        }),
      ],
    );
  }

  Widget _buildFoodItem(
    Map<String, dynamic> food,
    int index,
    bool isSmallScreen,
  ) {
    // Map food names to appropriate icons
    IconData getFoodIcon(String foodName) {
      switch (foodName.toLowerCase()) {
        case 'dosa':
          return Icons.breakfast_dining;
        case 'salad bowl':
          return Icons.eco;
        case 'grilled chicken':
          return Icons.set_meal;
        case 'smoothie bowl':
          return Icons.blender;
        case 'pasta':
          return Icons.dinner_dining;
        default:
          return Icons.restaurant;
      }
    }

    final isExpanded = _expandedFoodIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedFoodIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
          child: Column(
            children: [
              // Main food item row
              Row(
                children: [
                  // Food icon instead of image
                  Container(
                    width: isSmallScreen ? 50 : 60,
                    height: isSmallScreen ? 50 : 60,
                    decoration: BoxDecoration(
                      color: food['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getFoodIcon(food['name']),
                      color: food['color'],
                      size: isSmallScreen ? 24 : 30,
                    ),
                  ),

                  SizedBox(width: 12),

                  // Food details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        SizedBox(height: 4),

                        // Weight and time
                        Row(
                          children: [
                            Icon(
                              Icons.scale,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              food['weight'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            SizedBox(width: 12),

                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              food['time'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        // Calories
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${food['calories']} kcal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse indicator
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),

              // Expanded section with macros and action buttons
              if (isExpanded) ...[
                Divider(height: 24, color: Colors.grey.shade200),

                // Macros
                if (food.containsKey('protein') &&
                    food.containsKey('carbs') &&
                    food.containsKey('fat'))
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutrientBadge(
                          'Protein',
                          food['protein'],
                          Color(0xFF4CAF50),
                          'g',
                        ),
                        _buildNutrientBadge(
                          'Carbs',
                          food['carbs'],
                          Color(0xFF2196F3),
                          'g',
                        ),
                        _buildNutrientBadge(
                          'Fat',
                          food['fat'],
                          Color(0xFFFF9800),
                          'g',
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit button
                    TextButton.icon(
                      onPressed: () => _showFoodEditDrawer(food),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFF0F67FE),
                      ),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F67FE),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Delete button
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(food),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFF44336),
                      ),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF44336),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Build nutrient badge
  Widget _buildNutrientBadge(
    String label,
    int value,
    Color color,
    String unit,
  ) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$label ($unit)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
