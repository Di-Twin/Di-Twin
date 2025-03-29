import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  final Function(DateTime) onMonthChanged;
  final DateTime selectedMonth;
  final DateTime userJoinDate;

  const CustomDrawer({
    super.key,
    required this.onMonthChanged,
    required this.selectedMonth,
    required this.userJoinDate,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate available months (from join date to current)
    final now = DateTime.now();
    List<DateTime> availableMonths = [];
    
    DateTime startDate = DateTime(userJoinDate.year, userJoinDate.month, 1);
    DateTime endDate = DateTime(now.year, now.month, 1);
    
    while (startDate.isBefore(endDate) || (startDate.year == endDate.year && startDate.month == endDate.month)) {
      availableMonths.add(DateTime(startDate.year, startDate.month, 1));
      startDate = DateTime(startDate.year, startDate.month + 1, 1);
    }
    
    // Sort in descending order (newest first)
    availableMonths.sort((a, b) => b.compareTo(a));

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Calendar Options',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const Divider(),
            
            // Quick navigation options
            _buildSectionTitle('Quick Navigation'),
            _buildNavOption(
              context, 
              'Current Month', 
              Icons.today, 
              () => _selectMonth(context, DateTime(now.year, now.month, 1))
            ),
            _buildNavOption(
              context, 
              'Previous Month', 
              Icons.arrow_back, 
              () {
                final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
                if (!prevMonth.isBefore(DateTime(userJoinDate.year, userJoinDate.month, 1))) {
                  _selectMonth(context, prevMonth);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No data available before your join date'))
                  );
                }
              }
            ),
            _buildNavOption(
              context, 
              'Next Month', 
              Icons.arrow_forward, 
              () {
                final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
                if (!nextMonth.isAfter(DateTime(now.year, now.month, 1))) {
                  _selectMonth(context, nextMonth);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot navigate to future months'))
                  );
                }
              }
            ),
            
            const Divider(),
            
            // View options
            _buildSectionTitle('Calendar Views'),
            _buildNavOption(
              context, 
              'Monthly View', 
              Icons.calendar_month, 
              () => Navigator.pop(context)
            ),
            _buildNavOption(
              context, 
              'Weekly View', 
              Icons.view_week, 
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Weekly view coming soon!'))
                );
                Navigator.pop(context);
              }
            ),
            
            const Divider(),
            
            // Recent months
            _buildSectionTitle('Recent Months'),
            Expanded(
              child: ListView.builder(
                itemCount: Math.min(6, availableMonths.length),
                itemBuilder: (context, index) {
                  final month = availableMonths[index];
                  final isSelected = month.year == selectedMonth.year && 
                                    month.month == selectedMonth.month;
                  
                  return ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    title: Text(
                      '${_getMonthName(month.month)} ${month.year}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    onTap: () => _selectMonth(context, month),
                    selected: isSelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildNavOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(),
      ),
      onTap: onTap,
    );
  }

  void _selectMonth(BuildContext context, DateTime month) {
    onMonthChanged(month);
    Navigator.pop(context);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// Helper class for min function
class Math {
  static int min(int a, int b) {
    return a < b ? a : b;
  }
}