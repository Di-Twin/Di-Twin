import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({Key? key}) : super(key: key);

  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final TextEditingController _medicationNameController =
      TextEditingController();
  double _dosage = 1;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  bool _autoReminder = false;
  bool _beforeMeal = false;
  String _frequency = '3x Per Week';
  String _time = '9:00 AM';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _medicationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E2639),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Add Medication',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Medication Name'),
                    _buildMedicationNameInput(),
                    SizedBox(height: 24.h),

                    _buildSectionTitle('Medication Dosage'),
                    _buildDosageSlider(),
                    SizedBox(height: 24.h),

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
                                    _frequency,
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
                                    _time,
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
                    SizedBox(height: 24.h),

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
                                            ).format(_startDate),
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
                                            DateFormat(
                                              'MMM d',
                                            ).format(_endDate),
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
                    SizedBox(height: 24.h),

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
                                _beforeMeal = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color:
                                    _beforeMeal
                                        ? Color(0xFF0F67FE)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow:
                                    _beforeMeal
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
                                          _beforeMeal
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
                                            _beforeMeal
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
                                _beforeMeal = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color:
                                    !_beforeMeal
                                        ? Color(0xFF0F67FE)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow:
                                    !_beforeMeal
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
                                          !_beforeMeal
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
                                            !_beforeMeal
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
                          value: _autoReminder,
                          onChanged: (value) {
                            setState(() {
                              _autoReminder = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Color(0xFF0F67FE),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    _buildAddButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: Color(0xFF242E49),
      ),
    );
  }

  Widget _buildMedicationNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _medicationNameController,
        decoration: InputDecoration(
          hintText: 'Medication Name',
          prefixIcon: const Icon(Icons.medical_information_outlined),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildDosageSlider() {
    return Column(
      children: [
        Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Slider(
            value: _dosage,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: Color(0xFF0F67FE),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              setState(() {
                _dosage = value;
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                [1, 2, 3, 4, 5]
                    .map(
                      (e) => Text(
                        e.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
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
                    bool isSelected = _frequency == frequencyOptions[index];
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
                            _frequency = frequencyOptions[index];
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

  final List<String> frequencyOptions = [
    "1x Per Day",
    "2x Per Day",
    "3x Per Day",
    "1x Per Week",
    "2x Per Week",
    "3x Per Week",
    "As Needed",
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
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

    if (selectedTime != null) {
      setState(() {
        _reminderTime = selectedTime;

        final hour =
            selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod;
        final minute = selectedTime.minute.toString().padLeft(2, '0');
        final period = selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
        _time = '$hour:$minute $period';
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate =
        isStartDate
            ? DateTime.now().subtract(const Duration(days: 30))
            : _startDate;
    final DateTime lastDate =
        isStartDate ? _endDate : DateTime.now().add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF242E49),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF0F67FE)),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Color(0xFF0F67FE),
              headerForegroundColor: Colors.white,
              weekdayStyle: TextStyle(color: Color(0xFF242E49)),
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Color(0xFF242E49);
              }),
              dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Color(0xFF0F67FE);
                }
                return null;
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
          _startDate = picked;

          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildAddButton() {
    return CustomButton(
      text: "Add Medication",
      iconPath: 'images/SignInAddIcon.png',
      onPressed: () {},
      height: 45.h,
    );
  }

  void _saveMedication() {
    if (_medicationNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a medication name');
      return;
    }

    final medicationData = {
      'name': _medicationNameController.text,
      'dosage': _dosage,
      'frequency': _frequency,
      'reminderTime': _time,
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'mealOption': _beforeMeal ? 'Before' : 'After',
      'autoReminder': _autoReminder,
    };

    print('Saving medication: $medicationData');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Medication added successfully',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, medicationData);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: Colors.red,
      ),
    );
  }
}
