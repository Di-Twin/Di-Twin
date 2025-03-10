import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSecondaryButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomSecondaryButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.width = double.infinity, // Default width to full width
    this.height = 40, // Default height to 40
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(width.w, height.h), // Custom width & height
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ), // White border
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5.w), // Space between text and icon
              Image.asset(
                iconPath,
                height: 24.h,
                width: 24.w,
                color: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: 25.h),
      ],
    );
  }
}
