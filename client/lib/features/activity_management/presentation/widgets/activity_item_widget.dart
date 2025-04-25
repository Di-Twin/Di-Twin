import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/domain/entities/activity_calories.dart';

class ActivityItemWidget extends StatelessWidget {
  final ActivityCalories activity;

  const ActivityItemWidget({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: activity.backgroundColor ?? const Color(0xFFE6DBFF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: FaIcon(
                activity.icon ?? FontAwesomeIcons.heartPulse, 
                size: 24.sp, 
                color: activity.iconColor ?? const Color(0xFF9747FF),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.capitalizedActivityType,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${activity.caloriesBurned.toInt()} Calories Burned',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8F9BB3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
