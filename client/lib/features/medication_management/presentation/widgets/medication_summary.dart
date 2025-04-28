import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MedicationSummary extends StatelessWidget {
  final String selectedMedication;
  final double dosage;
  final String frequency;
  final List<String> selectedTimes;
  final DateTime startDate;
  final DateTime endDate;
  final bool beforeMeal;
  final bool autoReminder;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color borderColor;

  const MedicationSummary({
    super.key,
    required this.selectedMedication,
    required this.dosage,
    required this.frequency,
    required this.selectedTimes,
    required this.startDate,
    required this.endDate,
    required this.beforeMeal,
    required this.autoReminder,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.borderColor,
  });

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              "$label:",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.summarize,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Medication Summary",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSummaryItem(
            "Medication",
            selectedMedication.isEmpty ? "Not specified" : selectedMedication,
          ),
          _buildSummaryItem(
            "Dosage",
            "${dosage.toInt()} unit${dosage.toInt() > 1 ? 's' : ''}",
          ),
          _buildSummaryItem("Frequency", frequency),
          _buildSummaryItem("Time(s)", selectedTimes.join(", ")),
          _buildSummaryItem(
            "Duration",
            "${DateFormat("MMM d, yyyy").format(startDate)} to ${DateFormat("MMM d, yyyy").format(endDate)}",
          ),
          _buildSummaryItem(
            "Instructions",
            beforeMeal ? "Take before meals" : "Take after meals",
          ),
          _buildSummaryItem(
            "Reminders",
            autoReminder ? "Enabled" : "Disabled",
          ),
        ],
      ),
    );
  }
}
