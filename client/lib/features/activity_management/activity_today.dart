import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' show max, pow;

class ActivityToday extends StatefulWidget {
  const ActivityToday({super.key});

  @override
  _ActivityTodayState createState() => _ActivityTodayState();
}

class _ActivityTodayState extends State<ActivityToday> {
  double x = 165;
  double y = 275;

  final List<Map<String, dynamic>> allActivities = [
    {
      'minutes': '130',
      'label': 'Jogging',
      'color': const Color(0xFF1E293B),
      'icon': FontAwesomeIcons.personRunning,
    },
    {
      'minutes': '100',
      'label': 'Yoga',
      'color': const Color(0xFF0066FF),
      'icon': Icons.spa,
    },
    {
      'minutes': '200',
      'label': 'Biking',
      'color': Colors.redAccent,
      'icon': FontAwesomeIcons.bicycle,
    },
  ];

  List<Map<String, dynamic>> getTopActivities() {
    final sortedActivities = List<Map<String, dynamic>>.from(allActivities);
    
    sortedActivities.sort((a, b) => 
      double.parse(b['minutes'].toString()).compareTo(double.parse(a['minutes'].toString())));
    
    return sortedActivities.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topActivities = getTopActivities();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: _buildHeader(constraints),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildMostminutesSection(topActivities, constraints),
                  ),
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
            buttonImage: 'images/SignInAddIcon.png',
            onButtonTap: () {},
            backgroundColor: Color(0xFFD0E4FF),
            backgroundImagePath: 'images/activity_header_background.png',
            buttonColor: Color(0xFF242E49),
            buttonShadowColor: Color(0xFF242E49),
            titleTextColor: Color(0xFF242E49),
            scoreTextColor: Color(0xFF242E49),
            subtitleTextColor: Color(0xFF242E49),
            backButtonBorderColor: Color(0xFF242E49),
            badgeBackgroundColor: Color(0xFF0F67FE),
            badgeTextColor: Color(0xFF0F67FE),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCount() {
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

  Widget _buildMostminutesSection(List<Map<String, dynamic>> activityData, constraints) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.06;
    final double barWidth = screenSize.width * 0.24;
    
    double sectionHeightRatio;
    
    bool isTablet = screenSize.width > 600;
    bool isLandscape = screenSize.width > screenSize.height;
    
    if (isTablet) {
      sectionHeightRatio = isLandscape ? 0.38 : 0.45;
    } else {
      sectionHeightRatio = isLandscape ? 0.32 : 0.42;
    }
    
    if (screenSize.height < 600) {
      sectionHeightRatio *= 0.85;
    } else if (screenSize.height > 1200) {
      sectionHeightRatio *= 1.1;
    }

    double maxminutesValue = 0;
    for (var activity in activityData) {
      double minutes = double.parse(activity['minutes'].toString());
      if (minutes > maxminutesValue) {
        maxminutesValue = minutes;
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              'Most minutes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: constraints.maxHeight * sectionHeightRatio,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  activityData.length,
                  (index) => SizedBox(
                    width: barWidth,
                    child: _buildActivityBar(
                      minutes: activityData[index]['minutes'] as String,
                      label: activityData[index]['label'] as String,
                      color: activityData[index]['color'] as Color,
                      icon: activityData[index]['icon'] as IconData,
                      index: index,
                      maxminutes: maxminutesValue,
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
    required String minutes,
    required String label,
    required Color color,
    required IconData icon,
    required int index,
    required double maxminutes,
  }) {
    double minutesValue = double.parse(minutes);
    double maxBarHeight = 400.h;
    double coloredBarHeight;
    
    if (minutesValue <= 0) {
      coloredBarHeight = 0;
    } else {
      double ratio = minutesValue / maxminutes;
      coloredBarHeight = maxBarHeight * ratio;
    }
    
    return Container(
      height: maxBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (minutesValue > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  height: coloredBarHeight,
                  color: color,
                ),
              ),
            ),
          
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    minutes,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: (minutesValue > 0 && coloredBarHeight > 80.h) ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: (minutesValue > 0 && coloredBarHeight > 80.h) ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
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
        ],
      ),
    );
  }
}