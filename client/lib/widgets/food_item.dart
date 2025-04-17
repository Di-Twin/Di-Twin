import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodItem extends StatelessWidget {
  final Map<String, dynamic> food;

  const FoodItem({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.h),
      child: Row(
        children: [
          // Food icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: (food['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              food['icon'] as IconData,
              color: food['color'] as Color,
              size: 24.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // Food info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),

                SizedBox(height: 4.h),

                // Simplified row with just calories and time
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14.sp,
                      color: Color(0xFFFF9800),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${food['calories']} cal',
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
                      food['time'] as String,
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
    );
  }
}
