import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_country_code/ditwin_country_code.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/sleep_cycle_bar_graph.dart'; // Adjust import path as needed

class SleepManagementStats extends ConsumerStatefulWidget {
  const SleepManagementStats({super.key});
  
  @override
  ConsumerState<SleepManagementStats> createState() =>
      _SleepManagementStatsState();
}

class _SleepManagementStatsState extends ConsumerState<SleepManagementStats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Header widget defined in this file
                  _buildSleepStatsHeader(),
                  
                  // Sleep cycle section taking all remaining space
                  Expanded(
                    child: _buildSleepCycleSection(constraints),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStatsHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          // Back button row
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black87,
                padding: EdgeInsets.all(8.w),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Title row with score box opposite to text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleep Stats title and subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep Stats',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Discover insights on your sleep',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Score box - exactly 68x68
              Container(
                width: 68.w,
                height: 68.h,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '24',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCycleSection(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      height: double.infinity, // Take full height of the available space
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title for the graph section
          Text(
            'Sleep Overview',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Graph taking all remaining space
          Expanded(
            child: SleepCycleBarGraph(
              awakeValue: 100,
              remValue: 50,
              lightValue: 24,
              deepValue: 43,
            ),
          ),
        ],
      ),
    );
  }
}