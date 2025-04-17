import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NutrientCircle extends StatelessWidget {
  final String label;
  final dynamic value; // Can be int or double
  final Color color;
  final String unit;

  const NutrientCircle({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format value depending on type (int or double)
    String displayValue;
    if (value is int) {
      displayValue = value.toString();
    } else if (value is double) {
      displayValue = value.toStringAsFixed(1);
    } else {
      displayValue = '0';
    }

    return Column(
      children: [
        Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              displayValue,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '$label ($unit)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}