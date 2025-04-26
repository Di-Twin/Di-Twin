import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_type_selection.dart';
import 'package:client/features/activity_management/presentation/widgets/duration_selection.dart';

class ManualEntryDrawer extends StatelessWidget {
  final int currentStep;
  final String? selectedActivityType;
  final int activityDuration;
  final Function(String) onActivitySelected;
  final Function() onStepBack;
  final Function(int) onDurationChanged;
  final Function() onAddActivity;
  final bool isAddingActivity;

  const ManualEntryDrawer({
    super.key,
    required this.currentStep,
    required this.selectedActivityType,
    required this.activityDuration,
    required this.onActivitySelected,
    required this.onStepBack,
    required this.onDurationChanged,
    required this.onAddActivity,
    required this.isAddingActivity,
  });

  @override
  Widget build(BuildContext context) {
    final double drawerHeight = MediaQuery.of(context).size.height * 0.50;

    return Container(
      height: drawerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(
            currentStep == 0 ? 'Select Activity Type' : 'Set Duration',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: currentStep >= 0 ? const Color(0xFF0F67FE) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: currentStep >= 1 ? const Color(0xFF0F67FE) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: currentStep == 0 
                ? ActivityTypeSelection(
                    selectedActivityType: selectedActivityType,
                    onActivitySelected: onActivitySelected,
                  )
                : DurationSelection(
                    selectedActivityType: selectedActivityType,
                    activityDuration: activityDuration,
                    onBack: onStepBack,
                    onDurationChanged: onDurationChanged,
                    onAddActivity: onAddActivity,
                    isAddingActivity: isAddingActivity,
                  ),
          ),
        ],
      ),
    );
  }
}
