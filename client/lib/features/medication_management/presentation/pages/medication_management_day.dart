import 'dart:async';
import 'package:client/features/medication_management/presentation/providers/medication_provider.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_item_widget.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_status_indicator.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MedicationsManagementDay extends StatefulWidget {
  const MedicationsManagementDay({super.key});

  @override
  State<MedicationsManagementDay> createState() =>
      _MedicationsManagementDayState();
}

class _MedicationsManagementDayState extends State<MedicationsManagementDay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;
  final ScrollController _scrollController = ScrollController();
  Timer? _dayProgressTimer;
  Timer? _medicationCheckTimer;

  // Define the consistent background color
  final Color _backgroundColor = Color(0xFFF1F5F9);
  final Color _primaryColor = Color(0xFF0F67FE);
  final Color _secondaryColor = Color(0xFF1E293B);
  final Color _accentColor = Color(0xFF10B981); // Green for current time
  final Color _errorColor = Color(0xFFEF4444); // Red for missed medications

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with slower duration for day-long animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Slower animation
    )..repeat(reverse: true);

    // Create animation for the line
    _lineAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      provider.initialize();

      if (_scrollController.hasClients) {
        _scrollToSelectedDate();
      }

      _startMedicationCheckTimer();
      _startDayProgressTimer();
    });
  }

  @override
  void dispose() {
    _medicationCheckTimer?.cancel();
    _dayProgressTimer?.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    final selectedIndex = provider.selectedDateIndex;

    if (selectedIndex >= 0 && selectedIndex < provider.dateRange.length) {
      final double itemWidth = 80.0.w; // Increased width
      final double offset =
          (selectedIndex * itemWidth) -
              (MediaQuery.of(context).size.width / 2 - itemWidth / 2);

      _scrollController.jumpTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  void _startDayProgressTimer() {
    // Update day progress every minute
    _dayProgressTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      // Call the public method instead of private _calculateDayProgress
      provider.notifyListeners(); // This will trigger a rebuild
    });
  }

  void _startMedicationCheckTimer() {
    _medicationCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForMedicationAlerts();
    });

    _checkForMedicationAlerts();
  }

  // Make sure the _checkForMedicationAlerts method is properly implemented
  void _checkForMedicationAlerts() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final currentTime = DateFormat('HH:mm').format(now);

    final provider = Provider.of<MedicationProvider>(context, listen: false);
    provider.checkForMedicationAlerts(context);
  }

  @override
  Widget build(BuildContext context) {
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
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
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
                    DateFormat('EEEE, MMMM d, yyyy').format(provider.selectedDate),
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
      },
    );
  }

  Widget _buildDaySelector() {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
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
                  itemCount: provider.dateRange.length,
                  itemBuilder: (context, index) => _buildDayItem(index, provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayItem(int index, MedicationProvider provider) {
    final DateTime date = provider.dateRange[index];
    final bool isSelected = index == provider.selectedDateIndex;
    final bool isToday = _isSameDay(date, DateTime.now());

    // Get day name (Mon, Tue, etc.)
    final String dayName = DateFormat('EEE').format(date);

    // Get date number
    final String dateNumber = date.day.toString();

    // Get month name
    final String monthName = DateFormat('MMM').format(date);

    // Check medication status for this date
    final medicationStatus = provider.getMedicationStatusForDate(date);

    return GestureDetector(
      onTap: () {
        provider.selectDate(index);
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
              MedicationStatusIndicator(
                status: medicationStatus,
                isSelected: isSelected,
                accentColor: _accentColor,
                errorColor: _errorColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  Widget _buildMedicationTimeline() {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.currentMedicationSchedule.isEmpty) {
          return _buildEmptyState();
        }

        // Calculate timeline progress
        final timelineProgress = provider.calculateTimelineProgress();

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
              itemCount: provider.currentMedicationSchedule.length,
              itemBuilder: (context, index) {
                final timeSlot = provider.currentMedicationSchedule[index];
                final bool isLastItem =
                    index == provider.currentMedicationSchedule.length - 1;

                // Check if this time slot is current or upcoming
                final bool isCurrent = provider.isTimeSlotActive(timeSlot.time);
                final bool isPast = provider.isTimeSlotPassed(timeSlot.time);

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
                          timeSlot.displayTime,
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
                            '${timeSlot.total} ${timeSlot.total == 1 ? 'Medication' : 'Medications'}',
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
                          timeSlot.medications.length,
                              (medIndex) => MedicationItemWidget(
                            medication: timeSlot.medications[medIndex],
                            isCurrent: isCurrent,
                            timeStr: timeSlot.time,
                            onStatusChanged: (medicationId, taken) {
                              provider.updateMedicationStatus(medicationId, taken);
                            },
                            primaryColor: _primaryColor,
                            accentColor: _accentColor,
                            errorColor: _errorColor,
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
      },
    );
  }

  Widget _buildEmptyState() {
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
}
