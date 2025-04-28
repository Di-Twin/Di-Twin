import 'package:client/features/food_management/presentation/widgets/add_food_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/food_management_provider.dart';
import 'package:client/features/food_management/presentation/pages/food_management_my_stats.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/food_management/presentation/widgets/edit_meal_time_sheet.dart';
import 'package:client/features/food_management/presentation/providers/daily_food_provider.dart';
import 'package:client/features/food_management/presentation/providers/food_score_provider.dart';
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

  // Selected date
  DateTime _selectedDate = DateTime.now();

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

  // Food score placeholder
  String _foodScore = '0';
  bool _isLoadingScore = false;
  String _scoreError = '';

  @override
  void initState() {
    super.initState();

    _loadPopularFoods();
    
    // Load food data after a short delay to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyFoodData(forceRefresh: true);
      _loadDailyFoodScore();
    });
  }

  Future<void> _loadDailyFoodData({bool forceRefresh = false}) async {
    try {
      final dailyFoodProvider = Provider.of<DailyFoodProvider>(context, listen: false);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await dailyFoodProvider.getDailyFood(date: dateStr, forceRefresh: forceRefresh);
    } catch (e) {
      print('Error loading daily food data: $e');
      // Handle error gracefully
    }
  }
  
  Future<void> _loadDailyFoodScore() async {
    setState(() {
      _isLoadingScore = true;
      _scoreError = '';
    });
    
    try {
      // Check if provider is available
      if (!mounted) return;
      
      // Try to access the provider safely
      FoodScoreProvider? foodScoreProvider;
      try {
        foodScoreProvider = Provider.of<FoodScoreProvider>(context, listen: false);
      } catch (e) {
        print('FoodScoreProvider not available: $e');
        setState(() {
          _isLoadingScore = false;
          _scoreError = 'Provider not available';
          _foodScore = '0';
        });
        return;
      }
      
      // If provider is available, get the score
      await foodScoreProvider.getFoodScore();
      
      if (mounted) {
        setState(() {
          _isLoadingScore = false;
          _foodScore = foodScoreProvider?.error?.isEmpty == true 
              ? foodScoreProvider?.dailyFoodScore ?? '0' 
              : '0';
          _scoreError = foodScoreProvider?.error ?? '';
        });
      }
    } catch (e) {
      print('Error loading food score: $e');
      if (mounted) {
        setState(() {
          _isLoadingScore = false;
          _scoreError = 'Failed to load score';
          _foodScore = '0';
        });
      }
    }
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

  // Calculate total calories for the day
  int _calculateTotalCalories() {
    try {
      final dailyFoodProvider = Provider.of<DailyFoodProvider>(context, listen: false);
      if (dailyFoodProvider.dailyFood != null) {
        return dailyFoodProvider.dailyFood!.totalCalories.toInt();
      }
    } catch (e) {
      print('Error calculating total calories: $e');
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

  // Change date and reload data
  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadDailyFoodData(forceRefresh: true);
    _loadDailyFoodScore();
  }

  @override
  Widget build(BuildContext context) {
    // Fixed header height
    final double headerHeight = 370.0;
    
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
                // Use the local food score state instead of directly accessing provider
                CustomActivityHeader(
                  title: 'Food Intelligence',
                  badgeText: 'Healthy',
                  score: _isLoadingScore 
                      ? '...' 
                      : _scoreError.isNotEmpty 
                          ? '0' 
                          : _foodScore,
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
                ),
              ],
            ),
          ),

          // Spacer to replace the date selector
          SizedBox(height: 16.h),

          // Food Intake Title with day summary
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
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

          // Food Timeline Content
          Expanded(
            child: Consumer<DailyFoodProvider>(
              builder: (context, dailyFoodProvider, child) {
                if (dailyFoodProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF0F67FE),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading your food data...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (dailyFoodProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error: ${dailyFoodProvider.error}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () => _loadDailyFoodData(forceRefresh: true),
                          icon: Icon(Icons.refresh),
                          label: Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F67FE),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (dailyFoodProvider.dailyFood == null) {
                  return _buildEmptyFoodState();
                }
                
                // Display meal sections
                return _buildFoodTimeline(dailyFoodProvider);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Build empty state when no food data is available
  Widget _buildEmptyFoodState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_food,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No food logged for today',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start tracking your meals to get insights',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          _buildMealSessionButtons(),
        ],
      ),
    );
  }
  
  // Build meal session buttons for empty state
  Widget _buildMealSessionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add food to a meal:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildMealButton(
                  'Breakfast',
                  Icons.free_breakfast,
                  Color(0xFFFFA726),
                  () => _showAddFoodBottomSheet('breakfast'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMealButton(
                  'Lunch',
                  Icons.lunch_dining,
                  Color(0xFF42A5F5),
                  () => _showAddFoodBottomSheet('lunch'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildMealButton(
                  'Dinner',
                  Icons.dinner_dining,
                  Color(0xFF7E57C2),
                  () => _showAddFoodBottomSheet('dinner'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMealButton(
                  'Snacks',
                  Icons.cookie,
                  Color(0xFF66BB6A),
                  () => _showAddFoodBottomSheet('snacks'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Build a meal button for the empty state
  Widget _buildMealButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the food timeline with meal sections
  Widget _buildFoodTimeline(DailyFoodProvider dailyFoodProvider) {
    return RefreshIndicator(
      onRefresh: () => _loadDailyFoodData(forceRefresh: true),
      color: Color(0xFF0F67FE),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Display meals by meal type
            ...dailyFoodProvider.dailyFood!.meals.entries.map((entry) {
              final mealType = entry.key;
              final mealItems = entry.value;
              final mealScore = dailyFoodProvider.dailyFood!.scores[mealType] ?? 0.0;
              
              return _buildMealTypeSection(
                mealType: mealType,
                mealItems: mealItems,
                mealScore: mealScore,
              );
            }).toList(),
            
            // Add button for logging more food
            SizedBox(height: 24.h),
            Text(
              'Add food to another meal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            _buildMealSessionButtons(),
          ],
        ),
      ),
    );
  }
  
  // Build a section for a specific meal type
  Widget _buildMealTypeSection({
    required String mealType,
    required List<dynamic> mealItems,
    required double mealScore,
  }) {
    // Get icon and color based on meal type
    IconData mealIcon;
    Color mealColor;
    String mealTitle;
    
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        mealIcon = Icons.free_breakfast;
        mealColor = Color(0xFFFFA726);
        mealTitle = 'Breakfast';
        break;
      case 'lunch':
        mealIcon = Icons.lunch_dining;
        mealColor = Color(0xFF42A5F5);
        mealTitle = 'Lunch';
        break;
      case 'dinner':
        mealIcon = Icons.dinner_dining;
        mealColor = Color(0xFF7E57C2);
        mealTitle = 'Dinner';
        break;
      case 'snacks':
        mealIcon = Icons.cookie;
        mealColor = Color(0xFF66BB6A);
        mealTitle = 'Snacks';
        break;
      default:
        mealIcon = Icons.restaurant;
        mealColor = Color(0xFF9E9E9E);
        mealTitle = mealType.substring(0, 1).toUpperCase() + mealType.substring(1);
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: mealColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      mealIcon,
                      color: mealColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      mealTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Time range
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _mealTimes[mealType.toLowerCase()] ?? 'Any time',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    // Score
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(mealScore).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getScoreIcon(mealScore),
                            color: _getScoreColor(mealScore),
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${mealScore.toStringAsFixed(1)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _getScoreColor(mealScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Meal items
          if (mealItems.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.no_food,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No foods logged for $mealTitle',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: mealItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                indent: 16.w,
                endIndent: 16.w,
                color: Colors.grey.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final item = mealItems[index];
                final foodName = item['foodName'] ?? 'Unknown Food';
                final calories = item['calories'] ?? 0;
                final protein = item['protein'] ?? 0;
                final carbs = item['carbs'] ?? 0;
                final fat = item['fat'] ?? 0;
                final timeStr = item['time'] ?? DateTime.now().toIso8601String();
                
                // Parse time
                DateTime time;
                try {
                  time = DateTime.parse(timeStr);
                } catch (e) {
                  time = DateTime.now();
                }
                
                return InkWell(
                  onTap: () {
                    // Show detailed food info in a bottom sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(24.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 12.h),
                                  width: 40.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                              
                              // Header
                              Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56.w,
                                      height: 56.w,
                                      decoration: BoxDecoration(
                                        color: mealColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: Icon(
                                        _getFoodIcon(foodName),
                                        color: mealColor,
                                        size: 28.sp,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            foodName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '$mealTitle • ${DateFormat('h:mm a').format(time)}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEDF2FF),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: Text(
                                        '$calories cal',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F67FE),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              Divider(),
                              
                              // Nutrition info
                              Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nutrition Information',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildNutrientInfo('Protein', '$protein g', Colors.blue),
                                        _buildNutrientInfo('Carbs', '$carbs g', Colors.orange),
                                        _buildNutrientInfo('Fat', '$fat g', Colors.green),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              Spacer(),
                              
                              // Action buttons
                              Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // Edit food item
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.edit),
                                        label: Text('Edit'),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 12.h),
                                          side: BorderSide(color: mealColor),
                                          foregroundColor: mealColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Delete food item
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.delete),
                                        label: Text('Delete'),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 12.h),
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        // Food icon
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: mealColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            _getFoodIcon(foodName),
                            color: mealColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        
                        // Food details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  // Time
                                  Text(
                                    DateFormat('h:mm a').format(time),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Dot separator
                                  Container(
                                    width: 4.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Macros summary
                                  Text(
                                    'P: ${protein}g • C: ${carbs}g • F: ${fat}g',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Calories
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFEDF2FF),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            '$calories cal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F67FE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          // Add food button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextButton.icon(
              onPressed: () => _showAddFoodBottomSheet(mealType),
              icon: Icon(
                Icons.add,
                color: mealColor,
                size: 20.sp,
              ),
              label: Text(
                'Add to $mealTitle',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: mealColor,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                backgroundColor: mealColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build nutrient info widget
  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  // Get color based on score
  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  // Get icon based on score
  IconData _getScoreIcon(double score) {
    if (score >= 80) {
      return Icons.sentiment_very_satisfied;
    } else if (score >= 60) {
      return Icons.sentiment_satisfied;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  // Get icon based on food name
  IconData _getFoodIcon(String foodName) {
    final lowerCaseName = foodName.toLowerCase();
    
    if (lowerCaseName.contains('broccoli') || 
        lowerCaseName.contains('vegetable') || 
        lowerCaseName.contains('salad')) {
      return Icons.eco;
    } else if (lowerCaseName.contains('chicken') || 
               lowerCaseName.contains('meat') || 
               lowerCaseName.contains('beef') ||
               lowerCaseName.contains('fish')) {
      return Icons.set_meal;
    } else if (lowerCaseName.contains('apple') || 
               lowerCaseName.contains('fruit') || 
               lowerCaseName.contains('banana') ||
               lowerCaseName.contains('orange')) {
      return Icons.apple;
    } else if (lowerCaseName.contains('bread') || 
               lowerCaseName.contains('toast') || 
               lowerCaseName.contains('sandwich')) {
      return Icons.breakfast_dining;
    } else if (lowerCaseName.contains('coffee') || 
               lowerCaseName.contains('tea') || 
               lowerCaseName.contains('water') ||
               lowerCaseName.contains('juice') ||
               lowerCaseName.contains('drink')) {
      return Icons.local_cafe;
    } else if (lowerCaseName.contains('soup') || 
               lowerCaseName.contains('broth')) {
      return Icons.soup_kitchen;
    } else if (lowerCaseName.contains('cake') || 
               lowerCaseName.contains('dessert') || 
               lowerCaseName.contains('cookie') ||
               lowerCaseName.contains('sweet')) {
      return Icons.cake;
    } else if (lowerCaseName.contains('egg')) {
      return Icons.egg;
    } else if (lowerCaseName.contains('pizza')) {
      return Icons.local_pizza;
    } else if (lowerCaseName.contains('rice') || 
               lowerCaseName.contains('grain')) {
      return Icons.rice_bowl;
    }
    
    // Default icon
    return Icons.restaurant;
  }
}
