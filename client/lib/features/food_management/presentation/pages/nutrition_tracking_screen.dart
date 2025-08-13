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

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Page transition
  late PageController _pageController;
  int _currentPage = 0;

  // Calendar animation
  bool _isCalendarVisible = false;
  final double _calendarHeight = 350.0;
  double _calendarOffset = 0.0;
  bool _isDragging = false;

  late PageController _nutritionPageController;
  int _currentNutritionPage = 0;
  late AnimationController _pageAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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
    _pageController = PageController(initialPage: 1);
    _currentPage = 1;

    // Load daily food data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyFoodData();
    });
  }

  void _loadDailyFoodData() {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final dailyFoodProvider = Provider.of<DailyFoodProvider>(context, listen: false);
      dailyFoodProvider.getDailyFood(date: dateStr);
    } catch (e) {
      print('Error loading daily food data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nutritionPageController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  // Change to a specific date
  void _goToDate(DateTime date) {
    if (date.isAfter(_today)) {
      date = _today;
    }

    setState(() {
      _selectedDate = date;
    });

    _loadDailyFoodData();
    _pageController.jumpToPage(1);
    _currentPage = 1;
    _animationController.reset();
    _animationController.forward();
  }

  // Change to previous day - Fixed to prevent double navigation
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadDailyFoodData();
    _animationController.reset();
    _animationController.forward();
  }

  // Change to next day - Fixed to prevent double navigation
  void _goToNextDay() {
    if (_isCurrentDate) {
      return;
    }

    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadDailyFoodData();
    _animationController.reset();
    _animationController.forward();
  }

  // Handle calendar swipe gesture
  void _handleSwipe(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _calendarOffset -= details.delta.dy;
        _calendarOffset = _calendarOffset.clamp(0.0, _calendarHeight);
        _isCalendarVisible = _calendarOffset > 50.0;
      });
    }
  }

  void _onSwipeEnd(DragEndDetails details) {
    if (_isDragging) {
      setState(() {
        _isDragging = false;
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
    if (details.globalPosition.dy > MediaQuery.of(context).size.height - 150) {
      setState(() {
        _isDragging = true;
      });
    }
  }

  // Build calendar widget - Removed box shadow
  Widget _buildCalendar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _calendarOffset,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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

  // Calculate nutrition data with comprehensive null safety
  Map<String, dynamic> _calculateNutritionData(dynamic dailyFood, bool hasError) {
    // If there's an error or data is null, return zero values
    if (hasError || dailyFood == null) {
      return {
        'totalNutrition': '0',
        'proteins': '0.0g',
        'macro': '0.0g',
        'fiber': '0.0g',
        'blueProgress': 0.0,
        'lightBlueProgress': 0.0,
        'redProgress': 0.0,
        'pinkProgress': 0.0,
        'navyProgress': 0.0,
        'grayProgress': 0.0,
      };
    }

    try {
      // Daily targets
      const double dailyCalorieTarget = 2000;
      const double dailyProteinTarget = 150;
      const double dailyCarbTarget = 250;
      const double dailyFatTarget = 65;

      // Safely extract values with multiple fallbacks
      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFats = 0.0;

      // Handle different possible data structures
      if (dailyFood != null) {
        // Try to get totalCalories
        if (dailyFood.totalCalories != null) {
          totalCalories = double.tryParse(dailyFood.totalCalories.toString()) ?? 0.0;
        }

        // Try to get totalProtein
        if (dailyFood.totalProtein != null) {
          totalProtein = double.tryParse(dailyFood.totalProtein.toString()) ?? 0.0;
        }

        // Try to get totalCarbs
        if (dailyFood.totalCarbs != null) {
          totalCarbs = double.tryParse(dailyFood.totalCarbs.toString()) ?? 0.0;
        }

        // Try to get totalFats
        if (dailyFood.totalFats != null) {
          totalFats = double.tryParse(dailyFood.totalFats.toString()) ?? 0.0;
        }
      }

      // Calculate progress percentages safely
      final double calorieProgress = totalCalories > 0
          ? (totalCalories / dailyCalorieTarget).clamp(0.0, 1.0)
          : 0.0;
      final double proteinProgress = totalProtein > 0
          ? (totalProtein / dailyProteinTarget).clamp(0.0, 1.0)
          : 0.0;
      final double carbProgress = totalCarbs > 0
          ? (totalCarbs / dailyCarbTarget).clamp(0.0, 1.0)
          : 0.0;
      final double fatProgress = totalFats > 0
          ? (totalFats / dailyFatTarget).clamp(0.0, 1.0)
          : 0.0;

      return {
        'totalNutrition': totalCalories.toStringAsFixed(0),
        'proteins': '${totalProtein.toStringAsFixed(1)}g',
        'macro': '${totalCarbs.toStringAsFixed(1)}g',
        'fiber': '${totalFats.toStringAsFixed(1)}g',
        'blueProgress': calorieProgress,
        'lightBlueProgress': proteinProgress,
        'redProgress': carbProgress,
        'pinkProgress': fatProgress,
        'navyProgress': (calorieProgress + proteinProgress) / 2,
        'grayProgress': 0.2,
      };
    } catch (e) {
      print('Error calculating nutrition data: $e');
      // Return zero values if any error occurs
      return {
        'totalNutrition': '0',
        'proteins': '0.0g',
        'macro': '0.0g',
        'fiber': '0.0g',
        'blueProgress': 0.0,
        'lightBlueProgress': 0.0,
        'redProgress': 0.0,
        'pinkProgress': 0.0,
        'navyProgress': 0.0,
        'grayProgress': 0.0,
      };
    }
  }

  // Build nutrition content page
  Widget _buildNutritionPage(double screenWidth) {
    return Consumer<DailyFoodProvider>(
      builder: (context, dailyFoodProvider, child) {
        // Check for errors first
        final bool hasError = dailyFoodProvider.error.isNotEmpty;

        // Calculate nutrition data with error handling
        final nutritionData = _calculateNutritionData(
            dailyFoodProvider.dailyFood,
            hasError
        );

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
                                        nutritionData['totalNutrition']?.toString() ?? '0',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'kcal',
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
                          currentData: nutritionData,
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
                                  currentData: nutritionData,
                                ),
                              ),
                            );
                          },
                        ),

                        // Show message when no data is available - Removed box shadow
                        if (hasError || dailyFoodProvider.dailyFood == null)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutQuad,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'No nutrition data available for this date. Start tracking your meals!',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
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
      },
    );
  }

  void _onNutritionPageChanged(int page) {
    setState(() {
      _currentNutritionPage = page;
    });

    _pageAnimationController.forward().then((_) {
      _pageAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

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

                  // Loading indicator
                  Consumer<DailyFoodProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Main content - Removed PageView to fix double navigation
                  Expanded(
                    child: _buildNutritionPage(screenWidth),
                  ),

                  // Date navigation - Removed box shadow
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
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

              // Calendar overlay
              Positioned(left: 0, right: 0, bottom: 0, child: _buildCalendar()),
            ],
          ),
        ),
      ),
    );
  }
}
