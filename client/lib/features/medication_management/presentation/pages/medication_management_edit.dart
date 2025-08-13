import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/features/medication_management/presentation/providers/medication_api_provider.dart';
import 'package:client/features/medication_management/domain/usecases/update_medication_usecase.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';

class MedicationManagementEdit extends ConsumerStatefulWidget {
  final ApiMedicationModel medication;

  const MedicationManagementEdit({
    Key? key,
    required this.medication,
  }) : super(key: key);

  @override
  ConsumerState<MedicationManagementEdit> createState() =>
      _MedicationManagementEditState();
}

class _MedicationManagementEditState extends ConsumerState<MedicationManagementEdit> {
  late String medicationName;
  late DateTime startDate;
  late DateTime endDate;
  late String frequency;
  late String time;
  late String mealTiming; // 'before', 'after', 'none'
  late bool autoReminder;
  late String frequencyType; // 'daily', 'weekly'
  late double dailyFrequency;
  late int durationDays;
  late List<bool> selectedWeekDays;
  bool _isLoading = false;

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _durationOptions = [7, 14, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    _initializeFromMedication();
  }

  void _initializeFromMedication() {
    medicationName = widget.medication.medicationName;

    // Use current date as start date instead of medication's start date
    startDate = DateTime.now();

    // Calculate original duration from medication data
    final originalStartDate = DateTime.parse(widget.medication.startDate);
    final originalEndDate = DateTime.parse(widget.medication.endDate);
    final originalDuration = originalEndDate.difference(originalStartDate).inDays;

    // Set duration based on original duration, defaulting to 30 if not in options
    durationDays = _durationOptions.contains(originalDuration) ? originalDuration : 30;

    // Calculate end date based on current date + duration
    endDate = startDate.add(Duration(days: durationDays));

    // Parse frequency
    _parseFrequency(widget.medication.frequency);

    // Set meal timing
    mealTiming = widget.medication.afterFood ? 'after' : 'before';
    autoReminder = widget.medication.reminder;

    // Convert first timing to display format
    if (widget.medication.timings.isNotEmpty) {
      time = _formatTimeForDisplay(widget.medication.timings.first);
    } else {
      time = "9:00 AM";
    }

    // Initialize week days (default to Monday selected)
    selectedWeekDays = List.filled(7, false);
    selectedWeekDays[0] = true;
  }

  void _parseFrequency(String apiFrequency) {
    final lowerFreq = apiFrequency.toLowerCase();

    if (lowerFreq.contains('daily')) {
      frequencyType = 'daily';
      if (lowerFreq.contains('1x') || lowerFreq == 'daily') {
        dailyFrequency = 1.0;
      } else if (lowerFreq.contains('2x')) {
        dailyFrequency = 2.0;
      } else if (lowerFreq.contains('3x')) {
        dailyFrequency = 3.0;
      } else if (lowerFreq.contains('4x')) {
        dailyFrequency = 4.0;
      } else {
        dailyFrequency = 1.0;
      }
    } else if (lowerFreq.contains('week')) {
      frequencyType = 'weekly';
      if (lowerFreq.contains('1x')) {
        dailyFrequency = 1.0;
      } else if (lowerFreq.contains('2x')) {
        dailyFrequency = 2.0;
      } else if (lowerFreq.contains('3x')) {
        dailyFrequency = 3.0;
      } else {
        dailyFrequency = 1.0;
      }
    } else {
      frequencyType = 'daily';
      dailyFrequency = 1.0;
    }
  }

  String _formatTimeForDisplay(String apiTime) {
    try {
      final timeParts = apiTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:$minute $period';
    } catch (e) {
      return "9:00 AM";
    }
  }

  String _formatTimeForApi(String displayTime) {
    try {
      final timeParts = displayTime.split(' ');
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = hourMinute[1];
      final period = timeParts[1];

      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      return '09:00';
    }
  }

  String _formatFrequencyForApi() {
    if (frequencyType == 'daily') {
      return '${dailyFrequency.toInt()}x per day';
    } else {
      final selectedDays = selectedWeekDays.asMap().entries
          .where((entry) => entry.value)
          .map((entry) => _weekDays[entry.key])
          .join(', ');
      return '${dailyFrequency.toInt()}x per day on $selectedDays';
    }
  }

  void _updateFrequencyType(String type) {
    HapticFeedback.lightImpact();
    setState(() {
      frequencyType = type;
      if (type == 'daily') {
        dailyFrequency = 1.0;
      } else if (type == 'weekly') {
        dailyFrequency = 1.0;
        // Reset week days selection
        selectedWeekDays = List.filled(7, false);
        selectedWeekDays[0] = true; // Default to Monday
      }
    });
  }

  void _updateFrequency(double frequency) {
    HapticFeedback.lightImpact();
    setState(() {
      dailyFrequency = frequency;
    });
  }

  void _toggleWeekDay(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedWeekDays[index] = !selectedWeekDays[index];
      // Ensure at least one day is selected
      if (!selectedWeekDays.any((selected) => selected)) {
        selectedWeekDays[index] = true;
      }
    });
  }

  void _updateDuration(int days) {
    HapticFeedback.selectionClick();
    setState(() {
      durationDays = days;
      // Update end date based on current start date + new duration
      endDate = startDate.add(Duration(days: durationDays));
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final period = timeParts[1];

    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final TimeOfDay initialTime = TimeOfDay(hour: hour, minute: minute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Color(0xFF0F67FE);
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Color(0xFF242E49);
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
        time = '$hour:${picked.minute.toString().padLeft(2, '0')} $period';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Center(
                  child: Container(
                    width: 200.w,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        './images/MedicationManagement.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medication,
                            size: 48.sp,
                            color: Colors.grey.shade400,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                Center(
                  child: Column(
                    children: [
                      Text(
                        medicationName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF242E49),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        widget.medication.dose,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242E49).withOpacity(0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Updated Frequency Section
                _buildSection(
                  title: 'Frequency',
                  child: Column(
                    children: [
                      // Frequency Type Selection
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _updateFrequencyType('daily'),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: frequencyType == 'daily' ? const Color(0xFF0F67FE) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Daily',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: frequencyType == 'daily' ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _updateFrequencyType('weekly'),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: frequencyType == 'weekly' ? const Color(0xFF0F67FE) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Weekly',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: frequencyType == 'weekly' ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Frequency Slider
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  frequencyType == 'daily' ? 'Times per day' : 'Times per selected days',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${dailyFrequency.toInt()} ${dailyFrequency.toInt() == 1 ? 'time' : 'times'}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF242E49),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF0F67FE),
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: const Color(0xFF0F67FE),
                                overlayColor: const Color(0xFF0F67FE).withOpacity(0.2),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: dailyFrequency,
                                min: 1.0,
                                max: 4.0,
                                divisions: 3,
                                onChanged: _updateFrequency,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '1',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  '4',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Week Days Selection (only show if weekly)
                      if (frequencyType == 'weekly') ...[
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Choose which days of the week to take medication',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(7, (index) {
                                  final isSelected = selectedWeekDays[index];
                                  return GestureDetector(
                                    onTap: () => _toggleWeekDay(index),
                                    child: Container(
                                      width: 40.w,
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _weekDays[index],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 20.h),

                      // Time Selection
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey.shade600,
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Time',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  time,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF242E49),
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

                SizedBox(height: 32.h),

                // Updated Duration Section
                _buildSection(
                  title: 'Duration',
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey.shade600,
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Start Date',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(startDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF242E49),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Start date is set to today for updated medication schedule',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Duration',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: _durationOptions.map((days) {
                            final isSelected = durationDays == days;
                            return GestureDetector(
                              onTap: () => _updateDuration(days),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  '$days days',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF242E49),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green.shade600,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'End date: ${DateFormat('MMM d, yyyy').format(endDate)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Updated Take with Meal Section
                _buildSection(
                  title: 'Take with Meal?',
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              color: Colors.grey.shade600,
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Meal timing',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMealOption('before', 'Before meal'),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildMealOption('after', 'After meal'),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildMealOption('none', 'No meal'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Updated Auto Reminder Section
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey.shade600,
                        size: 24.r,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Reminder',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF242E49),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Get notified at scheduled times',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: autoReminder,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            autoReminder = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF0F67FE),
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                CustomButton(
                  text: _isLoading ? "Updating..." : "Update Medication",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: _isLoading ? null : _updateMedication,
                  height: 45.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF242E49),
          ),
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  Widget _buildMealOption(String mealTiming, String label) {
    final isSelected = this.mealTiming == mealTiming;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          this.mealTiming = mealTiming;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF242E49),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateMedication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final actions = ref.read(medicationActionsProvider);

      final params = UpdateMedicationParams(
        id: widget.medication.id,
        medicationName: medicationName,
        afterFood: mealTiming == 'after',
        frequency: _formatFrequencyForApi(),
        timings: [_formatTimeForApi(time)],
        reminder: autoReminder,
        dose: widget.medication.dose, // Keep existing dose
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
      );

      final result = await actions.updateMedication(params);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medication updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update medication. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
