import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/painters/ideal_response_painter.dart';
import 'package:client/painters/actual_response_painter.dart';

class SimplifiedBloodSugarResponse extends StatelessWidget {
  final Map<String, dynamic> food;
  final String impactLevel;
  final Color impactColor;

  const SimplifiedBloodSugarResponse({
    Key? key,
    required this.food,
    required this.impactLevel,
    required this.impactColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the curve type based on impact level
    String curveType = 'Moderate';
    if (impactLevel == 'Excellent' || impactLevel == 'Good') {
      curveType = 'Low';
    } else if (impactLevel == 'High') {
      curveType = 'High';
    }

    return SizedBox(
      height: 120.h,
      child: Row(
        children: [
          // Y-axis label
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'High',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                'Blood\nSugar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Low',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          // Graph area
          Expanded(
            child: Stack(
              children: [
                // Background grid
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 1, color: Color(0xFFE2E8F0)),
                      Container(height: 1, color: Color(0xFFE2E8F0)),
                      Container(height: 1, color: Color(0xFFE2E8F0)),
                    ],
                  ),
                ),

                // Ideal response curve
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CustomPaint(painter: IdealResponsePainter()),
                ),

                // Actual response curve based on impact
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: ActualResponsePainter(curveType, impactColor),
                  ),
                ),

                // Time labels
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '1h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '2h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '3h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
