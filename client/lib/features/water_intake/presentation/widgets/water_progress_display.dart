import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/water_intake.dart';

class WaterProgressDisplay extends StatelessWidget {
  final WaterIntake todayIntake;

  const WaterProgressDisplay({
    super.key,
    required this.todayIntake,
  });

  @override
  Widget build(BuildContext context) {
    final progress = todayIntake.progressPercentage / 100;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 280.w,
        maxHeight: 200.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              children: [
                // Background circle
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE2E8F0),
                    ),
                  ),
                ),

                // Progress circle
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0EA5E9),
                    ),
                  ),
                ),

                // Center content
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${todayIntake.totalAmount.toInt()}ml',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Today',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Progress bar
          Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Remaining amount or achievement
          if (todayIntake.totalAmount < todayIntake.goalAmount)
            Text(
              '${(todayIntake.goalAmount - todayIntake.totalAmount).toInt()}ml remaining',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Goal achieved! 🎉',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
