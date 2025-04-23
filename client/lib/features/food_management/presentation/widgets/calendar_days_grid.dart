import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarDaysGrid extends StatelessWidget {
  final DateTime selectedDate;
  final int selectedYear;
  final Function(DateTime) onDateSelected;
  
  const CalendarDaysGrid({
    super.key,
    required this.selectedDate,
    required this.selectedYear,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Get days in month
    final daysInMonth = DateTime(selectedYear, selectedDate.month + 1, 0).day;

    // Get first day of month
    final firstDayOfMonth = DateTime(selectedYear, selectedDate.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;

    // Adjust for Sunday start (1-7 to 0-6)
    final firstWeekdayAdjusted = (firstWeekdayOfMonth % 7);

    // Create list of day widgets
    List<Widget> dayWidgets = [];

    // Add weekday headers
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var weekday in weekdays) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            weekday,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    // Add empty spaces for days before first day of month
    for (var i = 0; i < firstWeekdayAdjusted; i++) {
      dayWidgets.add(Container());
    }

    // Add days of month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedYear, selectedDate.month, day);
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final isSelected =
          date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
      final isFutureDate = date.isAfter(DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: isFutureDate ? null : () => onDateSelected(date),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A73E8), Color(0xFF4D8EFF)],
                      )
                      : null,
              color: isToday && !isSelected ? Colors.grey.shade200 : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Color(0xFF1A73E8).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight:
                      isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected
                          ? Colors.white
                          : (isFutureDate
                              ? Colors.grey.shade400
                              : Color(0xFF1E293B)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }
}
