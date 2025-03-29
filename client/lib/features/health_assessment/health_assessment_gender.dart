import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class HealthAssessmentGender extends ConsumerStatefulWidget {
  const HealthAssessmentGender({super.key});

  @override
  ConsumerState<HealthAssessmentGender> createState() =>
      _HealthAssessmentGenderState();
}

class _HealthAssessmentGenderState
    extends ConsumerState<HealthAssessmentGender> {
  int _currentIndex = 1; // Start with male (index 1)
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
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.8);

    final savedGender = ref.read(onboardingProvider).gender;

    if (savedGender.isNotEmpty) {
      final savedIndex = _genders.indexWhere((g) => g['id'] == savedGender);
      if (savedIndex != -1) {
        _currentIndex = savedIndex;
        selectedGender = savedGender;
        _pageController.jumpToPage(savedIndex);
      }
    } else {
      selectedGender = _genders[_currentIndex]['id'];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    // Get screen dimensions for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if it's a small screen
    final isSmallScreen = screenHeight < 600;

    // Calculate responsive values while keeping original proportions
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final verticalSpacing = screenHeight * 0.02; // 2% of screen height

    // Keep original fixed height for PageView (370.h from original code)
    // but adjust slightly for very small screens
    final pageViewHeight = isSmallScreen ? 340.h : 370.h;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),
              // Back button and progress bar row
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
                  Expanded(child: ProgressBar(totalSteps: 7, currentStep: 2)),
                  SizedBox(width: screenWidth * 0.03),
                  GestureDetector(
                    onTap: () {
                      // Skip functionality
                      Navigator.pushNamed(context, '/questions/weight');
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
              SizedBox(height: verticalSpacing * 1.2),

              // Title with responsive font size
              Text(
                'What is your Gender?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 24.sp : 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.7),

              // Subtitle with responsive font size
              Text(
                'Please select your gender for better\npersonalized health experience.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 14.sp : 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              SizedBox(height: verticalSpacing * 1.5),

              // Gender selection cards - with original size preserved
              SizedBox(
                height: pageViewHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _genders.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      selectedGender = _genders[index]['id'];
                    });

                    // Save selected gender to Riverpod state
                    onboardingNotifier.updateGender(_genders[index]['id']);
                    print(
                      "✅ Selected Gender: ${ref.read(onboardingProvider).gender}",
                    );
                  },
                  itemBuilder: (context, index) {
                    final bool isCurrentPage = index == _currentIndex;

                    // Keep original sizing but adjust slightly for small screens
                    final verticalMargin =
                        isCurrentPage
                            ? 0.0
                            : isSmallScreen
                            ? 30.h
                            : 40.h;

                    // Keep original height ratios
                    final activeCardHeight = isSmallScreen ? 280.h : 320.h;
                    final inactiveCardHeight = isSmallScreen ? 220.h : 240.h;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: verticalMargin,
                      ),
                      height:
                          isCurrentPage ? activeCardHeight : inactiveCardHeight,
                      decoration: BoxDecoration(
                        color: _genders[index]['color'],
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow:
                            isCurrentPage
                                ? [
                                  BoxShadow(
                                    color: _genders[index]['shadowColor']
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                                : null,
                      ),
                      child: Stack(
                        children: [
                          // Gender title and icon
                          Positioned(
                            top: 20.h,
                            left: 20.w,
                            child: Row(
                              children: [
                                Icon(
                                  _genders[index]['icon'],
                                  color: Colors.white,
                                  size: isSmallScreen ? 16.sp : 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  _genders[index]['title'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: isSmallScreen ? 16.sp : 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Gender illustration - keep original height
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16.r),
                              ),
                              child: Image.asset(
                                _genders[index]['image'],
                                height: isSmallScreen ? 220.h : 250.h,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          // Selection checkmark
                          if (selectedGender == _genders[index]['id'])
                            Positioned(
                              top: 20.h,
                              right: 20.w,
                              child: Container(
                                width: isSmallScreen ? 20.w : 24.w,
                                height: isSmallScreen ? 20.w : 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    color: _genders[index]['color'],
                                    size: isSmallScreen ? 14.sp : 16.sp,
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

              // Gender selection indicators
              Padding(
                padding: EdgeInsets.only(top: verticalSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_genders.length, (index) {
                    return Container(
                      width: index == _currentIndex ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color:
                            index == _currentIndex
                                ? _genders[_currentIndex]['color']
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
              ),

              // Expanded spacer to push button to bottom on larger screens
              const Spacer(),

              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: verticalSpacing),
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    Navigator.pushNamed(context, '/questions/weight');
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
