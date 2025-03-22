import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class HealthAssessmentAge extends ConsumerStatefulWidget {
  const HealthAssessmentAge({super.key});

  @override
  ConsumerState<HealthAssessmentAge> createState() =>
      _HealthAssessmentAgeState();
}

class _HealthAssessmentAgeState extends ConsumerState<HealthAssessmentAge> {
  late FixedExtentScrollController _scrollController;
  late int _selectedAge;
  final int _minAge = 16;
  final int _maxAge = 80;
  int _lastSelectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // ✅ Read saved age from provider, if available
    final savedAge = ref.read(onboardingProvider).age;
    _selectedAge = savedAge > 0 ? savedAge : 19; // Default to 19 if not set
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

  // Calculate text size based on device dimensions
  double _calculateTextSize(BuildContext context, int age) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final smallerDimension =
        screenHeight < screenWidth ? screenHeight : screenWidth;

    int distance = (age - _selectedAge).abs();
    if (distance == 0) return smallerDimension * 0.16; // Selected age (large)
    if (distance == 1) return smallerDimension * 0.09; // Adjacent ages (medium)
    if (distance == 2) return smallerDimension * 0.07; // Further ages (small)
    return 0;
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
    // Get device dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Calculate responsive spacing values
    final double verticalSpacing = screenHeight * 0.02;
    final double horizontalPadding = screenWidth * 0.06;

    // Calculate wheel selector dimensions
    final double wheelHeight = screenHeight * 0.5;
    final double selectorBoxSize = screenWidth * 0.35;
    final double itemExtent = screenHeight * 0.14;
    final double backButtonSize = screenWidth * 0.12;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),

              // Navigation header
              Row(
                children: [
                  Container(
                    width: backButtonSize,
                    height: backButtonSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(
                        backButtonSize * 0.25,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: backButtonSize * 0.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(child: ProgressBar(totalSteps: 7, currentStep: 5)),
                  SizedBox(width: screenWidth * 0.04),
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),

              // Question header
              Text(
                'What is your age?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF252A40),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Age wheel selector
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background selection box
                    Center(
                      child: Container(
                        height: selectorBoxSize,
                        width: selectorBoxSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(
                            selectorBoxSize * 0.12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: selectorBoxSize * 0.03,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Age wheel
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ListWheelScrollView.useDelegate(
                              controller: _scrollController,
                              itemExtent: itemExtent,
                              perspective: 0.001,
                              diameterRatio: 5.0,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedAge = index + _minAge;
                                  _triggerHapticFeedback();
                                });

                                // ✅ Update age in provider safely
                                Future.microtask(() {
                                  ref
                                      .read(onboardingProvider.notifier)
                                      .updateAge(_selectedAge);
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
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: _calculateTextSize(
                                          context,
                                          age,
                                        ),
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
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
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
                padding: EdgeInsets.only(bottom: verticalSpacing * 1.2),
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    print("✅ Age Saved: ${ref.read(onboardingProvider).age}");
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
