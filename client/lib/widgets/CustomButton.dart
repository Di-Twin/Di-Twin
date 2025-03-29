import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onPressed; // Function for navigation

  const CustomButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed, // Navigation function
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 40.h),
            backgroundColor: const Color(0xFF0F67FE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Takes only necessary space
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5.w), // Space between text and icon
              Image.asset(
                iconPath,
                height: 24.h,
                width: 24.w,
              ),
            ],
          ),
        ),
        SizedBox(height: 25.h),
      ],
    );
  }
}
