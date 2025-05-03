import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/meal_item.dart';

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
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: foodItem.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      foodItem.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.restaurant,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.restaurant,
                    color: Color(0xFF94A3B8),
                  ),
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('hh:mm a').format(foodItem.time),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
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
