import 'package:client/features/medication_management/presentation/providers/medication_provider.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DaySelectorWidget extends StatelessWidget {
  final List<DateTime> dateRange;
  final int selectedDateIndex;
  final Function(int) onDateSelected;
  final ScrollController scrollController;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color errorColor;

  const DaySelectorWidget({
    super.key,
    required this.dateRange,
    required this.selectedDateIndex,
    required this.onDateSelected,
    required this.scrollController,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h, // Increased height to prevent overflow
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 4.h),
            child: Row(
              children: [
                Text(
                  'Select Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              itemCount: dateRange.length,
              itemBuilder: (context, index) => _buildDayItem(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(BuildContext context, int index) {
    final DateTime date = dateRange[index];
    final bool isSelected = index == selectedDateIndex;
    final bool isToday = _isSameDay(date, DateTime.now());

    // Get day name (Mon, Tue, etc.)
    final String dayName = DateFormat('EEE').format(date);

    // Get date number
    final String dateNumber = date.day.toString();

    // Get month name
    final String monthName = DateFormat('MMM').format(date);

    return GestureDetector(
      onTap: () {
        onDateSelected(index);
      },
      child: Container(
        width: 80.w, // Increased width
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border:
              !isSelected && isToday
                  ? Border.all(color: primaryColor, width: 2.w)
                  : null,
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4.r,
                spreadRadius: 0,
                offset: Offset(0, 2.h),
              ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, // Increased font size
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : secondaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                dateNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22.sp, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : secondaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                monthName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, // Increased font size
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4.h),
              // This would be replaced with a provider call in the actual implementation
              MedicationStatusIndicator(
                status: MedicationStatus.none,
                isSelected: isSelected,
                accentColor: accentColor,
                errorColor: errorColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day && 
           date1.month == date2.month && 
           date1.year == date2.year;
  }
}
