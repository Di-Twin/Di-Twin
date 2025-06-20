import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/presentation/widgets/sugar_spike_widget.dart';
import 'package:client/features/food_management/presentation/widgets/food_impact_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/food_management/presentation/providers/food_management_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddFoodBottomSheet extends ConsumerStatefulWidget {
  final String mealType;
  final String mealTitle;
  final Function(FoodItem)? onFoodAdded;

  const AddFoodBottomSheet({
    super.key,
    required this.mealType,
    this.mealTitle = '',
    this.onFoodAdded,
  });

  @override
  ConsumerState<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends ConsumerState<AddFoodBottomSheet>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _selectedFood;
  Map<String, dynamic>? _impactData;
  bool _isLoadingImpact = false;
  bool _isAddingFood = false;
  bool _isLoadingMeals = true;
  bool _isLoadingPopularFoods = true;
  Map<String, dynamic>? _dietPlan;
  List<Map<String, dynamic>> _popularFoods = [];
  List<Map<String, dynamic>> _filteredPopularFoods = [];
  String? _errorMessage;
  String? _popularFoodsError;


  late TabController _tabController;
  int _currentTabIndex = 0;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Add search listener
    _searchController.addListener(_onSearchChanged);

    _fetchDietPlan();
    _fetchPopularFoods();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterPopularFoods();
    });
  }

  void _filterPopularFoods() {
    if (_searchQuery.isEmpty) {
      _filteredPopularFoods = List.from(_popularFoods);
    } else {
      _filteredPopularFoods =
          _popularFoods.where((food) {
            final foodName = (food['name'] ?? '').toString().toLowerCase();
            return foodName.contains(_searchQuery);
          }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _filterPopularFoods();
    });
  }

  Future<void> _fetchPopularFoods() async {
    setState(() {
      _isLoadingPopularFoods = true;
      _popularFoodsError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      if (token.isEmpty) {
        throw Exception('No access token available');
      }

      final List<Future> futures = [
        http.get(
          Uri.parse('https://food-service-prod.onrender.com/api/food/items'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        http.get(
          Uri.parse(
            'https://food-service-prod.onrender.com/api/food/ingredients',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      ];

      final responses = await Future.wait(futures);
      final foodsResponse = responses[0] as http.Response;
      final ingredientsResponse = responses[1] as http.Response;

      print('Popular Foods Response status: ${foodsResponse.statusCode}');
      print('Ingredients Response status: ${ingredientsResponse.statusCode}');

      if (foodsResponse.statusCode == 200 &&
          ingredientsResponse.statusCode == 200) {
        final List<dynamic> foodsData = json.decode(foodsResponse.body);
        final List<dynamic> ingredientsData = json.decode(
          ingredientsResponse.body,
        );

        // Create a map for quick ingredient lookup by food name
        final Map<String, List<String>> ingredientsMap = {};
        for (var item in ingredientsData) {
          final foodName = item['food_name'] as String?;
          final ingredients = item['ingredients'] as List<dynamic>?;
          if (foodName != null && ingredients != null) {
            ingredientsMap[foodName] = ingredients.cast<String>();
          }
        }

        setState(() {
          _popularFoods =
              foodsData.asMap().entries.map((entry) {
                final index = entry.key;
                final food = entry.value;
                final macros = food['macronutrients'] ?? {};
                final micros = food['micronutrients'] ?? {};

                
                int safeToInt(dynamic value) {
                  if (value == null) return 0;
                  if (value is int) return value;
                  if (value is double) return value.round();
                  if (value is String) return int.tryParse(value) ?? 0;
                  return 0;
                }

                
                double safeToDouble(dynamic value) {
                  if (value == null) return 0.0;
                  if (value is double) return value;
                  if (value is int) return value.toDouble();
                  if (value is String) return double.tryParse(value) ?? 0.0;
                  return 0.0;
                }

                final foodName = food['food_name'] ?? 'Unknown Food';

                
                List<String> ingredients = [];

                
                if (index < ingredientsData.length) {
                  final ingredientItem = ingredientsData[index];
                  if (ingredientItem['food_name'] == foodName) {
                    ingredients =
                        (ingredientItem['ingredients'] as List<dynamic>?)
                            ?.cast<String>() ??
                        [];
                  }
                }

                if (ingredients.isEmpty) {
                  ingredients = ingredientsMap[foodName] ?? [];
                }

                if (ingredients.isEmpty) {
                  for (var entry in ingredientsMap.entries) {
                    if (entry.key.toLowerCase().contains(
                          foodName.toLowerCase(),
                        ) ||
                        foodName.toLowerCase().contains(
                          entry.key.toLowerCase(),
                        )) {
                      ingredients = entry.value;
                      break;
                    }
                  }
                }

                return {
                  'name': foodName,
                  'calories': safeToInt(macros['energy_kcal']),
                  'protein': safeToDouble(macros['protein_g']),
                  'carbs': safeToDouble(macros['carbohydrates_g']),
                  'fat': safeToDouble(macros['fat_g']),
                  'fiber': safeToDouble(macros['fiber_g']),
                  'sugar': safeToDouble(macros['sugar_g'] ?? 0),
                  'weight': '100g',
                  'color': _getMealColor(widget.mealType),
                  'image_url': food['image_url'],
                  'micronutrients': micros,
                  'instructions': _generateInstructions(foodName, ingredients),
                  'ingredients': _formatIngredients(ingredients, foodName),
                  'raw_ingredients':
                      ingredients, // Keep raw ingredients list for other uses
                  'calcium': safeToDouble(micros['calcium_mg']),
                  'iron': safeToDouble(micros['iron_mg']),
                  'magnesium': safeToDouble(micros['magnesium_mg']),
                  'phosphorus': safeToDouble(micros['phosphorus_mg']),
                  'potassium': safeToDouble(micros['potassium_mg']),
                  'sodium': safeToDouble(micros['sodium_mg']),
                  'zinc': safeToDouble(micros['zinc_mg']),
                  'vitamin_c': safeToDouble(micros['vitamin_c_mg']),
                  'thiamin': safeToDouble(micros['thiamin_mg']),
                  'riboflavin': safeToDouble(micros['riboflavin_mg']),
                  'niacin': safeToDouble(micros['niacin_mg']),
                  'vitamin_b6': safeToDouble(micros['vitamin_b6_mg']),
                  'folate': safeToDouble(micros['folate_ug']),
                  'vitamin_a': safeToDouble(micros['vitamin_a_ug']),
                  'vitamin_e': safeToDouble(micros['vitamin_e_mg']),
                  'vitamin_d': safeToDouble(micros['vitamin_d_ug']),
                };
              }).toList();
          _filterPopularFoods();
        });
      } else {
        if (foodsResponse.statusCode == 200) {
          final List<dynamic> foodsData = json.decode(foodsResponse.body);
          setState(() {
            _popularFoods =
                foodsData.map((food) {
                  final macros = food['macronutrients'] ?? {};
                  final micros = food['micronutrients'] ?? {};

                  int safeToInt(dynamic value) {
                    if (value == null) return 0;
                    if (value is int) return value;
                    if (value is double) return value.round();
                    if (value is String) return int.tryParse(value) ?? 0;
                    return 0;
                  }

                  double safeToDouble(dynamic value) {
                    if (value == null) return 0.0;
                    if (value is double) return value;
                    if (value is int) return value.toDouble();
                    if (value is String) return double.tryParse(value) ?? 0.0;
                    return 0.0;
                  }

                  final foodName = food['food_name'] ?? 'Unknown Food';

                  return {
                    'name': foodName,
                    'calories': safeToInt(macros['energy_kcal']),
                    'protein': safeToDouble(macros['protein_g']),
                    'carbs': safeToDouble(macros['carbohydrates_g']),
                    'fat': safeToDouble(macros['fat_g']),
                    'fiber': safeToDouble(macros['fiber_g']),
                    'sugar': safeToDouble(macros['sugar_g'] ?? 0),
                    'weight': '100g',
                    'color': _getMealColor(widget.mealType),
                    'image_url': food['image_url'],
                    'micronutrients': micros,
                    'instructions':
                        'Prepare as desired. This is a popular food choice.',
                    'ingredients': foodName, // Fallback to food name
                    'raw_ingredients': <String>[], // Empty list
                    'calcium': safeToDouble(micros['calcium_mg']),
                    'iron': safeToDouble(micros['iron_mg']),
                    'magnesium': safeToDouble(micros['magnesium_mg']),
                    'phosphorus': safeToDouble(micros['phosphorus_mg']),
                    'potassium': safeToDouble(micros['potassium_mg']),
                    'sodium': safeToDouble(micros['sodium_mg']),
                    'zinc': safeToDouble(micros['zinc_mg']),
                    'vitamin_c': safeToDouble(micros['vitamin_c_mg']),
                    'thiamin': safeToDouble(micros['thiamin_mg']),
                    'riboflavin': safeToDouble(micros['riboflavin_mg']),
                    'niacin': safeToDouble(micros['niacin_mg']),
                    'vitamin_b6': safeToDouble(micros['vitamin_b6_mg']),
                    'folate': safeToDouble(micros['folate_ug']),
                    'vitamin_a': safeToDouble(micros['vitamin_a_ug']),
                    'vitamin_e': safeToDouble(micros['vitamin_e_mg']),
                    'vitamin_d': safeToDouble(micros['vitamin_d_ug']),
                  };
                }).toList();
            _filterPopularFoods();
          });

          print(
            'Warning: Ingredients API failed, proceeding without ingredients',
          );
        } else {
          throw Exception(
            'Failed to load popular foods (status ${foodsResponse.statusCode})',
          );
        }
      }
    } catch (e) {
      print('Error fetching popular foods: $e');
      setState(() {
        _popularFoodsError = 'Failed to load popular foods: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingPopularFoods = false;
      });
    }
  }

  String _formatIngredients(List<String> ingredients, String foodName) {
    if (ingredients.isEmpty) {
      return foodName; // Fallback to food name if no ingredients
    }

    if (ingredients.length == 1) {
      return ingredients.first;
    }

    if (ingredients.length == 2) {
      return '${ingredients[0]} and ${ingredients[1]}';
    }

    final lastIngredient = ingredients.last;
    final otherIngredients = ingredients.sublist(0, ingredients.length - 1);
    return '${otherIngredients.join(', ')}, and $lastIngredient';
  }

  String _generateInstructions(String foodName, List<String> ingredients) {
    final lowerFoodName = foodName.toLowerCase();

    if (ingredients.isEmpty) {
      return 'Prepare as desired. This is a popular food choice.';
    }

    // Generate context-aware instructions based on food type
    if (lowerFoodName.contains('rice')) {
      return 'Rinse the rice until water runs clear. Cook with appropriate amount of water until tender. Let it rest for 5 minutes before serving.';
    } else if (lowerFoodName.contains('flour') ||
        lowerFoodName.contains('wheat')) {
      return 'Can be used for baking bread, making pasta, or other flour-based recipes. Mix with liquid ingredients as needed for your recipe.';
    } else if (lowerFoodName.contains('chicken') ||
        lowerFoodName.contains('meat')) {
      return 'Cook thoroughly until internal temperature reaches safe levels. Season as desired and cook using your preferred method.';
    } else if (lowerFoodName.contains('vegetable') ||
        lowerFoodName.contains('fruit')) {
      return 'Wash thoroughly before consumption. Can be eaten fresh or cooked according to preference.';
    } else if (lowerFoodName.contains('oil')) {
      return 'Use for cooking, frying, or as a dressing. Heat to appropriate temperature for cooking method.';
    } else if (lowerFoodName.contains('milk') ||
        lowerFoodName.contains('dairy')) {
      return 'Store refrigerated and consume before expiration date. Can be used in cooking, baking, or consumed directly.';
    } else if (lowerFoodName.contains('egg')) {
      return 'Cook thoroughly before consumption. Can be boiled, fried, scrambled, or used in baking.';
    } else if (lowerFoodName.contains('fish')) {
      return 'Cook until fish flakes easily with a fork. Season as desired and avoid overcooking.';
    } else if (lowerFoodName.contains('bean') ||
        lowerFoodName.contains('lentil')) {
      return 'Soak overnight if dried, then cook until tender. Season with spices and herbs as desired.';
    } else {
      // Generic instruction with ingredients
      return 'Prepare using ${_formatIngredients(ingredients, foodName)}. Cook according to your preference and dietary requirements.';
    }
  }

  Future<void> _regenerateMeal() async {
    setState(() {
      _isLoadingMeals = true;
      _errorMessage = null;
    });

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await http.post(
        Uri.parse(
          'https://test-prod-f427.onrender.com/api/diet-plan/regenerate/${widget.mealType}',
        ).replace(queryParameters: {'date': today}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            if (_dietPlan != null) {
              _dietPlan![widget.mealType] = data['data'];
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)} regenerated successfully!',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to regenerate meal');
        }
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid meal type');
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 404) {
        throw Exception('No ${widget.mealType} options found');
      } else {
        throw Exception('Failed to regenerate meal');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to regenerate meal: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to regenerate meal: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoadingMeals = false;
      });
    }
  }

  Future<void> _fetchDietPlan() async {
    setState(() {
      _isLoadingMeals = true;
      _errorMessage = null;
    });

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final uri = Uri.parse(
        'https://test-prod-f427.onrender.com/api/diet-plan',
      ).replace(queryParameters: {'date': today});

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dietPlan = data['data'];
        });
      } else {
        throw Exception(
          'Failed to load diet plan (status ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _errorMessage = 'Failed to load meals: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingMeals = false;
      });
    }
  }

  Future<void> _selectFood(Map<String, dynamic> food) async {
    setState(() {
      _selectedFood = food;
      _isLoadingImpact = true;
    });

    // Create a properly formatted food object for the impact calculator
    Map<String, dynamic> formattedFood = {
      'name': food['name'] ?? 'Unknown Food',
      'calories':
          (food['calories'] is double)
              ? (food['calories'] as double).round()
              : (food['calories'] ?? 0),
      'protein':
          (food['protein'] is double)
              ? (food['protein'] as double).round()
              : (food['protein'] ?? 0),
      'carbs':
          (food['carbs'] is double)
              ? (food['carbs'] as double).round()
              : (food['carbs'] ?? 0),
      'fat':
          (food['fat'] is double)
              ? (food['fat'] as double).round()
              : (food['fat'] ?? 0),
      'fiber':
          (food['fiber'] is double)
              ? (food['fiber'] as double).round()
              : (food['fiber'] ?? 0),
      'sugar':
          (food['sugar'] is double)
              ? (food['sugar'] as double).round()
              : (food['sugar'] ?? 0),
      'weight': food['weight'] ?? '100g',
      'mealType': widget.mealType,
      'color': food['color'] ?? _getMealColor(widget.mealType),
      'instructions': food['instructions'] ?? 'No instructions provided',
      'ingredients': food['ingredients'] ?? 'No ingredients listed',
      'image_url': food['image_url'],
      'micronutrients': food['micronutrients'] ?? {},
    };

    _selectedFood = formattedFood;

    try {
      final impactData = await FoodImpactCalculator.calculateImpact(
        formattedFood,
        ref,
      );

      setState(() {
        _impactData = impactData;
        _isLoadingImpact = false;
      });
    } catch (e) {
      print('Error calculating impact: $e');
      setState(() {
        _impactData = null;
        _isLoadingImpact = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not calculate blood sugar impact'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addFoodToMeal() async {
    if (_selectedFood == null) return;

    setState(() {
      _isAddingFood = true;
    });

    try {
      final foodProvider = FoodManagementProvider();

      final foodSession = {
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "foodItems": [
          {
            "foodName": _selectedFood!['name'] ?? 'Unknown Food',
            "macronutrients": {
              "energy_kcal": (_selectedFood!['calories'] as num).round(),
              "protein_g": (_selectedFood!['protein'] as num).toDouble(),
              "fat_g": (_selectedFood!['fat'] as num).toDouble(),
              "carbohydrates_g": (_selectedFood!['carbs'] as num).toDouble(),
              if (_selectedFood!['fiber'] != null)
                "fiber_g": (_selectedFood!['fiber'] as num).toDouble(),
              if (_selectedFood!['sugar'] != null)
                "sugar_g": (_selectedFood!['sugar'] as num).toDouble(),
            },
            "serving_size": _selectedFood!['weight'] ?? '100g',
            "serving_amount": 1.0,
            "mealType": widget.mealType,
          },
        ],
      };

      final FoodItem foodItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _selectedFood!['name'] ?? 'Unknown Food',
        calories: (_selectedFood!['calories'] as num).round(),
        weight: _selectedFood!['weight']?.toString() ?? '100g',
        protein: (_selectedFood!['protein'] as num).toDouble(),
        carbs: (_selectedFood!['carbs'] as num).toDouble(),
        fat: (_selectedFood!['fat'] as num).toDouble(),
        mealType: widget.mealType,
        time: DateFormat('HH:mm').format(DateTime.now()),
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        color: _selectedFood!['color'] ?? Colors.blue,
      );

      final response = await foodProvider.createFoodSession(foodSession);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedFood!['name'] ?? "Food"} added to ${widget.mealType}',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
        if (widget.onFoodAdded != null) {
          widget.onFoodAdded!(foodItem);
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to add food');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add food: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAddingFood = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          _selectedFood != null
              ? MediaQuery.of(context).size.height * 0.85
              : MediaQuery.of(context).size.height * 0.7,
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

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to ${widget.mealTitle.isNotEmpty ? widget.mealTitle : widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
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

          if (_selectedFood == null) ...[
            // Tab bar for switching between recommended and popular foods
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Color(0xFF0F67FE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF64748B),
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [Tab(text: 'Recommended'), Tab(text: 'Popular Foods')],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecommendedMealList(),
                  _buildPopularFoodsList(),
                ],
              ),
            ),
          ] else
            _buildSelectedFoodDetails(),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed:
                    (_selectedFood != null &&
                            !_isAddingFood &&
                            !_isLoadingImpact)
                        ? _addFoodToMeal
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(
                    0xFF0F67FE,
                  ).withOpacity(0.5),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child:
                    _isAddingFood
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Add to ${widget.mealTitle.isNotEmpty ? widget.mealTitle : widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
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
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _isSearching ? Color(0xFF0F67FE) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onTap: () {
          setState(() {
            _isSearching = true;
          });
        },
        onSubmitted: (value) {
          setState(() {
            _isSearching = false;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search foods...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isSearching ? Color(0xFF0F67FE) : Colors.grey[500],
            size: 20.sp,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                      size: 20.sp,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildPopularFoodsList() {
    if (_isLoadingPopularFoods) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0F67FE)),
            SizedBox(height: 16.h),
            Text(
              'Loading popular foods...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    if (_popularFoodsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _popularFoodsError!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchPopularFoods,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F67FE),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_popularFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No popular foods available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchPopularFoods,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F67FE),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Results count and clear search
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredPopularFoods.length} results for "$_searchQuery"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_filteredPopularFoods.isEmpty)
                  TextButton(
                    onPressed: _clearSearch,
                    child: Text(
                      'Clear search',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Color(0xFF0F67FE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Food list
        Expanded(
          child:
              _filteredPopularFoods.isEmpty && _searchQuery.isNotEmpty
                  ? _buildNoSearchResults()
                  : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchQuery.isEmpty) ...[
                          Text(
                            'Popular Foods',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Choose from our most popular food items',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _filteredPopularFoods.length,
                          separatorBuilder:
                              (context, index) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final food = _filteredPopularFoods[index];
                            return _buildFoodCard(food);
                          },
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No foods found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          TextButton.icon(
            onPressed: _clearSearch,
            icon: Icon(Icons.clear, size: 18.sp),
            label: Text('Clear search'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF0F67FE),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _selectFood(food),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _getMealColor(widget.mealType).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getMealColor(widget.mealType).withOpacity(0.8),
                    _getMealColor(widget.mealType),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: _getMealColor(widget.mealType).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getFoodIcon(food['name']),
                size: 28.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'P: ${food['protein'].toInt()}g • C: ${food['carbs'].toInt()}g • F: ${food['fat'].toInt()}g',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F67FE), Color(0xFF2E86FB)],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${food['calories']} cal',
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
    );
  }

  IconData _getFoodIcon(String foodName) {
    final lowerCaseName = foodName.toLowerCase();

    if (lowerCaseName.contains('rice')) {
      return Icons.rice_bowl;
    } else if (lowerCaseName.contains('chicken') ||
        lowerCaseName.contains('meat')) {
      return Icons.set_meal;
    } else if (lowerCaseName.contains('vegetable') ||
        lowerCaseName.contains('broccoli')) {
      return Icons.eco;
    } else if (lowerCaseName.contains('fruit') ||
        lowerCaseName.contains('apple')) {
      return Icons.apple;
    } else if (lowerCaseName.contains('bread') ||
        lowerCaseName.contains('toast')) {
      return Icons.breakfast_dining;
    } else if (lowerCaseName.contains('fish')) {
      return Icons.set_meal;
    } else if (lowerCaseName.contains('egg')) {
      return Icons.egg;
    } else if (lowerCaseName.contains('milk') ||
        lowerCaseName.contains('dairy')) {
      return Icons.local_cafe;
    }

    return Icons.restaurant;
  }

  // Keep all the other existing methods (_buildRecommendedMealList, _buildSelectedFoodDetails, etc.)
  // ... [Rest of the existing methods remain the same]

  Widget _buildRecommendedMealList() {
    // ... [Keep the existing implementation]
    if (_isLoadingMeals) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Loading meal recommendations...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDietPlan,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F67FE),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    String mealTypeKey = widget.mealType;

    if (_dietPlan == null || !_dietPlan!.containsKey(mealTypeKey)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No ${widget.mealType} available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _regenerateMeal,
              icon: Icon(Icons.refresh),
              label: Text(
                'Generate ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F67FE),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final meal = _dietPlan![mealTypeKey];

    if (meal == null) {
      return Center(child: Text('Meal data is null for $mealTypeKey'));
    }

    final nutrients = meal['nutrients'] ?? {};
    final formattedMeal = {
      'name': meal['name'] ?? 'Unknown Meal',
      'calories': meal['calories'] ?? 0,
      'protein': nutrients['protein'] ?? 0,
      'carbs': nutrients['carbs'] ?? 0,
      'fat': nutrients['fat'] ?? 0,
      'color': _getMealColor(widget.mealType),
      'instructions': meal['instructions'] ?? 'No instructions provided',
      'ingredients': meal['ingredients'] ?? 'No ingredients listed',
      'weight': '1 serving',
      'score': meal['score'] ?? 0,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended ${widget.mealTitle.isNotEmpty ? widget.mealTitle : widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isLoadingMeals ? null : _regenerateMeal,
                  icon:
                      _isLoadingMeals
                          ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0F67FE),
                            ),
                          )
                          : Icon(
                            Icons.refresh,
                            color: Color(0xFF0F67FE),
                            size: 20.sp,
                          ),
                  tooltip: 'Regenerate ${widget.mealType}',
                ),
              ),
            ],
          ),

          if (meal['score'] != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14.sp, color: Colors.green),
                    SizedBox(width: 2.w),
                    Text(
                      'Score: ${meal['score']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 16.h),

          GestureDetector(
            onTap: () => _selectFood(formattedMeal),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: _getMealColor(widget.mealType).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getMealColor(widget.mealType).withOpacity(0.8),
                              _getMealColor(widget.mealType),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: _getMealColor(
                                widget.mealType,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getMealIcon(widget.mealType),
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedMeal['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0F67FE),
                                    Color(0xFF2E86FB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '${formattedMeal['calories']} calories',
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
                    ],
                  ),
                  SizedBox(height: 16.h),

                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniNutrientInfo(
                          'Protein',
                          '${formattedMeal['protein']}g',
                          Color(0xFF0F67FE),
                        ),
                        _buildMiniNutrientInfo(
                          'Carbs',
                          '${formattedMeal['carbs']}g',
                          Color(0xFFFF9500),
                        ),
                        _buildMiniNutrientInfo(
                          'Fat',
                          '${formattedMeal['fat']}g',
                          Color(0xFFFF2D55),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'Instructions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    formattedMeal['instructions'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 16.h),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _getMealColor(widget.mealType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tap to view details and add to ${widget.mealTitle.isNotEmpty ? widget.mealTitle : widget.mealType}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: _getMealColor(widget.mealType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.sp,
                          color: _getMealColor(widget.mealType),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoodDetails() {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFood = null;
                  _impactData = null;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16.sp,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Back to food selection',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: _selectedFood!['color'] ?? Colors.blue,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFood!['name'] ?? 'Unknown Food',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${_selectedFood!['calories'] ?? 0} calories',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            Text(
              'Nutrition Information',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                _buildNutrientCard(
                  'Protein',
                  '${_selectedFood!['protein'] ?? 0}g',
                  Color(0xFFEDF2FF),
                  Color(0xFF0F67FE),
                ),
                SizedBox(width: 12.w),
                _buildNutrientCard(
                  'Carbs',
                  '${_selectedFood!['carbs'] ?? 0}g',
                  Color(0xFFFFF4DE),
                  Color(0xFFFF9500),
                ),
                SizedBox(width: 12.w),
                _buildNutrientCard(
                  'Fat',
                  '${_selectedFood!['fat'] ?? 0}g',
                  Color(0xFFFFEEF6),
                  Color(0xFFFF2D55),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            if (_selectedFood?['ingredients'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _selectedFood!['ingredients'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),

            if (_selectedFood?['instructions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _selectedFood!['instructions'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),

            if (_isLoadingImpact)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0F67FE)),
                    SizedBox(height: 16.h),
                    Text(
                      'Calculating blood sugar impact...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else if (_impactData != null)
              SugarSpikeWidget(
                food: _selectedFood!,
                sugarSpike: _impactData!['sugarSpike'],
                impactLevel: _impactData!['impactLevel'],
                impactColor: _impactData!['impactColor'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Color(0xFFFFC107);
      case 'lunch':
        return Color(0xFF0A84FF);
      case 'dinner':
        return Color(0xFF5E5CE6);
      case 'snacks':
      case 'snack':
        return Color(0xFF4CAF50);
      default:
        return Color(0xFF0F67FE);
    }
  }
}
