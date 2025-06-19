import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as Math;

import 'package:client/features/food_management/presentation/providers/food_management_provider.dart';
import 'package:client/features/food_management/presentation/pages/food_management_my_stats.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/food_management/presentation/providers/daily_food_provider.dart';
import 'package:client/features/food_management/presentation/widgets/add_food_bottom_sheet.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/data/datasources/food_remote_datasource.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/features/food_management/domain/usecases/get_food_items_usecase.dart';
import 'package:client/features/food_management/data/repositories/food_repository_impl.dart';
import 'package:client/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:client/features/food_management/data/models/food_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodIntelligencePage extends StatefulWidget {
  const FoodIntelligencePage({super.key});

  @override
  _FoodIntelligencePageState createState() => _FoodIntelligencePageState();
}

class _FoodIntelligencePageState extends State<FoodIntelligencePage> {
  // Add these variables to the _FoodIntelligencePageState class
  DateTime? _userJoinDate;
  bool _isLoadingUserProfile = false;

  // ScrollController for auto-scrolling
  final ScrollController _scrollController = ScrollController();
  final FoodManagementProvider _foodProvider = FoodManagementProvider();
  late final FoodRemoteDataSource _foodRemoteDataSource;

  // Selected date
  DateTime _selectedDate = DateTime.now();
  final List<String> _mealPeriods = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];

  // Popular food suggestions
  List<Map<String, dynamic>> _popularFoodsOld = [];

  bool _isLoading = true;
  String _foodScore = '0';
  List<FoodItem> _popularFoods = [];
  Map<String, List<FoodItem>> _dailyFoodData = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snacks': [],
    'custom': [],
  };

  // Custom meal times
  final Map<String, String> _mealTimes = {
    'breakfast': '06:00 - 10:00',
    'lunch': '12:00 - 14:00',
    'dinner': '18:00 - 21:00',
    'snacks': 'Any time',
    'custom': 'Custom meal',
  };

  // Food score placeholder
  bool _isLoadingScore = false;
  String _scoreError = '';

  // Page controllers for meal periods and content
  late PageController _pageController = PageController();
  late PageController _mealContentController = PageController();

  // Selected meal period index
  int _selectedMealPeriodIndex = 0;
  late PageController _mealContentPageController;

  GetFoodItemsUseCase? _getFoodItemsUseCase;
  String _accessToken = '';
  bool _isLoadingFoodItems = false;

  // Add this method to fetch user profile after the existing initState method
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingUserProfile = true;
    });

    try {
      // Get access token - in a real app, you would get this from secure storage
      final token = await _getAccessToken();

      developer.log(
        'User Profile API - Token available: ${token.isNotEmpty}',
        name: 'UserProfileAPI',
      );

      if (token.isEmpty) {
        developer.log(
          'User Profile API - No access token available',
          name: 'UserProfileAPI',
        );
        setState(() {
          _isLoadingUserProfile = false;
          _userJoinDate = DateTime.now(); // Default fallback
        });
        return;
      }

      // Make API request to get user profile
      final url = Uri.parse('https://test-prod-f427.onrender.com/api/users');
      developer.log(
        'User Profile API - Request URL: $url',
        name: 'UserProfileAPI',
      );
      developer.log(
        'User Profile API - Request Headers: Content-Type: application/json, Authorization: Bearer ${token.substring(0, 5)}...',
        name: 'UserProfileAPI',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log(
        'User Profile API - Response Status: ${response.statusCode}',
        name: 'UserProfileAPI',
      );

      if (response.statusCode == 401) {
        developer.log(
          'User Profile API - 401 Unauthorized Error',
          name: 'UserProfileAPI',
        );
        developer.log(
          'User Profile API - Response Body: ${response.body}',
          name: 'UserProfileAPI',
        );
        developer.log(
          'User Profile API - Token used: ${token.substring(0, 5)}...',
          name: 'UserProfileAPI',
        );

        setState(() {
          _isLoadingUserProfile = false;
          _userJoinDate = DateTime.now(); // Default fallback
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication error: Please log in again'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Details',
                onPressed: () {
                  // Show more details in a dialog
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Authentication Error'),
                          content: SingleChildScrollView(
                            child: Text(
                              'Failed to authenticate with the server.\n\nStatus: ${response.statusCode}\nResponse: ${response.body}',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          );
        }
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log(
          'User Profile API - Success: ${data['success']}',
          name: 'UserProfileAPI',
        );

        if (data['success'] == true && data['data'] != null) {
          // Parse the created_at date
          final createdAtString = data['data']['created_at'];
          if (createdAtString != null) {
            setState(() {
              _userJoinDate = DateTime.parse(createdAtString);
              _isLoadingUserProfile = false;
            });
            developer.log(
              'User Profile API - User join date: $_userJoinDate',
              name: 'UserProfileAPI',
            );
          } else {
            developer.log(
              'User Profile API - No created_at date found',
              name: 'UserProfileAPI',
            );
            setState(() {
              _userJoinDate = DateTime.now(); // Default fallback
              _isLoadingUserProfile = false;
            });
          }
        } else {
          developer.log(
            'User Profile API - Invalid response format: ${response.body}',
            name: 'UserProfileAPI',
          );
          setState(() {
            _userJoinDate = DateTime.now(); // Default fallback
            _isLoadingUserProfile = false;
          });
        }
      } else {
        developer.log(
          'User Profile API - Failed with status: ${response.statusCode}',
          name: 'UserProfileAPI',
        );
        developer.log(
          'User Profile API - Response Body: ${response.body}',
          name: 'UserProfileAPI',
        );

        setState(() {
          _userJoinDate = DateTime.now(); // Default fallback
          _isLoadingUserProfile = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('User Profile API - Error: $e', name: 'UserProfileAPI');
      developer.log(
        'User Profile API - Stack trace: $stackTrace',
        name: 'UserProfileAPI',
      );

      setState(() {
        _userJoinDate = DateTime.now(); // Default fallback
        _isLoadingUserProfile = false;
      });
    }
  }

  int _getCurrentMealPeriodIndex() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 11) {
      return 0; // Breakfast
    } else if (hour >= 11 && hour < 15) {
      return 1; // Lunch
    } else if (hour >= 15 && hour < 18) {
      return 2; // Snack
    } else if (hour >= 18 || hour < 5) {
      // Changed to include late night/early morning as Dinner
      return 3; // Dinner
    } else {
      return 0; // Default to Breakfast
    }
  }

  // Update the initState method to call _fetchUserProfile
  @override
  void initState() {
    super.initState();
    _selectedMealPeriodIndex = _getCurrentMealPeriodIndex();

    _mealContentController = PageController(
      initialPage: _selectedMealPeriodIndex,
    );
    _pageController = PageController(initialPage: _selectedMealPeriodIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mealContentController.jumpToPage(_selectedMealPeriodIndex);
      _pageController.jumpToPage(_selectedMealPeriodIndex);
    });

    // Create two separate API clients for the different services
    _foodRemoteDataSource = FoodRemoteDataSourceImpl(
      apiClient: ApiClient(
        baseUrl: 'https://test-prod-f427.onrender.com/api',
        httpClient: http.Client(),
      ),
      client: http.Client(),
    );

    // Initialize the use case with proper NetworkInfoImpl
    final networkInfo = NetworkInfoImpl(
      connectionChecker: InternetConnectionChecker.createInstance(),
    );
    final foodRepository = FoodRepositoryImpl(
      remoteDataSource: _foodRemoteDataSource,
      networkInfo: networkInfo,
    );
    _getFoodItemsUseCase = GetFoodItemsUseCase(foodRepository);

    // _loadPopularFoods();
    _loadData();

    // Get access token from auth provider if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Get token directly from shared preferences or secure storage
        _getAccessToken().then((token) {
          if (token.isNotEmpty) {
            setState(() {
              _accessToken = token;
            });
            // _loadFoodItemsFromAPI();
          }
        });

        // Fetch user profile to get join date
        _fetchUserProfile();

        if (_pageController.hasClients) {
          _pageController.jumpToPage(_selectedMealPeriodIndex);
        }
        if (_mealContentController.hasClients) {
          _mealContentController.jumpToPage(_selectedMealPeriodIndex);
        }

        _loadData();

        // Ensure the meal content is visible by scrolling to it
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              370.h, // Approximate header height
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });

        // _loadDailyFoodData(forceRefresh: true);
        // _loadDailyFoodScore();
      } catch (e) {
        print('Error in initialization: $e');
      }
    });
  }

  // Simple method to get access token
  Future<String> _getAccessToken() async {
    try {
      // In a real app, you would retrieve this from secure storage or shared preferences
      final prefs = await SharedPreferences.getInstance();
      // final token =
      //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlODE0NDQ3NS0yY2E1LTQ3YTQtOTUwOS1mMDhjYWZlNWYwZjUiLCJtb2JpbGUiOiIrOTE5ODc2NTQzMjEwIiwiaWF0IjoxNzUwMzI3MzU2LCJleHAiOjE3NTA0MTM3NTZ9.QAdTh8zdceJpFzEGF8jX3Ly0dYB60CuKb7mEwAPgykM";
      final token = prefs.getString('access_token') ?? '';
      developer.log(
        'Token retrieval - Token length: ${token.length}',
        name: 'TokenManager',
      );
      if (token.isNotEmpty) {
        developer.log(
          'Token retrieval - Token prefix: ${token.substring(0, Math.min(5, token.length))}...',
          name: 'TokenManager',
        );
      } else {
        developer.log('Token retrieval - No token found', name: 'TokenManager');
      }

      return token;
    } catch (e, stackTrace) {
      developer.log('Token retrieval - Error: $e', name: 'TokenManager');
      developer.log(
        'Token retrieval - Stack trace: $stackTrace',
        name: 'TokenManager',
      );
      return '';
    }
  }

  String _convertToLocalTimeAndFormat(String utcTimeString) {
    try {
      // Parse the UTC time
      DateTime utcTime = DateTime.parse(utcTimeString);

      // Convert to local time (automatically handles device timezone)
      DateTime localTime = utcTime.toLocal();

      // Format to HH:mm
      return DateFormat('HH:mm').format(localTime);
    } catch (e) {
      print('Error converting time: $e');
      // Return current time as fallback
      return DateFormat('HH:mm').format(DateTime.now());
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get today's date in the format YYYY-MM-dd
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Load food score
      try {
        final response = await http.get(
          Uri.parse(
            'https://test-prod-f427.onrender.com/api/food/score/daily/$today',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await _getAccessToken()}',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          final foodScore = data['data']?['food_score'];
          if (data['success'] == true && foodScore != null) {
            final roundedScore = (foodScore as num).round();
            setState(() {
              _foodScore = roundedScore.toString();
            });
          } else {
            setState(() {
              _foodScore = '0';
            });
          }
        } else {
          setState(() {
            _foodScore = '0';
          });
        }
      } catch (e) {
        print('Error loading food score: $e');
        setState(() {
          _foodScore = '0';
        });
      }


      // Load daily food data
      try {
        final response = await http.get(
          Uri.parse(
            'https://test-prod-f427.onrender.com/api/food/daily/$today',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await _getAccessToken()}',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            // Process the daily food data
            Map<String, List<FoodItem>> result = {
              'breakfast': [],
              'lunch': [],
              'dinner': [],
              'snacks': [],
              'custom': [],
            };

            if (data['data'].containsKey('meals')) {
              final meals = data['data']['meals'] as Map<String, dynamic>;

              meals.forEach((mealType, foodList) {
                if (result.containsKey(mealType)) {
                  for (var foodItem in foodList) {
                    String formattedTime = _convertToLocalTimeAndFormat(
                      foodItem['time'],
                    );

                    FoodItem processedFood = FoodItemModel(
                      id: foodItem['id'] ?? '',
                      name: foodItem['foodName'] ?? '',
                      calories:
                          (foodItem['calories'] ?? 0) is num
                              ? (foodItem['calories'] as num).toInt()
                              : 0,
                      protein:
                          (foodItem['protein'] ?? 0) is num
                              ? (foodItem['protein'] as num).toDouble()
                              : 0.0,
                      carbs:
                          (foodItem['carbs'] ?? 0) is num
                              ? (foodItem['carbs'] as num).toDouble()
                              : 0.0,
                      fat:
                          (foodItem['fats'] ?? 0) is num
                              ? (foodItem['fats'] as num).toDouble()
                              : 0.0,
                      time: formattedTime,
                      weight: foodItem['weight'] ?? '100g',
                      mealType: mealType,
                      date: today,
                      color: _getColorForMealType(mealType),
                    );

                    result[mealType]!.add(processedFood);
                  }
                }
              });
            }

            setState(() {
              _dailyFoodData = result;
            });
          }
        }
      } catch (e) {
        print('Error loading daily food data: $e');
        // Keep existing daily food data or initialize empty
        if (_dailyFoodData.isEmpty) {
          setState(() {
            _dailyFoodData = {
              'breakfast': [],
              'lunch': [],
              'dinner': [],
              'snacks': [],
              'custom': [],
            };
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading food intelligence data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mealContentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate total calories for the day
  int _calculateTotalCalories() {
    int total = 0;
    _dailyFoodData.forEach((mealType, foods) {
      for (var food in foods) {
        total += food.calories.toInt();
      }
    });
    return total;
  }

  // Show add food bottom sheet
  void _showAddFoodBottomSheet({String? mealType}) {
    // Get the proper meal title based on the meal type
    String mealTitle = 'Meal';
    String actualMealType = mealType ?? 'breakfast'; // Default fallback

    if (mealType == 'breakfast') {
      mealTitle = 'Breakfast';
      actualMealType = 'breakfast';
    } else if (mealType == 'lunch') {
      mealTitle = 'Lunch';
      actualMealType = 'lunch';
    } else if (mealType == 'dinner') {
      mealTitle = 'Dinner';
      actualMealType = 'dinner';
    } else if (mealType == 'snacks') {
      mealTitle = 'Snacks';
      actualMealType = 'snacks';
    }

    print(
      'Calling AddFoodBottomSheet with mealType: $actualMealType',
    ); // Debug print

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddFoodBottomSheet(
            mealType: actualMealType, // Make sure this is correct
            mealTitle: mealTitle,
            onFoodAdded: (FoodItem food) {
              // Refresh the data after adding food
              _loadData();
            },
          ),
    );
  }

  // Update the onButtonTap method to pass the user join date
  void onButtonTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FoodManagementStatsScreen(
              userJoinDate: _userJoinDate ?? DateTime(2025, 4, 1),
            ),
      ),
    );
  }


  // Replace the build method's header section with a more colorful version
  @override
  Widget build(BuildContext context) {
    // Fixed header height
    final double headerHeight = 370.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Custom header with reduced height - KEEPING THE ORIGINAL HEADER
                    SizedBox(
                      height: headerHeight.h,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Use the local food score state instead of directly accessing provider
                          CustomActivityHeader(
                            title: 'Food Intelligence',
                            badgeText: 'Healthy',
                            score:
                                _isLoadingScore
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

                    // Food Timeline Title with day summary
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Food Timeline',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.sp,
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

                    // Meal Period Carousel
                    // _buildMealPeriodCarousel(),

                    // Meal Content
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height -
                          450.h, // Adjust this value as needed
                      child: _buildMealContent(),
                    ),
                  ],
                ),
              ),
    );
  }

  // Build meal content based on selected period
  Widget _buildMealContent() {
    return PageView.builder(
      controller: _mealContentController,
      itemCount: _mealPeriods.length,
      onPageChanged: (index) {
        setState(() {
          _selectedMealPeriodIndex = index;
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      },
      itemBuilder: (context, index) {
        final period = _mealPeriods[index];
        return _buildMealPeriodContent(period);
      },
    );
  }

  Widget _buildMealPeriodContent(String period) {
    // Get meals for this period - Updated logic
    final mealType = _getMealTypeForPeriod(period);
    final meals = _dailyFoodData[mealType] ?? [];
    final bool isEmpty = meals.isEmpty;

    return RefreshIndicator(
      onRefresh: () => _loadData(),
      color: Color(0xFF0F67FE),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
        child:
            isEmpty
                ? _buildEmptyPeriodState(period)
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main meal section - Updated to pass individual meals
                    _buildMainMealSectionUpdated(period, meals),
                    SizedBox(height: 24.h),
                  ],
                ),
      ),
    );
  }

  // Build empty state for a meal period
  Widget _buildEmptyPeriodState(String period) {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getPeriodIcon(period), size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'No meals logged for $period',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first meal to start tracking',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed:
                  () => _showAddFoodBottomSheet(
                    mealType: _getMealTypeForPeriod(period),
                  ),
              icon: Icon(Icons.add),
              label: Text('Add a meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F67FE),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build main meal section
  Widget _buildMainMealSectionUpdated(String period, List<FoodItem> meals) {
    final mealType = _getMealTypeForPeriod(period);
    final mealTitle = period;

    // Calculate total calories for this meal type
    int totalCalories = meals.fold(
      0,
      (sum, item) => sum + item.calories.toInt(),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getPeriodColor(period).withOpacity(0.8),
                  _getPeriodColor(period),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _getPeriodIcon(period),
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${meals.length} item${meals.length != 1 ? 's' : ''}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16.sp,
                        color: Color(0xFF000000),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$totalCalories cal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Meal items list
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: meals.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: Colors.grey.withOpacity(0.1),
                ),
            itemBuilder: (context, index) {
              final item = meals[index];

              return InkWell(
                onTap: () {
                  _showFoodDetailBottomSheet(
                    item,
                    mealTitle,
                    _getPeriodColor(period),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      // Food icon
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getPeriodColor(period).withOpacity(0.7),
                              _getPeriodColor(period),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: _getPeriodColor(period).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getFoodIcon(item.name),
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Food details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                // Time
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    item.time,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Weight
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPeriodColor(
                                      period,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    item.weight,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: _getPeriodColor(period),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            // Macros summary
                            Text(
                              'P: ${item.protein.toInt()}g  •  C: ${item.carbs.toInt()}g  •  F: ${item.fat.toInt()}g',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Calories
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(255, 255, 255, 255),
                              Color.fromARGB(255, 255, 255, 255),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                255,
                                0,
                                0,
                                0,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          '${item.calories} cal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
            padding: EdgeInsets.all(20.w),
            child: ElevatedButton.icon(
              onPressed: () => _showAddFoodBottomSheet(mealType: mealType),
              icon: Icon(Icons.add_circle, color: Colors.white, size: 20.sp),
              label: Text(
                'Add to $mealTitle',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                backgroundColor: _getPeriodColor(period),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _getPeriodColor(period).withOpacity(0.5),
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

  // Build snacks section
  Widget _buildSnacksSection(String period) {
    final snackItems = _dailyFoodData['snacks'] ?? [];
    final filteredSnacks =
        snackItems.where((item) {
          final hour = int.tryParse(item.time.split(':')[0]) ?? 0;
          if (period == 'Morning') return hour >= 6 && hour < 12;
          if (period == 'Afternoon') return hour >= 12 && hour < 18;
          if (period == 'Evening') return hour >= 18 || hour < 6;
          return false;
        }).toList();

    return Container(
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
          // Snacks header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFF66BB6A).withOpacity(0.1),
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
                    Icon(Icons.cookie, color: Color(0xFF66BB6A), size: 24.sp),
                    SizedBox(width: 12.w),
                    Text(
                      '$period Snacks',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                if (filteredSnacks.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFEDF2FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_calculateSnackCaloriesForPeriod(period)} cal',
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

          // Snack items
          if (filteredSnacks.isEmpty)
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.cookie_outlined,
                      size: 48.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No snacks logged for $period',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
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
              itemCount: filteredSnacks.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: Colors.grey.withOpacity(0.1),
                  ),
              itemBuilder: (context, index) {
                final item = filteredSnacks[index];

                return InkWell(
                  onTap: () {
                    _showFoodDetailBottomSheet(
                      item,
                      'Snacks',
                      Color(0xFF66BB6A),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        // Food icon
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: Color(0xFF66BB6A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            _getFoodIcon(item.name),
                            color: Color(0xFF66BB6A),
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
                                item.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.time,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
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
                            '${item.calories} cal',
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

          // Add snack button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextButton.icon(
              onPressed: () => _showAddFoodBottomSheet(mealType: 'snacks'),
              icon: Icon(Icons.add, color: Color(0xFF66BB6A), size: 20.sp),
              label: Text(
                'Add a Snack',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF66BB6A),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                backgroundColor: Color(0xFF66BB6A).withOpacity(0.1),
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

  // Get meals for a specific period
  Map<String, List<FoodItem>> _getMealsForPeriod(String period) {
    Map<String, List<FoodItem>> result = {};

    // Define time ranges for each period
    int startHour = 0;
    int endHour = 24;

    if (period == 'Morning') {
      startHour = 6;
      endHour = 12;
    } else if (period == 'Afternoon') {
      startHour = 12;
      endHour = 18;
    } else if (period == 'Evening') {
      startHour = 18;
      endHour = 24;
    }

    // Filter meals by time period
    _dailyFoodData.forEach((mealType, mealItems) {
      if (mealType != 'snacks') {
        // Snacks are handled separately
        List<FoodItem> filteredItems =
            mealItems.where((item) {
              final hour = int.tryParse(item.time.split(':')[0]) ?? 0;
              return hour >= startHour && hour < endHour;
            }).toList();

        if (filteredItems.isNotEmpty) {
          result[mealType] = filteredItems;
        }
      }
    });

    return result;
  }

  // Get meal type for a period
  String _getMealTypeForPeriod(String period) {
  switch (period) {
    case 'Breakfast':
      return 'breakfast';
    case 'Lunch':
      return 'lunch';
    case 'Snack': // Make sure this case is handled
      return 'snacks';
    case 'Dinner':
      return 'dinner';
    default:
      print('Unknown period: $period'); // Debug print
      return 'breakfast'; // Default fallback
  }
}


  // Get meal title for a period
  String _getMealTitleForPeriod(String period) {
    switch (period) {
      case 'Breakfast':
        return 'Breakfast';
      case 'Lunch':
        return 'Lunch';
      case 'Snacks':
        return 'Snacks';
      case 'Dinner':
        return 'Dinner';
      default:
        return 'Meal';
    }
  }

  // Get period color
  Color _getPeriodColor(String period) {
    switch (period) {
      case 'Breakfast':
        return Color(0xFFFFC107); // Amber
      case 'Lunch':
        return Color(0xFF0A84FF); // Blue
      case 'Snack':
        return Color(0xFF4CAF50); // Green
      case 'Dinner':
        return Color(0xFF5E5CE6); // Indigo
      default:
        return Color(0xFF9E9E9E); // Grey
    }
  }

  // Get period icon
  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Snacks':
        return Icons.cookie; // or use Icons.fastfood;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  // Calculate calories for a specific period
  int _calculateCaloriesForPeriod(String period) {
    int total = 0;
    final meals = _getMealsForPeriod(period);

    meals.forEach((mealType, mealItems) {
      for (var item in mealItems) {
        total += item.calories.toInt();
      }
    });

    return total;
  }

  // Calculate snack calories for a specific period
  int _calculateSnackCaloriesForPeriod(String period) {
    int total = 0;
    final snackItems = _dailyFoodData['snacks'] ?? [];

    for (var item in snackItems) {
      final hour = int.tryParse(item.time.split(':')[0]) ?? 0;

      if (period == 'Morning' && hour >= 6 && hour < 12) {
        total += item.calories.toInt();
      } else if (period == 'Afternoon' && hour >= 12 && hour < 18) {
        total += item.calories.toInt();
      } else if (period == 'Evening' && (hour >= 18 || hour < 6)) {
        total += item.calories.toInt();
      }
    }

    return total;
  }

  // Show food detail bottom sheet
  void _showFoodDetailBottomSheet(
    FoodItem item,
    String mealTitle,
    Color mealColor,
  ) {
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
                        _getFoodIcon(item.name),
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
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$mealTitle • ${item.time}',
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
                        '${item.calories} cal',
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
                        _buildNutrientInfo(
                          'Protein',
                          '${item.protein.toInt()} g',
                          Colors.blue,
                        ),
                        _buildNutrientInfo(
                          'Carbs',
                          '${item.carbs.toInt()} g',
                          Colors.orange,
                        ),
                        _buildNutrientInfo(
                          'Fat',
                          '${item.fat.toInt()} g',
                          Colors.green,
                        ),
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

  // Helper method to get color for meal type
  Color _getColorForMealType(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return const Color(0xFFFF9500);
      case 'lunch':
        return const Color(0xFF0A84FF);
      case 'dinner':
        return const Color(0xFF5E5CE6);
      case 'snacks':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
