import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:client/data/providers/onboarding_provider.dart';
import 'package:client/data/API/onboarding_data.dart';

class SymptomsSelectionPage extends ConsumerStatefulWidget {
  const SymptomsSelectionPage({super.key});

  @override
  ConsumerState<SymptomsSelectionPage> createState() =>
      _SymptomsSelectionPageState();
}

class _SymptomsSelectionPageState extends ConsumerState<SymptomsSelectionPage> {
  final List<String> _availableSymptoms = [
    'Headache',
    'Muscle Fatigue',
    'Asthma',
    'Fever',
    'Cough',
  ];

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSymptomTyped(String value) {
    if (value.isNotEmpty) {
      final onboardingNotifier = ref.read(onboardingProvider.notifier);
      onboardingNotifier.toggleMedicalCondition(value.trim());

      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    final List<String> selectedConditions =
        onboardingState.medical_conditions ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              // Use MediaQuery to set responsive padding
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),
                  _buildHeader(isSmallScreen),
                  SizedBox(height: 20.h),
                  _buildTitle(isSmallScreen),
                  SizedBox(height: 20.h),
                  _buildImage(),
                  SizedBox(height: 20.h),
                  _buildSymptomSelection(
                    selectedConditions,
                    onboardingNotifier,
                    isSmallScreen,
                  ),
                  SizedBox(height: 30.h),
                  CustomButton(
                    text: "Continue",
                    iconPath: 'images/SignInAddIcon.png',
                    onPressed: () async {
                      final onboardingState = ref.read(onboardingProvider);

                      // Debugging check
                      print(
                        "🩺 Medical Conditions in State: ${onboardingState.medical_conditions}",
                      );

                      // Call API function
                      await updateUserHealthProfile(ref);

                      // Navigate to next page
                      Navigator.pushNamed(context, '/loading');
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Row(
          children: [
            Container(
              width: isSmallScreen ? 40.w : 48.w,
              height: isSmallScreen ? 40.h : 48.h,
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
            SizedBox(width: 8.w),
            // Calculate progress bar width based on available space
            Expanded(child: ProgressBar(totalSteps: 7, currentStep: 7)),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: () {
                // Handle skip action
                Navigator.pushNamed(context, '/loading');
              },
              child: Text(
                'Skip',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 14.sp : 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Text(
      'Do you have any symptoms/allergy?',
      style: GoogleFonts.plusJakartaSans(
        // Responsive font size based on screen width
        fontSize: isSmallScreen ? 24.sp : 30.sp,
        fontWeight: FontWeight.w800,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate image width based on available width
        final imageWidth = constraints.maxWidth * 0.9;

        return Center(
          child: Container(
            width: imageWidth,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9, // Maintain aspect ratio
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/HealthAssessmentSymptoms.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSymptomSelection(
    List<String> selectedConditions,
    OnboardingNotifier onboardingNotifier,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: isSmallScreen ? 6 : 8,
              runSpacing: isSmallScreen ? 8 : 10,
              children:
                  _availableSymptoms
                      .map(
                        (symptom) => _buildSymptomChip(
                          symptom,
                          selectedConditions,
                          onboardingNotifier,
                          isSmallScreen,
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16.h),
            _buildTextField(isSmallScreen),
            SizedBox(height: 16.h),
            if (selectedConditions.isNotEmpty) ...[
              Text(
                'Selected Symptoms:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 12.sp : 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: isSmallScreen ? 30.h : 36.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      selectedConditions.reversed
                          .map(
                            (symptom) => _buildSelectedSymptomChip(
                              symptom,
                              onboardingNotifier,
                              isSmallScreen,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(bool isSmallScreen) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      onSubmitted: _onSymptomTyped,
      textInputAction: TextInputAction.done,
      style: GoogleFonts.plusJakartaSans(
        fontSize: isSmallScreen ? 14.sp : 16.sp,
        color: const Color(0xFF1B283A),
      ),
      decoration: InputDecoration(
        hintText: 'Type a symptom...',
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: isSmallScreen ? 14.sp : 16.sp,
          color: Colors.grey,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10.h : 15.h,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildSymptomChip(
    String symptom,
    List<String> selectedConditions,
    OnboardingNotifier onboardingNotifier,
    bool isSmallScreen,
  ) {
    final bool isSelected = selectedConditions.contains(symptom);

    return GestureDetector(
      onTap: () {
        onboardingNotifier.toggleMedicalCondition(symptom);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 4 : 6,
          vertical: isSmallScreen ? 1 : 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symptom,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 10.sp : 12.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: isSmallScreen ? 2 : 4),
              Icon(
                Icons.check,
                size: isSmallScreen ? 12 : 14,
                color: Colors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSymptomChip(
    String symptom,
    OnboardingNotifier onboardingNotifier,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6.w : 8.w,
        vertical: isSmallScreen ? 1.h : 2.h,
      ),
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symptom,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 10.sp : 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(width: isSmallScreen ? 2.w : 4.w),
          GestureDetector(
            onTap: () {
              onboardingNotifier.toggleMedicalCondition(symptom);
            },
            // Increase touch target for better usability
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 2.0 : 4.0),
              child: Icon(
                Icons.close,
                size: isSmallScreen ? 10.sp : 12.sp,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
