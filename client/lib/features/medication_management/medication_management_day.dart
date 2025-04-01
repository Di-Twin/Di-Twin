import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationsManagementDay extends StatefulWidget {
  const MedicationsManagementDay({Key? key}) : super(key: key);

  @override
  State<MedicationsManagementDay> createState() =>
      _MedicationsManagementDayState();
}

class _MedicationsManagementDayState extends State<MedicationsManagementDay> {
  late DateTime _currentDate;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dateRange = [];
  final ScrollController _scrollController = ScrollController();
  int _selectedDateIndex = 0;
  Timer? _medicationCheckTimer;

  final Map<String, List<Map<String, dynamic>>> _medicationDatabase = {
    '2025-03-30': [
      {
        'time': '08:00',
        'displayTime': '8:00 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxicilline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_8am_20250330',
            'icon': Icons.medication,
            'taken': false,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_8am_20250330',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
        ],
      },
      {
        'time': '10:00',
        'displayTime': '10:00 AM',
        'total': 1,
        'medications': [
          {
            'name': 'Paracetamol',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'paracetamol_10am_20250330',
            'icon': Icons.medication,
            'taken': false,
          },
        ],
      },
      {
        'time': '13:00',
        'displayTime': '1:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxicilline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_1pm_20250330',
            'icon': Icons.medication,
            'taken': false,
          },
          {
            'name': 'Vitamin D',
            'dosage': '2000 IU',
            'instruction': 'With Food',
            'id': 'vitamind_1pm_20250330',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
        ],
      },
      {
        'time': '18:00',
        'displayTime': '6:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_6pm_20250330',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'vitaminc_6pm_20250330',
            'icon': Icons.medication,
            'taken': false,
          },
        ],
      },
      {
        'time': '22:00',
        'displayTime': '10:00 PM',
        'total': 1,
        'medications': [
          {
            'name': 'Melatonin',
            'dosage': '3mg',
            'instruction': 'Before Sleep',
            'id': 'melatonin_10pm_20250330',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
        ],
      },
    ],
    '2025-03-29': [
      {
        'time': '08:00',
        'displayTime': '8:00 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxicilline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_8am_20250329',
            'icon': Icons.medication,
            'taken': true,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_8am_20250329',
            'icon': Icons.medication_liquid,
            'taken': true,
          },
        ],
      },
      {
        'time': '13:00',
        'displayTime': '1:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxicilline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_1pm_20250329',
            'icon': Icons.medication,
            'taken': true,
          },
          {
            'name': 'Vitamin D',
            'dosage': '2000 IU',
            'instruction': 'With Food',
            'id': 'vitamind_1pm_20250329',
            'icon': Icons.medication_liquid,
            'taken': true,
          },
        ],
      },
      {
        'time': '18:00',
        'displayTime': '6:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_6pm_20250329',
            'icon': Icons.medication_liquid,
            'taken': true,
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'vitaminc_6pm_20250329',
            'icon': Icons.medication,
            'taken': true,
          },
        ],
      },
    ],
    '2025-03-31': [
      {
        'time': '08:00',
        'displayTime': '8:00 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxicilline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_8am_20250331',
            'icon': Icons.medication,
            'taken': false,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_8am_20250331',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
        ],
      },
      {
        'time': '11:55',
        'displayTime': '11:55 AM',
        'total': 1,
        'medications': [
          {
            'name': 'Amoxicilline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_1pm_20250331',
            'icon': Icons.medication,
            'taken': false,
          },
        ],
      },
      {
        'time': '20:05',
        'displayTime': '8:05 PM',
        'total': 3,
        'medications': [
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_6pm_20250331',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'vitaminc_6pm_20250331',
            'icon': Icons.medication,
            'taken': false,
          },
          {
            'name': 'Probuphine',
            'dosage': '80mg',
            'instruction': 'With Food',
            'id': 'probuphine_6pm_20250331',
            'icon': Icons.medication,
            'taken': false,
          },
        ],
      },
    ],
  };

  void _populateMoreDates() {
    final DateTime now = DateTime.now();

    for (int i = -7; i <= 7; i++) {
      if (i == -1 || i == 0 || i == 1) continue;

      final DateTime date = DateTime(now.year, now.month, now.day + i);
      final String dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!_medicationDatabase.containsKey(dateKey)) {
        _medicationDatabase[dateKey] = [
          {
            'time': '08:00',
            'displayTime': '8:00 AM',
            'total': 2,
            'medications': [
              {
                'name': 'Amoxicilline',
                'dosage': '500mg',
                'instruction': 'Before Eating',
                'id': 'amoxicilline_8am_${DateFormat('yyyyMMdd').format(date)}',
                'icon': Icons.medication,
                'taken': false,
              },
              {
                'name': 'Losartan',
                'dosage': '50mg',
                'instruction': 'After Eating',
                'id': 'losartan_8am_${DateFormat('yyyyMMdd').format(date)}',
                'icon': Icons.medication_liquid,
                'taken': false,
              },
            ],
          },
          {
            'time': '18:00',
            'displayTime': '6:00 PM',
            'total': 2,
            'medications': [
              {
                'name': 'Losartan',
                'dosage': '50mg',
                'instruction': 'After Eating',
                'id': 'losartan_6pm_${DateFormat('yyyyMMdd').format(date)}',
                'icon': Icons.medication_liquid,
                'taken': false,
              },
              {
                'name': 'Vitamin C',
                'dosage': '500mg',
                'instruction': 'With Water',
                'id': 'vitaminc_6pm_${DateFormat('yyyyMMdd').format(date)}',
                'icon': Icons.medication,
                'taken': false,
              },
            ],
          },
        ];
      }
    }
  }

  Map<String, bool> _medicationStatus = {};

  List<Map<String, dynamic>> _currentMedicationSchedule = [];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = _currentDate;
    _populateMoreDates();
    _generateDateRange();
    _loadMedicationSchedule();
    _initializeMedicationStatus();

    _selectedDateIndex = _dateRange.indexWhere(
      (date) =>
          date.day == _currentDate.day &&
          date.month == _currentDate.month &&
          date.year == _currentDate.year,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToSelectedDate();
      }

      _startMedicationCheckTimer();
    });
  }

  void _startMedicationCheckTimer() {
    _medicationCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForMedicationAlerts();
    });

    _checkForMedicationAlerts();
  }

  void _initializeMedicationStatus() {
    _medicationDatabase.forEach((dateKey, timeSlots) {
      for (var timeSlot in timeSlots) {
        for (var medication in timeSlot['medications']) {
          _medicationStatus[medication['id']] = medication['taken'];
        }
      }
    });
  }

  void _loadMedicationSchedule() {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    _currentMedicationSchedule = _medicationDatabase[dateKey] ?? [];

    _currentMedicationSchedule.sort((a, b) => a['time'].compareTo(b['time']));
  }

  void _scrollToSelectedDate() {
    if (_selectedDateIndex >= 0 && _selectedDateIndex < _dateRange.length) {
      final double itemWidth = 72.0.w;
      final double offset =
          (_selectedDateIndex * itemWidth) -
          (MediaQuery.of(context).size.width / 2 - itemWidth / 2);

      _scrollController.jumpTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  @override
  void dispose() {
    _medicationCheckTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkForMedicationAlerts() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final currentTime = DateFormat('HH:mm').format(now);

    if (_medicationDatabase.containsKey(today)) {
      for (var timeSlot in _medicationDatabase[today]!) {
        final timeSlotTime = timeSlot['time'];
        final timeSlotDateTime = _parseTimeSlot(today, timeSlotTime);

        final diff = timeSlotDateTime.difference(now);
        if (diff.inMinutes.abs() <= 5 && diff.inMinutes > -10) {
          for (var medication in timeSlot['medications']) {
            if (_medicationStatus[medication['id']] == true) continue;

            _showMedicationAlert(medication);
          }
        }
      }
    }
  }

  DateTime _parseTimeSlot(String dateStr, String timeStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    final timeParts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  void _showMedicationAlert(Map<String, dynamic> medication) {
    if (medication['alertShown'] == true) return;

    medication['alertShown'] = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MedicationManagementAlert(
          medicationName: medication['name'],
          dosage: medication['dosage'] ?? "No dosage specified",
          instructions: medication['instruction'],
        );
      },
    ).then((value) {
      if (value == 'take') {
        setState(() {
          _medicationStatus[medication['id']] = true;

          final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
          if (_medicationDatabase.containsKey(dateKey)) {
            for (var timeSlot in _medicationDatabase[dateKey]!) {
              for (var med in timeSlot['medications']) {
                if (med['id'] == medication['id']) {
                  med['taken'] = true;
                }
              }
            }
          }
        });
      } else if (value == 'reschedule') {}

      Future.delayed(const Duration(minutes: 30), () {
        medication['alertShown'] = false;
      });
    });
  }

  void _generateDateRange() {
    final startDate = _currentDate.subtract(const Duration(days: 15));
    _dateRange = List.generate(
      31,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  void _selectDate(int index) {
    final selectedDate = _dateRange[index];

    setState(() {
      _selectedDateIndex = index;
      _selectedDate = selectedDate;
      _loadMedicationSchedule();

      if (index < 2 && _dateRange.first.difference(_currentDate).inDays > -15) {
        final earliestDate = _dateRange.first;
        final daysToAdd =
            List.generate(
              5,
              (i) => earliestDate.subtract(Duration(days: i + 1)),
            ).reversed.toList();

        _dateRange.insertAll(0, daysToAdd);
        _selectedDateIndex += daysToAdd.length;
      } else if (index > _dateRange.length - 3 &&
          _dateRange.last.difference(_currentDate).inDays < 15) {
        final latestDate = _dateRange.last;
        final daysToAdd = List.generate(
          5,
          (i) => latestDate.add(Duration(days: i + 1)),
        );

        _dateRange.addAll(daysToAdd);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildDaySelector(),
              _buildDateInfo(),
              Expanded(child: _buildMedicationTimeline()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: IconButton(
              iconSize: 24.w,
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'My Medications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    bool isToday =
        _selectedDate.year == _currentDate.year &&
        _selectedDate.month == _currentDate.month &&
        _selectedDate.day == _currentDate.day;

    String dateText =
        isToday
            ? "Today's Medications"
            : "Medications for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            _currentMedicationSchedule.isEmpty
                ? "No medications"
                : "${_getTotalMedications()} total",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  int _getTotalMedications() {
    int total = 0;
    for (var timeSlot in _currentMedicationSchedule) {
      total += (timeSlot['medications'] as List).length;
    }
    return total;
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 100.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = 72.0.w;
          final viewableItemCount = 5;

          final double totalItemsWidth = viewableItemCount * itemWidth;
          final double sidePadding =
              (constraints.maxWidth - totalItemsWidth) / 2;

          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            itemCount: _dateRange.length,
            itemBuilder: (context, index) => _buildDayItem(index),
          );
        },
      ),
    );
  }

  Widget _buildDayItem(int index) {
    final DateTime date = _dateRange[index];
    final bool isSelected = index == _selectedDateIndex;
    final bool isToday =
        date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    final String dayName = DateFormat('E').format(date);

    final String dateNumber = date.day.toString();

    return GestureDetector(
      onTap: () {
        _selectDate(index);
      },
      child: Container(
        width: 64.w,
        margin: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 8.0.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0F67FE) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border:
              isToday && !isSelected
                  ? Border.all(color: Color(0xFF0F67FE), width: 2.w)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1.r,
              blurRadius: 2.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dateNumber,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationTimeline() {
    if (_currentMedicationSchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No medications scheduled for this day',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _currentMedicationSchedule.length,
      itemBuilder: (context, index) {
        final timeSlot = _currentMedicationSchedule[index];
        final bool isLastItem = index == _currentMedicationSchedule.length - 1;

        final now = DateTime.now();
        final timeElements = timeSlot['time'].split(':');
        final timeSlotDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          int.parse(timeElements[0]),
          int.parse(timeElements[1]),
        );

        final bool isPast = timeSlotDateTime.isBefore(now);
        final bool isCurrent =
            timeSlotDateTime.difference(now).inHours.abs() <= 1;

        Color timeColor =
            isPast
                ? Colors.grey.shade600
                : (isCurrent ? Colors.green : Colors.indigo.shade900);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: timeColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.access_time_filled,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  timeSlot['displayTime'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isCurrent ? Colors.green : null,
                  ),
                ),
                const Spacer(),
                Text(
                  '${timeSlot['total']} Total',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(width: 2.w, height: 16.h, color: timeColor),
                      if (!isLastItem)
                        Container(
                          width: 2.w,
                          height:
                              (timeSlot['medications'].length * 80.0.h + 16.h),
                          color: Colors.indigo.shade300,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: List.generate(
                      timeSlot['medications'].length,
                      (medIndex) => _buildMedicationItem(
                        timeSlot['medications'][medIndex],
                        isCurrent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication, bool isCurrent) {
    final bool isCompleted = _medicationStatus[medication['id']] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border:
            isCurrent && !isCompleted
                ? Border.all(color: Colors.green.shade400, width: 2.w)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.blue.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              medication['icon'],
              color: isCompleted ? Colors.blue : Colors.grey,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isCompleted ? Colors.grey.shade700 : null,
                  ),
                ),
                Text(
                  medication['instruction'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _medicationStatus[medication['id']] = !isCompleted;

                final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
                if (_medicationDatabase.containsKey(dateKey)) {
                  for (var timeSlot in _medicationDatabase[dateKey]!) {
                    for (var med in timeSlot['medications']) {
                      if (med['id'] == medication['id']) {
                        med['taken'] = !isCompleted;
                      }
                    }
                  }
                }
              });
            },
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(4.r),
                border:
                    isCompleted
                        ? null
                        : Border.all(color: Colors.grey.shade400),
              ),
              child:
                  isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationManagementAlert extends StatelessWidget {
  final String medicationName;
  final String dosage;
  final String instructions;
  final String backgroundImagePath;

  const MedicationManagementAlert({
    Key? key,
    required this.medicationName,
    this.dosage = "Default dosage",
    required this.instructions,
    this.backgroundImagePath = './images/medication_management_alert.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color blueColor = Color(0xFF0F67FE);
    const Color redColor = Color(0xFFFA4D5E);

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 100.w, 20.w, 20.w),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 256.w,
                          height: 236.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            backgroundImagePath,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        Text(
                          medicationName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medication,
                                  color: Colors.grey,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  dosage,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 16.w),

                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: Colors.grey,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  instructions,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context: context,
                          icon: Icons.close,
                          label: "Skip",
                          color: redColor,
                          onTap: () {
                            Navigator.of(context).pop('skip');
                          },
                        ),

                        _buildActionButton(
                          context: context,
                          icon: Icons.calendar_today,
                          label: "Reschedule",
                          color: const Color(0xFFAEC5EB),
                          onTap: () {
                            Navigator.of(context).pop('reschedule');
                          },
                        ),

                        _buildActionButton(
                          context: context,
                          icon: Icons.add,
                          label: "Take",
                          color: blueColor,
                          onTap: () {
                            Navigator.of(context).pop('take');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, size: 28.sp),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.white, size: 28.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: const Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }
}
