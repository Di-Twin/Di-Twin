import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationFrequencySelector extends StatelessWidget {
  final String frequency;
  final Function(String) onFrequencyChanged;
  final Color primaryColor;

  const MedicationFrequencySelector({
    Key? key,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.primaryColor,
  }) : super(key: key);

  String _getFrequencyDescription(String frequency) {
    switch (frequency) {
      case "1x Per Day":
        return "Take once every day";
      case "2x Per Day":
        return "Take twice every day";
      case "3x Per Day":
        return "Take three times every day";
      case "1x Per Week":
        return "Take once every week";
      case "2x Per Week":
        return "Take twice every week";
      case "3x Per Week":
        return "Take three times every week";
      case "As Needed":
        return "Take only when necessary";
      default:
        return "";
    }
  }

  void _showFrequencyDialog(BuildContext context) {
    final List<String> frequencyOptions = [
      "1x Per Day",
      "2x Per Day",
      "3x Per Day",
      "1x Per Week",
      "2x Per Week",
      "3x Per Week",
      "As Needed",
    ];

    final Color textPrimaryColor = Color(0xFF1E293B);
    final Color textSecondaryColor = Color(0xFF64748B);
    final Color borderColor = Color(0xFFE2E8F0);
    final Color cardColor = Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drawer handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Text(
                      'Select Frequency',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'How often do you need to take this medication?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Frequency options
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: frequencyOptions.length,
                  itemBuilder: (context, index) {
                    final option = frequencyOptions[index];
                    bool isSelected = frequency == option;
                    bool isDaily = option.contains("Day");

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.05) : cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () {
                            onFrequencyChanged(option);
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                // Icon container
                                Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isDaily ? Icons.today_rounded : Icons.date_range_rounded,
                                      color: isSelected ? Colors.white : textSecondaryColor,
                                      size: 24.r,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 16.w),

                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _getFrequencyDescription(option),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Checkmark for selected item
                                if (isSelected)
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16.r,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textPrimaryColor = Color(0xFF1E293B);
    final Color textSecondaryColor = Color(0xFF64748B);
    final Color borderColor = Color(0xFFE2E8F0);
    final Color cardColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often do you take this medication?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),

        SizedBox(height: 24.h),

        // Frequency selector
        GestureDetector(
          onTap: () => _showFrequencyDialog(context),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: primaryColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calendar_today,
                      color: primaryColor,
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
                        frequency,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getFrequencyDescription(frequency),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: textSecondaryColor,
                  size: 16.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
