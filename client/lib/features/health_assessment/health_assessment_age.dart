import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/ProgressBar.dart';

class HealthAssessmentAge extends StatefulWidget {
  const HealthAssessmentAge({super.key});

  @override
  State<HealthAssessmentAge> createState() => _HealthAssessmentAgeState();
}

class _HealthAssessmentAgeState extends State<HealthAssessmentAge> {
  late FixedExtentScrollController _scrollController;
  late int _selectedAge;
  final int _minAge = 16;
  final int _maxAge = 80;
  int _lastSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedAge = 19; // Default initial age
    _lastSelectedIndex = _selectedAge - _minAge;
    _scrollController = FixedExtentScrollController(
      initialItem: _lastSelectedIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  double _getTextSize(int age) {
    int distance = (age - _selectedAge).abs();
    if (distance == 0) return 80.sp;
    if (distance == 1) return 45.sp;
    if (distance == 2) return 35.sp;
    return 0.sp;
  }

  double _getTextOpacity(int age) {
    int distance = (age - _selectedAge).abs();
    if (distance == 0) return 1.0;
    if (distance == 1) return 0.6;
    if (distance == 2) return 0.4;
    return 0.0;
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
                  Expanded(child: ProgressBar(totalSteps: 7, currentStep: 5)),
                  SizedBox(width: 16.w),
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Text(
                'What is your age?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF252A40),
                ),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center the blue box on the page
                    Center(
                      child: Container(
                        height: 130.h,
                        width: 130.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(16.r),
                          // Add box shadow
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          final currentIndex = _scrollController.selectedItem;
                          if (currentIndex != _lastSelectedIndex) {
                            _triggerHapticFeedback();
                            _lastSelectedIndex = currentIndex;
                          }
                        }
                        return false;
                      },
                      // Add padding to create gap between numbers and box
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: ListWheelScrollView.useDelegate(
                          controller: _scrollController,
                          itemExtent: 115.h,
                          perspective: 0.001,
                          diameterRatio: 5.0, // Increased to create more space
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedAge = index + _minAge;
                              _triggerHapticFeedback();
                            });
                          },
                          clipBehavior: Clip.antiAlias,
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _maxAge - _minAge + 1,
                            builder: (context, index) {
                              final age = index + _minAge;
                              final isSelected = age == _selectedAge;
                              final distance = (age - _selectedAge).abs();

                              if (distance > 2) {
                                return const SizedBox.shrink();
                              }

                              // Center the text
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  textAlign: TextAlign.center, // Ensure text is centered
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: _getTextSize(age),
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey.withOpacity(
                                              _getTextOpacity(age),
                                            ),
                                  ),
                                  child: Text(
                                    age.toString(),
                                    textAlign: TextAlign.center, // Ensure text is centered
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    Navigator.pushNamed(context, '/questions/medication');
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