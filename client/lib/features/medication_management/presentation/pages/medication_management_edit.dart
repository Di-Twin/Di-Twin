import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
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
  late bool beforeMeal;
  late bool autoReminder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFromMedication();
  }

  void _initializeFromMedication() {
    medicationName = widget.medication.medicationName;
    startDate = DateTime.parse(widget.medication.startDate);
    endDate = DateTime.parse(widget.medication.endDate);
    frequency = _formatFrequencyForDisplay(widget.medication.frequency);
    beforeMeal = !widget.medication.afterFood; // Inverted logic
    autoReminder = widget.medication.reminder;

    // Convert first timing to display format
    if (widget.medication.timings.isNotEmpty) {
      time = _formatTimeForDisplay(widget.medication.timings.first);
    } else {
      time = "9:00 AM";
    }
  }

  String _formatFrequencyForDisplay(String apiFrequency) {
    switch (apiFrequency.toLowerCase()) {
      case 'daily':
        return '1x Per Day';
      case '2x per day':
        return '2x Per Day';
      case '3x per day':
        return '3x Per Day';
      case 'weekly':
        return '1x Per Week';
      case '2x per week':
        return '2x Per Week';
      case '3x per week':
        return '3x Per Week';
      case 'as needed':
        return 'As Needed';
      default:
        return '1x Per Day';
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

  String _formatFrequencyForApi(String displayFrequency) {
    switch (displayFrequency) {
      case '1x Per Day':
        return 'daily';
      case '2x Per Day':
        return '2x per day';
      case '3x Per Day':
        return '3x per day';
      case '1x Per Week':
        return 'weekly';
      case '2x Per Week':
        return '2x per week';
      case '3x Per Week':
        return '3x per week';
      case 'As Needed':
        return 'as needed';
      default:
        return 'daily';
    }
  }

  final List<String> frequencyOptions = [
    "1x Per Day",
    "2x Per Day",
    "3x Per Day",
    "1x Per Week",
    "2x Per Week",
    "3x Per Week",
    "As Needed",
  ];

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
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF242E49),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Color(0xFF0F67FE),
              headerForegroundColor: Colors.white,
              dayBackgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Color(0xFF0F67FE);
                }
                return Colors.transparent;
              }),
              dayForegroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Color(0xFF242E49);
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
    }
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

  void _showFrequencyDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Frequency',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: frequencyOptions.length,
                  itemBuilder: (context, index) {
                    bool isSelected = frequency == frequencyOptions[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected ? Color(0xFF0F67FE) : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          frequencyOptions[index],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                          Icons.check_circle,
                          color: Color(0xFF0F67FE),
                        )
                            : null,
                        onTap: () {
                          setState(() {
                            frequency = frequencyOptions[index];
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Frequency',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF242E49),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showFrequencyDialog,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.black,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    frequency,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF242E49),
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
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    time,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF242E49),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Duration',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF242E49),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.black,
                                            size: 20.r,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            DateFormat('MMM d').format(startDate),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF242E49),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black.withOpacity(0.5),
                                        size: 20.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.black,
                                            size: 20.r,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            DateFormat('MMM d').format(endDate),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF242E49),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.blueGrey.shade600,
                                        size: 20.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Take with Meal?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF242E49),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                beforeMeal = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color: beforeMeal ? Color(0xFF0F67FE) : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: beforeMeal
                                    ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.25),
                                    blurRadius: 0,
                                    spreadRadius: 5,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      color: beforeMeal ? Colors.white : Colors.black,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Before',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: beforeMeal ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
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
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color: !beforeMeal ? Color(0xFF0F67FE) : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: !beforeMeal
                                    ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.25),
                                    blurRadius: 0,
                                    spreadRadius: 5,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      color: !beforeMeal ? Colors.white : Colors.black,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'After',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: !beforeMeal ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set Auto Reminder?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF242E49),
                      ),
                    ),
                    Switch(
                      value: autoReminder,
                      onChanged: (value) {
                        setState(() {
                          autoReminder = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xFF0F67FE),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

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

  Future<void> _updateMedication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final actions = ref.read(medicationActionsProvider);

      final params = UpdateMedicationParams(
        id: widget.medication.id,
        medicationName: medicationName,
        afterFood: !beforeMeal, // Inverted because UI shows "before meal" but API expects "after food"
        frequency: _formatFrequencyForApi(frequency),
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
