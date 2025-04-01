import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomActivityHeader extends StatelessWidget {
  final String title;
  final String badgeText;
  final String score;
  final String subtitle;
  final String buttonImage;
  final VoidCallback onButtonTap;
  
  // Added customizable properties with defaults
  final Color backgroundColor;
  final String? backgroundImagePath;
  final Color buttonColor;
  final Color buttonShadowColor;
  final double buttonShadowSpread;
  final Color backButtonBorderColor;
  final double backButtonBorderWidth;
  final Color badgeBackgroundColor;
  final Color titleTextColor;
  final Color scoreTextColor;
  final Color subtitleTextColor;
  final Color badgeTextColor;
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final bool showBadge;


  const CustomActivityHeader({
    super.key,
    required this.title,
    required this.badgeText,
    required this.score,
    required this.subtitle,
    required this.buttonImage,
    required this.onButtonTap,
    
    // All customizable properties with defaults
    this.backgroundColor = const Color(0xFF242E49),
    this.backgroundImagePath,
    this.buttonColor = const Color(0xFF0F67FE),
    this.buttonShadowColor = const Color(0xFF0F67FE),
    this.buttonShadowSpread = 5.0,
    this.backButtonBorderColor = Colors.white,
    this.backButtonBorderWidth = 1.5,
    this.badgeBackgroundColor = Colors.white,
    this.titleTextColor = Colors.white,
    this.scoreTextColor = Colors.white,
    this.subtitleTextColor = Colors.white,
    this.badgeTextColor = Colors.white,
    this.bottomLeftRadius = 30.0,
    this.bottomRightRadius = 30.0,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none, // Allows button to extend outside the header
          children: [
            Container(
              height: constraints.maxHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                image: backgroundImagePath != null
                    ? DecorationImage(
                        image: AssetImage(backgroundImagePath!),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomLeftRadius.r),
                  bottomRight: Radius.circular(bottomRightRadius.r),
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
                              // Back Button with customizable properties
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
                                      color: backButtonBorderColor,
                                      width: backButtonBorderWidth.w,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.chevron_left,
                                    color: backButtonBorderColor,
                                    size: 20.sp,
                                  ),
                                ),
                              ),

                              SizedBox(width: 12.w),
                              // Dynamic Title with customizable color
                              Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  color: titleTextColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Dynamic Badge with customizable background
                          if (showBadge)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBackgroundColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.plusJakartaSans(
                                color: badgeTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Centered Score & Subtitle with customizable colors
                      Center(
                        child: Column(
                          children: [
                            // Dynamic Score
                            Text(
                              score,
                              style: GoogleFonts.plusJakartaSans(
                                color: scoreTextColor,
                                fontSize: 100.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            // Dynamic Subtitle
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: subtitleTextColor,
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

            // Positioned Floating Button with customizable colors
            Positioned(
              bottom: -30.h,
              left: (constraints.maxWidth / 2) - 40.w,
              child: GestureDetector(
                onTap: onButtonTap,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: buttonShadowColor.withOpacity(0.25),
                        blurRadius: 0,
                        spreadRadius: buttonShadowSpread,
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