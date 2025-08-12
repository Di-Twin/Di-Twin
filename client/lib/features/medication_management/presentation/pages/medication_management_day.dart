import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late AnimationController _completionAnimationController;

  // Track loading states for individual medications
  final Set<String> _loadingMedications = <String>{};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = _currentDate;
    _generateDateRange();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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
      _progressAnimationController.forward();
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
    _completionAnimationController.dispose();
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

  String _getMedicationKey(String medicationId, String time) {
    return '${medicationId}_$time';
  }

  Future<void> _takeMedication(String medicationId, String time) async {
    final medicationKey = _getMedicationKey(medicationId, time);

    // Prevent multiple clicks
    if (_loadingMedications.contains(medicationKey)) {
      return;
    }

    setState(() {
      _loadingMedications.add(medicationKey);
    });

    try {
      final actions = ref.read(medicationActionsProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final success = await actions.takeMedication(medicationId, dateStr, time);

      if (success) {
        _completionAnimationController.forward().then((_) {
          _completionAnimationController.reset();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Great! Medication taken successfully',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update medication status',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please try again.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      setState(() {
        _loadingMedications.remove(medicationKey);
      });
    }
  }

  Future<void> _skipMedication(String medicationId, String time, {String? reason}) async {
    final medicationKey = _getMedicationKey(medicationId, time);

    // Prevent multiple clicks
    if (_loadingMedications.contains(medicationKey)) {
      return;
    }

    setState(() {
      _loadingMedications.add(medicationKey);
    });

    try {
      final actions = ref.read(medicationActionsProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final success = await actions.skipMedication(medicationId, dateStr, time, reason: reason);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(Icons.schedule, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Medication skipped',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                      if (reason != null && reason.isNotEmpty)
                        Text(
                          'Reason: $reason',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFBBF24),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to skip medication',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please try again.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      setState(() {
        _loadingMedications.remove(medicationKey);
      });
    }
  }

  void _showSkipReasonBottomSheet(String medicationId, String time) {
    final TextEditingController customReasonController = TextEditingController();
    String selectedReason = '';
    bool showCustomInput = false;

    final List<Map<String, dynamic>> skipOptions = [
      {
        'title': 'Feeling unwell',
        'subtitle': 'Not feeling good today',
        'icon': Icons.sick_outlined,
        'color': const Color(0xFFEF4444),
        'bgColor': const Color(0xFFFEF2F2),
      },
      {
        'title': 'Forgot to take',
        'subtitle': 'Missed the scheduled time',
        'icon': Icons.schedule_outlined,
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
      },
      {
        'title': 'Side effects',
        'subtitle': 'Experiencing adverse effects',
        'icon': Icons.warning_amber_outlined,
        'color': const Color(0xFFDC2626),
        'bgColor': const Color(0xFFFEE2E2),
      },
      {
        'title': 'Other reason',
        'subtitle': 'Specify your own reason',
        'icon': Icons.edit_outlined,
        'color': const Color(0xFF6366F1),
        'bgColor': const Color(0xFFF0F0FF),
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.pause_circle_outline,
                              color: const Color(0xFFF59E0B),
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Skip Medication',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Why are you skipping this dose?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Skip options
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: skipOptions.map((option) {
                          final isSelected = selectedReason == option['title'];
                          final isOther = option['title'] == 'Other reason';

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setModalState(() {
                                selectedReason = option['title'];
                                showCustomInput = isOther;
                                if (!isOther) {
                                  customReasonController.clear();
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: isSelected ? option['bgColor'] : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected ? option['color'] : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2.w : 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.w,
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? option['color'].withOpacity(0.1)
                                          : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      option['icon'],
                                      color: isSelected ? option['color'] : const Color(0xFF64748B),
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option['title'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          option['subtitle'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedScale(
                                    scale: isSelected ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 24.w,
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        color: option['color'],
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Custom reason input
                    if (showCustomInput) ...[
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Please specify your reason:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                controller: customReasonController,
                                maxLines: 3,
                                maxLength: 200,
                                decoration: InputDecoration(
                                  hintText: 'Enter your reason for skipping...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 14.sp,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16.w),
                                  counterStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF1E293B),
                                ),
                                onChanged: (value) {
                                  setModalState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 32.h),

                    // Action buttons
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 52.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: selectedReason.isEmpty ||
                                  (showCustomInput && customReasonController.text.trim().isEmpty)
                                  ? null
                                  : () {
                                HapticFeedback.mediumImpact();
                                Navigator.of(context).pop();
                                final reason = showCustomInput
                                    ? customReasonController.text.trim()
                                    : selectedReason;
                                _skipMedication(medicationId, time, reason: reason);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 52.h,
                                decoration: BoxDecoration(
                                  color: selectedReason.isEmpty ||
                                      (showCustomInput && customReasonController.text.trim().isEmpty)
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pause_circle_outline,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Skip Medication',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(),
            _buildEnhancedDaySelector(),
            _buildProgressHeader(),
            Expanded(child: _buildModernMedicationTimeline()),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18.sp,
                color: const Color(0xFF1E293B),
              ),
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
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Stay on track with your health',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDaySelector() {
    return Container(
      height: 140.h,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Today',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
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
              itemBuilder: (context, index) => _buildEnhancedDayItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDayItem(int index) {
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
        curve: Curves.easeInOut,
        width: 68.w,
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : (isToday ? const Color(0xFFF1F5F9) : Colors.transparent),
          borderRadius: BorderRadius.circular(16.r),
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF3B82F6), width: 1.5.w)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected
                    ? Colors.white
                    : (isToday ? const Color(0xFF3B82F6) : const Color(0xFF64748B)),
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              dateNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white
                    : (isToday ? const Color(0xFF3B82F6) : const Color(0xFF1E293B)),
              ),
            ),
            if (isToday && !isSelected)
              Container(
                width: 4.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyMedicationAsync = ref.watch(dailyMedicationProvider(dateStr));

    return dailyMedicationAsync.when(
      data: (dailyData) {
        final totalMedications = dailyData.medications.length;
        final takenMedications = dailyData.medications.where((m) => m.status == 'taken').length;
        final progress = totalMedications > 0 ? takenMedications / totalMedications : 0.0;

        bool isToday = _selectedDate.year == DateTime.now().year &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.day == DateTime.now().day;

        String dateText = isToday
            ? "Today's Progress"
            : DateFormat('MMM dd').format(_selectedDate);

        return Container(
          margin: EdgeInsets.all(20.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '$takenMedications of $totalMedications medications taken',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  _buildProgressRing(progress, takenMedications, totalMedications),
                ],
              ),
              if (totalMedications > 0) ...[
                SizedBox(height: 20.h),
                _buildProgressBar(progress),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: 200.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(32.r),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Unable to load progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(double progress, int taken, int total) {
    return AnimatedBuilder(
      animation: _progressAnimationController,
      builder: (context, child) {
        return SizedBox(
          width: 64.w,
          height: 64.h,
          child: Stack(
            children: [
              SizedBox(
                width: 64.w,
                height: 64.h,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6.w,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF1F5F9)),
                ),
              ),
              SizedBox(
                width: 64.w,
                height: 64.h,
                child: CircularProgressIndicator(
                  value: progress * _progressAnimationController.value,
                  strokeWidth: 6.w,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? const Color(0xFF10B981)
                        : progress >= 0.5
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFFBBF24),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              '${(progress * 100).round()}% Complete',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: progress >= 1.0
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        AnimatedBuilder(
          animation: _progressAnimationController,
          builder: (context, child) {
            return Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress * _progressAnimationController.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? const Color(0xFF10B981)
                        : progress >= 0.5
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernMedicationTimeline() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyMedicationAsync = ref.watch(dailyMedicationProvider(dateStr));

    return dailyMedicationAsync.when(
      data: (dailyData) {
        if (dailyData.medications.isEmpty) {
          return _buildEmptyState();
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
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          itemCount: sortedTimes.length,
          itemBuilder: (context, index) {
            final time = sortedTimes[index];
            final medications = groupedMedications[time]!;
            final bool isLastItem = index == sortedTimes.length - 1;

            return _buildModernTimeSlot(time, medications, isLastItem, index);
          },
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Icon(
                Icons.medication_outlined,
                size: 60.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'No medications scheduled',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Enjoy your medication-free day!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 180.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Icon(
                Icons.error_outline,
                size: 60.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Unable to load medications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please check your connection and try again',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            GestureDetector(
              onTap: () {
                final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                ref.invalidate(dailyMedicationProvider(dateStr));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTimeSlot(String time, List<DailyMedicationModel> medications, bool isLastItem, int timeSlotIndex) {
    final now = DateTime.now();
    final timeSlotDateTime = _parseTimeSlot(DateFormat('yyyy-MM-dd').format(_selectedDate), time);

    final bool isPast = timeSlotDateTime.isBefore(now);
    final bool isCurrent = timeSlotDateTime.difference(now).inHours.abs() <= 1;
    final bool isUpcoming = timeSlotDateTime.isAfter(now);

    final completedCount = medications.where((m) => m.status == 'taken').length;
    final totalCount = medications.length;
    final isTimeSlotComplete = completedCount == totalCount;

    Color timeColor = isPast
        ? (isTimeSlotComplete ? const Color(0xFF10B981) : const Color(0xFF94A3B8))
        : (isCurrent ? const Color(0xFF3B82F6) : const Color(0xFF64748B));

    final displayTime = _formatDisplayTime(time);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: timeColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        isCurrent
                            ? Icons.schedule
                            : (isTimeSlotComplete ? Icons.check : Icons.access_time),
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    if (isTimeSlotComplete)
                      Positioned(
                        top: 1.h,
                        right: 1.w,
                        child: Container(
                          width: 14.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(7.r),
                            border: Border.all(color: Colors.white, width: 1.5.w),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 8.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isLastItem)
                Container(
                  width: 2.w,
                  height: (medications.length * 90.0.h + 16.h),
                  color: const Color(0xFFE2E8F0),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Time slot content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time header
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTime,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 18.sp,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$completedCount of $totalCount medications',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFDF7),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Now',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                      if (isTimeSlotComplete && !isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFDF7),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12.sp,
                                color: const Color(0xFF059669),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Complete',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Medications list
                ...medications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medication = entry.value;
                  return _buildModernMedicationItem(
                    medication,
                    isCurrent,
                    index == medications.length - 1,
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMedicationItem(DailyMedicationModel medication, bool isCurrent, bool isLast) {
    final bool isCompleted = medication.status == 'taken';
    final bool isMissed = medication.status == 'missed';
    final bool isPending = medication.status == 'pending';
    final medicationKey = _getMedicationKey(medication.id, medication.time);
    final bool isLoading = _loadingMedications.contains(medicationKey);

    Color statusColor = isCompleted
        ? const Color(0xFF10B981)
        : (isMissed ? const Color(0xFFEF4444) : const Color(0xFF64748B));

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: isCurrent && isPending
            ? Border.all(color: const Color(0xFF3B82F6), width: 1.5.w)
            : null,
      ),
      child: Row(
        children: [
          // Medication icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFDCFDF7)
                  : (isMissed ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.medication,
              color: statusColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          // Medication details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.medicationName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: isCompleted || isMissed
                        ? const Color(0xFF64748B)
                        : const Color(0xFF1E293B),
                    decoration: isCompleted || isMissed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Wrap(
                  children: [
                    Text(
                      medication.dose,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 3.w,
                      height: 3.h,
                      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF94A3B8),
                        borderRadius: BorderRadius.circular(1.5.r),
                      ),
                    ),
                    Text(
                      medication.afterFood ? 'After Food' : 'Before Food',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Action buttons section
          if (!isCompleted && !isMissed)
            Row(
              children: [
                // Skip button with reason
                GestureDetector(
                  onTap: isLoading ? null : () {
                    HapticFeedback.lightImpact();
                    _showSkipReasonBottomSheet(medication.id, medication.time);
                  },
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.pause_circle_outline,
                      color: const Color(0xFFF59E0B),
                      size: 18.sp,
                    ),
                  ),
                ),
                // Take button (existing)
                GestureDetector(
                  onTap: isLoading ? null : () {
                    HapticFeedback.mediumImpact();
                    _takeMedication(medication.id, medication.time);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? const Color(0xFFF1F5F9)
                          : (isCurrent
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    )
                        : Icon(
                      Icons.check,
                      color: isCurrent ? Colors.white : const Color(0xFF64748B),
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: statusColor,
                size: 18.sp,
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
