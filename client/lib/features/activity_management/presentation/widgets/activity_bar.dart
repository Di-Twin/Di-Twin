import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityBar extends StatelessWidget {
  final String minutes;
  final String label;
  final Color color;
  final IconData icon;
  final double maxMinutes;

  const ActivityBar({
    Key? key,
    required this.minutes,
    required this.label,
    required this.color,
    required this.icon,
    required this.maxMinutes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutesValue = double.parse(minutes);
    final maxBarHeight = 300.h;
    final coloredBarHeight = minutesValue <= 0 ? 0 : maxBarHeight * (minutesValue / maxMinutes);

    return Container(
      height: maxBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (minutesValue > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(height: coloredBarHeight.toDouble(), color: color),
              ),
            ),
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    minutes,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: (minutesValue > 0 && coloredBarHeight > 80.h)
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: (minutesValue > 0 && coloredBarHeight > 80.h)
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 16.sp, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
