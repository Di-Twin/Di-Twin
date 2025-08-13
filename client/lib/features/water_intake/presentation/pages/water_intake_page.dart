// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../../../widgets/CustomActivityHeaderWidget.dart';
// import '../../data/providers/water_intake_provider.dart';
// import '../../data/providers/water_intake_api_provider.dart';
// import '../widgets/goal_setting_sheet.dart';
// import '../widgets/water_stats_cards.dart';
// import '../widgets/water_progress_display.dart';
// import '../widgets/quick_add_buttons.dart';
// import '../widgets/monthly_insights_card.dart';

// class WaterIntakePage extends StatefulWidget {
//   const WaterIntakePage({super.key});

//   @override
//   State<WaterIntakePage> createState() => _WaterIntakePageState();
// }

// class _WaterIntakePageState extends State<WaterIntakePage> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final waterProvider = Provider.of<WaterIntakeProvider>(
//         context,
//         listen: false,
//       );
//       final apiProvider = Provider.of<WaterIntakeApiProvider>(
//         context,
//         listen: false,
//       );
//       await waterProvider.initialize();
//       await apiProvider.getCurrentWaterData(DateTime.now().toString());
//     } catch (e) {
//       print('Error initializing water intake data: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleRefresh() async {
//     final provider = Provider.of<WaterIntakeProvider>(context, listen: false);
//     await provider.refresh();
//     await _initializeData();
//   }

//   void _showGoalSettingSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const GoalSettingSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body:
//           _isLoading
//               ? const Center(
//                 child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
//               )
//               : Consumer<WaterIntakeProvider>(
//                 builder: (context, provider, child) {
//                   final todayIntake = provider.todayIntake;
//                   final progressPercentage = provider.progressPercentage;

//                   if (provider.error != null) {
//                     return _buildErrorState(provider.error!);
//                   }

//                   return RefreshIndicator(
//                     onRefresh: _handleRefresh,
//                     color: const Color(0xFF0EA5E9),
//                     child: SingleChildScrollView(
//                       controller: _scrollController,
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       child: Column(
//                         children: [
//                           // Custom header with progress display
//                           _buildCustomHeader(provider, progressPercentage),

//                           SizedBox(height: 50.h),

//                           // Quick Add Buttons
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 20.w),
//                             child: const QuickAddButtons(),
//                           ),

//                           SizedBox(height: 24.h),

//                           // Stats Cards
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 20.w),
//                             child: const WaterStatsCards(),
//                           ),

//                           SizedBox(height: 24.h),

//                           // Monthly Insights Card
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 20.w),
//                             child: const MonthlyInsightsCard(),
//                           ),

//                           SizedBox(height: 100.h), // Bottom padding
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64.sp,
//               color: const Color(0xFFEF4444),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               'Something went wrong',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF1E293B),
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               error,
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 14.sp,
//                 color: const Color(0xFF64748B),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 24.h),
//             ElevatedButton(
//               onPressed: _handleRefresh,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0EA5E9),
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//               ),
//               child: Text(
//                 'Try Again',
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomHeader(
//     WaterIntakeProvider provider,
//     double progressPercentage,
//   ) {
//     return SizedBox(
//       height: 370.h,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             height: 370.h,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               color: Color(0xFFE0F2FE),
//               image: DecorationImage(
//                 image: AssetImage('images/activity_header_background.png'),
//                 fit: BoxFit.cover,
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   // Navigation row
//                   Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 12.h,
//                     ),
//                     child: Row(
//                       children: [
//                         // Back button
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.of(context).pop();
//                           },
//                           child: Container(
//                             width: 48.w,
//                             height: 48.h,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color(0xFF1E293B),
//                               ),
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             child: Center(
//                               child: Icon(
//                                 Icons.chevron_left,
//                                 color: const Color(0xFF1E293B),
//                                 size: 28.sp,
//                               ),
//                             ),
//                           ),
//                         ),

//                         SizedBox(width: 16.w),

//                         // Title
//                         Text(
//                           'Water Intake',
//                           style: GoogleFonts.plusJakartaSans(
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF1E293B),
//                           ),
//                         ),

//                         const Spacer(),

//                         // Goal setting icon
//                         GestureDetector(
//                           onTap: _showGoalSettingSheet,
//                           child: Container(
//                             width: 48.w,
//                             height: 48.h,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color(0xFF1E293B),
//                               ),
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             child: Center(
//                               child: Icon(
//                                 Icons.settings,
//                                 color: const Color(0xFF1E293B),
//                                 size: 24.sp,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Expanded content area with progress display
//                   Expanded(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.w),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Badge
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10.w,
//                               vertical: 6.h,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(8.r),
//                             ),
//                             child: Text(
//                               _getBadgeText(progressPercentage),
//                               style: GoogleFonts.plusJakartaSans(
//                                 color: const Color(0xFF0EA5E9),
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: 20.h),

//                           // Water Progress Display
//                           Flexible(
//                             child: WaterProgressDisplay(
//                               dailyGoal: 2000, // Daily goal in ml
//                               date: '2025-08-13', // Optional, defaults to today
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Space for floating button
//                   SizedBox(height: 40.h),
//                 ],
//               ),
//             ),
//           ),

//           // Floating button
//           Positioned(
//             bottom: -30.h,
//             left: (MediaQuery.of(context).size.width / 2) - 40.w,
//             child: GestureDetector(
//               onTap: _showGoalSettingSheet,
//               child: Container(
//                 width: 80.w,
//                 height: 80.w,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E293B),
//                   borderRadius: BorderRadius.circular(15.r),
//                 ),
//                 alignment: Alignment.center,
//                 child: Image.asset(
//                   'images/SignInAddIcon.png',
//                   width: 20.w,
//                   height: 20.w,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getBadgeText(double progressPercentage) {
//     if (progressPercentage >= 100) {
//       return 'Goal Achieved! 🎉';
//     } else if (progressPercentage >= 75) {
//       return 'Almost There! 💪';
//     } else if (progressPercentage >= 50) {
//       return 'Good Progress 👍';
//     } else if (progressPercentage >= 25) {
//       return 'Getting Started 🌱';
//     } else {
//       return 'Let\'s Hydrate! 💧';
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

// 🔴 Still water intake should be checked


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/providers/water_intake_api_provider.dart';
import '../widgets/goal_setting_sheet.dart';
import '../widgets/water_stats_cards.dart';
import '../widgets/water_progress_display.dart';
import '../widgets/quick_add_buttons.dart';
import '../widgets/monthly_insights_card.dart';

class WaterIntakePage extends StatefulWidget {
  const WaterIntakePage({super.key});

  @override
  State<WaterIntakePage> createState() => _WaterIntakePageState();
}

class _WaterIntakePageState extends State<WaterIntakePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiProvider = Provider.of<WaterIntakeApiProvider>(
        context,
        listen: false,
      );
      _dashboardData = await apiProvider.getWaterDashboard();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      debugPrint('Error initializing water intake data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _initializeData();
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
              )
              : _error != null
              ? _buildErrorState(_error!)
              : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFF0EA5E9),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildCustomHeader(),
                      SizedBox(height: 50.h),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: QuickAddButtons(),
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: WaterStatsCards(
                          streak: _dashboardData?['streak'] ?? 0,
                          weeklyAvg: _dashboardData?['weekly_avg'] ?? 0,
                          completionRate:
                              _dashboardData?['weekly_completion_rate'] ?? 0,
                          dailyGoal: _dashboardData?['target_water_ml'] ?? 2000,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: MonthlyInsightsCard(),
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final progressPercentage =
        ((_dashboardData?['total_water_taken'] ?? 0) /
            (_dashboardData?['target_water_ml'] ?? 1)) *
        100;

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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                        Text(
                          'Water Intake',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          Flexible(
                            child: WaterProgressDisplay(
                              goal: _dashboardData?['target_water_ml'] ?? 2000,
                              consumed:
                                  _dashboardData?['total_water_taken'] ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
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
                child: Icon(Icons.add, color: Colors.white, size: 24.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeText(double progressPercentage) {
    if (progressPercentage >= 100) return 'Goal Achieved! 🎉';
    if (progressPercentage >= 75) return 'Almost There! 💪';
    if (progressPercentage >= 50) return 'Good Progress 👍';
    if (progressPercentage >= 25) return 'Getting Started 🌱';
    return 'Let\'s Hydrate! 💧';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
