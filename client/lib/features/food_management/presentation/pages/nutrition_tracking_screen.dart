import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_progress_bars.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_legend.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_metrics_card.dart';
import 'package:client/features/food_management/presentation/widgets/date_navigation.dart';
import 'package:client/features/food_management/presentation/widgets/date_picker_drawer.dart';
import 'package:client/features/food_management/presentation/widgets/nutrition_header.dart';
import 'package:client/features/food_management/presentation/widgets/add_food_button.dart';

class NutritionTrackingPage extends StatefulWidget {
  const NutritionTrackingPage({super.key});

  @override
  State<NutritionTrackingPage> createState() => _NutritionTrackingPageState();
}

class _NutritionTrackingPageState extends State<NutritionTrackingPage>
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
        return DatePickerDrawer(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _updateDataForSelectedDate();
            });
          },
        );
      },
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
          NutritionProgressBars(
            currentData: _currentData,
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
                  child: NutritionMetricsCard(currentData: _currentData),
                ),
              );
            },
          ),

          const Spacer(),
        ],
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            NutritionHeader(
              onBack: () => Navigator.pop(context),
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
            DateNavigation(
              selectedDate: _selectedDate,
              onPrevious: _goToPreviousDay,
              onNext: _goToNextDay,
              onSelectDate: _showDatePickerDrawer,
            ),

            // Add Food button
            Padding(
              padding: const EdgeInsets.all(12),
              child: AddFoodButton(
                onPressed: () {
                  // Add food functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
