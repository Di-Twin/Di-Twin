import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCaloriesTracker extends StatelessWidget {
  const ActivityCaloriesTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildCaloriesSummary(),
              SizedBox(height: 32.h),
              _buildCaloriesChart(),
              SizedBox(height: 16.h),
              _buildChartLegend(),
              SizedBox(height: 32.h),
              _buildActivitiesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDFE4EC), width: 1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left,
                size: 24.sp,
                color: const Color(0xFF1A1F36),
              ),
            ),
          ),

          // Title
          Text(
            'Calories',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),

          // Status pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD9E4F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'On Track',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today, you just burned',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '1,542',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 64.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'kcal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8F9BB3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesChart() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 48.h,
        child: Row(
          children: [
            // Target section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E4F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Taken section
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFFF5A5F)),
              ),
            ),
            // Burned section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildLegendItem(const Color(0xFFD9E4F5), 'Target'),
          SizedBox(width: 24.w),
          _buildLegendItem(const Color(0xFF0066FF), 'Burned'),
          SizedBox(width: 24.w),
          _buildLegendItem(const Color(0xFFFF5A5F), 'Taken'),
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

  Widget _buildActivitiesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 16.h),
          _buildActivityItem(
            iconData: FontAwesomeIcons.personRunning,
            title: 'Cardio Workout',
            calories: 154,
            color: const Color(0xFFE6DBFF),
            iconColor: const Color(0xFF9747FF),
          ),
          SizedBox(height: 12.h),
          _buildActivityItem(
            iconData: FontAwesomeIcons.personHiking,
            title: 'Hiking',
            calories: 854,
            color: const Color(0xFFD9E4F5),
            iconColor: const Color(0xFF0066FF),
          ),
          SizedBox(height: 12.h),
          _buildActivityItem(
            iconData: FontAwesomeIcons.bicycle,
            title: 'Biking',
            calories: 224,
            color: const Color(0xFFFFE4E4),
            iconColor: const Color(0xFFFF5A5F),
          ),
          SizedBox(height: 12.h),
          _buildActivityItem(
            iconData: FontAwesomeIcons.personRunning,
            title: 'Cardio Workout',
            calories: 154,
            color: const Color(0xFFE6DBFF),
            iconColor: const Color(0xFF9747FF),
          ),
          SizedBox(height: 12.h),
          _buildActivityItem(
            iconData: FontAwesomeIcons.personHiking,
            title: 'Hiking',
            calories: 854,
            color: const Color(0xFFD9E4F5),
            iconColor: const Color(0xFF0066FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData iconData,
    required String title,
    required int calories,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: FaIcon(iconData, size: 24.sp, color: iconColor),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$calories Calories Burned',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8F9BB3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
