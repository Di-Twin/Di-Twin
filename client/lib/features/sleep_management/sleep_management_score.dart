import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/widgets/sleep_cycle_bar_graph.dart';
import 'package:client/data/API/sleep_data.dart';
import 'package:client/data/providers/sleep_provider.dart';

class SleepManagementScore extends ConsumerStatefulWidget {
  const SleepManagementScore({super.key});
  
  @override
  ConsumerState<SleepManagementScore> createState() =>
      _SleepManagementScoreState();
}

class _SleepManagementScoreState extends ConsumerState<SleepManagementScore> {
  @override
  Widget build(BuildContext context) {
    final sleepDataAsyncValue = ref.watch(sleepDataProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: sleepDataAsyncValue.when(
            data: (sleepData) => _buildContent(context, sleepData),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading sleep data: $error'),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, SleepApiResponse sleepData) {
    return LayoutBuilder(
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
              child: _buildSleepCycleSection(constraints, sleepData),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHeader(BoxConstraints constraints) {
    // Get the sleep efficiency score from the provider
    final efficiencyScore = ref.watch(sleepEfficiencyProvider);
    
    // Determine sleep quality badge and subtitle
    String badgeText = 'Insomniac';
    String subtitle = 'You are Insomniac';
    String score = '0';
    
    if (efficiencyScore > 0) {
      score = efficiencyScore.toString();
      
      if (efficiencyScore >= 90) {
        badgeText = 'Excellent';
        subtitle = 'You have excellent sleep quality';
      } else if (efficiencyScore >= 80) {
        badgeText = 'Good';
        subtitle = 'You have good sleep quality';
      } else if (efficiencyScore >= 70) {
        badgeText = 'Fair';
        subtitle = 'Your sleep quality is fair';
      } else if (efficiencyScore >= 60) {
        badgeText = 'Poor';
        subtitle = 'Your sleep quality needs improvement';
      } else {
        badgeText = 'Insomniac';
        subtitle = 'You are Insomniac';
      }
    }
    
    return SizedBox(
      height: constraints.maxHeight * 0.45, // Reduced to leave room for graph
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomActivityHeader(
            title: 'Sleep Score',
            backgroundColor: Color(0xFF242E49),
            badgeText: badgeText,
            score: score,
            subtitle: subtitle,
            titleTextColor: Colors.white,
            subtitleTextColor: Colors.white,
            badgeTextColor: Colors.white,
            badgeBackgroundColor: Color(0xFF242E49).withOpacity(0.5),
            scoreTextColor: Colors.white,
            buttonColor: Color(0xFF0F67FE),
            buttonShadowColor: Colors.black.withOpacity(0.2),
            backButtonBorderColor: Colors.white,
            backButtonBorderWidth: 1.0,
            headerHeight: constraints.maxHeight * 0.45,
            bottomLeftRadius: 16.0,
            bottomRightRadius: 16.0,
            buttonShadowSpread: 4.0,
            
            backgroundImagePath: './images/header_background.png',
            buttonImage: 'images/SignInAddIcon.png',
            onButtonTap: () {
              print("Button clicked!");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCycleSection(BoxConstraints constraints, SleepApiResponse sleepData) {
    // Extract stage percentages from the data
    final stagePercentages = sleepData.data.stagePercentages;
    
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
            child: SleepCycleBarGraph(
              awakeValue: stagePercentages['AWAKE'] ?? 0.0,
              remValue: stagePercentages['REM'] ?? 0.0,
              lightValue: stagePercentages['LIGHT'] ?? 0.0,
              deepValue: stagePercentages['DEEP'] ?? 0.0,
            ),
          ),
        ],
      ),
    );
  }
}