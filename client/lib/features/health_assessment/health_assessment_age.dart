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
                  Expanded(child: ProgressBar(totalSteps: 5, currentStep: 1)),
                  SizedBox(width: 16.w),
                  // Disabled Skip button (Greyed out)
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey, // Greyed out
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
                    Positioned(
                      child: Container(
                        height: 150.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(16.r),
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
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 90.h,
                        perspective: 0.001,
                        diameterRatio: 4.0,
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

                            return Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
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
                                child: Text(age.toString()),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/questions/weight');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F67FE),
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
            ],
          ),
        ),
      ),
    );
  }
}
