import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/domain/entities/activity_type.dart';

class DurationSelection extends StatelessWidget {
  final String? selectedActivityType;
  final int activityDuration;
  final Function() onBack;
  final Function(int) onDurationChanged;
  final Function() onAddActivity;
  final bool isAddingActivity;

  const DurationSelection({
    super.key,
    required this.selectedActivityType,
    required this.activityDuration,
    required this.onBack,
    required this.onDurationChanged,
    required this.onAddActivity,
    required this.isAddingActivity,
  });

  @override
  Widget build(BuildContext context) {
    final activityTypes = ActivityType.getActivityTypes();
    final selectedActivity = activityTypes.firstWhere(
      (element) => element.label == selectedActivityType,
      orElse: () => activityTypes[0],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: selectedActivity.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selectedActivity.icon,
                  color: selectedActivity.color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  selectedActivityType ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onBack,
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F67FE),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duration (minutes)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDurationButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (activityDuration > 5) {
                        onDurationChanged(activityDuration - 5);
                      }
                    },
                  ),
                  SizedBox(width: 24.w),
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      '$activityDuration',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 24.w),
                  _buildDurationButton(
                    icon: Icons.add,
                    onPressed: () {
                      onDurationChanged(activityDuration + 5);
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickDurationButton(15, activityDuration, onDurationChanged),
                  _buildQuickDurationButton(30, activityDuration, onDurationChanged),
                  _buildQuickDurationButton(45, activityDuration, onDurationChanged),
                  _buildQuickDurationButton(60, activityDuration, onDurationChanged),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0F67FE)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F67FE),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isAddingActivity ? null : onAddActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F67FE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: isAddingActivity 
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Add Activity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: const Color(0xFF1E293B), size: 24.sp),
      ),
    );
  }

  Widget _buildQuickDurationButton(int minutes, int currentDuration, Function(int) onDurationChanged) {
    final bool isSelected = currentDuration == minutes;

    return InkWell(
      onTap: () {
        onDurationChanged(minutes);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F67FE) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '$minutes min',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}
