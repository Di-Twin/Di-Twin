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
  final bool showMenu;
  final double headerHeight; // New property to control header height

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
    this.showMenu = true,
    this.headerHeight =
        300.0, // Default height that should work for most screens
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes
        final double actualHeaderHeight = headerHeight.h;
        final double scoreFontSize = (actualHeaderHeight * 0.25).clamp(
          60.0,
          100.0,
        );
        final double subtitleFontSize = (actualHeaderHeight * 0.07).clamp(
          18.0,
          24.0,
        );

        return Stack(
          clipBehavior: Clip.none, // Allows button to extend outside the header
          children: [
            Container(
              height: actualHeaderHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                image:
                    backgroundImagePath != null
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
                child: Column(
                  children: [
                    // Updated navigation to match heart rate screen
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          // Back button with heart rate screen styling
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: backButtonBorderColor,
                                  width: backButtonBorderWidth,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.chevron_left,
                                  color: titleTextColor,
                                  size: 28.sp,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // Title with heart rate screen styling
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: titleTextColor,
                            ),
                          ),

                          const Spacer(),

                          // Menu icon (optional)
                          if (showMenu)
                            Icon(
                              Icons.more_horiz,
                              color: titleTextColor.withOpacity(0.7),
                              size: 28.sp,
                            ),
                        ],
                      ),
                    ),

                    // Badge (if shown)
                    if (showBadge)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                      ),

                    // Expanded to push content to center with flexible sizing
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Dynamic Score with responsive font size
                            Text(
                              score,
                              style: GoogleFonts.plusJakartaSans(
                                color: scoreTextColor,
                                fontSize: scoreFontSize,
                                fontWeight: FontWeight.w800,
                                height: 1.0, // Reduce line height to save space
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Dynamic Subtitle with responsive font size
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: subtitleTextColor,
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Space for the floating button
                    SizedBox(height: 40.h),
                  ],
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
