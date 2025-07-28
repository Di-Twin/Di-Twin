import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/medication_management/presentation/providers/medication_api_provider.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_management_alert.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';

class MedicationsManagementDay extends ConsumerStatefulWidget {
  const MedicationsManagementDay({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationsManagementDay> createState() =>
      _MedicationsManagementDayState();
}

class _MedicationsManagementDayState extends ConsumerState<MedicationsManagementDay> {
  late DateTime _currentDate;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dateRange = [];
  final ScrollController _scrollController = ScrollController();
  int _selectedDateIndex = 0;
  Timer? _medicationCheckTimer;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = _currentDate;
    _generateDateRange();

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

  @override
  void dispose() {
    _medicationCheckTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkForMedicationAlerts() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    // Get daily medication data and check for alerts
    ref.read(dailyMedicationProvider(today).future).then((dailyData) {
      for (var medication in dailyData.medications) {
        if (medication.status == 'pending') {
          final timeSlotDateTime = _parseTimeSlot(today, medication.time);
          final diff = timeSlotDateTime.difference(now);

          if (diff.inMinutes.abs() <= 5 && diff.inMinutes > -10) {
            _showMedicationAlert(medication);
          }
        }
      }
    }).catchError((error) {
      // Handle error silently or show appropriate message
      print('Error checking medication alerts: $error');
    });
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

  void _showMedicationAlert(DailyMedicationModel medication) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MedicationManagementAlert(
          medicationName: medication.medicationName,
          dosage: medication.dose,
          instructions: medication.afterFood ? 'After Food' : 'Before Food',
          onTake: () {
            _takeMedication(medication.id, medication.time);
          },
          onSkip: () {
            _skipMedication(medication.id, medication.time);
          },
        );
      },
    );
  }

  Future<void> _takeMedication(String medicationId, String time) async {
    final actions = ref.read(medicationActionsProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final success = await actions.takeMedication(medicationId, dateStr, time);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medication marked as taken'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update medication status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _skipMedication(String medicationId, String time, {String? reason}) async {
    final actions = ref.read(medicationActionsProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final success = await actions.skipMedication(medicationId, dateStr, time, reason: reason);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medication marked as skipped'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update medication status'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

      if (index < 2 && _dateRange.first.difference(_currentDate).inDays > -15) {
        final earliestDate = _dateRange.first;
        final daysToAdd = List.generate(
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

  void _scrollToSelectedDate() {
    if (_selectedDateIndex >= 0 && _selectedDateIndex < _dateRange.length) {
      final double itemWidth = 72.0.w;
      final double offset = (_selectedDateIndex * itemWidth) -
          (MediaQuery.of(context).size.width / 2 - itemWidth / 2);

      _scrollController.jumpTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
      );
    }
  }

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
    bool isToday = _selectedDate.year == _currentDate.year &&
        _selectedDate.month == _currentDate.month &&
        _selectedDate.day == _currentDate.day;

    String dateText = isToday
        ? "Today's Medications"
        : "Medications for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}";

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyMedicationAsync = ref.watch(dailyMedicationProvider(dateStr));

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
          dailyMedicationAsync.when(
            data: (dailyData) => Text(
              "${dailyData.medications.length} total",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
            loading: () => Text(
              "Loading...",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
            error: (error, stack) => Text(
              "No medications",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 100.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = 72.0.w;
          final viewableItemCount = 5;
          final double totalItemsWidth = viewableItemCount * itemWidth;
          final double sidePadding = (constraints.maxWidth - totalItemsWidth) / 2;

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
    final bool isToday = date.day == DateTime.now().day &&
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
          border: isToday && !isSelected
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
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyMedicationAsync = ref.watch(dailyMedicationProvider(dateStr));

    return dailyMedicationAsync.when(
      data: (dailyData) {
        if (dailyData.medications.isEmpty) {
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

        // Group medications by time
        final Map<String, List<DailyMedicationModel>> groupedMedications = {};
        for (var medication in dailyData.medications) {
          final timeKey = medication.time;
          if (!groupedMedications.containsKey(timeKey)) {
            groupedMedications[timeKey] = [];
          }
          groupedMedications[timeKey]!.add(medication);
        }

        final sortedTimes = groupedMedications.keys.toList()..sort();

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: sortedTimes.length,
          itemBuilder: (context, index) {
            final time = sortedTimes[index];
            final medications = groupedMedications[time]!;
            final bool isLastItem = index == sortedTimes.length - 1;

            return _buildTimeSlot(time, medications, isLastItem);
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F67FE)),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load medications',
              style: TextStyle(color: Colors.red.shade600, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(dailyMedicationProvider(dateStr));
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time, List<DailyMedicationModel> medications, bool isLastItem) {
    final now = DateTime.now();
    final timeSlotDateTime = _parseTimeSlot(DateFormat('yyyy-MM-dd').format(_selectedDate), time);

    final bool isPast = timeSlotDateTime.isBefore(now);
    final bool isCurrent = timeSlotDateTime.difference(now).inHours.abs() <= 1;

    Color timeColor = isPast
        ? Colors.grey.shade600
        : (isCurrent ? Colors.green : Colors.indigo.shade900);

    final displayTime = _formatDisplayTime(time);

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
              displayTime,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isCurrent ? Colors.green : null,
              ),
            ),
            const Spacer(),
            Text(
              '${medications.length} Total',
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
                      height: (medications.length * 80.0.h + 16.h),
                      color: Colors.indigo.shade300,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: medications
                    .map((medication) => _buildMedicationItem(medication, isCurrent))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationItem(DailyMedicationModel medication, bool isCurrent) {
    final bool isCompleted = medication.status == 'taken';
    final bool isMissed = medication.status == 'missed';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: isCurrent && !isCompleted
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
              color: isCompleted
                  ? Colors.blue.shade100
                  : (isMissed ? Colors.red.shade100 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.medication,
              color: isCompleted
                  ? Colors.blue
                  : (isMissed ? Colors.red : Colors.grey),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.medicationName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isCompleted || isMissed ? Colors.grey.shade700 : null,
                    decoration: isCompleted || isMissed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${medication.dose} - ${medication.afterFood ? 'After Food' : 'Before Food'}',
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
              if (!isCompleted && !isMissed) {
                _takeMedication(medication.id, medication.time);
              }
            },
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.blue
                    : (isMissed ? Colors.red : Colors.white),
                borderRadius: BorderRadius.circular(4.r),
                border: (!isCompleted && !isMissed)
                    ? Border.all(color: Colors.grey.shade400)
                    : null,
              ),
              child: (isCompleted || isMissed)
                  ? Icon(
                isCompleted ? Icons.check : Icons.close,
                color: Colors.white,
                size: 16.sp,
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplayTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }
}
