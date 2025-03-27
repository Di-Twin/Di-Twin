import 'package:client/widgets/ActivityHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/widgets/CustomCalander.dart';

class FoodLog {
  final String name;
  final String quantity;
  final String time;
  final String imageUrl;

  FoodLog({
    required this.name,
    required this.quantity,
    required this.time,
    required this.imageUrl,
  });
}

class FoodLogsNutritionTracker extends ConsumerStatefulWidget {
  const FoodLogsNutritionTracker({super.key});

  @override
  ConsumerState<FoodLogsNutritionTracker> createState() =>
      _FoodLogsNutritionTrackerState();
}

class _FoodLogsNutritionTrackerState
    extends ConsumerState<FoodLogsNutritionTracker> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final DateTime _userJoinedDate = DateTime(2024, 1, 1);

  final List<FoodLog> _foodLogs = [
    FoodLog(name: 'Dosa', quantity: '500g', time: '9:00 AM', imageUrl: ''),
    FoodLog(name: 'Dosa', quantity: '500g', time: '9:00 AM', imageUrl: ''),
    FoodLog(name: 'Dosa', quantity: '500g', time: '9:00 AM', imageUrl: ''),
    FoodLog(name: 'Dosa', quantity: '500g', time: '9:00 AM', imageUrl: ''),
    FoodLog(name: 'Dosa', quantity: '500g', time: '9:00 AM', imageUrl: ''),
  ];

  final Map<int, bool> _foodLogRegularity = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: true,
    8: true,
    9: true,
    10: true,
    11: true,
    13: true,
    14: true,
    15: true,
    16: true,
    17: true,
    18: true,
    24: true,
    25: true,
    26: true,
    28: true,
    12: false,
    19: false,
    20: false,
    21: false,
    22: false,
    27: false,
    29: false,
    30: false,
  };

  void _changeMonth(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      // TODO: Add logic to fetch food logs for the selected date
    });
  }

  Widget _buildFoodIntakeSection() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Intake',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: _foodLogs.length,
                itemBuilder: (context, index) {
                  final foodLog = _foodLogs[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Placeholder for food image
                        Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.image_outlined),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodLog.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${foodLog.quantity} • ${foodLog.time}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            // TODO: Add options for food log (edit, delete, etc.)
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MonthYearPicker(
          initialDate: _selectedMonth,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onMonthYearChanged: (newDate) {
            Navigator.pop(context);
            setState(() {
              _selectedMonth = newDate;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      splitScreenMode: true,
      builder:
          (_, child) => Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  const ActivityHeader(),
                  _buildAppBar(),

                  // Activity Calendar with Reduced Height
                  // SizedBox(
                  //   height: 390.h, // Reduced height
                    ActivityCalendar(
                      selectedMonth: _selectedMonth,
                      today: DateTime.now(),
                      activityRegularity: _foodLogRegularity,
                      userJoinedDate: _userJoinedDate,
                      onMonthChanged: _changeMonth,
                      onDateSelected: _selectDate,
                    ),
                  // ),

                  // Food Intake Section
                  _buildFoodIntakeSection(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nutrition Tracking',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: _showMonthPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.sp,
                    // color: Colors.blue,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    DateFormat('MMM').format(_selectedMonth),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... rest of the code remains the same
}

// Month Year Picker Widget
class MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onMonthYearChanged;

  const MonthYearPicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onMonthYearChanged,
  }) : super(key: key);

  @override
  _MonthYearPickerState createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late DateTime _selectedDate;
  late List<String> _months;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            'Select Month and Year',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 24.sp),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year - 1,
                      _selectedDate.month,
                    );
                  });
                },
              ),
              Text(
                _selectedDate.year.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 24.sp),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year + 1,
                      _selectedDate.month,
                    );
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.onMonthYearChanged(
                      DateTime(_selectedDate.year, index + 1),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          _selectedDate.month == index + 1
                              ? Colors.blue
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _months[index],
                        style: GoogleFonts.plusJakartaSans(
                          color:
                              _selectedDate.month == index + 1
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
