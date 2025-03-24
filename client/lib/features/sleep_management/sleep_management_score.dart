import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/widgets/sleep_cycle_bar_graph.dart'; // Adjust import path as needed

class SleepManagementScore extends ConsumerStatefulWidget {
  const SleepManagementScore({super.key});
  
  @override
  ConsumerState<SleepManagementScore> createState() =>
      _SleepManagementScoreState();
}

class _SleepManagementScoreState extends ConsumerState<SleepManagementScore> {
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
              return Stack(
                children: [
                  // Full-height header
                  SizedBox(
                    height: constraints.maxHeight,
                    child: _buildHeader(constraints),
                  ),
                  // Bottom graph section
                  
                  Positioned(
                    bottom: 0, // Stick to bottom
                    left: 0,
                    right: 0,
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
}

  
  Widget _buildHeader(BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight , // Reduced to leave room for graph
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomActivityHeader(
            title: 'Sleep Score',
            badgeText: 'Insomniac',
            score: '24',
            subtitle: 'You are Insomniac',
            buttonImage: 'images/SignInAddIcon.png',
            onButtonTap: () {
              print("Button clicked!");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCycleSection(BoxConstraints constraints) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.w), // No bottom padding
    decoration: BoxDecoration(
      // Decoration properties commented out as requested
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sleep Overview',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: constraints.maxHeight * 0.45,
          child: const SleepCycleBarGraph(
            awakeValue: 16,
            remValue: 31,
            lightValue: 24,
            deepValue: 43,
          ),
        ),
      ],
    ),
  );
}  
