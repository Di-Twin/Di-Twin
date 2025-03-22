import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class HealthAssessmentGoal extends ConsumerStatefulWidget {
  const HealthAssessmentGoal({super.key});

  @override
  ConsumerState<HealthAssessmentGoal> createState() =>
      _HealthAssessmentGoalState();
}

class _HealthAssessmentGoalState extends ConsumerState<HealthAssessmentGoal> {
  String? selectedGoal;

  final List<Map<String, dynamic>> healthGoals = [
    {
      'icon': Icons.favorite_outline,
      'text': 'I wanna get healthy',
      'value': 'get_healthy',
    },
    {
      'icon': Icons.monitor_weight_outlined,
      'text': 'I wanna lose weight',
      'value': 'lose_weight',
    },
    {
      'icon': Icons.smart_toy_outlined,
      'text': 'I wanna try AI Chatbot',
      'value': 'ai_chatbot',
    },
    {
      'icon': Icons.medication_outlined,
      'text': 'I wanna manage meds',
      'value': 'manage_meds',
    },
    {
      'icon': Icons.phone_android_outlined,
      'text': 'Just trying out the app',
      'value': 'trying_app',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with "lose weight" selected
    selectedGoal = 'lose_weight';
  }

  @override
  Widget build(BuildContext context) {
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    // Get the screen size for better responsiveness
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if we're on a small screen
    final isSmallScreen = screenHeight < 600;

    // Calculate responsive padding based on screen size
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final verticalSpacing = screenHeight * 0.02; // 2% of screen height

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),
              // Back button and progress bar
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: isSmallScreen ? 16.sp : 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(child: ProgressBar(totalSteps: 7, currentStep: 1)),
                  SizedBox(width: screenWidth * 0.03),
                  GestureDetector(
                    onTap: () {
                      // Handle skip functionality
                      Navigator.pushNamed(context, '/questions/gender');
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 14.sp : 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing * 1.5),
              // Main title text - responsive font size
              Text(
                'What is your health goal\nfor the app?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 24.sp : 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2138),
                  height: 1.2,
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),
              // Goal options - Expanded with SingleChildScrollView for flexibility
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children:
                        healthGoals.map((goal) {
                          final isSelected = selectedGoal == goal['value'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedGoal = goal['value'];
                              });

                              onboardingNotifier.updateGoal(goal['text']);

                              print(
                                "Selected Goal: ${ref.read(onboardingProvider).goal}",
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: verticalSpacing),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding * 0.7,
                                vertical: isSmallScreen ? 16.h : 20.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFF0F67FE)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: isSmallScreen ? 32.w : 36.w,
                                          height: isSmallScreen ? 32.h : 36.h,
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Colors.white.withOpacity(
                                                      0.2,
                                                    )
                                                    : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Icon(
                                            goal['icon'],
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.grey,
                                            size: isSmallScreen ? 16.sp : 20.sp,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Flexible(
                                          child: Text(
                                            goal['text'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize:
                                                  isSmallScreen ? 14.sp : 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: isSmallScreen ? 20.w : 24.w,
                                    height: isSmallScreen ? 20.h : 24.h,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.grey[300]!,
                                      ),
                                    ),
                                    child:
                                        isSelected
                                            ? Icon(
                                              Icons.check,
                                              color: Colors.blue,
                                              size: isSmallScreen ? 14 : 18,
                                            )
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              // Continue button
              Padding(
                padding: EdgeInsets.only(
                  bottom: verticalSpacing,
                  top: verticalSpacing / 2,
                ),
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    // Go to the next step (Gender selection)
                    Navigator.pushNamed(context, '/questions/gender');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
