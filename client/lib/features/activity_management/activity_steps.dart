import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ActivitySteps extends ConsumerStatefulWidget {
  const ActivitySteps({super.key});

  @override
  ConsumerState<ActivitySteps> createState() => _ActivityStepsState();
}

class _ActivityStepsState extends ConsumerState<ActivitySteps>
    with TickerProviderStateMixin {
  // Dummy data
  final int currentSteps = 1542;
  final int goalSteps = 2000;
  final String calories = "500kcal";
  final String distance = "51km";
  final String duration = "1h";

  // Date related variables
  DateTime _selectedMonth = DateTime.now();
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Weekly progress data (Mon to Sun)
  final List<double> weeklyProgress = [0.3, 0.8, 0.5, 0.2, 0.7, 0.4, 0.9];

  // Animation controllers
  late AnimationController _drawerAnimationController;
  late Animation<Offset> _drawerSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for drawer
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _showMonthSelectionDrawer() {
    _drawerAnimationController.forward();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return GestureDetector(
                onTap: () {},
                child: _buildMonthSelectionDrawer(setModalState),
              );
            },
          ),
    ).then((_) {
      _drawerAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      _buildTodayStepsSection(),
                      SizedBox(height: 24.h),
                      _buildStepsProgressCard(),
                      SizedBox(height: 24.h),
                      _buildMetricsRow(),
                      SizedBox(height: 32.h),
                      _buildProgressSection(),
                      SizedBox(height: 16.h),
                      _buildWeeklyChart(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
            'Steps',
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

  Widget _buildTodayStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today, you have walked',
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
              '$currentSteps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 64.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'steps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8F9BB3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepsProgressCard() {
    final double progressPercentage = currentSteps / goalSteps;

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                color: const Color(0xFF0066FF),
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
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      size: 24.sp,
                      color: const Color(0xFF0066FF),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Steps count
                  Text(
                    currentSteps.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),

                  // Steps label
                  Text(
                    'Steps',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      color: const Color(0xFF8F9BB3),
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF8F9BB3),
                  ),
                ),
                Text(
                  goalSteps.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF8F9BB3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.white,
          iconBgColor: const Color(0xFFFF5A5F),
          label: 'Calories',
          value: calories,
        ),
        _buildMetricCard(
          icon: Icons.place,
          iconColor: Colors.white,
          iconBgColor: const Color(0xFF0066FF),
          label: 'Distance',
          value: distance,
        ),
        _buildMetricCard(
          icon: Icons.timer,
          iconColor: Colors.white,
          iconBgColor: const Color(0xFF00B884),
          label: 'Duration',
          value: duration,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weekly Progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
          ),
        ),
        GestureDetector(
          onTap: _showMonthSelectionDrawer,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFDFE4EC)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: const Color(0xFF1A1F36),
                ),
                SizedBox(width: 8.w),
                Text(
                  _months[_selectedMonth.month - 1],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1F36),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: const Color(0xFF1A1F36),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Update the _buildWeeklyChart method to match the new graph design
  Widget _buildWeeklyChart() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) => _buildProgressBar(
                  progress: weeklyProgress[index],
                  isHighlighted: index == 1 || index == 4 || index == 6,
                  day: _getDayLabel(index),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  'Week One',
                  style: GoogleFonts.plusJakartaSans(
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
    );
  }

  // Replace the _buildProgressBar method with this updated version
  Widget _buildProgressBar({
    required double progress,
    required String day,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background bar
            Container(
              width: 12.w,
              height: 160.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            // Progress bar
            Container(
              width: 12.w,
              height: 160.h * progress,
              decoration: BoxDecoration(
                color:
                    isHighlighted
                        ? const Color(0xFF0066FF)
                        : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color:
                isHighlighted
                    ? const Color(0xFF0066FF)
                    : const Color(0xFF8F9BB3),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(16.r),
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
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: const Color(0xFF8F9BB3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelectionDrawer(StateSetter setModalState) {
    // Calculate the fixed height for the drawer (60% of screen height)
    final double drawerHeight = MediaQuery.of(context).size.height * 0.6;

    return SlideTransition(
      position: _drawerSlideAnimation,
      child: Container(
        height: drawerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Drawer handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Month',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Current selection display
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0066FF), const Color(0xFF4D8EFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _months[_selectedMonth.month - 1],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _selectedMonth.year.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Month grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final bool isSelected = _selectedMonth.month == index + 1;

                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          index + 1,
                        );
                      });

                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          index + 1,
                        );
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected
                                ? LinearGradient(
                                  colors: [
                                    const Color(0xFF0066FF),
                                    const Color(0xFF4D8EFF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0066FF,
                                    ).withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                        border:
                            !isSelected
                                ? Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          _months[index].substring(0, 3),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF1A1F36),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Apply button
            Padding(
              padding: EdgeInsets.all(20.r),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(int index) {
    switch (index) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
      default:
        return '';
    }
  }
}
