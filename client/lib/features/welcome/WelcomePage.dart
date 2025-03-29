import 'package:client/features/auth/signin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/welcome/OnboardingPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB), // Light background color
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 20.h), // Responsive spacing
              // Logo Section
              Column(
                children: [
                  Image.asset(
                    'images/DiTwinLogo.png', // Replace with your logo asset
                    height: 80.h, // Responsive height
                    width: 80.w, // Responsive width
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Welcome to",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30.sp, // Responsive heading
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Di-Twin",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30.sp, // Responsive heading
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F67FE),
                    ),
                  ),
                ],
              ),

              // Illustration
              Image.asset(
                'images/WelcomePage.png', // Replace with your image asset
                width: 350.w, // Responsive width
                height: 350.h, // Responsive height
              ),

              // Get Started Button Section
              Column(
                children: [
                  SizedBox(
                    width: 230.w, // Responsive button width
                    height: 55.h, // Responsive button height
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F67FE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OnboardingPage(
                                  onComplete: () {},
                                  onSkip: () {},
                                ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp, // Responsive font size
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Sign In Link (Clickable)
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp, // Responsive paragraph size
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign In.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp, // Responsive paragraph size
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SignInScreen(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
