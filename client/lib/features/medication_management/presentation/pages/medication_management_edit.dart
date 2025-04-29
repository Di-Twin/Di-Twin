import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/medication_step_indicator.dart';
import '../widgets/medication_frequency_selector.dart';
import '../widgets/medication_duration_selector.dart';
import '../widgets/medication_reminder_selector.dart';
import '../widgets/medication_dosage_selector.dart';

class MedicationManagementEdit extends StatefulWidget {
  const MedicationManagementEdit({super.key});

  @override
  State<MedicationManagementEdit> createState() => _MedicationManagementEditState();
}

class _MedicationManagementEditState extends State<MedicationManagementEdit> with TickerProviderStateMixin {
  // Medication data
  final String medicationName = "Amoxiciline";
  final String medicationInstructions = "Before Eating";
  DateTime startDate = DateTime(2025, 3, 1);
  DateTime endDate = DateTime(2025, 6, 1);
  String frequency = "3x Per Week";
  List<String> selectedTimes = ["9:00 AM"];
  bool beforeMeal = true;
  bool autoReminder = false;
  double dosage = 1.0;

  // Current step in the form
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;  

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Theme colors
  final Color _primaryColor = Color(0xFF0F67FE);
  final Color _secondaryColor = Color(0xFF242E49);
  final Color _backgroundColor = Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;
  final Color _textPrimaryColor = Color(0xFF1E293B);
  final Color _textSecondaryColor = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);

  // Encouraging messages
  final List<String> _encouragingMessages = [
    "Great start! Let's set up your medication schedule.",
    "You're doing great! Just a few more details.",
    "Almost there! Your health journey is important.",
    "Final step! You're taking control of your health.",
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Navigate to next step
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });

      // Reset and play animations
      _slideController.reset();
      _slideController.forward();
      _fadeController.reset();
      _fadeController.forward();

      // Add haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  // Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });

      // Reset and play animations
      _slideController.reset();
      _slideController.forward();
      _fadeController.reset();
      _fadeController.forward();

      // Add haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  // Get title for current step
  String _getTitleForStep(int step) {
    switch (step) {
      case 0: return "Medication Details";
      case 1: return "Frequency & Timing";
      case 2: return "Duration & Instructions";
      case 3: return "Reminders & Finish";
      default: return "Complete";
    }
  }

  // Build current step content
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildMedicationDetailsStep();
      case 1: return _buildFrequencyStep();
      case 2: return _buildDurationStep();
      case 3: return _buildReminderStep();
      default: return Container();
    }
  }

  // Step 1: Medication Details
  Widget _buildMedicationDetailsStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Medication image
            _buildMedicationImage(),

            SizedBox(height: 32.h),

            // Medication name
            Text(
              medicationName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: _textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            // Medication instructions
            _buildMedicationInstructions(),

            SizedBox(height: 40.h),

            // Medication dosage selector
            MedicationDosageSelector(
              dosage: dosage,
              onDosageChanged: (value) {
                setState(() {
                  dosage = value;
                });
              },
              primaryColor: _primaryColor,
              textPrimaryColor: _textPrimaryColor,
              textSecondaryColor: _textSecondaryColor,
              borderColor: _borderColor,
              cardColor: _cardColor,
            ),

            SizedBox(height: 24.h),

            // Fun fact about medication
            _buildFunFactContainer(),
          ],
        ),
      ),
    );
  }

  // Step 2: Frequency
  Widget _buildFrequencyStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frequency selector
            MedicationFrequencySelector(
              frequency: frequency,
              onFrequencyChanged: (value) {
                setState(() {
                  frequency = value;
                  
                  // Update times based on frequency
                  final int timesCount = int.parse(value.split('x')[0]);
                  List<String> newTimes = [];
                  
                  for (int i = 0; i < timesCount; i++) {
                    if (i < selectedTimes.length) {
                      newTimes.add(selectedTimes[i]);
                    } else {
                      if (i == 0) {
                        newTimes.add("9:00 AM");
                      } else if (i == 1) newTimes.add("2:00 PM");
                      else if (i == 2) newTimes.add("8:00 PM");
                      else newTimes.add("12:00 PM");
                    }
                  }
                  
                  selectedTimes = newTimes;
                });
              },
              primaryColor: _primaryColor,
            ),

            SizedBox(height: 32.h),

            // Time selector
            Text(
              'When do you take this medication?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),

            SizedBox(height: 16.h),

            // Time selector button
            GestureDetector(
              onTap: () {
                _showTimeSetterDialog();
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: _primaryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.access_time,
                          color: _primaryColor,
                          size: 24.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedTimes.length > 1
                                ? "${selectedTimes.length} times per day"
                                : selectedTimes.first,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: _textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            selectedTimes.length > 1
                                ? selectedTimes.join(", ")
                                : "Tap to set time",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: _textSecondaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _textSecondaryColor,
                      size: 16.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Duration
  Widget _buildDurationStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MedicationDurationSelector(
          startDate: startDate,
          endDate: endDate,
          beforeMeal: beforeMeal,
          onDatesChanged: ({DateTime? startDate, DateTime? endDate}) {
            setState(() {
              if (startDate != null) this.startDate = startDate;
              if (endDate != null) this.endDate = endDate;
            });
          },
          onMealPreferenceChanged: (value) {
            setState(() {
              beforeMeal = value;
            });
          },
          primaryColor: _primaryColor,
          textPrimaryColor: _textPrimaryColor,
          textSecondaryColor: _textSecondaryColor,
          borderColor: _borderColor,
          cardColor: _cardColor,
        ),
      ),
    );
  }

  // Step 4: Reminders
  Widget _buildReminderStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MedicationReminderSelector(
          autoReminder: autoReminder,
          onReminderChanged: (value) {
            setState(() {
              autoReminder = value;
            });
          },
          primaryColor: _primaryColor,
          textPrimaryColor: _textPrimaryColor,
          textSecondaryColor: _textSecondaryColor,
          borderColor: _borderColor,
          cardColor: _cardColor,
        ),
      ),
    );
  }

  // Helper method to build the medication image
  Widget _buildMedicationImage() {
    return Container(
      width: 180.w,
      height: 180.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset(
        './images/MedicationManagement.png',
        fit: BoxFit.cover,
      ),
    );
  }

  // Helper method to build the medication instructions
  Widget _buildMedicationInstructions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        medicationInstructions,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to build the fun fact container
  Widget _buildFunFactContainer() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Did you know?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "Taking your medication at the same time each day helps maintain consistent levels in your bloodstream and improves effectiveness.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: _textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and step title
            _buildHeader(),

            // Step indicator
            MedicationStepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              primaryColor: _primaryColor,
              borderColor: _borderColor,
            ),

            // Encouraging message
            _buildEncouragingMessage(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: _buildStepContent(),
              ),
            ),

            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // Helper method to build the header
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: _borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.chevron_left,
                color: _textPrimaryColor,
                size: 24.r,
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Step title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitleForStep(_currentStep),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _textPrimaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Step ${_currentStep + 1} of $_totalSteps",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the encouraging message
  Widget _buildEncouragingMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        _encouragingMessages[_currentStep],
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          fontStyle: FontStyle.italic,
          color: _primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to build the bottom navigation
  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button (except for first step)
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Back",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Spacer if back button is shown
          if (_currentStep > 0) SizedBox(width: 16.w),

          // Next/Finish button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _currentStep < _totalSteps - 1
                  ? _nextStep
                  : () {
                      // Handle form submission
                      Navigator.pop(context);
                    },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _currentStep < _totalSteps - 1
                        ? "Continue"
                        : "Save Medication",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
