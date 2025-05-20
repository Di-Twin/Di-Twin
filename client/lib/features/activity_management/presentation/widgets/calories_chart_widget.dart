import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CaloriesChartWidget extends StatelessWidget {
  const CaloriesChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCaloriesChart(),
        SizedBox(height: 8.h),
        _buildChartLegend(),
      ],
    );
  }

  Widget _buildCaloriesChart() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Target section
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(right: 5.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E4F5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          // Taken section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A5F),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          // Burned section
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: 5.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(const Color(0xFFD9E4F5), 'Target'),
          _buildLegendItem(const Color(0xFFFF5A5F), 'Taken'),
          _buildLegendItem(const Color(0xFF0066FF), 'Burned'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8F9BB3),
          ),
        ),
      ],
    );
  }
}
