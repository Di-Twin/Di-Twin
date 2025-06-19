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

class _AddFoodBottomSheetState extends ConsumerState<AddFoodBottomSheet> {
  Map<String, dynamic>? _selectedFood;
  Map<String, dynamic>? _impactData;
  bool _isLoadingImpact = false;
  bool _isAddingFood = false;
  bool _isLoadingMeals = true;
  Map<String, dynamic>? _dietPlan;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDietPlan();
  }

  Future<void> _regenerateMeal() async {
    setState(() {
      _isLoadingMeals = true;
      _errorMessage = null;
    });

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // final token =
      //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlODE0NDQ3NS0yY2E1LTQ3YTQtOTUwOS1mMDhjYWZlNWYwZjUiLCJtb2JpbGUiOiIrOTE5ODc2NTQzMjEwIiwiaWF0IjoxNzUwMzI3MzU2LCJleHAiOjE3NTA0MTM3NTZ9.QAdTh8zdceJpFzEGF8jX3Ly0dYB60CuKb7mEwAPgykM';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      // Call the regenerate API endpoint
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
          // Update the diet plan with the new regenerated meal
          setState(() {
            if (_dietPlan != null) {
              _dietPlan![widget.mealType] = data['data'];
            }
          });

          // Show success message
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

      // Show error message
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
      // final token =
      //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlODE0NDQ3NS0yY2E1LTQ3YTQtOTUwOS1mMDhjYWZlNWYwZjUiLCJtb2JpbGUiOiIrOTE5ODc2NTQzMjEwIiwiaWF0IjoxNzUwMzI3MzU2LCJleHAiOjE3NTA0MTM3NTZ9.QAdTh8zdceJpFzEGF8jX3Ly0dYB60CuKb7mEwAPgykM';
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

    _selectedFood!['mealType'] = widget.mealType;

    final impactData = await FoodImpactCalculator.calculateImpact(food, ref);

    setState(() {
      _impactData = impactData;
      _isLoadingImpact = false;
    });
  }

  Future<void> _addFoodToMeal() async {
    if (_selectedFood == null) return;

    setState(() {
      _isAddingFood = true;
    });

    try {
      final foodProvider = FoodManagementProvider();

      // Prepare the food session data according to the new API format
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
            "serving_amount": 1.0, // Default serving amount
            "mealType": widget.mealType,
          },
        ],
      };

      // Create the FoodItem object for local use
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

      // Call the updated API endpoint
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

          if (_selectedFood == null)
            _buildMealList()
          else
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

  Widget _buildMealList() {
    if (_isLoadingMeals) {
      return Expanded(
        child: Center(
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
        ),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
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
        ),
      );
    }

    String mealTypeKey = widget.mealType;

    if (_dietPlan == null || !_dietPlan!.containsKey(mealTypeKey)) {
      return Expanded(
        child: Center(
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
        ),
      );
    }

    final meal = _dietPlan![mealTypeKey];

    if (meal == null) {
      return Expanded(
        child: Center(child: Text('Meal data is null for $mealTypeKey')),
      );
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

    return Expanded(
      child: SingleChildScrollView(
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
                // Add regenerate button here
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

            // Show score if available
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

            // Rest of the meal display code remains the same...
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

                    // Nutrition summary
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

                    // Tap to view more indicator
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
      ),
    );
  }

  // Add this helper method to build mini nutrient info
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
        return Color(0xFFFFC107); // Amber
      case 'lunch':
        return Color(0xFF0A84FF); // Blue
      case 'dinner':
        return Color(0xFF5E5CE6); // Indigo
      case 'snacks':
      case 'snack':
        return Color(0xFF4CAF50); // Green
      default:
        return Color(0xFF0F67FE); // Default blue
    }
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
                    'Back to meal',
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
}
