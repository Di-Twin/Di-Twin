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
  final PageController _pageController = PageController();
  final PageController _mealContentController = PageController();

  // Selected meal period index
  int _selectedMealPeriodIndex = 0;

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

      developer.log('User Profile API - Token available: ${token.isNotEmpty}', name: 'UserProfileAPI');
      
      if (token.isEmpty) {
        developer.log('User Profile API - No access token available', name: 'UserProfileAPI');
        setState(() {
          _isLoadingUserProfile = false;
          _userJoinDate = DateTime.now(); // Default fallback
        });
        return;
      }

      // Make API request to get user profile
      final url = Uri.parse('https://test-prod-f427.onrender.com/api/users');
      developer.log('User Profile API - Request URL: $url', name: 'UserProfileAPI');
      developer.log('User Profile API - Request Headers: Content-Type: application/json, Authorization: Bearer ${token.substring(0, 5)}...', name: 'UserProfileAPI');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('User Profile API - Response Status: ${response.statusCode}', name: 'UserProfileAPI');
      
      if (response.statusCode == 401) {
        developer.log('User Profile API - 401 Unauthorized Error', name: 'UserProfileAPI');
        developer.log('User Profile API - Response Body: ${response.body}', name: 'UserProfileAPI');
        developer.log('User Profile API - Token used: ${token.substring(0, 5)}...', name: 'UserProfileAPI');
        
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
                    builder: (context) => AlertDialog(
                      title: Text('Authentication Error'),
                      content: SingleChildScrollView(
                        child: Text('Failed to authenticate with the server.\n\nStatus: ${response.statusCode}\nResponse: ${response.body}'),
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
        developer.log('User Profile API - Success: ${data['success']}', name: 'UserProfileAPI');
        
        if (data['success'] == true && data['data'] != null) {
          // Parse the created_at date
          final createdAtString = data['data']['created_at'];
          if (createdAtString != null) {
            setState(() {
              _userJoinDate = DateTime.parse(createdAtString);
              _isLoadingUserProfile = false;
            });
            developer.log('User Profile API - User join date: $_userJoinDate', name: 'UserProfileAPI');
          } else {
            developer.log('User Profile API - No created_at date found', name: 'UserProfileAPI');
            setState(() {
              _userJoinDate = DateTime.now(); // Default fallback
              _isLoadingUserProfile = false;
            });
          }
        } else {
          developer.log('User Profile API - Invalid response format: ${response.body}', name: 'UserProfileAPI');
          setState(() {
            _userJoinDate = DateTime.now(); // Default fallback
            _isLoadingUserProfile = false;
          });
        }
      } else {
        developer.log('User Profile API - Failed with status: ${response.statusCode}', name: 'UserProfileAPI');
        developer.log('User Profile API - Response Body: ${response.body}', name: 'UserProfileAPI');
        
        setState(() {
          _userJoinDate = DateTime.now(); // Default fallback
          _isLoadingUserProfile = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('User Profile API - Error: $e', name: 'UserProfileAPI');
      developer.log('User Profile API - Stack trace: $stackTrace', name: 'UserProfileAPI');
      
      setState(() {
        _userJoinDate = DateTime.now(); // Default fallback
        _isLoadingUserProfile = false;
      });
    }
  }

  // Update the initState method to call _fetchUserProfile
  @override
  void initState() {
    super.initState();

    // Create two separate API clients for the different services
    _foodRemoteDataSource = FoodRemoteDataSourceImpl(
      apiClient: ApiClient(
        baseUrl: 'https://food-service-prod.onrender.com/api',
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

    _loadPopularFoods();
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
            _loadFoodItemsFromAPI();
          }
        });

        // Fetch user profile to get join date
        _fetchUserProfile();

        // Set initial meal period based on current time
        final currentHour = DateTime.now().hour;
        if (currentHour >= 6 && currentHour < 12) {
          _selectedMealPeriodIndex = 0; // Morning
        } else if (currentHour >= 12 && currentHour < 18) {
          _selectedMealPeriodIndex = 1; // Afternoon
        } else {
          _selectedMealPeriodIndex = 2; // Evening
        }

        // Jump to the correct page based on current time
        _pageController.jumpToPage(_selectedMealPeriodIndex);
        _mealContentController.jumpToPage(_selectedMealPeriodIndex);

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

        _loadDailyFoodData(forceRefresh: true);
        _loadDailyFoodScore();
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
      final token = prefs.getString('access_token') ?? '';
      
      developer.log('Token retrieval - Token length: ${token.length}', name: 'TokenManager');
      if (token.isNotEmpty) {
        developer.log('Token retrieval - Token prefix: ${token.substring(0, Math.min(5, token.length))}...', name: 'TokenManager');
      } else {
        developer.log('Token retrieval - No token found', name: 'TokenManager');
      }
      
      return token;
    } catch (e, stackTrace) {
      developer.log('Token retrieval - Error: $e', name: 'TokenManager');
      developer.log('Token retrieval - Stack trace: $stackTrace', name: 'TokenManager');
      return '';
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
          Uri.parse('https://food-service-prod.onrender.com/api/food/score/daily/$today'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            setState(() {
              _foodScore = data['data']['food_score'].toString();
            });
          } else {
            setState(() {
              _foodScore = '0'; // Show 0 instead of default score
            });
          }
        } else {
          setState(() {
            _foodScore = '0'; // Show 0 instead of default score
          });
        }
      } catch (e) {
        print('Error loading food score: $e');
        setState(() {
          _foodScore = '0'; // Show 0 instead of default score
        });
      }

      // Load popular foods
      try {
        await _loadFoodItemsFromAPI();
      } catch (e) {
        print('Error loading popular foods: $e');
        // Don't set any default foods
      }

      // Load daily food data
      try {
        final response = await http.get(
          Uri.parse('https://food-service-prod.onrender.com/api/food/daily/$today'),
          headers: {'Content-Type': 'application/json'},
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
                    DateTime foodTime = DateTime.parse(foodItem['time']);

                    FoodItem processedFood = FoodItemModel(
                      id: foodItem['id'] ?? '',
                      name: foodItem['foodName'],
                      calories: foodItem['calories'] is int
                          ? foodItem['calories']
                          : (foodItem['calories'] as num).toInt(),
                      protein: foodItem['protein'] ?? 0,
                      carbs: foodItem['carbs'] ?? 0,
                      fat: foodItem['fat'] ?? 0,
                      time: DateFormat('HH:mm').format(foodTime),
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

  Future<void> _loadDailyFoodData({bool forceRefresh = false}) async {
    try {
      if (!mounted) return;
      
      final dailyFoodProvider = Provider.of<DailyFoodProvider>(
        context,
        listen: false,
      );
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await dailyFoodProvider.getDailyFood(
        date: dateStr,
        forceRefresh: forceRefresh,
      );
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
      // Format today's date
      final today = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Use the correct API endpoint
      final response = await http.get(
        Uri.parse(
          'https://food-service-prod.onrender.com/api/food/score/daily/$today',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _foodScore = data['data']['food_score'].toString();
            _isLoadingScore = false;
          });
        } else {
          setState(() {
            _isLoadingScore = false;
            _scoreError = data['message'] ?? 'Failed to load score';
            _foodScore = '0'; // Show 0 instead of default score
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load food score: ${data['message'] ?? 'Unknown error'}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        setState(() {
          _isLoadingScore = false;
          _scoreError = 'Server error: ${response.statusCode}';
          _foodScore = '0'; // Show 0 instead of default score
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server error: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading food score: $e');
      if (mounted) {
        setState(() {
          _isLoadingScore = false;
          _scoreError = 'Failed to load score';
          _foodScore = '0'; // Show 0 instead of default score
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to the server. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add a new method to load food items from the API
  // Update the _loadFoodItemsFromAPI method to use direct HTTP request
  Future<void> _loadFoodItemsFromAPI() async {
    setState(() {
      _isLoadingFoodItems = true;
    });

    try {
      // Use direct HTTP request to the correct endpoint
      final url = Uri.parse('https://food-service-prod.onrender.com/api/food/items');
      developer.log('Food API - Request URL: $url', name: 'FoodAPI');
      
      // Get token for debugging purposes
      final token = await _getAccessToken();
      developer.log('Food API - Token available: ${token.isNotEmpty}', name: 'FoodAPI');
      
      // Prepare headers
      final headers = {'Content-Type': 'application/json'};
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        developer.log('Food API - Using authorization header', name: 'FoodAPI');
      }
      
      developer.log('Food API - Request Headers: $headers', name: 'FoodAPI');
      
      final response = await http.get(
        url,
        headers: headers,
      );

      developer.log('Food API - Response Status: ${response.statusCode}', name: 'FoodAPI');
      
      if (response.statusCode == 401) {
        developer.log('Food API - 401 Unauthorized Error', name: 'FoodAPI');
        developer.log('Food API - Response Body: ${response.body}', name: 'FoodAPI');
        
        setState(() {
          _isLoadingFoodItems = false;
          _popularFoodsOld = [];
          _popularFoods = [];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication error: Unable to fetch food items'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Details',
                onPressed: () {
                  // Show more details in a dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Authentication Error'),
                      content: SingleChildScrollView(
                        child: Text('Failed to authenticate with the food service.\n\nStatus: ${response.statusCode}\nResponse: ${response.body}'),
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
        developer.log('Food API - Success: ${data['success']}', name: 'FoodAPI');
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          developer.log('Food API - Items count: ${items.length}', name: 'FoodAPI');
          
          final foodItems = items.map((item) => FoodItemModel.fromJson(item)).toList();

          setState(() {
            _popularFoods = foodItems;
            _isLoadingFoodItems = false;

            // Convert to the format expected by AddFoodBottomSheet
            _popularFoodsOld = foodItems
                .map(
                  (item) => {
                    'id': item.id,
                    'name': item.name,
                    'calories': item.calories,
                    'weight': item.weight,
                    'protein': item.protein,
                    'carbs': item.carbs,
                    'fat': item.fat,
                    'color': item.color,
                  },
                )
                .toList();
        });
      } else {
        developer.log('Food API - Invalid response format: ${response.body}', name: 'FoodAPI');
        setState(() {
          _isLoadingFoodItems = false;
          _popularFoodsOld = [];
          _popularFoods = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load food items: ${data['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      developer.log('Food API - Failed with status: ${response.statusCode}', name: 'FoodAPI');
      developer.log('Food API - Response Body: ${response.body}', name: 'FoodAPI');
      
      setState(() {
        _isLoadingFoodItems = false;
        _popularFoodsOld = [];
        _popularFoods = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e, stackTrace) {
    developer.log('Food API - Error: $e', name: 'FoodAPI');
    developer.log('Food API - Stack trace: $stackTrace', name: 'FoodAPI');
    
    setState(() {
      _isLoadingFoodItems = false;
      _popularFoodsOld = [];
      _popularFoods = [];
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to the server. Please check your internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  // Update _loadPopularFoods method to use the new API endpoint if token is available
  Future<void> _loadPopularFoods() async {
    await _loadFoodItemsFromAPI();
  }

  // Fallback popular foods data
  List<Map<String, dynamic>> _getDefaultPopularFoods() {
    return [
      {
        'id': '1',
        'name': 'Grilled Chicken',
        'calories': 165,
        'weight': '100g',
        'protein': 31,
        'carbs': 0,
        'fat': 3.6,
        'color': Colors.orange,
      },
      {
        'id': '2',
        'name': 'Salmon',
        'calories': 206,
        'weight': '100g',
        'protein': 22,
        'carbs': 0,
        'fat': 13,
        'color': Colors.pink,
      },
      {
        'id': '3',
        'name': 'Greek Yogurt',
        'calories': 59,
        'weight': '100g',
        'protein': 10,
        'carbs': 3.6,
        'fat': 0.4,
        'color': Colors.blue,
      },
      {
        'id': '4',
        'name': 'Avocado',
        'calories': 160,
        'weight': '100g',
        'protein': 2,
        'carbs': 8.5,
        'fat': 14.7,
        'color': Colors.green,
      },
      {
        'id': '5',
        'name': 'Quinoa',
        'calories': 120,
        'weight': '100g',
        'protein': 4.4,
        'carbs': 21.3,
        'fat': 1.9,
        'color': Colors.amber,
      },
    ];
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
    if (mealType == 'breakfast') {
      mealTitle = 'Breakfast';
    } else if (mealType == 'lunch') {
      mealTitle = 'Lunch';
    } else if (mealType == 'dinner') {
      mealTitle = 'Dinner';
    } else if (mealType == 'snacks') {
      mealTitle = 'Snacks';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddFoodBottomSheet(
            mealType: mealType ?? 'breakfast',
            mealTitle: mealTitle,
            popularFoods: _popularFoodsOld,
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
        builder: (context) => FoodManagementStatsScreen(
          userJoinDate: _userJoinDate ?? DateTime(2025, 4, 1),
        ),
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
                    _buildMealPeriodCarousel(),

                    // Meal Content
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height -
                          500.h, // Adjust this value as needed
                      child: _buildMealContent(),
                    ),
                  ],
                ),
              ),
    );
  }

  // Build meal period carousel
  Widget _buildMealPeriodCarousel() {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedMealPeriodIndex = index;
          });
        },
        children: [
          _buildMealPeriodTab('Morning', 0),
          _buildMealPeriodTab('Afternoon', 1),
          _buildMealPeriodTab('Evening', 2),
        ],
      ),
    );
  }

  // Build meal period tab
  Widget _buildMealPeriodTab(String title, int index) {
    final isSelected = _selectedMealPeriodIndex == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0F67FE) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Color(0xFF0F67FE).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // Build meal content based on selected period
  Widget _buildMealContent() {
    return PageView(
      controller: _mealContentController,
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
      children: [
        _buildMealPeriodContent('Morning'),
        _buildMealPeriodContent('Afternoon'),
        _buildMealPeriodContent('Evening'),
      ],
    );
  }

  // Build content for a specific meal period
  Widget _buildMealPeriodContent(String period) {
    // Get meals for this period
    final meals = _getMealsForPeriod(period);
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
                    // Main meal section
                    _buildMainMealSection(period, meals),

                    SizedBox(height: 24.h),

                    // Snacks section
                    _buildSnacksSection(period),

                    SizedBox(height: 24.h),

                    // Popular foods section
                    _buildPopularFoodsSection(),
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
  Widget _buildMainMealSection(
    String period,
    Map<String, List<FoodItem>> meals,
  ) {
    final mealType = _getMealTypeForPeriod(period);
    final mealTitle = _getMealTitleForPeriod(period);
    final mealItems = meals[mealType] ?? [];

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
                    Text(
                      _getMealTitleForPeriod(period),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
                        color: Color(0xFF0F67FE),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${_calculateCaloriesForPeriod(period)} cal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F67FE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Meal items
          if (mealItems.isEmpty)
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 48.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No ${_getMealTitleForPeriod(period).toLowerCase()} logged yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add your meal to track your nutrition',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
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
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: Colors.grey.withOpacity(0.1),
                  ),
              itemBuilder: (context, index) {
                final item = mealItems[index];

                return InkWell(
                  onTap: () {
                    _showFoodDetailBottomSheet(
                      item,
                      _getMealTitleForPeriod(period),
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
                                    'P: ${item.protein.toInt()}g • C: ${item.carbs.toInt()}g • F: ${item.fat.toInt()}g',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
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
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F67FE), Color(0xFF2E86FB)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0F67FE).withOpacity(0.3),
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
                              color: Colors.white,
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

  // Build popular foods section
  Widget _buildPopularFoodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Foods',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            Row(
              children: [
                if (_accessToken.isNotEmpty)
                  IconButton(
                    onPressed: _loadFoodItemsFromAPI,
                    icon:
                        _isLoadingFoodItems
                            ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0F67FE),
                              ),
                            )
                            : Icon(
                              Icons.refresh,
                              color: Color(0xFF0F67FE),
                              size: 22.sp,
                            ),
                  ),
                TextButton(
                  onPressed: () => _showAddFoodBottomSheet(),
                  child: Text(
                    'View All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F67FE),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularFoods.length,
            itemBuilder: (context, index) {
              final food = _popularFoods[index];
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: GestureDetector(
                  onTap: () => _showAddFoodBottomSheet(),
                  child: Container(
                    width: 120.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [food.color.withOpacity(0.8), food.color],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: food.color.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getFoodIcon(food.name),
                          color: Colors.white,
                          size: 36.sp,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          food.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${food.calories} cal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
      ],
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
    if (period == 'Morning') return 'breakfast';
    if (period == 'Afternoon') return 'lunch';
    if (period == 'Evening') return 'dinner';
    return 'breakfast';
  }

  // Get meal title for a period
  String _getMealTitleForPeriod(String period) {
    if (period == 'Morning') return 'Breakfast';
    if (period == 'Afternoon') return 'Lunch';
    if (period == 'Evening') return 'Dinner';
    return 'Meal';
  }

  // Get period color
  Color _getPeriodColor(String period) {
    if (period == 'Morning') return Color(0xFFFF9500);
    if (period == 'Afternoon') return Color(0xFF0A84FF);
    if (period == 'Evening') return Color(0xFF5E5CE6);
    return Color(0xFF9E9E9E);
  }

  // Get period icon
  IconData _getPeriodIcon(String period) {
    if (period == 'Morning') return Icons.free_breakfast;
    if (period == 'Afternoon') return Icons.lunch_dining;
    if (period == 'Evening') return Icons.dinner_dining;
    return Icons.restaurant;
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
