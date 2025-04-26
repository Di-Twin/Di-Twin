import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationDosageSelector extends StatelessWidget {
  final double dosage;
  final Function(double) onDosageChanged;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color borderColor;
  final Color cardColor;

  const MedicationDosageSelector({
    Key? key,
    required this.dosage,
    required this.onDosageChanged,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.borderColor,
    required this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication Dosage',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),

        SizedBox(height: 16.h),

        // Dosage slider
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dosage Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${dosage.toInt()} unit${dosage.toInt() > 1 ? 's' : ''}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6.h,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 12.r,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 24.r,
                  ),
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorTextStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                child: Slider(
                  value: dosage,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: primaryColor,
                  inactiveColor: Colors.grey.shade200,
                  label: '${dosage.toInt()} unit${dosage.toInt() > 1 ? 's' : ''}',
                  onChanged: (value) {
                    onDosageChanged(value);
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final number = index + 1;
                  final isSelected = dosage.toInt() == number;

                  return SizedBox(
                    width: 24.w,
                    child: Text(
                      number.toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryColor : textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
