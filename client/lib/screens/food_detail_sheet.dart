import 'package:client/data/providers/food_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/utils/food_utils.dart';
import 'package:client/widgets/nutrient_circle.dart';
import 'package:client/widgets/simplified_blood_sugar_response.dart';

class FoodDetailSheet extends StatefulWidget {
  final Map<String, dynamic> food;
  final String mealType;
  final Function(Map<String, dynamic>)? onAdd;

  const FoodDetailSheet({
    Key? key,
    required this.food,
    required this.mealType,
    this.onAdd,
  }) : super(key: key);

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  TimeOfDay selectedTime = TimeOfDay.now();
  double servingSize = 1.0;
  String servingUnit = 'g'; // Default unit

  final FoodManagementProvider _foodProvider = FoodManagementProvider();
  // double _servingSize = 1.0;

  void _addFood() async {
    try {
      // Prepare food data with mealType and serving size
      final foodData = {
        'foodId': widget.food['id'],
        'mealType': widget.mealType.toLowerCase(),
        'servingSize': servingSize,
      };

      // Call provider to add food
      final addedFood = await _foodProvider.addFoodItem(foodData);

      // Notify parent widget and close sheet
      if (widget.onAdd != null) widget.onAdd!(addedFood);
      Navigator.pop(context, addedFood);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add food: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFoodDetailSheet(Map<String, dynamic> food) async {
    final addedFood = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FoodDetailSheet(food: food, mealType: widget.mealType),
    );

    if (addedFood != null) {
      // Close the AddFoodBottomSheet and return the added food
      Navigator.pop(context, addedFood);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate data for charts
    final int metabolicImpact = FoodUtils.calculateMetabolicImpact(widget.food);
    final String impactLevel = FoodUtils.getImpactLevel(metabolicImpact);
    final Color impactColor = FoodUtils.getImpactColor(metabolicImpact);

    // Calculate nutrition values based on serving size
    // Calculate nutrition values based on serving size
    int calories = widget.food['calories'] as int;
    double protein =
        widget.food.containsKey('protein')
            ? (widget.food['protein'] as double)
            : 0.0;
    double carbs =
        widget.food.containsKey('carbs')
            ? (widget.food['carbs'] as double)
            : 0.0;
    double fat =
        widget.food.containsKey('fat') ? (widget.food['fat'] as double) : 0.0;
    double fiber =
        widget.food.containsKey('fiber')
            ? (widget.food['fiber'] as double)
            : 0.0;

    // Calculate adjusted nutrition values based on serving size
    int adjustedCalories = (calories * servingSize).round();
    double adjustedProtein = (protein * servingSize);
    double adjustedCarbs = (carbs * servingSize);
    double adjustedFat = (fat * servingSize);
    double adjustedFiber = (fiber * servingSize);

    // For display, round to one decimal place
    final proteinDisplay = adjustedProtein.toStringAsFixed(1);
    final carbsDisplay = adjustedCarbs.toStringAsFixed(1);
    final fatDisplay = adjustedFat.toStringAsFixed(1);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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

          // Header with food info
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F67FE).withOpacity(0.05),
                  Color(0xFF4D8EFF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Color(0xFF64748B)),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Food info card with compact layout
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Food icon
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          widget.food['icon'] ?? Icons.restaurant,
                          size: 28.sp,
                          color: Color(0xFF0F67FE),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Food details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.food['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14.sp,
                                  color: Color(0xFFFF9800),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '$adjustedCalories cal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  width: 4.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF64748B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  widget.food['weight'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Time selection - MOVED TO TOP
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );

                                if (time != null) {
                                  setState(() {
                                    selectedTime = time;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.r,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Color(0xFF0F67FE),
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      selectedTime.format(context),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Serving size - COMPACT VERSION
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serving Size',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.r,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Extract base weight from food weight string
                                      final baseWeight = double.parse(
                                        widget.food['weight']
                                            .toString()
                                            .replaceAll(RegExp(r'[^0-9.]'), ''),
                                      );
                                      if (servingSize > 0.5) {
                                        setState(() {
                                          // Decrease by 50g
                                          servingSize =
                                              ((baseWeight * servingSize) -
                                                  50) /
                                              baseWeight;
                                          servingSize = servingSize.clamp(
                                            0.5,
                                            5.0,
                                          );
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.remove_circle_outline),
                                    color: Color(0xFF0F67FE),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    iconSize: 20.sp,
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '${(double.parse(widget.food['weight'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) * servingSize).toStringAsFixed(0)}$servingUnit',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Extract base weight from food weight string
                                      final baseWeight = double.parse(
                                        widget.food['weight']
                                            .toString()
                                            .replaceAll(RegExp(r'[^0-9.]'), ''),
                                      );
                                      if (servingSize < 5.0) {
                                        setState(() {
                                          // Increase by 50g
                                          servingSize =
                                              ((baseWeight * servingSize) +
                                                  50) /
                                              baseWeight;
                                          servingSize = servingSize.clamp(
                                            0.5,
                                            5.0,
                                          );
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.add_circle_outline),
                                    color: Color(0xFF0F67FE),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    iconSize: 20.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Nutrition info - COMPACT CARD
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition Facts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NutrientCircle(
                              label: 'Protein',
                              value: adjustedProtein,
                              color: Color(0xFF4CAF50),
                              unit: 'g',
                            ),
                            NutrientCircle(
                              label: 'Carbs',
                              value: adjustedCarbs,
                              color: Color(0xFF2196F3),
                              unit: 'g',
                            ),
                            NutrientCircle(
                              label: 'Fat',
                              value: adjustedFat,
                              color: Color(0xFFFF9800),
                              unit: 'g',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Metabolic impact - SIMPLIFIED
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [impactColor.withOpacity(0.8), impactColor],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: impactColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FoodUtils.getImpactIcon(metabolicImpact),
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$impactLevel Impact',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'This food will ${metabolicImpact > 0 ? 'increase' : 'decrease'} your metabolic score by ${metabolicImpact.abs()}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.9),
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

                  SizedBox(height: 16.h),

                  // Blood Sugar Response - SIMPLIFIED
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blood Sugar Response',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Simplified blood sugar response visualization
                        SimplifiedBloodSugarResponse(
                          food: widget.food,
                          impactLevel: impactLevel,
                          impactColor: impactColor,
                        ),

                        SizedBox(height: 8.h),

                        // Simple explanation
                        Text(
                          FoodUtils.getSimplifiedSugarExplanation(
                            widget.food['name'],
                            impactLevel,
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add button
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // Add food to meal
                  // Navigator.pop(context);
                  _addFood();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.food['name']} added to ${widget.mealType}',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Color(0xFF0F67FE).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Add to ${widget.mealType}',
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
}
