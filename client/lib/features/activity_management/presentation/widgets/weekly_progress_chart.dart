import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyProgressChart extends StatelessWidget {
  final List<double> weeklyProgress;
  final int selectedWeek;
  final Function(int) onWeekChanged;

  const WeeklyProgressChart({
    super.key,
    required this.weeklyProgress,
    required this.selectedWeek,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) => _buildProgressBar(
                  progress: weeklyProgress[index],
                  isHighlighted: index == 1 || index == 4 || index == 6,
                  day: _getDayLabel(index),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (selectedWeek > 1) {
                      onWeekChanged(selectedWeek - 1);
                    }
                  },
                  child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Week $selectedWeek',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    // Assuming 4 weeks in a month for simplicity
                    if (selectedWeek < 4) {
                      onWeekChanged(selectedWeek + 1);
                    }
                  },
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required double progress,
    required String day,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background bar
            Container(
              width: 12.w,
              height: 160.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            // Progress bar
            Container(
              width: 12.w,
              height: 160.h * progress,
              decoration: BoxDecoration(
                color:
                    isHighlighted
                        ? const Color(0xFF0066FF)
                        : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color:
                isHighlighted
                    ? const Color(0xFF0066FF)
                    : const Color(0xFF8F9BB3),
          ),
        ),
      ],
    );
  }

  String _getDayLabel(int index) {
    switch (index) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
      default:
        return '';
    }
  }
}
