import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCalendar extends StatefulWidget {
  final DateTime selectedMonth;
  final DateTime today;
  final Map<int, bool> activityRegularity;
  final DateTime userJoinedDate;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected; // New callback function

  const ActivityCalendar({
    super.key,
    required this.selectedMonth,
    required this.today,
    required this.activityRegularity,
    required this.userJoinedDate,
    required this.onMonthChanged,
    required this.onDateSelected, // Add this
  });

  @override
  State<ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime _displayedMonth = DateTime.now();
  Offset _slideDirection = const Offset(
    1.0,
    0.0,
  ); // Default direction (right to left)

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.selectedMonth;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set up the fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Set up slide animation
    _slideAnimation = Tween<Offset>(
      begin: _slideDirection,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation when widget first builds
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ActivityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the month changed, trigger animation
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      // Determine slide direction based on month comparison
      if (widget.selectedMonth.isBefore(_displayedMonth)) {
        _slideDirection = const Offset(
          -1.0,
          0.0,
        ); // Right slide (newer to older)
      } else {
        _slideDirection = const Offset(1.0, 0.0); // Left slide (older to newer)
      }

      // Update the slide animation with new direction
      _slideAnimation = Tween<Offset>(
        begin: _slideDirection,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      // Reset to play the animation
      _animationController.reset();

      // Update the displayed month after animation starts
      setState(() {
        _displayedMonth = widget.selectedMonth;
      });

      // Run the animation
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16), // Add spacing before calendar
        // Calendar UI with animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildCalendar(context),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Legend
        // Centered Legend
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min, // Shrink to fit content
            mainAxisAlignment: MainAxisAlignment.center, // Center alignment
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Regular',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Irregular',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
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
    final daysFromPreviousMonth = firstDayOfWeek;
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
    final daysInMonth = lastDay.day;
    final daysFromNextMonth =
        (7 - ((daysFromPreviousMonth + daysInMonth) % 7)) % 7;

    final List<DateTime> daysToDisplay = [];
    bool showPreviousMonthDays = true;

    if (previousMonth.year < widget.userJoinedDate.year ||
        (previousMonth.year == widget.userJoinedDate.year &&
            previousMonth.month < widget.userJoinedDate.month - 1)) {
      showPreviousMonthDays = false;
    }

    if (showPreviousMonthDays) {
      for (int i = 0; i < daysFromPreviousMonth; i++) {
        daysToDisplay.add(
          DateTime(
            previousMonth.year,
            previousMonth.month,
            lastDayOfPreviousMonth.day - daysFromPreviousMonth + i + 1,
          ),
        );
      }
    } else {
      for (int i = 0; i < daysFromPreviousMonth; i++) {
        daysToDisplay.add(DateTime(0, 0, 0));
      }
    }

    for (int i = 1; i <= daysInMonth; i++) {
      daysToDisplay.add(
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month, i),
      );
    }

    for (int i = 1; i <= daysFromNextMonth; i++) {
      daysToDisplay.add(
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, i),
      );
    }

    return Column(
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

        // In _buildCalendar method, modify the GridView.builder section:
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: daysToDisplay.length,
          itemBuilder: (context, index) {
            final day = daysToDisplay[index];

            if (day.year == 0) {
              return Container(); // Empty placeholder
            }

            final isCurrentMonth = day.month == widget.selectedMonth.month;
            final isToday =
                day.year == widget.today.year &&
                day.month == widget.today.month &&
                day.day == widget.today.day;

            final isBeforeJoinDate =
                day.isBefore(widget.userJoinedDate) &&
                !(day.year == widget.userJoinedDate.year &&
                    day.month == widget.userJoinedDate.month &&
                    day.day == widget.userJoinedDate.day);

            final hasActivity =
                widget.activityRegularity.containsKey(day.day) &&
                isCurrentMonth &&
                !isBeforeJoinDate;
            final isRegular =
                hasActivity ? widget.activityRegularity[day.day]! : false;

            Color backgroundColor;
            Color textColor;

            if (!isCurrentMonth) {
              backgroundColor = Colors.transparent;
              textColor = Colors.grey.withOpacity(0.5);
            } else if (isBeforeJoinDate) {
              backgroundColor = Colors.transparent;
              textColor = Colors.grey.withOpacity(0.3);
            } else if (hasActivity) {
              backgroundColor =
                  isRegular ? Colors.blue : const Color(0xFF64748B);
              textColor = Colors.white;
            } else {
              backgroundColor = Colors.transparent;
              textColor = Colors.black;
            }

            // Remove the individual cell animations and use a simple widget
            return GestureDetector(
              onTap: () {
                widget.onDateSelected(day); // Pass the clicked date
              },
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
          },
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
