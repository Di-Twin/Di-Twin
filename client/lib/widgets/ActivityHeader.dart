import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityHeader extends StatelessWidget {
  final String? name;
  final String? onTrack;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding; 
  final VoidCallback? onBackPressed;

  const ActivityHeader({
    super.key,
    this.name,
    this.onTrack,
    this.backgroundColor, 
    this.padding, 
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(8.w), // Use the provided padding or default to 8.w
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_left,
                  size: 24.sp,
                ),
              ),
            ),
          ),
          if (name != null)
            Text(
              name!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          if (onTrack != null)
            Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFFBBD6FB), // Use the provided background color or default to 0xFFBBD6FB
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  onTrack!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}