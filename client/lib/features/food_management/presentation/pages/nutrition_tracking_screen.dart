import 'package:client/features/food_management/presentation/widgets/custom_date_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_progress_bars.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_legend.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_metrics_card.dart';
import 'package:client/features/food_management/presentation/widgets/date_picker.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_header.dart';
import 'package:client/features/food_management/presentation/widgets/add_food_button.dart';
import 'package:client/features/food_management/presentation/providers/daily_food_provider.dart';

class NutritionTrackingPage extends StatefulWidget {
  const NutritionTrackingPage({super.key});

  @override
  State<NutritionTrackingPage> createState() => _NutritionTrackingPageState();
}

class _NutritionTrackingPageState extends State<NutritionTrackingPage>
    with TickerProviderStateMixin {
  // Date tracking
  DateTime _selectedDate = DateTime.now();
  final DateTime _today = DateTime.now();

  // Function to check if date is the current date
  bool get _isCurrentDate {
    return _selectedDate.year == _today.year &&
        _selectedDate.month == _today.month &&
        _selectedDate.day == _today.day;
  }

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

  // Calendar animation
  bool _isCalendarVisible = false;
  final double _calendarHeight = 350.0; // Adjust based on your calendar size
  double _calendarOffset = 0.0;
  bool _isDragging = false;

  late PageController _nutritionPageController;
  int _currentNutritionPage = 0;
  late AnimationController _pageAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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

    _nutritionPageController = PageController();
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _animationController.forward();

    // Initialize page controller
    _pageController = PageController(initialPage: 1); // Start in the middle
    _currentPage = 1;

    // Load daily food data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyFoodData();
    });
  }

  void _loadDailyFoodData() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyFoodProvider = Provider.of<DailyFoodProvider>(context, listen: false);
    dailyFoodProvider.getDailyFood(date: dateStr);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nutritionPageController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  // Change to a specific date with fixed implementation
  void _goToDate(DateTime date) {
    // Don't allow navigating to future dates
    if (date.isAfter(_today)) {
      date = _today;
    }

    setState(() {
      _selectedDate = date;
      _updateDataForSelectedDate();
    });

    // Reset page controller to middle position
    _pageController.jumpToPage(1);
    _currentPage = 1;
  }

  // Change to previous day - fixed implementation to handle many days back
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _updateDataForSelectedDate();

      // Load daily food data for the new date
      _loadDailyFoodData();
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
    // Don't allow navigating to future dates
    if (_isCurrentDate) {
      return;
    }

    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _updateDataForSelectedDate();

      // Load daily food data for the new date
      _loadDailyFoodData();
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
    final today = DateTime(_today.year, _today.month, _today.day);
    final difference = _selectedDate.difference(today).inDays;

    // Update current data based on difference
    if (difference == 0) {
      _currentData = _nutritionData['today']!;
    } else if (difference == -1) {
      _currentData = _nutritionData['yesterday']!;
    } else if (difference == -2) {
      _currentData = _nutritionData['2days_ago']!;
    } else {
      // For any other day, generate a random data set based on the other days
      final baseData = _nutritionData['yesterday']!;

      // Copy of the data with some random variation
      _currentData = {
        'totalNutrition': (double.parse(
          baseData['totalNutrition'].toString().replaceAll(',', '.'),
        ) *
            (0.8 +
                0.4 *
                    (DateTime.now().millisecondsSinceEpoch % 1000) /
                    1000))
            .toStringAsFixed(2)
            .replaceAll('.', ','),
        'proteins':
        '${(int.parse(baseData['proteins'].toString().replaceAll('g', '')) * (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).toInt()}g',
        'macro':
        '${(int.parse(baseData['macro'].toString().replaceAll('g', '')) * (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).toInt()}g',
        'fiber':
        '${(int.parse(baseData['fiber'].toString().replaceAll('g', '')) * (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).toInt()}g',
        'blueProgress':
        (baseData['blueProgress'] as double) *
            (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000),
        'lightBlueProgress':
        (baseData['lightBlueProgress'] as double) *
            (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000),
        'redProgress':
        (baseData['redProgress'] as double) *
            (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000),
        'pinkProgress':
        (baseData['pinkProgress'] as double) *
            (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000),
        'navyProgress':
        (baseData['navyProgress'] as double) *
            (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000),
        'grayProgress':
        (baseData['grayProgress'] as double) *
            (0.8 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000),
        'date': _selectedDate,
      };
    }

    // Reset and restart animation
    _animationController.reset();
    _animationController.forward();
  }

  // Handle calendar swipe gesture
  void _handleSwipe(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        // Calculate new offset
        _calendarOffset -= details.delta.dy;

        // Constrain the offset
        _calendarOffset = _calendarOffset.clamp(0.0, _calendarHeight);

        // Update visibility status
        _isCalendarVisible = _calendarOffset > 50.0;
      });
    }
  }

  void _onSwipeEnd(DragEndDetails details) {
    if (_isDragging) {
      setState(() {
        _isDragging = false;

        // Snap to open or closed based on position
        if (_calendarOffset > _calendarHeight / 2) {
          _calendarOffset = _calendarHeight;
          _isCalendarVisible = true;
        } else {
          _calendarOffset = 0.0;
          _isCalendarVisible = false;
        }
      });
    }
  }

  void _onSwipeStart(DragStartDetails details) {
    // Only respond to upward swipes starting near the date navigator
    if (details.globalPosition.dy > MediaQuery.of(context).size.height - 150) {
      setState(() {
        _isDragging = true;
      });
    }
  }

  // Build calendar widget
  Widget _buildCalendar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _calendarOffset,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: _calendarHeight,
            child: Stack(
              children: [
                DatePicker(
                  selectedDate: _selectedDate,
                  onDateSelected: _goToDate,
                ),
                // Handle on top for dragging
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build nutrition content page
  Widget _buildNutritionPage(double screenWidth) {
    final dailyFoodProvider = Provider.of<DailyFoodProvider>(context);
    final dailyFood = dailyFoodProvider.dailyFood;

    // Use API data if available, otherwise use mock data
    final totalNutrition = dailyFood != null
        ? dailyFood.totalCalories.toStringAsFixed(2)
        : _currentData['totalNutrition'];

    final proteins = dailyFood != null
        ? '${dailyFood.totalProtein.toStringAsFixed(1)}g'
        : _currentData['proteins'];

    final carbs = dailyFood != null
        ? '${dailyFood.totalCarbs.toStringAsFixed(1)}g'
        : _currentData['macro'];

    final fats = dailyFood != null
        ? '${dailyFood.totalFats.toStringAsFixed(1)}g'
        : _currentData['fiber'];

    // Create a data map that combines API and mock data
    final displayData = Map<String, dynamic>.from(_currentData);
    if (dailyFood != null) {
      displayData['totalNutrition'] = totalNutrition;
      displayData['proteins'] = proteins;
      displayData['macro'] = carbs;
      displayData['fiber'] = fats;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    displayData['totalNutrition'],
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Progress bars with animation
                    NutritionProgressBars(
                      currentData: displayData,
                      progressAnimation: _progressAnimation,
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
                          child: const NutritionLegend(),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

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
                            child: NutritionMetricsCard(
                              currentData: displayData,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onNutritionPageChanged(int page) {
    setState(() {
      _currentNutritionPage = page;
      // Update data based on page
      final keys = _nutritionData.keys.toList();
      if (page < keys.length) {
        _updateDataForDate(DateTime.now().subtract(Duration(days: keys.length - 1 - page)));
      }
    });

    // Trigger slide animation
    _pageAnimationController.forward().then((_) {
      _pageAnimationController.reverse();
    });
  }

  // Update data based on date
  void _updateDataForDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _updateDataForSelectedDate();
    });
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GestureDetector(
        onVerticalDragStart: _onSwipeStart,
        onVerticalDragUpdate: _handleSwipe,
        onVerticalDragEnd: _onSwipeEnd,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  NutritionHeader(onBack: () => Navigator.pop(context)),

                  // Loading indicator or error message
                  Consumer<DailyFoodProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (provider.error.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error: ${provider.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Main content with PageView for transitions
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
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

                  // Date navigation with visual indicator for calendar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: CustomDateNavigation(
                      selectedDate: _selectedDate,
                      isCurrentDate: _isCurrentDate,
                      onDateSelected: _goToDate,
                      onPrevious: _goToPreviousDay,
                      onNext: _goToNextDay,
                    ),
                  ),

                  // Add Food button
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: AddFoodButton(
                      onPressed: () {
                        // Add food functionality
                      },
                    ),
                  ),
                ],
              ),

              // Calendar overlay that slides in from bottom
              Positioned(left: 0, right: 0, bottom: 0, child: _buildCalendar()),
            ],
          ),
        ),
      ),
    );
  }
}
