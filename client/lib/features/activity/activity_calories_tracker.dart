import 'package:client/widgets/ActivityHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCaloriesTracker extends StatelessWidget {
  const ActivityCaloriesTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: SingleChildScrollView(  // Added SingleChildScrollView to make the page scrollable
          child: Padding(
            padding: EdgeInsets.symmetric(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                // _buildHeader(),
                ActivityHeader(name: 'Calories',
  onTrack: 'On Track',
  onBackPressed: () {
    // Handle back button press
  }),
                SizedBox(height: 24.h),
                _buildCaloriesSummary(),
                SizedBox(height: 24.h),
                _buildCaloriesChart(),
                SizedBox(height: 8.h),
                _buildChartLegend(),
                SizedBox(height: 24.h),
                _buildActivitiesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w), // Add horizontal padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today, you just burned',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
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
                fontSize: 40.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(width: 8.w),
            Text(
              'kcal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
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
    padding: EdgeInsets.symmetric(horizontal: 16.w), // Add horizontal padding
    child: Container(
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
              padding: EdgeInsets.only(right: 5.w), // Add gap between sections
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E4F5),
                  borderRadius: BorderRadius.circular(8.r), // Add border radius
                ),
              ),
            ),
          ),
          // Taken section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w), // Add gap between sections
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A5F),
                  borderRadius: BorderRadius.circular(8.r), // Add border radius
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
                  borderRadius: BorderRadius.circular(8.r), // Add border radius
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
    padding: EdgeInsets.symmetric(horizontal: 16.w), // Add horizontal padding
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildActivitiesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.r),
          ),
        ),
        color: Colors.white,
        // margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Activities',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildActivityItem(
                    iconData: FontAwesomeIcons.personRunning,
                    title: 'Cardio Workout',
                    calories: 154,
                    color: const Color(0xFFE6DBFF),
                  ),
                  SizedBox(height: 12.h),
                  _buildActivityItem(
                    iconData: FontAwesomeIcons.personHiking,
                    title: 'Hiking',
                    calories: 854,
                    color: const Color(0xFFD9E4F5),
                  ),
                  SizedBox(height: 12.h),
                  _buildActivityItem(
                    iconData: FontAwesomeIcons.bicycle,
                    title: 'Biking',
                    calories: 224,
                    color: const Color(0xFFFFE4E4),
                  ),
                  SizedBox(height: 12.h),
                  _buildActivityItem(
                    iconData: FontAwesomeIcons.personRunning,
                    title: 'Cardio Workout',
                    calories: 154,
                    color: const Color(0xFFE6DBFF),
                  ),
                  SizedBox(height: 12.h),
                  _buildActivityItem(
                    iconData: FontAwesomeIcons.personHiking,
                    title: 'Hiking',
                    calories: 156,
                    color: const Color(0xFFD9E4F5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildActivityItem({
    required IconData iconData,
    required String title,
    required int calories,
    required Color color,
  }) {
    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: FaIcon(
                iconData,
                size: 20.sp,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$calories Calories Burned',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}