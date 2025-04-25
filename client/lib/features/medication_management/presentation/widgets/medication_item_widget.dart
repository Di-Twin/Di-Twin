import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_take_now_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MedicationItemWidget extends StatelessWidget {
  final Medication medication;
  final bool isCurrent;
  final String timeStr;
  final Function(String, bool) onStatusChanged;
  final Color primaryColor;
  final Color accentColor;
  final Color errorColor;

  const MedicationItemWidget({
    super.key,
    required this.medication,
    required this.isCurrent,
    required this.timeStr,
    required this.onStatusChanged,
    required this.primaryColor,
    required this.accentColor,
    required this.errorColor,
  });

  bool _isTimeSlotPassed(String timeStr) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeSlotDateTime = _parseTimeSlot(today, timeStr);
    
    return now.isAfter(timeSlotDateTime);
  }
  
  DateTime _parseTimeSlot(String dateStr, String timeStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    final timeParts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = medication.taken;
    final bool isTimeSlotPassed = _isTimeSlotPassed(timeStr);
    final bool isMissed = isTimeSlotPassed && !isCompleted;

    // Create custom medication icon based on the medication type
    Widget medicationIcon;
    if (medication.icon == Icons.medication) {
      medicationIcon = Icon(
        Icons.circle,
        color: isCompleted ? primaryColor : Colors.grey.shade400,
        size: 20.sp,
      );
    } else {
      medicationIcon = Icon(
        Icons.crop_square,
        color: isCompleted ? primaryColor : Colors.grey.shade400,
        size: 20.sp,
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border:
            isCurrent && !isCompleted
                ? Border.all(color: accentColor, width: 2.w)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            spreadRadius: 0,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(child: medicationIcon),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medication.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              decoration:
                                  isCompleted || isMissed
                                      ? TextDecoration.lineThrough
                                      : null,
                              decorationColor:
                                  isCompleted
                                      ? Colors.grey.shade400
                                      : errorColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            medication.dosage,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            medication.instruction,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status indicator icon
              GestureDetector(
                onTap: () {
                  if (!isCompleted) {
                    onStatusChanged(medication.id, true);
                  }
                },
                child: Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? accentColor
                            : (isMissed ? errorColor : Colors.white),
                    borderRadius: BorderRadius.circular(6.r),
                    border:
                        (!isCompleted && !isMissed)
                            ? Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5.w,
                            )
                            : null,
                    boxShadow: [
                      if (isCompleted || isMissed)
                        BoxShadow(
                          color: (isCompleted ? accentColor : errorColor)
                              .withOpacity(0.3),
                          blurRadius: 4.r,
                          spreadRadius: 0,
                          offset: Offset(0, 2.h),
                        ),
                    ],
                  ),
                  child:
                      isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                          : (isMissed
                              ? Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.sp,
                              )
                              : null),
                ),
              ),
            ],
          ),

          // Add "Take now" button for missed medications
          if (isMissed)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: GestureDetector(
                onTap: () {
                  // Show confirmation popup before marking as taken
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return MedicationTakeNowAlert(
                        medicationName: medication.name,
                        dosage: medication.dosage,
                        instructions: medication.instruction,
                        onTake: () {
                          // Mark medication as taken
                          onStatusChanged(medication.id, true);
                        },
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Take now',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
