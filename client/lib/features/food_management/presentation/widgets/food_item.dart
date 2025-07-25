import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/features/food_management/domain/entities/meal_item.dart';

class FoodItemWidget extends StatelessWidget {
  final MealItem foodItem;
  final String mealType;

  const FoodItemWidget({
    super.key,
    required this.foodItem,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Food image or placeholder
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
              image: foodItem.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(foodItem.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: foodItem.imageUrl == null
                ? Icon(
                    Icons.restaurant,
                    color: Colors.grey[400],
                    size: 24.sp,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.foodName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('h:mm a').format(foodItem.time),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Calories
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${foodItem.calories.toInt()} cal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F67FE),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
