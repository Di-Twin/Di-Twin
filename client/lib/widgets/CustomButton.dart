import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double fontSize;
  final double iconSize;
  final double bottomMargin;

  const CustomButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.onPressed,
    this.width = double.infinity, // Default width
    this.height = 40, // Default height
    this.fontSize = 18, // Default font size
    this.iconSize = 24, // Default icon size
    this.bottomMargin = 25, // Default bottom margin
  });

  @override
  Widget build(BuildContext context) {
    // Use a Container instead of Column to avoid overflow
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin.h),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(width.w, height.h),
          backgroundColor: const Color(0xFF0F67FE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 5.w),
            Image.asset(
              iconPath,
              height: iconSize.h,
              width: iconSize.w,
            ),
          ],
        ),
      ),
    );
  }
}
