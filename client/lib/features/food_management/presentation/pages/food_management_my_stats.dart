import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/CustomCalander.dart';
import 'package:client/widgets/CustomDrawer.dart';
import 'package:client/features/food_management/presentation/providers/food_management_provider.dart';
import 'package:client/features/food_management/presentation/widgets/monthly_score_card.dart';
import 'package:client/features/food_management/presentation/widgets/meal_type_section.dart';
import 'package:client/features/food_management/presentation/widgets/month_year_picker.dart';
import 'package:client/features/food_management/presentation/widgets/food_edit_form.dart';
import 'package:client/features/food_management/presentation/widgets/delete_confirmation_dialog.dart';

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

  bool _isLoadingFoodData = false;
  String? _loadingError;

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
  List<Map<String, dynamic>> _foodHistory = [];
  final FoodManagementProvider _foodProvider = FoodManagementProvider();

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedMonth = DateTime(_today.year, _today.month, 1);
    _selectedYear = _today.year;
    _selectedDate = _today; // Initialize selected date to today

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

    // Load food data
    _loadFoodData();

    // Add listener for navigation events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called after the widget is built
      // We can use it to set up listeners or do other initialization
      print('FoodManagementStatsScreen built');
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
    print('Date selected: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');

    setState(() {
      _selectedDate = selectedDate;
      _expandedFoodIndex = null; // Reset expanded food when date changes
    });

    // Add a small delay to ensure state is updated before loading data
    Future.delayed(Duration(milliseconds: 100), () {
      _loadFoodData();
    });
  }

  List<Map<String, dynamic>> _getFilteredFoods() {
    print('=== FILTERING DEBUG ===');
    print(
      'Selected date: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'null'}',
    );
    print('Total food history items: ${_foodHistory.length}');

    // Print all food dates for debugging
    for (int i = 0; i < _foodHistory.length; i++) {
      final food = _foodHistory[i];
      final foodDateStr =
          food['date'] != null
              ? DateFormat('yyyy-MM-dd').format(food['date'] as DateTime)
              : 'null';
      print('Food $i: ${food['name']} - Date: $foodDateStr');
    }

    if (_selectedDate == null) {
      // Show last 5 days foods by default
      final filtered =
          _foodHistory.where((food) {
            if (food['date'] == null) return false;

            final foodDate = food['date'] as DateTime;
            final isInLast5Days = _last5Days.any(
              (date) =>
                  DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(foodDate),
            );

            if (isInLast5Days) {
              print('✓ Food ${food['name']} matches last 5 days filter');
            }

            return isInLast5Days;
          }).toList();

      print('Filtered foods (last 5 days): ${filtered.length}');
      return filtered;
    }

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final filtered =
        _foodHistory.where((food) {
          if (food['date'] == null) {
            print('✗ Food ${food['name']} has null date');
            return false;
          }

          final foodDateStr = DateFormat(
            'yyyy-MM-dd',
          ).format(food['date'] as DateTime);
          final matches = foodDateStr == selectedDateStr;

          if (matches) {
            print(
              '✓ Food ${food['name']} matches selected date $selectedDateStr',
            );
          } else {
            print(
              '✗ Food ${food['name']} date $foodDateStr != $selectedDateStr',
            );
          }

          return matches;
        }).toList();

    print('Filtered foods for $selectedDateStr: ${filtered.length}');
    print('=== END FILTERING DEBUG ===');
    return filtered;
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
      _availableMonths.add(DateTime(startDate.year, startDate.month + 1, 1));
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
            return MonthYearPicker(
              selectedMonth: _selectedMonth,
              selectedYear: _selectedYear,
              availableYears: _availableYears,
              availableMonths: _availableMonths,
              today: _today,
              userJoinDate: widget.userJoinDate,
              onApply: (DateTime newMonth) {
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
                  _expandedFoodIndex = null; // Reset expanded food
                });

                // Start animation
                _pageTransitionController.forward();

                // Restart score animation
                _scoreAnimationController.reset();
                Future.delayed(Duration(milliseconds: 300), () {
                  _scoreAnimationController.forward();
                });
              },
            );
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

    // Restart score animation
    _scoreAnimationController.reset();
    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  // Show food edit drawer
  void _showFoodEditDrawer(dynamic foodData) {
    // Cast the dynamic to Map<String, dynamic>
    final food = foodData as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FoodEditForm(
          food: food,
          onSave: (updatedFood) {
            // Update food item
            final index = _foodHistory.indexWhere(
              (item) =>
                  item['name'] == food['name'] &&
                  item['date'] == food['date'] &&
                  item['time'] == food['time'],
            );

            if (index != -1) {
              setState(() {
                _foodHistory[index] = updatedFood;
              });
            }

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Food updated successfully'),
                backgroundColor: Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  // Show delete confirmation dialog
  dynamic _showDeleteConfirmation(dynamic foodData) {
    // Cast the dynamic to Map<String, dynamic>
    final food = foodData as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          food: food,
          onDelete: (food) {
            // Delete food item locally
            setState(() {
              _foodHistory.removeWhere(
                (item) =>
                    item['name'] == food['name'] &&
                    item['date'] == food['date'] &&
                    item['time'] == food['time'],
              );
              _expandedFoodIndex = null; // Reset expanded food
            });

            // Reload food data to ensure UI is in sync with provider
            _loadFoodData();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Food deleted successfully'),
                backgroundColor: Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );

    // Return null to match the expected return type
    return null;
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
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(_selectedDate ?? _today),
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
                      MonthlyScoreCard(
                        isSmallScreen: isSmallScreen,
                        scoreScaleAnimation: _scoreScaleAnimation,
                        scoreOpacityAnimation: _scoreOpacityAnimation,
                        scoreRotationAnimation: _scoreRotationAnimation,
                      ),

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

  // Build categorized food sections
  Widget _buildCategorizedFoodSections(bool isSmallScreen) {
    if (_isLoadingFoodData) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text(
              'Loading food data...',
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

    if (_loadingError != null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.error, size: 48, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text(
              _loadingError!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadFoodData, child: Text('Retry')),
          ],
        ),
      );
    }

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
              _selectedDate != null
                  ? 'No food entries for ${DateFormat('MMM d, yyyy').format(_selectedDate!)}'
                  : 'No food entries found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Build sections for each meal type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add debug info in development
        // if (kDebugMode)
        //   Container(
        //     padding: EdgeInsets.all(8),
        //     margin: EdgeInsets.only(bottom: 16),
        //     decoration: BoxDecoration(
        //       color: Colors.blue.shade50,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Text(
        //       'Total: ${filteredFoods.length} foods for ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'last 5 days'}',
        //       style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
        //     ),
        //   ),

        // Breakfast section
        MealTypeSection(
          title: 'Breakfast',
          foods: categorizedFoods['breakfast']!,
          color: Color(0xFF4CAF50),
          icon: Icons.breakfast_dining,
          isSmallScreen: isSmallScreen,
          expandedFoodIndex: _expandedFoodIndex,
          onToggleExpand: (index) {
            setState(() {
              _expandedFoodIndex = _expandedFoodIndex == index ? null : index;
            });
          },
          onEdit: _showFoodEditDrawer,
          onDelete: _showDeleteConfirmation,
        ),

        // Lunch section
        MealTypeSection(
          title: 'Lunch',
          foods: categorizedFoods['lunch']!,
          color: Color(0xFFFFA726),
          icon: Icons.lunch_dining,
          isSmallScreen: isSmallScreen,
          expandedFoodIndex: _expandedFoodIndex,
          onToggleExpand: (index) {
            setState(() {
              _expandedFoodIndex = _expandedFoodIndex == index ? null : index;
            });
          },
          onEdit: _showFoodEditDrawer,
          onDelete: _showDeleteConfirmation,
        ),

        // Dinner section
        MealTypeSection(
          title: 'Dinner',
          foods: categorizedFoods['dinner']!,
          color: Color(0xFFEC407A),
          icon: Icons.dinner_dining,
          isSmallScreen: isSmallScreen,
          expandedFoodIndex: _expandedFoodIndex,
          onToggleExpand: (index) {
            setState(() {
              _expandedFoodIndex = _expandedFoodIndex == index ? null : index;
            });
          },
          onEdit: _showFoodEditDrawer,
          onDelete: _showDeleteConfirmation,
        ),

        // Snack section
        MealTypeSection(
          title: 'Snack',
          foods: categorizedFoods['snack']!,
          color: Color(0xFF7E57C2),
          icon: Icons.restaurant,
          isSmallScreen: isSmallScreen,
          expandedFoodIndex: _expandedFoodIndex,
          onToggleExpand: (index) {
            setState(() {
              _expandedFoodIndex = _expandedFoodIndex == index ? null : index;
            });
          },
          onEdit: _showFoodEditDrawer,
          onDelete: _showDeleteConfirmation,
        ),
      ],
    );
  }

  // Add this method to load food data
  Future<void> _loadFoodData() async {
    try {
      setState(() {
        _isLoadingFoodData = true;
        _loadingError = null;
      });

      // Get date in YYYY-MM-DD format
      final selectedDate = _selectedDate ?? DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      print('Loading food data for date: $formattedDate');

      // Fetch food data from provider
      final foodData = await _foodProvider.getDailyFoodData(formattedDate);

      print('Received food data: $foodData');

      // Convert the data structure to match our UI needs
      List<Map<String, dynamic>> newFoodHistory = [];

      // Process each meal type
      foodData.forEach((mealType, foods) {
        if (foods is List) {
          for (var food in foods) {
            // Ensure we have valid food data
            if (food is Map<String, dynamic> && food['name'] != null) {
              // IMPORTANT FIX: Use the selected date instead of the API date
              // This fixes the date mismatch issue
              DateTime foodDate = selectedDate; // Use the requested date

              // Only use API date if it matches the selected date
              if (food['date'] is String) {
                try {
                  DateTime apiDate = DateTime.parse(food['date']);
                  String apiDateStr = DateFormat('yyyy-MM-dd').format(apiDate);
                  if (apiDateStr == formattedDate) {
                    foodDate = apiDate; // Use API date only if it matches
                  }
                  print(
                    'API date: $apiDateStr, Selected date: $formattedDate, Match: ${apiDateStr == formattedDate}',
                  );
                } catch (e) {
                  print('Error parsing API date: $e');
                  foodDate = selectedDate; // Fallback to selected date
                }
              } else if (food['date'] is DateTime) {
                DateTime apiDate = food['date'];
                String apiDateStr = DateFormat('yyyy-MM-dd').format(apiDate);
                if (apiDateStr == formattedDate) {
                  foodDate = apiDate;
                }
              }

              newFoodHistory.add({
                'name': food['name'] ?? 'Unknown Food',
                'calories': (food['calories'] ?? 0).toDouble(),
                'image': food['image'] ?? 'images/default.png',
                'color': food['colorValue'] ?? food['color'] ?? 0xFF4CAF50,
                'date': foodDate, // This will now match the selected date
                'time': food['time'] ?? '00:00',
                'weight': food['weight'] ?? '100g',
                'mealType': mealType,
                'protein': (food['protein'] ?? 0).toDouble(),
                'carbs': (food['carbs'] ?? 0).toDouble(),
                'fat': (food['fat'] ?? 0).toDouble(),
              });

              print(
                'Added food: ${food['name']} with date: ${DateFormat('yyyy-MM-dd').format(foodDate)}',
              );
            }
          }
        }
      });

      print('Processed food history: ${newFoodHistory.length} items');

      // Update state with new food data
      setState(() {
        _foodHistory = newFoodHistory;
        _isLoadingFoodData = false;
      });

      // Force a rebuild of the categorized sections
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      print('Error loading food data: $e');
      setState(() {
        _loadingError = 'Failed to load food data: $e';
        _isLoadingFoodData = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will reload data when returning to this screen
    _loadFoodData();
  }

  @override
  void didUpdateWidget(FoodManagementStatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when widget updates
    _loadFoodData();
  }
}
