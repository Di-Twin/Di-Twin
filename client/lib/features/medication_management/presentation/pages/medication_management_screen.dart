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

class _MedicationsManagementDayState extends ConsumerState<MedicationsManagementDay>
    with TickerProviderStateMixin {
  late DateTime _currentDate;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dateRange = [];
  final ScrollController _scrollController = ScrollController();
  int _selectedDateIndex = 0;
  Timer? _medicationCheckTimer;
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

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

    // Initialize animations
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToSelectedDate();
      }
      _startMedicationCheckTimer();
      _progressAnimationController.forward();
      _pulseAnimationController.repeat(reverse: true);
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
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _checkForMedicationAlerts() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

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
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              Text('Great job! Medication taken successfully'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update medication status'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8.w),
              Text('Medication marked as skipped'),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update medication status'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildDaySelector(),
              Expanded(child: _buildMedicationContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              iconSize: 20.w,
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF64748B)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Medications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Stay on track with your health',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: const Color(0xFF64748B),
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 120.h,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Select Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
    final bool isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    final String dayName = DateFormat('E').format(date);
    final String dateNumber = date.day.toString();

    return GestureDetector(
      onTap: () => _selectDate(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F67FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF0F67FE), width: 2.w)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dateNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationContent() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyMedicationAsync = ref.watch(dailyMedicationProvider(dateStr));

    return dailyMedicationAsync.when(
      data: (dailyData) => _buildMedicationList(dailyData),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(dateStr),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F67FE)),
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading your medications...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String dateStr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.sp,
              color: const Color(0xFFEF4444),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Unable to load medications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please check your connection and try again',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => ref.invalidate(dailyMedicationProvider(dateStr)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F67FE),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList(DailyMedicationResponseModel dailyData) {
    if (dailyData.medications.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate progress
    final totalMeds = dailyData.medications.length;
    final takenMeds = dailyData.medications.where((m) => m.status == 'taken').length;
    final progress = totalMeds > 0 ? takenMeds / totalMeds : 0.0;

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

    return Column(
      children: [
        _buildProgressSection(progress, takenMeds, totalMeds),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: sortedTimes.length,
            itemBuilder: (context, index) {
              final time = sortedTimes[index];
              final medications = groupedMedications[time]!;
              return _buildTimeSlotCard(time, medications, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(60.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: Icon(
              Icons.medication_outlined,
              size: 48.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No medications today',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enjoy your medication-free day!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress, int taken, int total) {
    final bool isToday = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? "Today's Progress" : "Daily Progress",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$taken of $total medications taken',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: progress == 1.0 ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: progress == 1.0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Center(
                        child: progress == 1.0
                            ? Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 24.sp,
                        )
                            : Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F67FE),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progress == 1.0
                          ? const Color(0xFF10B981)
                          : const Color(0xFF0F67FE),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              );
            },
          ),
          if (progress == 1.0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: const Color(0xFF10B981),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Perfect day! All medications taken',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(String time, List<DailyMedicationModel> medications, int index) {
    final now = DateTime.now();
    final timeSlotDateTime = _parseTimeSlot(DateFormat('yyyy-MM-dd').format(_selectedDate), time);
    final bool isPast = timeSlotDateTime.isBefore(now);
    final bool isCurrent = timeSlotDateTime.difference(now).inHours.abs() <= 1;
    final displayTime = _formatDisplayTime(time);

    final allTaken = medications.every((m) => m.status == 'taken');
    final anyTaken = medications.any((m) => m.status == 'taken');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrent && !allTaken
              ? const Color(0xFF0F67FE)
              : const Color(0xFFE2E8F0),
          width: isCurrent && !allTaken ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: allTaken
                  ? const Color(0xFFF0FDF4)
                  : isCurrent
                  ? const Color(0xFFF0F9FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: allTaken
                        ? const Color(0xFF10B981)
                        : isCurrent
                        ? const Color(0xFF0F67FE)
                        : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    allTaken
                        ? Icons.check_circle
                        : isCurrent
                        ? Icons.schedule
                        : Icons.access_time,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${medications.length} medication${medications.length > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (allTaken)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Complete',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (anyTaken)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Partial',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: medications.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _buildMedicationItem(medications[index], isCurrent);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(DailyMedicationModel medication, bool isCurrent) {
    final bool isCompleted = medication.status == 'taken';
    final bool isMissed = medication.status == 'missed';

    return GestureDetector(
      onTap: () {
        if (!isCompleted && !isMissed) {
          _takeMedication(medication.id, medication.time);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF10B981)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.medication,
                color: isCompleted ? Colors.white : const Color(0xFF64748B),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.medicationName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          medication.dose,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        medication.afterFood ? 'After Food' : 'Before Food',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isCompleted && !isMissed)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F67FE),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Take',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
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
