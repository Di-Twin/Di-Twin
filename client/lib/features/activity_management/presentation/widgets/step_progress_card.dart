import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StepProgressCard extends StatelessWidget {
  final int currentSteps;
  final int goalSteps;

  const StepProgressCard({
    Key? key,
    required this.currentSteps,
    required this.goalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progressPercentage = currentSteps / goalSteps;

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blue curved background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
            ),
          ),

          // Dashed border container
          Center(
            child: Container(
              width: 200.w,
              height: 160.h,
              margin: EdgeInsets.only(top: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Walking icon
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      size: 24.sp,
                      color: const Color(0xFF0066FF),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Steps count
                  Text(
                    currentSteps.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),

                  // Steps label
                  Text(
                    'Steps',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      color: const Color(0xFF8F9BB3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Progress indicator
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF8F9BB3),
                  ),
                ),
                Text(
                  goalSteps.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF8F9BB3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
