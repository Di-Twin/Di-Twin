// Header background color default : 0xFF242E49


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String badgeText;
  final String score;
  final String subtitle;
  final String buttonImage;
  final VoidCallback onButtonTap;
  final Color backgroundColor;

  const CustomHeader({
    super.key,
    required this.title,
    required this.badgeText,
    required this.score,
    required this.subtitle,
    required this.buttonImage,
    required this.onButtonTap,
    Color? backgroundColor, 
  })  : backgroundColor = backgroundColor ?? const Color(0xFF242E49);


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none, // Allows button to extend outside the header
          children: [
            Container(
              height: constraints.maxHeight * 0.45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                image: const DecorationImage(
                  image: AssetImage('images/header_background.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Back Button
                              GestureDetector(
  onTap: () {
    Navigator.of(context).pop(); // Navigate back to the previous screen
  },
  child: Container(
    padding: EdgeInsets.all(6.w),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(
        color: Colors.white,
        width: 1.5.w,
      ),
    ),
    child: Icon(
      Icons.chevron_left,
      color: Colors.white,
      size: 20.sp,
    ),
  ),
),

                              SizedBox(width: 12.w),
                              // Dynamic Title
                              Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Dynamic Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Centered Score & Subtitle
                      Center(
                        child: Column(
                          children: [
                            // Dynamic Score
                            Text(
                              score,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 100.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            // Dynamic Subtitle
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Positioned Floating Button
            Positioned(
              bottom: -30.h,
              left: (constraints.maxWidth / 2) - 40.w,
              child: GestureDetector(
                onTap: onButtonTap,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF0F67FE),
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0F67FE).withOpacity(0.25),
                        blurRadius: 0,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    buttonImage,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
