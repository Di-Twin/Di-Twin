import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class MedicationManagementEdit extends StatefulWidget {
  const MedicationManagementEdit({super.key});

  @override
  State<MedicationManagementEdit> createState() =>
      _MedicationManagementEditState();
}

class _MedicationManagementEditState extends State<MedicationManagementEdit>
    with TickerProviderStateMixin {
  final String medicationName = "Amoxiciline";
  final String medicationInstructions = "Before Eating";
  DateTime startDate = DateTime(2025, 3, 1);
  DateTime endDate = DateTime(2025, 6, 1);
  String frequency = "3x Per Week";
  List<String> selectedTimes = ["9:00 AM"];
  bool beforeMeal = true;
  bool autoReminder = false;

  // Current step in the form
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  late AnimationController _fadeController;  

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Theme colors - more refined and less saturated
  final Color _primaryColor = Color(0xFF0F67FE);
  final Color _secondaryColor = Color(0xFF242E49);
  final Color _accentColor = Color(0xFF10B981);
  final Color _backgroundColor = Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;
  final Color _textPrimaryColor = Color(0xFF1E293B);
  final Color _textSecondaryColor = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);

  final List<String> frequencyOptions = [
    "1x Per Day",
    "2x Per Day",
    "3x Per Day",
    "1x Per Week",
    "2x Per Week",
    "3x Per Week",
    "As Needed",
  ];

  // Encouraging messages
  final List<String> _encouragingMessages = [
    "Great start! Let's set up your medication schedule.",
    "You're doing great! Just a few more details.",
    "Almost there! Your health journey is important.",
    "Final step! You're taking control of your health.",
  ];

  // Get number of times from frequency
  int getTimesCount() {
    if (frequency.contains("As Needed")) return 0;
    return int.parse(frequency.split('x')[0]);
  }

  // Get period (Day/Week) from frequency
  String getPeriod() {
    if (frequency.contains("As Needed")) return "As Needed";
    return frequency.contains("Day") ? "Day" : "Week";
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers first
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Then initialize animations
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

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

    // Start animations after they're fully initialized
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _secondaryColor,
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: _primaryColor,
              headerForegroundColor: Colors.white,
              dayBackgroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _primaryColor;
                }
                return Colors.transparent;
              }),
              dayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return _secondaryColor;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      // Add haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    // Default to 9:00 AM if no time is set
    String currentTime =
        index < selectedTimes.length ? selectedTimes[index] : "9:00 AM";

    final TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(currentTime.split(':')[0]),
      minute: int.parse(currentTime.split(':')[1].split(' ')[0]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _primaryColor;
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return _secondaryColor;
              }),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        final newTime =
            '$hour:${picked.minute.toString().padLeft(2, '0')} $period';

        // Update or add the time at the specified index
        if (index < selectedTimes.length) {
          selectedTimes[index] = newTime;
        } else {
          selectedTimes.add(newTime);
        }
      });

      // Add haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  void _showFrequencyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drawer handle
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Text(
                          'Select Frequency',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'How often do you need to take this medication?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: _textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Frequency options
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: frequencyOptions.length,
                      itemBuilder: (context, index) {
                        bool isSelected = frequency == frequencyOptions[index];
                        bool isDaily = frequencyOptions[index].contains("Day");

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? _primaryColor.withOpacity(0.05)
                                    : _cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected ? _primaryColor : _borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: _primaryColor.withOpacity(0.1),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () {
                                // Update the frequency
                                final newFrequency = frequencyOptions[index];

                                // Update the selected times based on the new frequency
                                final int timesCount = int.parse(
                                  newFrequency.split('x')[0],
                                );
                                List<String> newTimes = [];

                                // Keep existing times if available, otherwise add defaults
                                for (int i = 0; i < timesCount; i++) {
                                  if (i < selectedTimes.length) {
                                    newTimes.add(selectedTimes[i]);
                                  } else {
                                    // Add default times based on the time of day
                                    if (i == 0) {
                                      newTimes.add("9:00 AM");
                                    } else if (i == 1)
                                      newTimes.add("2:00 PM");
                                    else if (i == 2)
                                      newTimes.add("8:00 PM");
                                    else
                                      newTimes.add("12:00 PM");
                                  }
                                }

                                // Update the state in the parent widget
                                this.setState(() {
                                  frequency = newFrequency;
                                  selectedTimes = newTimes;
                                });

                                // Add haptic feedback
                                HapticFeedback.mediumImpact();

                                // Close after a short delay to show the selection
                                Future.delayed(Duration(milliseconds: 300), () {
                                  Navigator.pop(context);

                                  // Show time picker if frequency is not "As Needed"
                                  if (!newFrequency.contains("As Needed")) {
                                    _showTimeSetterDialog();
                                  }
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    // Icon container
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? _primaryColor
                                                : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isDaily
                                              ? Icons.today_rounded
                                              : Icons.date_range_rounded,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : _textSecondaryColor,
                                          size: 24.r,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16.w),

                                    // Text content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            frequencyOptions[index],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: _textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            _getFrequencyDescription(
                                              frequencyOptions[index],
                                            ),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              color: _textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Checkmark for selected item
                                    if (isSelected)
                                      Container(
                                        width: 24.w,
                                        height: 24.w,
                                        decoration: BoxDecoration(
                                          color: _primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16.r,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom padding
                  SizedBox(height: 16.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTimeSetterDialog() {
    final int timesCount = getTimesCount();
    final String period = getPeriod();

    if (timesCount == 0) return; // Don't show for "As Needed"

    // Ensure we have enough times in the list
    while (selectedTimes.length < timesCount) {
      if (selectedTimes.isEmpty) {
        selectedTimes.add("9:00 AM");
      } else if (selectedTimes.length == 1) {
        selectedTimes.add("2:00 PM");
      } else if (selectedTimes.length == 2) {
        selectedTimes.add("8:00 PM");
      } else {
        selectedTimes.add("12:00 PM");
      }
    }

    // Trim extra times if needed
    if (selectedTimes.length > timesCount) {
      selectedTimes = selectedTimes.sublist(0, timesCount);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drawer handle
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Text(
                          'Set Medication Times',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'When do you need to take this medication?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: _textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Frequency badge
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '$timesCount time${timesCount > 1 ? 's' : ''} per $period',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Time slots
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: timesCount,
                      itemBuilder: (context, index) {
                        final String timeLabel = _getTimeLabelForIndex(index);
                        final String timeValue = selectedTimes[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: _borderColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () async {
                                await _selectTime(context, index);
                                setModalState(() {}); // Update the modal state
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    // Time icon with color
                                    Container(
                                      width: 56.w,
                                      height: 56.w,
                                      decoration: BoxDecoration(
                                        color: _getColorForIndex(index),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getIconForIndex(index),
                                          color: Colors.white,
                                          size: 28.r,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16.w),

                                    // Time details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            timeLabel,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: _textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            timeValue,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w700,
                                              color: _getColorForIndex(index),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Edit icon
                                    Container(
                                      width: 40.w,
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: _textSecondaryColor,
                                        size: 20.r,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Save button
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Container(
                      width: double.infinity,
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
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          HapticFeedback.mediumImpact();
                        },
                        child: Text(
                          'Save Times',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper methods for time setter
  String _getTimeLabelForIndex(int index) {
    switch (index) {
      case 0:
        return "First Dose";
      case 1:
        return "Second Dose";
      case 2:
        return "Third Dose";
      default:
        return "Dose ${index + 1}";
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
        return Icons.wb_twilight_outlined;
      case 2:
        return Icons.nightlight_outlined;
      default:
        return Icons.access_time;
    }
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Color(0xFFF59E0B); // Morning - Amber
      case 1:
        return Color(0xFF3B82F6); // Afternoon - Blue
      case 2:
        return Color(0xFF6366F1); // Evening - Indigo
      default:
        return Color(0xFF14B8A6); // Default - Teal
    }
  }

  // Add this helper method to provide descriptions for each frequency option
  String _getFrequencyDescription(String frequency) {
    switch (frequency) {
      case "1x Per Day":
        return "Take once every day";
      case "2x Per Day":
        return "Take twice every day";
      case "3x Per Day":
        return "Take three times every day";
      case "1x Per Week":
        return "Take once every week";
      case "2x Per Week":
        return "Take twice every week";
      case "3x Per Week":
        return "Take three times every week";
      case "As Needed":
        return "Take only when necessary";
      default:
        return "";
    }
  }

  // Get icon for current step
  IconData _getIconForStep(int step) {
    switch (step) {
      case 0:
        return Icons.medication;
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.date_range;
      case 3:
        return Icons.notifications;
      default:
        return Icons.check_circle;
    }
  }

  // Get title for current step
  String _getTitleForStep(int step) {
    switch (step) {
      case 0:
        return "Medication Details";
      case 1:
        return "Frequency & Timing";
      case 2:
        return "Duration & Instructions";
      case 3:
        return "Reminders & Finish";
      default:
        return "Complete";
    }
  }

  // Build step indicator
  Widget _buildStepIndicator() {
    return SizedBox(
      height: 80.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;

          return Row(
            children: [
              // Step circle
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: isCurrent ? 50.w : 40.w,
                height: isCurrent ? 50.w : 40.w,
                decoration: BoxDecoration(
                  color: isActive ? _primaryColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? _primaryColor : _borderColor,
                    width: 1.5.w,
                  ),
                  boxShadow:
                      isCurrent
                          ? [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child:
                    isCurrent
                        ? AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Icon(
                                _getIconForStep(index),
                                color: Colors.white,
                                size: 24.r,
                              ),
                            );
                          },
                        )
                        : Icon(
                          isActive ? Icons.check : _getIconForStep(index),
                          color: isActive ? Colors.white : Colors.grey.shade400,
                          size: 20.r,
                        ),
              ),
              // Connector line (except for last item)
              if (index < _totalSteps - 1)
                Container(
                  width: 30.w,
                  height: 2.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: index < _currentStep ? _primaryColor : _borderColor,
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // Build current step content
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildMedicationDetailsStep();
      case 1:
        return _buildFrequencyStep();
      case 2:
        return _buildDurationStep();
      case 3:
        return _buildReminderStep();
      default:
        return Container();
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
            // Medication image with subtle animation
            Container(
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
            ),

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
            Container(
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
            ),

            SizedBox(height: 40.h),

            // Fun fact about medication
            Container(
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
            ),
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
            Text(
              'How often do you take this medication?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),

            SizedBox(height: 24.h),

            // Frequency selector
            GestureDetector(
              onTap: _showFrequencyDialog,
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
                          Icons.calendar_today,
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
                            frequency,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: _textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getFrequencyDescription(frequency),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: _textSecondaryColor,
                            ),
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

            SizedBox(height: 32.h),

            Text(
              'When do you take this medication?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),

            SizedBox(height: 16.h),

            // Time selector
            GestureDetector(
              onTap: () {
                if (frequency.contains("As Needed")) {
                  _selectTime(context, 0);
                } else {
                  _showTimeSetterDialog();
                }
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

            // Illustration
            SizedBox(height: 40.h),
            Center(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: _primaryColor,
                  size: 60.r,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How long will you take this medication?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),

            SizedBox(height: 24.h),

            // Date range selector
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: _borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Start Date",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: _textSecondaryColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _primaryColor,
                                size: 18.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                DateFormat("MMM d, yyyy").format(startDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: _borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "End Date",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: _textSecondaryColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _primaryColor,
                                size: 18.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                DateFormat("MMM d, yyyy").format(endDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            Text(
              'When should you take it?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),

            SizedBox(height: 16.h),

            // Before/After meal selector
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        beforeMeal = true;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: beforeMeal ? _primaryColor : _cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border:
                            beforeMeal
                                ? null
                                : Border.all(color: _borderColor, width: 1),
                        boxShadow:
                            beforeMeal
                                ? [
                                  BoxShadow(
                                    color: _primaryColor.withOpacity(0.2),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fastfood,
                            color:
                                beforeMeal ? Colors.white : _textSecondaryColor,
                            size: 32.r,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Before Meal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  beforeMeal
                                      ? Colors.white
                                      : _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        beforeMeal = false;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: !beforeMeal ? _primaryColor : _cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border:
                            !beforeMeal
                                ? null
                                : Border.all(color: _borderColor, width: 1),
                        boxShadow:
                            !beforeMeal
                                ? [
                                  BoxShadow(
                                    color: _primaryColor.withOpacity(0.2),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color:
                                !beforeMeal
                                    ? Colors.white
                                    : _textSecondaryColor,
                            size: 32.r,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'After Meal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  !beforeMeal
                                      ? Colors.white
                                      : _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Duration visualization
            SizedBox(height: 40.h),
            Center(
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      "Treatment Duration",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: _primaryColor,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "${endDate.difference(startDate).inDays} days",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ],
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

  // Step 4: Reminders
  Widget _buildReminderStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Would you like reminders?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),

            SizedBox(height: 16.h),

            // Reminder toggle
            GestureDetector(
              onTap: () {
                setState(() {
                  autoReminder = !autoReminder;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: autoReminder ? _primaryColor : _borderColor,
                    width: autoReminder ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color:
                            autoReminder
                                ? _primaryColor.withOpacity(0.1)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.notifications_active,
                          color:
                              autoReminder
                                  ? _primaryColor
                                  : Colors.grey.shade400,
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
                            "Medication Reminders",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            autoReminder
                                ? "You'll receive reminders when it's time to take your medication"
                                : "No reminders will be sent",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: autoReminder,
                      onChanged: (value) {
                        setState(() {
                          autoReminder = value;
                        });
                        HapticFeedback.selectionClick();
                      },
                      activeColor: Colors.white,
                      activeTrackColor: _primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Summary
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: _borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.summarize,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Medication Summary",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildSummaryItem("Medication", medicationName),
                  _buildSummaryItem("Frequency", frequency),
                  _buildSummaryItem("Time(s)", selectedTimes.join(", ")),
                  _buildSummaryItem(
                    "Duration",
                    "${DateFormat("MMM d, yyyy").format(startDate)} to ${DateFormat("MMM d, yyyy").format(endDate)}",
                  ),
                  _buildSummaryItem(
                    "Instructions",
                    beforeMeal ? "Take before meals" : "Take after meals",
                  ),
                  _buildSummaryItem(
                    "Reminders",
                    autoReminder ? "Enabled" : "Disabled",
                  ),
                ],
              ),
            ),

            // Completion illustration
            SizedBox(height: 40.h),
            Center(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: _primaryColor,
                  size: 60.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Summary item
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              "$label:",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: _cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap:
                        _currentStep > 0
                            ? _previousStep
                            : () => Navigator.pop(context),
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
            ),

            // Step indicator
            _buildStepIndicator(),

            // Encouraging message
            Container(
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
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: _buildStepContent(),
              ),
            ),

            // Bottom navigation
            Container(
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
                      onTap:
                          _currentStep < _totalSteps - 1
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
            ),
          ],
        ),
      ),
    );
  }
}
