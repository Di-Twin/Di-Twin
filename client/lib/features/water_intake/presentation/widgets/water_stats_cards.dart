import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../data/providers/water_intake_provider.dart';

class WaterStatsCards extends StatelessWidget {
  const WaterStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterIntakeProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // First row - Current Streak and Weekly Average
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Current Streak',
                    value: '${provider.currentStreak}',
                    unit: 'days',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    title: 'Weekly Average',
                    value: '${provider.weeklyAverage.toInt()}',
                    unit: 'ml',
                    icon: Icons.trending_up,
                    color: const Color(0xFF10B981),
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
                    value: '${provider.todayIntake.goalAmount.toInt()}',
                    unit: 'ml',
                    icon: Icons.flag,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    title: 'Completion Rate',
                    value: '${provider.weeklyCompletionRate.toInt()}',
                    unit: '%',
                    icon: Icons.check_circle,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
        ],
      ),
    );
  }
}
