import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/CustomActivityHeaderWidget.dart';
import '../../data/providers/water_intake_provider.dart';
import '../widgets/goal_setting_sheet.dart';
import '../widgets/water_stats_cards.dart';
import '../widgets/water_progress_display.dart';
import '../widgets/quick_add_buttons.dart';

class WaterIntakePage extends StatefulWidget {
  const WaterIntakePage({super.key});

  @override
  State<WaterIntakePage> createState() => _WaterIntakePageState();
}

class _WaterIntakePageState extends State<WaterIntakePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<WaterIntakeProvider>(context, listen: false);
      await provider.initialize();
    } catch (e) {
      print('Error initializing water intake data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<WaterIntakeProvider>(context, listen: false);
    await provider.refresh();
  }

  void _showGoalSettingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalSettingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<WaterIntakeProvider>(
        builder: (context, provider, child) {
          final todayIntake = provider.todayIntake;
          final progressPercentage = provider.progressPercentage;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF0EA5E9),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Custom header with progress display
                  _buildCustomHeader(provider, progressPercentage),

                  SizedBox(height: 24.h),

                  // Quick Add Buttons (replacing daily slots)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const QuickAddButtons(),
                  ),

                  SizedBox(height: 24.h),

                  // Stats Cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const WaterStatsCards(),
                  ),

                  SizedBox(height: 24.h),

                  // Monthly Progress Card
                  _buildMonthlyProgressCard(provider),

                  SizedBox(height: 100.h), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomHeader(WaterIntakeProvider provider, double progressPercentage) {
    return SizedBox(
      height: 370.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 370.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              image: DecorationImage(
                image: AssetImage('images/activity_header_background.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Navigation row
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.chevron_left,
                                color: const Color(0xFF1E293B),
                                size: 28.sp,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16.w),

                        // Title
                        Text(
                          'Water Intake',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),

                        const Spacer(),

                        // Goal setting icon
                        GestureDetector(
                          onTap: _showGoalSettingSheet,
                          child: Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.settings,
                                color: const Color(0xFF1E293B),
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expanded content area with progress display
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              _getBadgeText(progressPercentage),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF0EA5E9),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Water Progress Display
                          Flexible(
                            child: WaterProgressDisplay(
                              todayIntake: provider.todayIntake,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Space for floating button
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // Floating button
          Positioned(
            bottom: -30.h,
            left: (MediaQuery.of(context).size.width / 2) - 40.w,
            child: GestureDetector(
              onTap: _showGoalSettingSheet,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'images/SignInAddIcon.png',
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeText(double progressPercentage) {
    if (progressPercentage >= 100) {
      return 'Goal Achieved!';
    } else if (progressPercentage >= 75) {
      return 'Almost There';
    } else if (progressPercentage >= 50) {
      return 'Good Progress';
    } else if (progressPercentage >= 25) {
      return 'Getting Started';
    } else {
      return 'Let\'s Hydrate';
    }
  }

  Widget _buildMonthlyProgressCard(WaterIntakeProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: const Color(0xFF0EA5E9),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Hydration',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Daily Average',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${provider.monthlyAverage.toInt()}ml',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                    Text(
                      'avg',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              provider.missedDays > 0
                  ? '${provider.missedDays} missed days'
                  : 'Perfect month!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: provider.missedDays > 0
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
