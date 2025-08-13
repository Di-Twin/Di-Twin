import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickDateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  
  const QuickDateButton({
    super.key,
    required this.label,
    required this.date,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;

    return Expanded(
      child: ElevatedButton(
        onPressed: () => onDateSelected(date),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xFF1A73E8) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Color(0xFF1E293B),
          elevation: isSelected ? 2 : 0,
          shadowColor:
              isSelected
                  ? Color(0xFF1A73E8).withOpacity(0.3)
                  : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
