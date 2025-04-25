import 'package:client/features/food_management/presentation/widgets/add_food_bottom_sheet.dart';
import 'package:client/features/food_management/presentation/widgets/time_period_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/food_management_provider.dart';
import 'package:client/features/food_management/presentation/pages/food_management_my_stats.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/food_management/presentation/widgets/edit_meal_time_sheet.dart';
import 'package:client/features/food_management/presentation/providers/daily_food_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FoodIntelligencePage extends StatefulWidget {
  const FoodIntelligencePage({super.key});

  @override
  State<FoodIntelligencePage> createState() => _FoodIntelligencePageState();
}

class _FoodIntelligencePageState extends State<FoodIntelligencePage> {
  // ScrollController for auto-scrolling
  final ScrollController _scrollController = ScrollController();
  final FoodManagementProvider _foodProvider = FoodManagementProvider();

  // Current time period
  String _currentTimePeriod = 'Morning';

  // Sample meal data
  final Map<String, List<Map<String, dynamic>>> _mealData = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snacks': [],
    'custom': [],
  };

  // Popular food suggestions
  List<Map<String, dynamic>> _popularFoods = [];

  // Custom meal times
  final Map<String, String> _mealTimes = {
    'breakfast': '06:00 - 10:00',
    'lunch': '12:00 - 14:00',
    'dinner': '18:00 - 21:00',
    'snacks': 'Any time',
    'custom': 'Custom meal',
  };

  // Meal illustrations
  final Map<String, String> _mealIllustrations = {
    'breakfast': 'images/breakfast_illustration.png',
    'lunch': 'images/lunch_illustration.png',
    'dinner': 'images/dinner_illustration.png',
    'snacks': 'images/snacks_illustration.png',
    'custom': 'images/custom_illustration.png',
  };

  // Time periods for the timeline
  final List<Map<String, dynamic>> _timePeriods = [
    {
      'name': 'Morning',
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFFA726),
      'startTime': 6,
      'endTime': 12,
    },
    {
      'name': 'Afternoon',
      'icon': Icons.wb_cloudy,
      'color': Color(0xFF42A5F5),
      'startTime': 12,
      'endTime': 18,
    },
    {
      'name': 'Evening',
      'icon': Icons.nights_stay,
      'color': Color(0xFF7E57C2),
      'startTime': 18,
      'endTime': 24,
    },
  ];

  @override
  void initState() {
    super.initState();

    _loadPopularFoods();
    _loadDailyFoodData();

    // Determine current time period based on current hour
    final currentHour = DateTime.now().hour;
    if (currentHour >= 6 && currentHour < 12) {
      _currentTimePeriod = 'Morning';
    } else if (currentHour >= 12 && currentHour < 18) {
      _currentTimePeriod = 'Afternoon';
    } else {
      _currentTimePeriod = 'Evening';
    }

    // Schedule auto-scroll after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTimePeriod();
    });
  }

  Future<void> _loadDailyFoodData() async {
    final dailyFoodProvider = Provider.of<DailyFoodProvider>(context, listen: false);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await dailyFoodProvider.getDailyFood(today);
  }

  Future<void> _loadPopularFoods() async {
    try {
      final foods = await _foodProvider.getPopularFoods();
      if (mounted) {
        setState(() {
          _popularFoods = foods;
        });
      }
    } catch (e) {
      print('Error loading popular foods: $e');
      if (mounted) {
        setState(() {
          _popularFoods = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to current time period
  void _scrollToCurrentTimePeriod() {
    // Find the index of the current time period
    int index = _timePeriods.indexWhere(
      (period) => period['name'] == _currentTimePeriod,
    );
    if (index != -1) {
      // Calculate approximate scroll position (each section is about 300 height units)
      double scrollPosition = index * 300.0;

      // Animate to the position
      _scrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Calculate total calories for the day
  int _calculateTotalCalories() {
    final dailyFoodProvider = Provider.of<DailyFoodProvider>(context, listen: false);
    if (dailyFoodProvider.dailyFood != null) {
      return dailyFoodProvider.dailyFood!.totalCalories.toInt();
    }
    return 0;
  }

  // Show add food bottom sheet
  void _showAddFoodBottomSheet(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddFoodBottomSheet(
          mealType: mealType,
          popularFoods: _popularFoods,
        );
      },
    );
  }

  // Show edit meal time sheet
  void _showEditMealTimeSheet(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditMealTimeSheet(
          mealType: mealType,
          currentTimeRange: _mealTimes[mealType] ?? '',
          onSave: (mealType, newTimeRange) {
            setState(() {
              _mealTimes[mealType] = newTimeRange;
            });
          },
        );
      },
    );
  }

  // Navigate to stats screen
  void onButtonTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                FoodManagementStatsScreen(userJoinDate: DateTime(2025, 4, 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fixed header height
    final double headerHeight = 370.0;
    final dailyFoodProvider = Provider.of<DailyFoodProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Custom header with reduced height
          SizedBox(
            height: headerHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FutureBuilder<String>(
                  future: _foodProvider.getTodayFoodScore(),
                  builder: (context, snapshot) {
                    // Default score if data is not loaded yet or there's an error
                    String score = snapshot.hasData ? snapshot.data! : '0';
                    return CustomActivityHeader(
                      title: 'Food Intelligence',
                      badgeText: 'Healthy',
                      score: score,
                      subtitle: 'Your Food Score',
                      buttonImage: 'images/SignInAddIcon.png',
                      onButtonTap: () => onButtonTap(context),
                      backgroundColor: Color(0xFFD9EAFF),
                      backgroundImagePath:
                          'images/activity_header_background.png',
                      buttonColor: Color(0xFF1E293B),
                      buttonShadowColor: Color(0xFF1E293B),
                      titleTextColor: Color(0xFF1E293B),
                      scoreTextColor: Color(0xFF1E293B),
                      subtitleTextColor: Color(0xFF1E293B),
                      backButtonBorderColor: Color(0xFF1E293B),
                      badgeBackgroundColor: Colors.blue.withOpacity(0.2),
                      badgeTextColor: Colors.blue,
                      backButtonBorderWidth: 1.0,
                      bottomLeftRadius: 30,
                      bottomRightRadius: 30,
                      buttonShadowSpread: 0,
                      headerHeight: headerHeight,
                      showBadge: true,
                      showMenu: false,
                    );
                  },
                ),
              ],
            ),
          ),

          // Food Intake Title with day summary
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Food Timeline',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16.sp,
                        color: Color(0xFF0F67FE),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${_calculateTotalCalories()} cal today',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F67FE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timeline content
          Expanded(
            child: dailyFoodProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : dailyFoodProvider.error.isNotEmpty
                    ? Center(
                        child: Text(
                          'Error: ${dailyFoodProvider.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                        child: Column(
                          children: _timePeriods
                              .map(
                                (timePeriod) => TimePeriodSection(
                                  timePeriod: timePeriod,
                                  mealData: _mealData,
                                  currentTimePeriod: _currentTimePeriod,
                                  showAddFoodBottomSheet: _showAddFoodBottomSheet,
                                  foodProvider: _foodProvider,
                                ),
                              )
                              .toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
