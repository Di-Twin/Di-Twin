import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationTimeSelector extends StatelessWidget {
  final int index;
  final String timeValue;
  final Function(String) onTimeSelected;

  const MedicationTimeSelector({
    super.key,
    required this.index,
    required this.timeValue,
    required this.onTimeSelected,
  });

  String _getTimeLabelForIndex(int index) {
    switch (index) {
      case 0:
        return "First Dose";
      case 1:
        return "Second Dose";
      case 2:
        return "Third Dose";
      default:
        return "Dose ${index + 1}";
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
        return Icons.wb_twilight_outlined;
      case 2:
        return Icons.nightlight_outlined;
      default:
        return Icons.access_time;
    }
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Color(0xFFF59E0B); // Morning - Amber
      case 1:
        return Color(0xFF3B82F6); // Afternoon - Blue
      case 2:
        return Color(0xFF6366F1); // Evening - Indigo
      default:
        return Color(0xFF14B8A6); // Default - Teal
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    // Parse current time
    final timeParts = timeValue.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final int minute = int.parse(hourMinute[1]);
    final String period = timeParts[1];
    
    // Convert to 24-hour format for TimeOfDay
    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final TimeOfDay initialTime = TimeOfDay(hour: hour, minute: minute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _getColorForIndex(index),
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _getColorForIndex(index);
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Color(0xFF242E49);
              }),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // Convert back to 12-hour format
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final newTime = '$hour:${picked.minute.toString().padLeft(2, '0')} $period';
      
      onTimeSelected(newTime);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeLabel = _getTimeLabelForIndex(index);
    final Color color = _getColorForIndex(index);
    final IconData icon = _getIconForIndex(index);
    final Color textPrimaryColor = Color(0xFF1E293B);
    final Color textSecondaryColor = Color(0xFF64748B);
    final Color borderColor = Color(0xFFE2E8F0);
    final Color cardColor = Colors.white;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _selectTime(context),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Time icon with color
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28.r,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Time details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        timeValue,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit icon
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: textSecondaryColor,
                    size: 20.r,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
