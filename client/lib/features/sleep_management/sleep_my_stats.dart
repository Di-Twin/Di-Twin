import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:client/widgets/CustomCalander.dart';
import 'package:client/widgets/CustomDrawer.dart';
import 'package:client/data/providers/sleep_provider.dart';
import 'package:client/features/sleep_management/presentation/widgets/month_year_picker.dart';
import 'package:client/features/sleep_management/presentation/widgets/monthly_sleep_score_card.dart';

class MySleepScreen extends StatefulWidget {
  final DateTime userJoinDate;

  const MySleepScreen({super.key, required this.userJoinDate});

  @override
  State<MySleepScreen> createState() => _MySleepScreenState();
}

class _MySleepScreenState extends State<MySleepScreen>
    with TickerProviderStateMixin { // Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin to support multiple AnimationControllers
  // Class variables
  List<int> _availableYears = [];
  List<DateTime> _availableMonths = [];
  DateTime _today = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate = DateTime.now(); // Default to today

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controller for page transition
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Offset _slideDirection = const Offset(1.0, 0.0);

  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;
  late Animation<double> _scoreOpacityAnimation;
  late Animation<double> _scoreRotationAnimation;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedMonth = DateTime(_today.year, _today.month, 1);
    _selectedYear = _today.year;

    // Initialize the collections
    _generateAvailableYears();
    _generateAvailableMonths();

    // Initialize animation controller
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOut),
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _scoreOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scoreRotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _pageTransitionController.forward();

    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _handleDateSelection(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
  }

  List<Map<String, dynamic>> _getFilteredSleepRecords(WidgetRef ref) {
    final monthlySleepData = ref.watch(MonthlyuniqueSleepDaysProvider);
    debugPrint('[UI] Retrieved ${monthlySleepData.length} sleep days');

    return monthlySleepData.map((session) {
      final dateTime = DateTime.parse(session.date);
      debugPrint('[UI] Session on ${session.date}: duration=${session.duration}, efficiency=${session.efficiencyScore}');

      return {
        'day': dateTime.day,
        'month': dateTime.month,
        'duration': session.getDurationInHours(),
        'quality': session.getSleepQuality(),
        'date': dateTime,
      };
    }).toList();
  }

  void _generateAvailableYears() {
    _availableYears = [];

    // Start from the user's join year
    int startYear = widget.userJoinDate.year;
    int endYear = _today.year;

    for (int year = startYear; year <= endYear; year++) {
      _availableYears.add(year);
    }

    // Sort in descending order (newest first)
    _availableYears.sort((a, b) => b.compareTo(a));
  }

  void _generateAvailableMonths() {
    _availableMonths = [];

    // Start from the user's join date
    DateTime startDate = DateTime(
      widget.userJoinDate.year,
      widget.userJoinDate.month,
      1,
    );

    // Go up to the current month
    DateTime endDate = DateTime(_today.year, _today.month, 1);

    // Generate a list of all months between start and end date
    while (startDate.isBefore(endDate) ||
        (startDate.year == endDate.year && startDate.month == endDate.month)) {
      _availableMonths.add(DateTime(startDate.year, startDate.month, 1));
      startDate = DateTime(startDate.year, startDate.month + 1, 1);
    }

    // Sort in descending order (newest first)
    _availableMonths.sort((a, b) => b.compareTo(a));
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SleepMonthYearPicker(
              selectedMonth: _selectedMonth,
              selectedYear: _selectedYear,
              availableYears: _availableYears,
              availableMonths: _availableMonths,
              today: _today,
              userJoinDate: widget.userJoinDate,
              onApply: (DateTime newMonth) {
                // Determine slide direction based on month comparison
                DateTime oldMonth = _selectedMonth;

                if (newMonth.isBefore(oldMonth)) {
                  _slideDirection = const Offset(
                    -1.0,
                    0.0,
                  ); // Right slide (newer to older)
                } else if (newMonth.isAfter(oldMonth)) {
                  _slideDirection = const Offset(
                    1.0,
                    0.0,
                  ); // Left slide (older to newer)
                } else {
                  // Same month, no animation needed
                  this.setState(() {
                    _selectedMonth = newMonth;
                  });
                  return;
                }

                // Update the slide animation with new direction
                _slideAnimation = Tween<Offset>(
                  begin: _slideDirection,
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _pageTransitionController,
                    curve: Curves.easeOut,
                  ),
                );

                // Reset animation
                _pageTransitionController.reset();

                // Update state with the new selected month
                this.setState(() {
                  _selectedMonth = newMonth;
                  _selectedYear = newMonth.year;
                });

                // Start animation
                _pageTransitionController.forward();

                _scoreAnimationController.reset();
                Future.delayed(Duration(milliseconds: 300), () {
                  _scoreAnimationController.forward();
                });
              },
            );
          },
        );
      },
    );
  }

  // Helper method to check if a month is available
  bool _isMonthAvailable(DateTime monthDate) {
    // Month should be after or same as join date
    bool isAfterJoinDate = monthDate.isAfter(
      DateTime(widget.userJoinDate.year, widget.userJoinDate.month - 1, 1),
    );

    // Month should not be in the future
    bool isNotInFuture = monthDate.isBefore(
      DateTime(_today.year, _today.month + 1, 1),
    );

    return isAfterJoinDate && isNotInFuture;
  }

  // Method to handle month changes from the drawer
  void _handleMonthChange(DateTime newMonth) {
    // Determine slide direction based on month comparison
    if (newMonth.isBefore(_selectedMonth)) {
      _slideDirection = const Offset(-1.0, 0.0); // Right slide (newer to older)
    } else if (newMonth.isAfter(_selectedMonth)) {
      _slideDirection = const Offset(1.0, 0.0); // Left slide (older to newer)
    } else {
      // Same month, no animation needed
      return;
    }

    // Update the slide animation with new direction
    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOut),
    );

    // Reset animation
    _pageTransitionController.reset();

    // Update state with the new selected month
    setState(() {
      _selectedMonth = newMonth;
      _selectedYear = newMonth.year;
    });

    // Start animation
    _pageTransitionController.forward();

    _scoreAnimationController.reset();
    Future.delayed(Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create a text theme using Google Fonts
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FA),
        drawer: CustomDrawer(
          onMonthChanged: _handleMonthChange,
          selectedMonth: _selectedMonth,
          userJoinDate: widget.userJoinDate,
        ),
        body: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final monthlySummary = ref.watch(monthlySleepSummaryProvider);
              final monthlySleepData = ref.watch(MonthlyuniqueSleepDaysProvider);
              final activityMap = ref.watch(MonthlyactivityCalendarDataProvider);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Back button and drawer button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Sleep Tracking',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          InkWell(
                            onTap: _showMonthYearPicker,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width < 400 ? 8 : 16,
                                vertical: MediaQuery.of(context).size.width < 400 ? 6 : 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: MediaQuery.of(context).size.width < 400 ? 14 : 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(_selectedMonth),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: MediaQuery.of(context).size.width < 400 ? 14 : 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      MonthlySleepScoreCard(
                        isSmallScreen: MediaQuery.of(context).size.width < 400,
                        selectedMonth: _selectedMonth.month,
                        selectedYear: _selectedMonth.year,
                        scoreScaleAnimation: _scoreScaleAnimation,
                        scoreOpacityAnimation: _scoreOpacityAnimation,
                        scoreRotationAnimation: _scoreRotationAnimation,
                      ),

                      const SizedBox(height: 24),

                      // Calendar with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ActivityCalendar(
                            selectedMonth: _selectedMonth,
                            today: _today,
                            activityRegularity: activityMap,
                            userJoinedDate: widget.userJoinDate,
                            onMonthChanged: _handleMonthChange,
                            onDateSelected: _handleDateSelection,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sleep History Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sleep History',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Check if sleep history is empty
                      if (monthlySleepData.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              'No sleep records for this period',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),

                      // Sleep records list
                      Column(
                        children: _getFilteredSleepRecords(ref)
                            .map((sleep) => _buildSleepItem(sleep))
                            .toList(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSleepItem(Map<String, dynamic> sleep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM').format(sleep['date']).toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  sleep['day'].toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You slept for ${sleep['duration']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'No Suggestions',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sleep['quality'] == 'Deep'
                  ? Colors.grey.shade200
                  : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sleep['quality'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: sleep['quality'] == 'Deep'
                    ? Colors.grey.shade700
                    : Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
