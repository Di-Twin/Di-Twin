import 'dart:async';
import 'package:client/features/medication_management/medication_management_add.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/medication_management/medication_take_now_alert.dart';
import 'package:client/features/medication_management/medication_management_alert.dart';

class MedicationsManagementDay extends StatefulWidget {
  const MedicationsManagementDay({super.key});

  @override
  State<MedicationsManagementDay> createState() =>
      _MedicationsManagementDayState();
}

class _MedicationsManagementDayState extends State<MedicationsManagementDay>
    with SingleTickerProviderStateMixin {
  late DateTime _currentDate;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dateRange = [];
  final ScrollController _scrollController = ScrollController();
  int _selectedDateIndex = 0;
  Timer? _medicationCheckTimer;
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  // Define the consistent background color
  final Color _backgroundColor = Color(0xFFF1F5F9);
  final Color _primaryColor = Color(0xFF0F67FE);
  final Color _secondaryColor = Color(0xFF1E293B);
  final Color _accentColor = Color(0xFF10B981); // Green for current time
  final Color _errorColor = Color(0xFFEF4444); // Red for missed medications

  // Day progress
  double _dayProgress = 0.0;
  Timer? _dayProgressTimer;

  final Map<String, List<Map<String, dynamic>>> _medicationDatabase = {
    '2025-04-04': [
      {
        'time': '09:43',
        'displayTime': '9:43 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxiciline',
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
        'time': '09:00',
        'displayTime': '9:00 AM',
        'total': 5,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_9am_20250330',
            'icon': Icons.medication,
            'taken': true,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_9am_20250330',
            'icon': Icons.medication_liquid,
            'taken': false,
          },
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_9am_20250330_2',
            'icon': Icons.medication,
            'taken': true,
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
            'name': 'Amoxiciline',
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
        'time': '17:18',
        'displayTime': '5:18 PM',
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
            'name': 'Amoxiciline',
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
            'name': 'Amoxiciline',
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
            'name': 'Amoxiciline',
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
            'name': 'Amoxiciline',
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
                'name': 'Amoxiciline',
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

  final Map<String, bool> _medicationStatus = {};

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
    _calculateDayProgress();

    // Initialize animation controller with slower duration for day-long animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Slower animation
    )..repeat(reverse: true);

    // Create animation for the line
    _lineAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
      _startDayProgressTimer();
    });
  }

  void _calculateDayProgress() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final totalDayMinutes = 24 * 60;
    final minutesPassed = now.difference(startOfDay).inMinutes;

    setState(() {
      _dayProgress = (minutesPassed / totalDayMinutes).clamp(0.0, 1.0);
    });
  }

  void _startDayProgressTimer() {
    // Update day progress every minute
    _dayProgressTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateDayProgress();
    });
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
      final double itemWidth = 80.0.w; // Increased width
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
    _dayProgressTimer?.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startMedicationCheckTimer() {
    _medicationCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForMedicationAlerts();
    });

    _checkForMedicationAlerts();
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

  // Check if all medications for a specific date are taken
  MedicationStatus _getMedicationStatusForDate(DateTime date) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);

    // If no medications for this date, return none
    if (!_medicationDatabase.containsKey(dateKey) ||
        _medicationDatabase[dateKey]!.isEmpty) {
      return MedicationStatus.none;
    }

    int totalMedications = 0;
    int takenMedications = 0;

    for (var timeSlot in _medicationDatabase[dateKey]!) {
      for (var medication in timeSlot['medications']) {
        totalMedications++;
        if (medication['taken']) {
          takenMedications++;
        }
      }
    }

    // If all medications are taken
    if (takenMedications == totalMedications) {
      return MedicationStatus.complete;
    }

    // If some medications are taken
    if (takenMedications > 0) {
      return MedicationStatus.partial;
    }

    // If no medications are taken
    return MedicationStatus.incomplete;
  }

  // Check if a time slot is currently active (within 15 minutes)
  bool _isTimeSlotActive(String timeStr) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeSlotDateTime = _parseTimeSlot(today, timeStr);

    final diff = now.difference(timeSlotDateTime).inMinutes.abs();
    return diff <= 15; // Within 15 minutes
  }

  // Check if a medication time has passed
  bool _isTimeSlotPassed(String timeStr) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeSlotDateTime = _parseTimeSlot(today, timeStr);

    return now.isAfter(timeSlotDateTime);
  }

  // Calculate the vertical timeline progress based on current time
  double _calculateTimelineProgress() {
    // If selected date is in the past, return 1.0 (100%)
    if (_selectedDate.isBefore(
      DateTime(_currentDate.year, _currentDate.month, _currentDate.day),
    )) {
      return 1.0;
    }

    // If selected date is in the future, return 0.0 (0%)
    if (_selectedDate.isAfter(
      DateTime(_currentDate.year, _currentDate.month, _currentDate.day),
    )) {
      return 0.0;
    }

    // If today, return current progress through the day
    return _dayProgress;
  }

  @override
  Widget build(BuildContext context) {
    final bool isToday =
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDaySelector(),
            Expanded(child: _buildMedicationTimeline()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: _secondaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_left,
                  color: _secondaryColor,
                  size: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Medications',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: _secondaryColor,
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.calendar_today,
                color: _primaryColor,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 180.h, // Increased height to prevent overflow
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 4.h),
            child: Row(
              children: [
                Text(
                  'Select Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              itemCount: _dateRange.length,
              itemBuilder: (context, index) => _buildDayItem(index),
            ),
          ),
        ],
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

    // Get day name (Mon, Tue, etc.)
    final String dayName = DateFormat('EEE').format(date);

    // Get date number
    final String dateNumber = date.day.toString();

    // Get month name
    final String monthName = DateFormat('MMM').format(date);

    // Check medication status for this date
    final medicationStatus = _getMedicationStatusForDate(date);

    return GestureDetector(
      onTap: () {
        _selectDate(index);
      },
      child: Container(
        width: 80.w, // Increased width
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border:
              !isSelected && isToday
                  ? Border.all(color: _primaryColor, width: 2.w)
                  : null,
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4.r,
                spreadRadius: 0,
                offset: Offset(0, 2.h),
              ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, // Increased font size
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : _secondaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                dateNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22.sp, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : _secondaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                monthName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, // Increased font size
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4.h),
              _buildMedicationStatusIndicator(medicationStatus, isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationStatusIndicator(
    MedicationStatus status,
    bool isSelected,
  ) {
    switch (status) {
      case MedicationStatus.complete:
        return Icon(
          Icons.check_circle,
          color: isSelected ? Colors.white : _accentColor,
          size: 18.sp, // Increased size
        );
      case MedicationStatus.partial:
        return Icon(
          Icons.timelapse,
          color: isSelected ? Colors.white : Colors.orange,
          size: 18.sp, // Increased size
        );
      case MedicationStatus.incomplete:
        return Icon(
          Icons.cancel,
          color: isSelected ? Colors.white : _errorColor,
          size: 18.sp,
        );
      case MedicationStatus.none:
      default:
        return SizedBox(
          height: 18.sp,
          width: 18.sp,
        ); // Empty space to maintain layout
    }
  }

  Widget _buildMedicationTimeline() {
    if (_currentMedicationSchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_outlined,
                size: 40.sp,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No medications scheduled',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _secondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the + button to add medications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 32.h),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicationManagementAddPage()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w), 
                    Text(
                      'Add Medication',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

    // Calculate timeline progress
    final timelineProgress = _calculateTimelineProgress();

    return Stack(
      children: [
        // Timeline line that runs according to the current time - centered with clock icon
        Positioned(
          left: 20.w, // Position at the center of the clock icon (40.w / 2)
          top: 0,
          bottom: 0,
          child: Container(width: 2.w, color: Colors.grey.shade300),
        ),

        // Progress line (based on current time) - centered with clock icon
        Positioned(
          left: 20.w, // Position at the center of the clock icon (40.w / 2)
          top: 0,
          height: MediaQuery.of(context).size.height * timelineProgress,
          child: Container(
            width: 2.w,
            decoration: BoxDecoration(color: _primaryColor),
          ),
        ),

        ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _currentMedicationSchedule.length,
          itemBuilder: (context, index) {
            final timeSlot = _currentMedicationSchedule[index];
            final bool isLastItem =
                index == _currentMedicationSchedule.length - 1;

            // Check if this time slot is current or upcoming
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
            final bool isCurrent = _isTimeSlotActive(timeSlot['time']);

            // Set colors based on time status
            Color timeColor =
                isPast
                    ? Colors.grey.shade600
                    : (isCurrent ? _accentColor : _secondaryColor);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: timeColor,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: timeColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      timeSlot['displayTime'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? _accentColor : _secondaryColor,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isCurrent
                                ? _accentColor.withOpacity(0.1)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '${timeSlot['total']} ${timeSlot['total'] == 1 ? 'Medication' : 'Medications'}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              isCurrent ? _accentColor : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Added more spacing between time title and medications
                SizedBox(height: 24.h),

                // Medication list with added left padding to align with timeline
                Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: Column(
                    children: List.generate(
                      timeSlot['medications'].length,
                      (medIndex) => _buildMedicationItem(
                        timeSlot['medications'][medIndex],
                        isCurrent,
                        timeSlot['time'],
                      ),
                    ),
                  ),
                ),

                // Add more spacing between time slots
                if (!isLastItem) SizedBox(height: 24.h),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicationItem(
    Map<String, dynamic> medication,
    bool isCurrent,
    String timeStr,
  ) {
    final bool isCompleted = _medicationStatus[medication['id']] ?? false;
    final bool isTimeSlotPassed = _isTimeSlotPassed(timeStr);
    final bool isMissed = isTimeSlotPassed && !isCompleted;

    // Create custom medication icon based on the medication type
    Widget medicationIcon;
    if (medication['icon'] == Icons.medication) {
      medicationIcon = Icon(
        Icons.circle,
        color: isCompleted ? _primaryColor : Colors.grey.shade400,
        size: 20.sp,
      );
    } else {
      medicationIcon = Icon(
        Icons.crop_square,
        color: isCompleted ? _primaryColor : Colors.grey.shade400,
        size: 20.sp,
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border:
            isCurrent && !isCompleted
                ? Border.all(color: _accentColor, width: 2.w)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            spreadRadius: 0,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? _primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(child: medicationIcon),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medication['name'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _secondaryColor,
                              decoration:
                                  isCompleted || isMissed
                                      ? TextDecoration.lineThrough
                                      : null,
                              decorationColor:
                                  isCompleted
                                      ? Colors.grey.shade400
                                      : _errorColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            medication['dosage'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            medication['instruction'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status indicator icon
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? _accentColor
                          : (isMissed ? _errorColor : Colors.white),
                  borderRadius: BorderRadius.circular(6.r),
                  border:
                      (!isCompleted && !isMissed)
                          ? Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5.w,
                          )
                          : null,
                  boxShadow: [
                    if (isCompleted || isMissed)
                      BoxShadow(
                        color: (isCompleted ? _accentColor : _errorColor)
                            .withOpacity(0.3),
                        blurRadius: 4.r,
                        spreadRadius: 0,
                        offset: Offset(0, 2.h),
                      ),
                  ],
                ),
                child:
                    isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : (isMissed
                            ? Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.sp,
                            )
                            : null),
              ),
            ],
          ),

          // Add "Take now" button for missed medications
          if (isMissed)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: GestureDetector(
                onTap: () {
                  // Show confirmation popup before marking as taken
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return MedicationTakeNowAlert(
                        medicationName: medication['name'],
                        dosage: medication['dosage'],
                        instructions: medication['instruction'],
                        onTake: () {
                          // Mark medication as taken
                          setState(() {
                            _medicationStatus[medication['id']] = true;

                            final dateKey = DateFormat(
                              'yyyy-MM-dd',
                            ).format(_selectedDate);
                            if (_medicationDatabase.containsKey(dateKey)) {
                              for (var timeSlot
                                  in _medicationDatabase[dateKey]!) {
                                for (var med in timeSlot['medications']) {
                                  if (med['id'] == medication['id']) {
                                    med['taken'] = true;
                                  }
                                }
                              }
                            }
                          });
                          // Navigator.of(context).pop(); // Close the dialog
                        },
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Take now',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
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

// Enum to represent medication status for a day
enum MedicationStatus {
  none, // No medications for this day
  complete, // All medications taken
  partial, // Some medications taken
  incomplete, // No medications taken
}
