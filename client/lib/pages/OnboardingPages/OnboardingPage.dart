import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/components/ProgressBar.dart';

// todo: fix images, remove the skip from last step

class OnboardingPage extends StatefulWidget {
  final VoidCallback onSkip;
  final VoidCallback onComplete; // Changed from onNext to onComplete for final step

  const OnboardingPage({
    super.key,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentStep = 0;
  final int totalSteps = 5;

  // Array of onboarding content
  final List<Map<String, String>> onboardingContent = [
    {
      'heading': 'Personalize Your Health with Smart AI',
      'subheading': 'Achieve your wellness goals with our AI-powered platform to your unique needs',
      'image': 'images/onboardingDoc.png',
    },
    {
      'heading': 'Your Intelligent Fitness Companion.',
      'subheading': 'Track your calory & fitness nutrition with AI and get special recommendations.',
      'image': 'images/onboardingFitness.png',
    },
    {
      'heading': 'Emphatic AI Wellness Chatbot For All.',
      'subheading': 'Experience compassionate and personalized care with our AI chatbot.',
      'image': 'images/onboardingChatBot.png',
    },
    {
      'heading': 'Intuitive Nutrition & Med Tracker with AI',
      'subheading': 'Set goals and achieve them with daily encouragement',
      'image': 'images/onboardingNutrition.png',
    },
    {
      'heading': 'Helpful Resources &  Community.',
      'subheading': 'Join a community of 5,000+ users dedicating to healthy life with AI/ML.',
      'image': 'images/onboardingCommunity.png',
    },
  ];

  void _handleNext() {
    if (currentStep < totalSteps - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      widget.onComplete(); // Call onComplete when reaching the last step
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 0.5.sw,
                            child: ProgressBar(
                              totalSteps: totalSteps,
                              currentStep: currentStep + 1, // +1 since it starts from 0
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: widget.onSkip,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: const Color(0xFF2D3648),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.05.sh),
                      Text(
                        onboardingContent[currentStep]['heading']!,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2D3648),
                          fontSize: ScreenUtil().screenWidth < 600 ? 24.sp : 30.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 0.02.sh),
                      Text(
                        onboardingContent[currentStep]['subheading']!,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF677489),
                          fontSize: ScreenUtil().screenWidth < 600 ? 18.sp : 20.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.asset(
                        onboardingContent[currentStep]['image']!,
                        height: 0.57.sh,
                        width: 0.56.sh,
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.bottomCenter,
                      ),
                      Positioned(
                        right: 0.04.sw,
                        bottom: 0.02.sh,
                        child: GestureDetector(
                          onTap: _handleNext,
                          child: Container(
                            width: 0.18.sw,
                            height: 0.18.sw,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D3648),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Icon(
                                currentStep == totalSteps - 1 
                                    ? Icons.check 
                                    : Icons.arrow_forward,
                                color: Colors.white,
                                size: 32.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}