import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' show max;

class ActivityToday extends StatefulWidget {
  const ActivityToday({super.key});

  @override
  _ActivityTodayState createState() => _ActivityTodayState();
}

class _ActivityTodayState extends State<ActivityToday> {
  double x = 165;
  double y = 275;

  // BoxConstraints get constraints => null;

  @override
  Widget build(BuildContext context) {
    final activityData = [
      {
        'hours': '2.5',
        'label': 'Jogging',
        'color': const Color(0xFF1E2A3D),
        'icon': FontAwesomeIcons.personRunning,
      },
      {
        'hours': '6.5',
        'label': 'Yoga',
        'color': const Color(0xFF0066FF),
        'icon': Icons.spa,
      },
      {
        'hours': '7.8',
        'label': 'Biking',
        'color': Colors.redAccent,
        'icon': FontAwesomeIcons.bicycle,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD6E4FF),
      body: SafeArea(
        child: GestureDetector(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(constraints),
                        // _buildActivityCount(),
                        
                        _buildMostHoursSection(activityData),
                        // SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                  // _buildDraggableAddButton(), // Now inside Stack
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BoxConstraints constrains) {
    return SizedBox(
      height: constrains.maxHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomActivityHeader(
            title: 'Activities',
            badgeText: 'Normal',
            score: '16',
            subtitle: 'Activities Today.',
            buttonImage: 'images/header_background.png',
            onButtonTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCount() {
    // dart(TODO:) need to add image as per figma
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '16',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 100.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Activities Today.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableAddButton() {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        child: Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  151,
                  149,
                  149,
                ).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'images/SignInAddIcon.png',
              width: 30.w,
              height: 30.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMostHoursSection(List<Map<String, dynamic>> activityData) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100], // Lighter background color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 24.h, bottom: 12.h),
            child: Text(
              'Most Hours',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 400.h, // Fixed height for the bar chart
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  activityData.length,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildActivityBar(
                        hours: activityData[index]['hours'] as String,
                        label: activityData[index]['label'] as String,
                        color: activityData[index]['color'] as Color,
                        icon: activityData[index]['icon'] as IconData,
                        index: index,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildActivityBar({
    required String hours,
    required String label,
    required Color color,
    required IconData icon,
    required int index,
  }) {
    double maxHours = 10.0;
    double heightFactor = double.parse(hours) / maxHours;
    double maxBarHeight = 400.h;
    double coloredBarHeight = max(
      80.h,
      maxBarHeight * heightFactor,
    ); // Add minimum height of 80.h

    // Adjust colors to match design
    if (index == 0) {
      color = const Color(0xFF1E293B); // Dark blue for Jogging
    } else if (index == 1) {
      color = Colors.blue; // Blue for Yoga
    } else if (index == 2) {
      color = Colors.redAccent; // Red for Biking
    }

    return Container(
      height: maxBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // Top icon
          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 16.sp, color: Colors.grey[600]),
              ),
            ),
          ),
          // Colored bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: coloredBarHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      hours,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
