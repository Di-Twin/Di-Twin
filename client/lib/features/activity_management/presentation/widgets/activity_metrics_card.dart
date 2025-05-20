import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/domain/entities/activity_detail.dart';

class ActivityMetricsCard extends StatelessWidget {
  final ActivityDetail activity;

  const ActivityMetricsCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
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
          Text(
            'Activity Metrics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow(
            icon: FontAwesomeIcons.personRunning,
            label: 'Distance',
            value: '${activity.distance.toStringAsFixed(2)} km',
            iconColor: const Color(0xFF0066FF),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow(
            icon: FontAwesomeIcons.shoePrints,
            label: 'Steps',
            value: '${activity.steps}',
            iconColor: const Color(0xFF7ED321),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow(
            icon: FontAwesomeIcons.fire,
            label: 'Calories Burned',
            value: '${activity.caloriesBurned.toInt()} kcal',
            iconColor: const Color(0xFFFF5A5F),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow(
            icon: FontAwesomeIcons.heartPulse,
            label: 'Average Heart Rate',
            value: '${activity.averageHeartRate.toInt()} bpm',
            iconColor: const Color(0xFF9747FF),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow(
            icon: FontAwesomeIcons.heartCircleExclamation,
            label: 'Max Heart Rate',
            value: '${activity.maxHeartRate.toInt()} bpm',
            iconColor: const Color(0xFFFF9A00),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 18.sp,
              color: iconColor,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1F36),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
          ),
        ),
      ],
    );
  }
}
