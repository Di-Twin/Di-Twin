// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../data/providers/water_intake_provider.dart';
// import 'package:intl/intl.dart';

// class MonthlyInsightsCard extends StatelessWidget {
//   const MonthlyInsightsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WaterIntakeProvider>(
//       builder: (context, provider, child) {
//         return Container(
//           padding: EdgeInsets.all(20.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(12.r),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF0EA5E9).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Icon(
//                       Icons.insights,
//                       color: const Color(0xFF0EA5E9),
//                       size: 24.sp,
//                     ),
//                   ),
//                   SizedBox(width: 16.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Monthly Insights',
//                           style: GoogleFonts.plusJakartaSans(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w700,
//                             color: const Color(0xFF1E293B),
//                           ),
//                         ),
//                         Text(
//                           DateFormat('MMMM yyyy').format(DateTime.now()),
//                           style: GoogleFonts.plusJakartaSans(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xFF64748B),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Monthly average
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         '${provider.monthlyAverage.toInt()}ml',
//                         style: GoogleFonts.plusJakartaSans(
//                           fontSize: 24.sp,
//                           fontWeight: FontWeight.w800,
//                           color: const Color(0xFF0EA5E9),
//                         ),
//                       ),
//                       Text(
//                         'daily avg',
//                         style: GoogleFonts.plusJakartaSans(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xFF64748B),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),

//               SizedBox(height: 20.h),

//               // Insights Grid
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildInsightItem(
//                       icon: Icons.celebration,
//                       label: 'Best Day',
//                       value: _formatDate(provider.mostHydratedDay),
//                       color: const Color(0xFF10B981),
//                     ),
//                   ),
//                   SizedBox(width: 16.w),
//                   Expanded(
//                     child: _buildInsightItem(
//                       icon: Icons.trending_down,
//                       label: 'Missed Days',
//                       value: '${provider.missedDays}',
//                       color: provider.missedDays > 0
//                           ? const Color(0xFFEF4444)
//                           : const Color(0xFF10B981),
//                     ),
//                   ),
//                 ],
//               ),

//               if (provider.leastHydratedDay.isNotEmpty) ...[
//                 SizedBox(height: 16.h),
//                 _buildInsightItem(
//                   icon: Icons.water_drop_outlined,
//                   label: 'Needs Attention',
//                   value: _formatDate(provider.leastHydratedDay),
//                   color: const Color(0xFFF59E0B),
//                   fullWidth: true,
//                 ),
//               ],

//               SizedBox(height: 16.h),

//               // Progress indicator
//               _buildMonthlyProgress(provider),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildInsightItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//     bool fullWidth = false,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//         ),
//       ),
//       child: fullWidth
//           ? Row(
//         children: [
//           Icon(icon, color: color, size: 20.sp),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xFF64748B),
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w700,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       )
//           : Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 20.sp),
//           SizedBox(height: 8.h),
//           Text(
//             label,
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w500,
//               color: const Color(0xFF64748B),
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMonthlyProgress(WaterIntakeProvider provider) {
//     final daysInMonth = DateTime.now().day;
//     final completedDays = daysInMonth - provider.missedDays;
//     final completionRate = daysInMonth > 0 ? (completedDays / daysInMonth) : 0.0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Monthly Progress',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF1E293B),
//               ),
//             ),
//             Text(
//               '${(completionRate * 100).toInt()}%',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF0EA5E9),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 8.h),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4.r),
//           child: LinearProgressIndicator(
//             value: completionRate,
//             backgroundColor: const Color(0xFFE2E8F0),
//             valueColor: AlwaysStoppedAnimation<Color>(
//               completionRate >= 0.8
//                   ? const Color(0xFF10B981)
//                   : completionRate >= 0.6
//                   ? const Color(0xFF0EA5E9)
//                   : const Color(0xFFF59E0B),
//             ),
//             minHeight: 6.h,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           '$completedDays of $daysInMonth days completed',
//           style: GoogleFonts.plusJakartaSans(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xFF64748B),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(String dateString) {
//     if (dateString.isEmpty) return 'N/A';

//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('MMM d').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/water_intake_api_provider.dart';

class MonthlyInsightsCard extends StatefulWidget {
  const MonthlyInsightsCard({super.key});

  @override
  State<MonthlyInsightsCard> createState() => _MonthlyInsightsCardState();
}

class _MonthlyInsightsCardState extends State<MonthlyInsightsCard> {
  Map<String, dynamic>? _monthlyData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final apiProvider = Provider.of<WaterIntakeApiProvider>(context, listen: false);
      final data = await apiProvider.getMonthlyWaterData(now.year, now.month);
      setState(() {
        _monthlyData = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      debugPrint('Error fetching monthly data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_error != null) {
      return _buildErrorCard();
    }

    if (_monthlyData == null) {
      return const SizedBox.shrink();
    }

    final dailyIntake = _monthlyData!['daily_intake'] as List<dynamic>? ?? [];
    final monthlyAvg = _monthlyData!['monthly_avg'] as int? ?? 0;
    final mostHydratedDay = _monthlyData!['most_hydrated_day'] as String? ?? '';
    final leastHydratedDay = _monthlyData!['least_hydrated_day'] as String? ?? '';
    final missedDays = _monthlyData!['missed_days'] as int? ?? 0;

    return Container(
      padding: EdgeInsets.all(20.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.insights,
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
                      'Monthly Insights',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Monthly average
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${monthlyAvg}ml',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0EA5E9),
                    ),
                  ),
                  Text(
                    'daily avg',
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

          SizedBox(height: 20.h),

          // Insights Grid
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.celebration,
                  label: 'Best Day',
                  value: _formatDate(mostHydratedDay),
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.trending_down,
                  label: 'Missed Days',
                  value: '$missedDays',
                  color: missedDays > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
              ),
            ],
          ),

          if (leastHydratedDay.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildInsightItem(
              icon: Icons.water_drop_outlined,
              label: 'Needs Attention',
              value: _formatDate(leastHydratedDay),
              color: const Color(0xFFF59E0B),
              fullWidth: true,
            ),
          ],

          SizedBox(height: 16.h),

          // Progress indicator
          _buildMonthlyProgress(dailyIntake, missedDays),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
          SizedBox(height: 8.h),
          Text(
            'Failed to load data',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: _fetchMonthlyData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        value,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthlyProgress(List<dynamic> dailyIntake, int missedDays) {
    final now = DateTime.now();
    final daysInMonth = now.day;
    final completedDays = daysInMonth - missedDays;
    final completionRate = daysInMonth > 0 ? (completedDays / daysInMonth) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              '${(completionRate * 100).toInt()}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0EA5E9),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: completionRate,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              completionRate >= 0.8
                  ? const Color(0xFF10B981)
                  : completionRate >= 0.6
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFFF59E0B),
            ),
            minHeight: 6.h,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '$completedDays of $daysInMonth days completed',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateString;
    }
  }
}