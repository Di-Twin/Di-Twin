import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCalendar extends StatefulWidget {
  final DateTime selectedMonth;
  final DateTime today;
  final Map<int, bool> activityRegularity;
  final DateTime userJoinedDate;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  final double? width;
  final double? height;
  final double? cellSize;
  final double? horizontalPadding;
  final double? verticalPadding;

  const ActivityCalendar({
    super.key,
    required this.selectedMonth,
    required this.today,
    required this.activityRegularity,
    required this.userJoinedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
    this.width,
    this.height,
    this.cellSize,
    this.horizontalPadding,
    this.verticalPadding,
    this.selectedDate,
  });

  @override
  State<ActivityCalendar> createState() => ActivityCalendarState();
}

class ActivityCalendarState extends State<ActivityCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime _displayedMonth = DateTime.now();
  Offset _slideDirection = const Offset(1.0, 0.0);
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.selectedMonth;
    _selectedDate = widget.selectedDate ?? widget.today;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _updateAnimationDirection(DateTime oldMonth) {
    _slideDirection =
        widget.selectedMonth.isBefore(oldMonth)
            ? const Offset(-1.0, 0.0) // Right slide (newer to older)
            : const Offset(1.0, 0.0); // Left slide (older to newer)

    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ActivityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _updateAnimationDirection(oldWidget.selectedMonth);
      _animationController.reset();

      setState(() {
        _displayedMonth = widget.selectedMonth;
      });

      _animationController.forward();
    }

    if (widget.selectedDate != null && widget.selectedDate != _selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<DateTime> _generateCalendarDays() {
    final firstDay = DateTime(
      widget.selectedMonth.year,
      widget.selectedMonth.month,
      1,
    );
    final lastDay = DateTime(
      widget.selectedMonth.year,
      widget.selectedMonth.month + 1,
      0,
    );
    final firstDayOfWeek = firstDay.weekday % 7;
    final previousMonth = DateTime(
      widget.selectedMonth.year,
      widget.selectedMonth.month - 1,
      1,
    );
    final lastDayOfPreviousMonth = DateTime(
      widget.selectedMonth.year,
      widget.selectedMonth.month,
      0,
    );

    final List<DateTime> daysToDisplay = [];
    final bool showPreviousMonthDays =
        !(previousMonth.year < widget.userJoinedDate.year ||
            (previousMonth.year == widget.userJoinedDate.year &&
                previousMonth.month < widget.userJoinedDate.month - 1));

    // Previous month days
    if (showPreviousMonthDays) {
      for (int i = 0; i < firstDayOfWeek; i++) {
        daysToDisplay.add(
          DateTime(
            previousMonth.year,
            previousMonth.month,
            lastDayOfPreviousMonth.day - firstDayOfWeek + i + 1,
          ),
        );
      }
    } else {
      daysToDisplay.addAll(List.filled(firstDayOfWeek, DateTime(0, 0, 0)));
    }

    // Current month days
    for (int i = 1; i <= lastDay.day; i++) {
      daysToDisplay.add(
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month, i),
      );
    }

    // Next month days
    final daysFromNextMonth = (7 - ((firstDayOfWeek + lastDay.day) % 7)) % 7;
    for (int i = 1; i <= daysFromNextMonth; i++) {
      daysToDisplay.add(
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, i),
      );
    }

    return daysToDisplay;
  }

  bool _isFutureDate(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(day.year, day.month, day.day);
    return checkDate.isAfter(today);
  }

  Color _determineBackgroundColor(DateTime day) {
    final isCurrentMonth = day.month == widget.selectedMonth.month;
    final isBeforeJoinDate =
        day.isBefore(widget.userJoinedDate) &&
        !(day.year == widget.userJoinedDate.year &&
            day.month == widget.userJoinedDate.month &&
            day.day == widget.userJoinedDate.day);
    final isFuture = _isFutureDate(day);
    final isToday =
        day.year == widget.today.year &&
        day.month == widget.today.month &&
        day.day == widget.today.day;

    final hasActivity =
        widget.activityRegularity.containsKey(day.day) &&
        isCurrentMonth &&
        !isBeforeJoinDate &&
        !isFuture;

    final isSelected =
        _selectedDate != null &&
        day.year == _selectedDate!.year &&
        day.month == _selectedDate!.month &&
        day.day == _selectedDate!.day;

    if (!isCurrentMonth) return Colors.grey.shade50;
    if (isBeforeJoinDate) return Colors.transparent;
    if (isFuture) return Colors.transparent;
    if (isSelected) return Color(0xFF0F67FE);
    if (isToday && !isSelected) return Color(0xFFE6F0FF);
    if (hasActivity) {
      return widget.activityRegularity[day.day]!
          ? Color(0xFF0F67FE).withOpacity(0.8)
          : Color(0xFF64748B);
    }
    return Colors.transparent;
  }

  Color _determineTextColor(DateTime day) {
    final isCurrentMonth = day.month == widget.selectedMonth.month;
    final isBeforeJoinDate =
        day.isBefore(widget.userJoinedDate) &&
        !(day.year == widget.userJoinedDate.year &&
            day.month == widget.userJoinedDate.month &&
            day.day == widget.userJoinedDate.day);
    final isFuture = _isFutureDate(day);
    final isToday =
        day.year == widget.today.year &&
        day.month == widget.today.month &&
        day.day == widget.today.day;

    final isSelected =
        _selectedDate != null &&
        day.year == _selectedDate!.year &&
        day.month == _selectedDate!.month &&
        day.day == _selectedDate!.day;

    final hasActivity =
        widget.activityRegularity.containsKey(day.day) &&
        isCurrentMonth &&
        !isBeforeJoinDate &&
        !isFuture;

    if (!isCurrentMonth) return Color(0xFFA0AEC0).withOpacity(0.5);
    if (isBeforeJoinDate) return Color(0xFFA0AEC0).withOpacity(0.5);
    if (isFuture) return Color(0xFFA0AEC0);
    if (isSelected || (hasActivity && isCurrentMonth)) return Colors.white;
    return Color(0xFF1E293B);
  }

  Widget _buildCalendarGrid() {
    final days = _generateCalendarDays();
    final cellSize = widget.cellSize ?? 40.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];

        if (day.year == 0) return Container();

        return _buildCalendarCell(day, cellSize);
      },
    );
  }

  Widget _buildCalendarCell(DateTime day, double cellSize) {
    final backgroundColor = _determineBackgroundColor(day);
    final textColor = _determineTextColor(day);
    final isCurrentMonth = day.month == widget.selectedMonth.month;
    final isFuture = _isFutureDate(day);
    final isToday =
        day.year == widget.today.year &&
        day.month == widget.today.month &&
        day.day == widget.today.day;

    final isSelected =
        _selectedDate != null &&
        day.year == _selectedDate!.year &&
        day.month == _selectedDate!.month &&
        day.day == _selectedDate!.day;

    return GestureDetector(
      onTap: () {
        if (isFuture) return; // Don't allow future date selection

        if (!isCurrentMonth) {
          // If clicking on previous or next month date, navigate to that month
          final newMonth = DateTime(day.year, day.month, 1);
          widget.onMonthChanged(newMonth);

          // Also select the date
          setState(() {
            _selectedDate = day;
          });
          widget.onDateSelected(day);
          return;
        }

        setState(() {
          _selectedDate = day;
        });
        widget.onDateSelected(day);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border:
              isToday ? Border.all(color: Color(0xFF0F67FE), width: 2) : null,
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Color(0xFF0F67FE).withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 14,
              fontWeight:
                  isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Day of week headers
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DayOfWeekHeader('S'),
                      _DayOfWeekHeader('M'),
                      _DayOfWeekHeader('T'),
                      _DayOfWeekHeader('W'),
                      _DayOfWeekHeader('T'),
                      _DayOfWeekHeader('F'),
                      _DayOfWeekHeader('S'),
                    ],
                  ),
                ),

                // Calendar grid
                _buildCalendarGrid(),

                // Legend
                Container(
                  margin: EdgeInsets.only(top: 24, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Color(0xFF0F67FE), 'Regular'),
                      SizedBox(width: 24),
                      _buildLegendItem(Color(0xFF64748B), 'Irregular'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DayOfWeekHeader extends StatelessWidget {
  final String day;

  const _DayOfWeekHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
