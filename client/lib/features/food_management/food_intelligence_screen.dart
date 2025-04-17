import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/food_management_provider.dart';
import 'package:client/features/food_management/food_management_my_stats.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/widgets/time_period_section.dart';
import 'package:client/screens/add_food_bottom_sheet.dart';

class FoodIntelligenceScreen extends StatefulWidget {
  const FoodIntelligenceScreen({super.key});

  @override
  State<FoodIntelligenceScreen> createState() => _FoodIntelligenceScreenState();
}

class _FoodIntelligenceScreenState extends State<FoodIntelligenceScreen> {
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

  Future<void> _loadPopularFoods() async {
    try {
      final foods = await _foodProvider.getPopularFoods();
      if (mounted) {
        setState(() {
          _popularFoods = foods;
          // _isLoadingPopularFoods = false;
        });
      }
    } catch (e) {
      print('Error loading popular foods: $e');
      if (mounted) {
        setState(() {
          _popularFoods = [];
          // _isLoadingPopularFoods = false;
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
    int total = 0;
    _mealData.forEach((mealType, foods) {
      for (var food in foods) {
        total += food['calories'] as int;
      }
    });
    return total;
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
          // isLoading: _isLoadingPopularFoods,
        );
      },
    );
  }

//   void _showAddFoodBottomSheet(String mealType) async {
//   final addedFood = await showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => AddFoodBottomSheet(
//       mealType: mealType,
//       popularFoods: _popularFoods,
//     ),
//   );

//   if (addedFood != null && mounted) {
//     setState(() {
//       _mealData[mealType]?.add(addedFood);
//     });
//   }
// }

  // Show edit meal time sheet
  void _showEditMealTimeSheet(String mealType) {
    TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0); // Default
    TimeOfDay endTime = TimeOfDay(hour: 10, minute: 0); // Default

    // Parse current time range
    if (mealType != 'snacks' && mealType != 'custom') {
      final timeRange = _mealTimes[mealType]!.split(' - ');
      final startTimeStr = timeRange[0];
      final endTimeStr = timeRange[1];

      // Parse start time
      final startHour = int.parse(startTimeStr.split(':')[0]);
      final startMinute = int.parse(startTimeStr.split(':')[1]);
      startTime = TimeOfDay(hour: startHour, minute: startMinute);

      // Parse end time
      final endHour = int.parse(endTimeStr.split(':')[0]);
      final endMinute = int.parse(endTimeStr.split(':')[1]);
      endTime = TimeOfDay(hour: endHour, minute: endMinute);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
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
                  // Handle bar
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
                    padding: EdgeInsets.all(20.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit ${mealType.substring(0, 1).toUpperCase() + mealType.substring(1)} Time',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),

                  // Time selection
                  if (mealType != 'snacks' && mealType != 'custom')
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Range',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Start time
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Time',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    InkWell(
                                      onTap: () async {
                                        final TimeOfDay? time =
                                            await showTimePicker(
                                              context: context,
                                              initialTime: startTime,
                                            );

                                        if (time != null) {
                                          setState(() {
                                            startTime = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.r,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              startTime.format(context),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16.sp,
                                                    color: const Color(
                                                      0xFF1E293B,
                                                    ),
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
                                  ],
                                ),
                              ),

                              SizedBox(width: 16.w),

                              // End time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Time',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    InkWell(
                                      onTap: () async {
                                        final TimeOfDay? time =
                                            await showTimePicker(
                                              context: context,
                                              initialTime: endTime,
                                            );

                                        if (time != null) {
                                          setState(() {
                                            endTime = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.r,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              endTime.format(context),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16.sp,
                                                    color: const Color(
                                                      0xFF1E293B,
                                                    ),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Custom meal name (for custom meal type)
                  if (mealType == 'custom')
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Meal Name',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter meal name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.r,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Spacer(),

                  // Save button
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Save meal time
                          if (mealType != 'snacks' && mealType != 'custom') {
                            final startTimeStr =
                                '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                            final endTimeStr =
                                '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

                            setState(() {
                              _mealTimes[mealType] =
                                  '$startTimeStr - $endTimeStr';
                            });
                          }

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$mealType time updated'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0F67FE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
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
                      subtitle: 'Your Metabolic Score',
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
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Column(
                children:
                    _timePeriods
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
