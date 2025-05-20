import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/data/models/activity_detail_model.dart';

class ActivityDetailHeader extends StatelessWidget {
  final ActivityDetailModel activity;

  const ActivityDetailHeader({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: activity.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: FaIcon(
                    activity.icon,
                    size: 28.sp,
                    color: activity.iconColor,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.capitalizedActivityType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1F36),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${activity.formattedDate} • ${activity.formattedStartTime}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: FontAwesomeIcons.fire,
                value: '${activity.caloriesBurned.toInt()}',
                label: 'Calories',
                iconColor: const Color(0xFFFF5A5F),
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.clock,
                value: activity.formattedDuration,
                label: 'Duration',
                iconColor: const Color(0xFF0066FF),
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.heartPulse,
                value: '${activity.averageHeartRate.toInt()}',
                label: 'Avg BPM',
                iconColor: const Color(0xFF9747FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 20.sp,
              color: iconColor,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1F36),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8F9BB3),
          ),
        ),
      ],
    );
  }
}
