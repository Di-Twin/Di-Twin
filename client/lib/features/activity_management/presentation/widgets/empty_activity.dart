import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class EmptyActivityState extends StatelessWidget {
  final VoidCallback onAddActivity;

  const EmptyActivityState({
    super.key,
    required this.onAddActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a nice animation for empty state
            Lottie.asset(
              'assets/animations/empty_activity.json',
              width: 200.w,
              height: 200.h,
              fit: BoxFit.contain,
              repeat: true,
              // If you don't have a Lottie animation, use an Image instead
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'images/empty_activity.png',
                width: 200.w,
                height: 200.h,
                fit: BoxFit.contain,
                // If no image is available, show an icon
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.directions_run,
                  size: 100.sp,
                  color: const Color(0xFF0F67FE).withOpacity(0.3),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Activities Yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF242E49),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Start tracking your physical activities to improve your health score and monitor your progress.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            GestureDetector(
              onTap: onAddActivity,
              child: Container(
                width: 220.w,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F67FE), Color(0xFF4D8EFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F67FE).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Add Activity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
}