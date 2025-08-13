import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MedicationDurationSelector extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool beforeMeal;
  final Function({DateTime? startDate, DateTime? endDate}) onDatesChanged;
  final Function(bool) onMealPreferenceChanged;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color borderColor;
  final Color cardColor;

  const MedicationDurationSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.beforeMeal,
    required this.onDatesChanged,
    required this.onMealPreferenceChanged,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.borderColor,
    required this.cardColor,
  });

  @override
  State<MedicationDurationSelector> createState() => _MedicationDurationSelectorState();
}

class _MedicationDurationSelectorState extends State<MedicationDurationSelector> {
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = isStartDate ? widget.startDate : widget.endDate;
    final DateTime firstDate = isStartDate
        ? DateTime.now().subtract(const Duration(days: 30))
        : widget.startDate;
    final DateTime lastDate = isStartDate
        ? widget.endDate
        : DateTime.now().add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF242E49),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: widget.primaryColor,
              headerForegroundColor: Colors.white,
              dayBackgroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return widget.primaryColor;
                }
                return Colors.transparent;
              }),
              dayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Color(0xFF242E49);
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDate) {
        widget.onDatesChanged(startDate: picked);
        if (widget.endDate.isBefore(picked)) {
          widget.onDatesChanged(endDate: picked.add(const Duration(days: 30)));
        }
      } else {
        widget.onDatesChanged(endDate: picked);
      }
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How long will you take this medication?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: widget.textPrimaryColor,
          ),
        ),

        SizedBox(height: 24.h),

        // Date range selector
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: widget.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: widget.borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Start Date",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: widget.primaryColor,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat("MMM d, yyyy").format(widget.startDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: widget.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: widget.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: widget.borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "End Date",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: widget.primaryColor,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat("MMM d, yyyy").format(widget.endDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: widget.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 32.h),

        Text(
          'When should you take it?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: widget.textPrimaryColor,
          ),
        ),

        SizedBox(height: 16.h),

        // Before/After meal selector
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.onMealPreferenceChanged(true);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: widget.beforeMeal ? widget.primaryColor : widget.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: widget.beforeMeal
                        ? null
                        : Border.all(color: widget.borderColor, width: 1),
                    boxShadow: widget.beforeMeal
                        ? [
                            BoxShadow(
                              color: widget.primaryColor.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fastfood,
                        color: widget.beforeMeal ? Colors.white : widget.textSecondaryColor,
                        size: 32.r,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Before Meal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.beforeMeal ? Colors.white : widget.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.onMealPreferenceChanged(false);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: !widget.beforeMeal ? widget.primaryColor : widget.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: !widget.beforeMeal
                        ? null
                        : Border.all(color: widget.borderColor, width: 1),
                    boxShadow: !widget.beforeMeal
                        ? [
                            BoxShadow(
                              color: widget.primaryColor.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        color: !widget.beforeMeal ? Colors.white : widget.textSecondaryColor,
                        size: 32.r,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'After Meal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: !widget.beforeMeal ? Colors.white : widget.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Duration visualization
        SizedBox(height: 40.h),
        Center(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  "Treatment Duration",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: widget.primaryColor,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${widget.endDate.difference(widget.startDate).inDays} days",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
