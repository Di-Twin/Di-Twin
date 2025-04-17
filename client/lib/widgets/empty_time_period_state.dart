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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.r),
      child: Column(
        children: [
          // Illustration
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: (timePeriod['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              timePeriod['icon'] as IconData,
              size: 50.sp,
              color: (timePeriod['color'] as Color).withOpacity(0.7),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'No foods added yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            'Track your ${timePeriod['name'].toLowerCase()} meals to maintain a healthy diet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
