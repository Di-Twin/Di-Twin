import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaterStatsCards extends StatelessWidget {
  final int streak;
  final double weeklyAvg;
  final double completionRate;
  final int dailyGoal;

  const WaterStatsCards({
    super.key,
    required this.streak,
    required this.weeklyAvg,
    required this.completionRate,
    this.dailyGoal = 2000, // Default value if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row - Current Streak and Weekly Average
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Current Streak',
                value: '$streak',
                unit: 'days',
                icon: Icons.local_fire_department,
                color: const Color(0xFFEF4444),
                subtitle: streak > 0 ? 'Keep it up!' : 'Start today!',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: 'Weekly Average',
                value: '${weeklyAvg.toInt()}',
                unit: 'ml',
                icon: Icons.trending_up,
                color: const Color(0xFF10B981),
                subtitle: 'Per day',
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Second row - Today's Goal and Completion Rate
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Today\'s Goal',
                value: '$dailyGoal',
                unit: 'ml',
                icon: Icons.flag,
                color: const Color(0xFF3B82F6),
                subtitle: 'Target',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: 'Weekly Rate',
                value: '${(completionRate * 100).toInt()}',
                unit: '%',
                icon: Icons.check_circle,
                color: const Color(0xFF8B5CF6),
                subtitle: 'Completion',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              Text(
                unit,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),

          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}