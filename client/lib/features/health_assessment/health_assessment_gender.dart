import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HealthAssessmentGender extends StatefulWidget {
  const HealthAssessmentGender({Key? key}) : super(key: key);

  @override
  State<HealthAssessmentGender> createState() => _HealthAssessmentGenderState();
}

class _HealthAssessmentGenderState extends State<HealthAssessmentGender> {
  int _currentIndex = 1; // Start with male (index 1) as the center item
  String? selectedGender;
  
  final List<Map<String, dynamic>> _genders = [
    {
      'id': 'female',
      'title': 'I Am Female',
      'color': Colors.red.shade400,
      'icon': FontAwesomeIcons.venus,
      'image': 'images/health_assesment_gender_female.png',
      'shadowColor': Colors.red.shade400,
    },
    {
      'id': 'male',
      'title': 'I Am Male',
      'color': const Color(0xFF1A73E8),
      'icon': FontAwesomeIcons.mars,
      'image': 'images/health_assesment_gender_male.png',
      'shadowColor': const Color(0xFF1A73E8),
    },
    {
      'id': 'non_binary',
      'title': 'I Am Non-Binary',
      'color': Color(0xFF8A3FFC),
      'icon': FontAwesomeIcons.transgender,
      'image': 'images/health_assesment_gender_other.png',
      'shadowColor': Color(0xFF8A3FFC),
    },
  ];
  
  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.8,
  );

  @override
  void initState() {
    super.initState();
    selectedGender = _genders[_currentIndex]['id'];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
              
              // Title
              Text(
                'What is your Gender?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Subtitle
              Text(
                'Please select your gender for better\npersonalized health experience.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Gender selection cards with swipe functionality
              SizedBox(
                height: 320.h,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _genders.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      selectedGender = _genders[index]['id'];
                    });
                  },
                  itemBuilder: (context, index) {
                    final bool isCurrentPage = index == _currentIndex;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: isCurrentPage ? 0 : 40.h,
                      ),
                      height: isCurrentPage ? 320.h : 240.h,
                      decoration: BoxDecoration(
                        color: _genders[index]['color'],
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: isCurrentPage ? [
                          BoxShadow(
                            color: _genders[index]['shadowColor'].withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ] : null,
                      ),
                      child: Stack(
                        children: [
                          // Gender illustration
                          Positioned.fill(
                            child: Image.asset(
                              _genders[index]['image'],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback if image is not found
                                return Center(
                                  child: Icon(
                                    _genders[index]['icon'],
                                    size: 80.sp,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Gender text and icon
                          Positioned(
                            top: 20.h,
                            left: 20.w,
                            child: Row(
                              children: [
                                Icon(
                                  _genders[index]['icon'],
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  _genders[index]['title'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Checkmark if selected
                          if (selectedGender == _genders[index]['id'])
                            Positioned(
                              top: 20.h,
                              right: 20.w,
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    color: _genders[index]['color'],
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Gender selection indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_genders.length, (index) {
                  return Container(
                    width: index == _currentIndex ? 24.w : 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: index == _currentIndex 
                          ? _genders[_currentIndex]['color'] 
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
              
              // const Spacer(),

              SizedBox(height: 40.h),
              
              // Skip button
              GestureDetector(
                onTap: () {
                  // Handle skip action
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1ECFF),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Prefer to skip this',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A73E8),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward,
                        color: const Color(0xFF1A73E8),
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Continue button
              GestureDetector(
                onTap: () {
                  // Handle continue action with selected gender
                  // print('Selected gender: $selectedGender');
                  Navigator.pushNamed(context, '/questions/weight');
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20.sp,
                      ),
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