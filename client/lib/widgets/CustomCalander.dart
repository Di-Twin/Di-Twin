import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCalendar extends StatefulWidget {
  final DateTime selectedMonth;
  final DateTime today;
  final Map<int, bool> activityRegularity;
  final DateTime userJoinedDate;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;

  final double? width;
  final double? height;
  final double? cellSize;
  final double? horizontalPadding;
  final double? verticalPadding;

  const ActivityCalendar({
    Key? key,
    required this.selectedMonth,
    required this.today,
    required this.activityRegularity,
    required this.userJoinedDate,
    required this.onMonthChanged,
    required this.onDateSelected, this.width, this.height, this.cellSize, this.horizontalPadding, this.verticalPadding,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.selectedMonth;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeInOut
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOut
      ),
    );

    _animationController.forward();
  }

  void _updateAnimationDirection(DateTime oldMonth) {
    _slideDirection = widget.selectedMonth.isBefore(oldMonth)
        ? const Offset(-1.0, 0.0)  // Right slide (newer to older)
        : const Offset(1.0, 0.0);  // Left slide (older to newer)

    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOut
      ),
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
      daysToDisplay.addAll(
        List.filled(firstDayOfWeek, DateTime(0, 0, 0))
      );
    }

    // Current month days
    for (int i = 1; i <= lastDay.day; i++) {
      daysToDisplay.add(
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month, i),
      );
    }

    // Next month days
    final daysFromNextMonth = 
      (7 - ((firstDayOfWeek + lastDay.day) % 7)) % 7;
    for (int i = 1; i <= daysFromNextMonth; i++) {
      daysToDisplay.add(
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, i),
      );
    }

    return daysToDisplay;
  }

  Color _determineBackgroundColor(DateTime day) {
    final isCurrentMonth = day.month == widget.selectedMonth.month;
    final isBeforeJoinDate = 
      day.isBefore(widget.userJoinedDate) &&
      !(day.year == widget.userJoinedDate.year &&
        day.month == widget.userJoinedDate.month &&
        day.day == widget.userJoinedDate.day);

    final hasActivity = 
      widget.activityRegularity.containsKey(day.day) &&
      isCurrentMonth && 
      !isBeforeJoinDate;

    if (!isCurrentMonth) return Colors.transparent;
    if (isBeforeJoinDate) return Colors.transparent;
    if (hasActivity) {
      return widget.activityRegularity[day.day]! 
        ? Colors.blue 
        : const Color(0xFF64748B);
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
    final isToday = 
      day.year == widget.today.year &&
      day.month == widget.today.month &&
      day.day == widget.today.day;

    if (!isCurrentMonth) return Colors.grey.withOpacity(0.5);
    if (isBeforeJoinDate) return Colors.grey.withOpacity(0.3);
    return isToday ? Colors.white : Colors.black;
  }

  Widget _buildCalendarGrid() {
    final days = _generateCalendarDays();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];

        if (day.year == 0) return Container();

        return _buildCalendarCell(day);
      },
    );
  }

  Widget _buildCalendarCell(DateTime day) {
    final backgroundColor = _determineBackgroundColor(day);
    final textColor = _determineTextColor(day);
    final isToday = 
      day.year == widget.today.year &&
      day.month == widget.today.month &&
      day.day == widget.today.day;

    return GestureDetector(
      onTap: () => widget.onDateSelected(day),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
                Row(
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
                const SizedBox(height: 8),
                _buildCalendarGrid(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayOfWeekHeader extends StatelessWidget {
  final String day;

  const _DayOfWeekHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}