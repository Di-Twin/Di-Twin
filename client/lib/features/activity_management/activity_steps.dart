import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivitySteps extends ConsumerWidget {
  const ActivitySteps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy data
    final int currentSteps = 1542;
    final int goalSteps = 2000;
    final String calories = "500kcal";
    final String distance = "51km";
    final String duration = "1h";
    final String currentMonth = "March";
    
    // Weekly progress data (Mon to Sun)
    final List<double> weeklyProgress = [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              
              // Header with back button and title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Steps',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Today's steps navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chevron_left, color: Colors.grey.shade600),
                      SizedBox(width: 8.w),
                      Text(
                        'Today, you have walked',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade600),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Steps card with progress
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    // Blue curved background
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r),
                          ),
                        ),
                      ),
                    ),
                    
                    // Dashed border container
                    Center(
                      child: Container(
                        width: 200.w,
                        height: 160.h,
                        margin: EdgeInsets.only(top: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Walking icon
                            Icon(
                              Icons.directions_walk,
                              size: 24.sp,
                              color: const Color(0xFF1E293B),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            // Steps count
                            Text(
                              currentSteps.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            
                            // Steps label
                            Text(
                              'Steps',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Progress indicator
                    Positioned(
                      bottom: 16.h,
                      left: 16.w,
                      right: 16.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            goalSteps.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Metrics row (calories, distance, time)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricCard(
                    icon: Icon(FontAwesomeIcons.bolt, color: Colors.white, size: 16.sp),
                    iconBgColor: const Color(0xFFF43F5E),
                    value: calories,
                  ),
                  _buildMetricCard(
                    icon: Icon(Icons.location_on, color: Colors.white, size: 16.sp),
                    iconBgColor: const Color(0xFF22D3EE),
                    value: distance,
                  ),
                  _buildMetricCard(
                    icon: Icon(Icons.access_time_filled, color: Colors.white, size: 16.sp),
                    iconBgColor: const Color(0xFF8B5CF6),
                    value: duration,
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Current progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(
                          currentMonth,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.keyboard_arrow_down, size: 16.sp),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Weekly progress chart
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Column(
                    children: [
                      // Bar chart
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            7,
                            (index) => _buildProgressBar(
                              progress: weeklyProgress[index],
                              isHighlighted: index == 1 || index == 4 || index == 6,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Day labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDayLabel('Mon'),
                          _buildDayLabel('Tue'),
                          _buildDayLabel('Wed'),
                          _buildDayLabel('Thu'),
                          _buildDayLabel('Fri'),
                          _buildDayLabel('Sat'),
                          _buildDayLabel('Sun'),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Week indicator
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Week One',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMetricCard({
    required Icon icon,
    required Color iconBgColor,
    required String value,
  }) {
    return Container(
      width: 100.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: icon,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar({required double progress, bool isHighlighted = false}) {
    return SizedBox(
      width: 30.w,
      height: 120.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 12.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          Container(
            width: 12.w,
            height: 120.h * progress,
            decoration: BoxDecoration(
              color: isHighlighted 
                  ? const Color(0xFF1E293B) 
                  : const Color(0xFF334155),
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayLabel(String day) {
    return SizedBox(
      width: 30.w,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}