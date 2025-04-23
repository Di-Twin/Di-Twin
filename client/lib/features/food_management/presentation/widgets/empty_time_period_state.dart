import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyTimePeriodState extends StatelessWidget {
  final Map<String, dynamic> timePeriod;

  const EmptyTimePeriodState({
    Key? key,
    required this.timePeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      child: Column(
        children: [
          // Empty state illustration
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: timePeriod['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              size: 40.sp,
              color: timePeriod['color'] as Color,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Empty state text
          Text(
            'No ${timePeriod['name']} foods yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Add your ${timePeriod['name'].toString().toLowerCase()} foods to track your nutrition',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
