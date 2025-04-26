import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomDateNavigation extends StatefulWidget {
  final DateTime selectedDate;
  final bool isCurrentDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CustomDateNavigation({
    Key? key,
    required this.selectedDate,
    required this.isCurrentDate,
    required this.onDateSelected,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  State<CustomDateNavigation> createState() => _CustomDateNavigationState();
}

class _CustomDateNavigationState extends State<CustomDateNavigation>
    with SingleTickerProviderStateMixin {
  // Calendar animation
  late AnimationController _animationController;
  late Animation<double> _calendarAnimation;
  bool _isCalendarVisible = false;
  
  // For date formatting
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _calendarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
      if (_isCalendarVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      
      widget.onDateSelected(selectedDay);
      
      // Close calendar after selection
      _toggleCalendar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('EEEE, d MMMM').format(widget.selectedDate);
    
    // Split the date string into parts to make day bold
    final List<String> dateParts = dateString.split(', ');
    final String dayOfWeek = dateParts[0]; // "Monday"
    final List<String> dayAndMonth = dateParts[1].split(' '); // ["15", "April"]
    final String day = dayAndMonth[0]; // "15"
    final String month = dayAndMonth[1]; // "April"
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date navigation bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous day button
              IconButton(
                onPressed: widget.onPrevious,
                icon: const Icon(Icons.chevron_left, size: 28),
                color: const Color(0xFF1E293B),
              ),
              
              // Date display with tap to show calendar
              GestureDetector(
                onTap: _toggleCalendar,
                child: Row(
                  children: [
                    Text(
                      day,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700, // Bold day
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      " $month",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _calendarAnimation.value * 3.14159,
                          child: child,
                        );
                      },
                      child: Icon(
                        _isCalendarVisible 
                            ? Icons.keyboard_arrow_up 
                            : Icons.calendar_today_outlined,
                        size: 16,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Next day button (gray when on current day)
              IconButton(
                onPressed: widget.isCurrentDate ? null : widget.onNext,
                icon: const Icon(Icons.chevron_right, size: 28),
                color: widget.isCurrentDate 
                    ? Colors.grey.withOpacity(0.5) 
                    : const Color(0xFF1E293B),
              ),
            ],
          ),
        ),
        
        // Calendar section that slides up/down
        ClipRect(
          child: SizeTransition(
            sizeFactor: _calendarAnimation,
            axis: Axis.vertical,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calendar title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Select Date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  
                  // Calendar widget
                  TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: _onDaySelected,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  
                  // Done button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _toggleCalendar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}