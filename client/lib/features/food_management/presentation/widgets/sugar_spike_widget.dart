import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/painters/ideal_response_painter.dart';
import 'package:client/painters/actual_response_painter.dart';

class SugarSpikeWidget extends StatelessWidget {
  final Map<String, dynamic> food;
  final double sugarSpike;
  final String impactLevel;
  final Color impactColor;

  const SugarSpikeWidget({
    super.key,
    required this.food,
    required this.sugarSpike,
    required this.impactLevel,
    required this.impactColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Blood Sugar Impact',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                decoration: BoxDecoration(
                  color: impactColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 14.sp,
                      color: impactColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '+${sugarSpike.toStringAsFixed(1)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: impactColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Simplified blood sugar response graph
          SizedBox(
            height: 100.h,
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
                          painter: ActualResponsePainter(
                            _getCurveType(impactLevel), 
                            impactColor
                          ),
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
          ),
          
          SizedBox(height: 12.h),
          
          // Impact description
          Text(
            _getImpactDescription(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurveType(String impact) {
    if (impact == 'Minimal' || impact == 'Low') {
      return 'Low';
    } else if (impact == 'High' || impact == 'Very High') {
      return 'High';
    } else {
      return 'Moderate';
    }
  }

  String _getImpactDescription() {
    final foodName = food['name'];
    
    switch (impactLevel) {
      case 'Minimal':
        return '$foodName has a minimal impact on your blood sugar levels, making it an excellent choice for stable energy.';
      case 'Low':
        return '$foodName has a low impact on your blood sugar levels, providing steady energy without significant spikes.';
      case 'Moderate':
        return '$foodName causes a moderate rise in blood sugar. Consider pairing with protein or healthy fats to reduce the impact.';
      case 'High':
        return '$foodName may cause a significant blood sugar spike. Consider reducing portion size or pairing with fiber-rich foods.';
      case 'Very High':
        return '$foodName causes a very high blood sugar response. Consider alternatives or consume in small amounts with protein and fiber.';
      default:
        return 'Analyzing how $foodName affects your blood sugar levels...';
    }
  }
}
