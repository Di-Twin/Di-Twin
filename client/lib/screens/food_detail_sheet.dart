import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/food_management_provider.dart';

class FoodDetailSheet extends StatefulWidget {
  final Map<String, dynamic> food;
  final String mealType;

  const FoodDetailSheet({
    super.key,
    required this.food,
    required this.mealType,
  });

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  final FoodManagementProvider _foodProvider = FoodManagementProvider();
  bool _isAdding = false;

  Future<void> _addFoodToMeal() async {
    setState(() {
      _isAdding = true;
    });

    try {
      // Create food data with current date and meal type
      final foodData = Map<String, dynamic>.from(widget.food);
      foodData['date'] = DateTime.now();
      foodData['mealType'] = widget.mealType;
      foodData['time'] = TimeOfDay.now().format(context);

      // Add food item
      final result = await _foodProvider.addFoodItem(foodData);

      if (result['success'] == true) { // Check for success key in the map
        // Close the sheet and return success
        Navigator.pop(context, true);
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add food: ${result['message']}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Food Details',
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

          // Food image
          Center(
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: widget.food['color'] ?? Colors.blue,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.restaurant,
                size: 60.sp,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Food name
          Center(
            child: Text(
              widget.food['name'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Calories
          Center(
            child: Text(
              '${widget.food['calories']} calories',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Nutrition info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Text(
              'Nutrition Information',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Nutrition cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Row(
              children: [
                _buildNutrientCard(
                  'Protein',
                  '${widget.food['protein']}g',
                  Color(0xFFEDF2FF),
                  Color(0xFF0F67FE),
                ),
                SizedBox(width: 12.w),
                _buildNutrientCard(
                  'Carbs',
                  '${widget.food['carbs']}g',
                  Color(0xFFFFF4DE),
                  Color(0xFFFF9500),
                ),
                SizedBox(width: 12.w),
                _buildNutrientCard(
                  'Fat',
                  '${widget.food['fat']}g',
                  Color(0xFFFFEEF6),
                  Color(0xFFFF2D55),
                ),
              ],
            ),
          ),

          Spacer(),

          // Add button
          Padding(
            padding: EdgeInsets.all(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isAdding ? null : _addFoodToMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: _isAdding
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
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

  // Build nutrient card
  Widget _buildNutrientCard(String title, String value, Color bgColor, Color textColor) {
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