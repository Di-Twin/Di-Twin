import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicationManagementEdit extends StatefulWidget {
  const MedicationManagementEdit({Key? key}) : super(key: key);

  @override
  State<MedicationManagementEdit> createState() =>
      _MedicationManagementEditState();
}

class _MedicationManagementEditState extends State<MedicationManagementEdit> {
  final String medicationName = "Amoxiciline";
  final String medicationInstructions = "Before Eating";
  DateTime startDate = DateTime(2025, 3, 1);
  DateTime endDate = DateTime(2025, 6, 1);
  String frequency = "3x Per Week";
  String time = "9:00 AM";
  bool beforeMeal = true;
  bool autoReminder = false;

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
    final TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1].split(' ')[0]),
    );

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
                          color:
                              isSelected
                                  ? Color(0xFF0F67FE)
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          frequencyOptions[index],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        trailing:
                            isSelected
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
                      ),
                    ),
                  ),
                ),

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
                        medicationInstructions,
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

                SizedBox(height: 16.h),

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

                SizedBox(height: 16.h),

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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            DateFormat(
                                              'MMM d',
                                            ).format(startDate),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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

                SizedBox(height: 16.h),

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
                                color:
                                    beforeMeal
                                        ? Color(0xFF0F67FE)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow:
                                    beforeMeal
                                        ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(
                                              0.25,
                                            ),
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
                                      color:
                                          beforeMeal
                                              ? Colors.white
                                              : Colors.black,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Before',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            beforeMeal
                                                ? Colors.white
                                                : Colors.grey,
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
                                color:
                                    !beforeMeal
                                        ? Color(0xFF0F67FE)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow:
                                    !beforeMeal
                                        ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(
                                              0.25,
                                            ),
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
                                      color:
                                          !beforeMeal
                                              ? Colors.white
                                              : Colors.black,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'After',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            !beforeMeal
                                                ? Colors.white
                                                : Colors.grey,
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
                SizedBox(height: 16.h),

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

                SizedBox(height: 12.h),

                CustomButton(
                  text: "Edit Medication",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {},
                  height: 45.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
