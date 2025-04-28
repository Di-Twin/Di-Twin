import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationReminderSelector extends StatelessWidget {
  final bool autoReminder;
  final Function(bool) onReminderChanged;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color borderColor;
  final Color cardColor;

  const MedicationReminderSelector({
    super.key,
    required this.autoReminder,
    required this.onReminderChanged,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.borderColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Would you like reminders?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),

        SizedBox(height: 16.h),

        // Reminder toggle
        GestureDetector(
          onTap: () {
            onReminderChanged(!autoReminder);
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: autoReminder ? primaryColor : borderColor,
                width: autoReminder ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: autoReminder ? primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications_active,
                      color: autoReminder ? primaryColor : Colors.grey.shade400,
                      size: 24.r,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medication Reminders",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        autoReminder
                            ? "You'll receive reminders when it's time to take your medication"
                            : "No reminders will be sent",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: autoReminder,
                  onChanged: (value) {
                    onReminderChanged(value);
                    HapticFeedback.selectionClick();
                  },
                  activeColor: Colors.white,
                  activeTrackColor: primaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
