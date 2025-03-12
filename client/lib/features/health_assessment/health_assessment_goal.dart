import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:client/widgets/CustomButton.dart';

class HealthAssessmentGoal extends StatefulWidget {
  const HealthAssessmentGoal({super.key});

  @override
  State<HealthAssessmentGoal> createState() => _HealthAssessmentGoalState();
}

class _HealthAssessmentGoalState extends State<HealthAssessmentGoal> {
  String? selectedGoal;

  final List<Map<String, dynamic>> healthGoals = [
    {
      'icon': Icons.favorite_outline,
      'text': 'I wanna get healthy',
      'value': 'get_healthy'
    },
    {
      'icon': Icons.monitor_weight_outlined,
      'text': 'I wanna lose weight',
      'value': 'lose_weight'
    },
    {
      'icon': Icons.smart_toy_outlined,
      'text': 'I wanna try AI Chatbot',
      'value': 'ai_chatbot'
    },
    {
      'icon': Icons.medication_outlined,
      'text': 'I wanna manage meds',
      'value': 'manage_meds'
    },
    {
      'icon': Icons.phone_android_outlined,
      'text': 'Just trying out the app',
      'value': 'trying_app'
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
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
                        child: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ProgressBar(
                      totalSteps: 5,
                      currentStep: 1,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              // Main title text
              Text(
                'What is your health goal\nfor the app?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2138),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 32.h),
              // Goal options
              Expanded(
                child: ListView.builder(
                  itemCount: healthGoals.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final goal = healthGoals[index];
                    final isSelected = selectedGoal == goal['value'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGoal = goal['value'];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFF0F67FE) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    goal['icon'],
                                    color: isSelected ? Colors.white : Colors.grey,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  goal['text'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.grey[300]!,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.blue, size: 18)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: ElevatedButton(
                  onPressed: () {
                    // dart(TODO:) should change the route to the next screen not age
                    Navigator.pushNamed(context, '/questions/age');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0F67FE),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 20.sp),
                    ],
                  ),
                ),
              ),
              // child: CustomButton(
              //       text: "Continue",
              //       iconPath: 'images/SignInAddIcon.png',
              //       onPressed: () {
              //         // should navigate to the next page
              //       }
              //     )

              // dart(TODO:) should use this custom compo after height and width can be customisable
            ],
          ),
        ),
      ),
    );
  }
}

// dart(TODO:) should add a haptic feed on click on an option, and should store the value somewhere
// Skip button should be disabled in this screen. grey color.

