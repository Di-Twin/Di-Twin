import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SleepMonthYearPicker extends StatefulWidget {
  final DateTime selectedMonth;
  final int selectedYear;
  final List<int> availableYears;
  final List<DateTime> availableMonths;
  final DateTime today;
  final DateTime userJoinDate;
  final Function(DateTime) onApply;

  const SleepMonthYearPicker({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.availableYears,
    required this.availableMonths,
    required this.today,
    required this.userJoinDate,
    required this.onApply,
  });

  @override
  State<SleepMonthYearPicker> createState() => _SleepMonthYearPickerState();
}

class _SleepMonthYearPickerState extends State<SleepMonthYearPicker> {
  late int _selectedYear;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedYear;
    _selectedMonth = widget.selectedMonth;
  }

  // Helper method to check if a month is available
  bool _isMonthAvailable(DateTime monthDate) {
    // Month should be after or same as join date
    bool isAfterJoinDate = !monthDate.isBefore(
      DateTime(widget.userJoinDate.year, widget.userJoinDate.month, 1),
    );

    // Month should not be in the future
    bool isNotInFuture = !monthDate.isAfter(
      DateTime(widget.today.year, widget.today.month, 1),
    );

    return isAfterJoinDate && isNotInFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle and header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Title with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Month & Year',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current selection display
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF06B6D4).withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.nightlight_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMMM').format(_selectedMonth),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _selectedYear.toString(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Year selector
                  Text(
                    'Year',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Improved year selector with animation
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.availableYears.length,
                      itemBuilder: (context, index) {
                        final year = widget.availableYears[index];
                        final isSelected = year == _selectedYear;
                        final isFutureYear = year > widget.today.year;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF06B6D4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: Color(0xFF06B6D4).withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isFutureYear
                                    ? null
                                    : () {
                                  setState(() {
                                    _selectedYear = year;

                                    // Get months available in the selected year
                                    List<DateTime> monthsInYear =
                                    widget.availableMonths
                                        .where(
                                          (month) => month.year == year,
                                    )
                                        .toList();

                                    if (monthsInYear.isNotEmpty) {
                                      // If current year, default to current month; otherwise, use first available
                                      _selectedMonth = (year == widget.today.year)
                                          ? DateTime(
                                        year,
                                        widget.today.month,
                                        1,
                                      )
                                          : monthsInYear.first;
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Center(
                                  child: Text(
                                    year.toString(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (isFutureYear
                                          ? Colors.grey.shade400
                                          : Color(0xFF1E293B)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24),

                  // Month selector
                  Text(
                    'Month',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Improved month selector with animation
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final monthDate = DateTime(
                          _selectedYear,
                          monthNum,
                          1,
                        );
                        final monthName = DateFormat('MMM').format(monthDate);

                        // Check if the month should be disabled
                        bool isAvailable = _isMonthAvailable(monthDate);
                        bool isSelected = _selectedMonth.month == monthNum &&
                            _selectedMonth.year == _selectedYear;

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                              colors: [
                                Color(0xFF06B6D4),
                                Color(0xFF0891B2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            color: isSelected
                                ? null
                                : (isAvailable
                                ? Colors.white
                                : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Color(0xFF06B6D4).withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ]
                                : null,
                            border: !isSelected && isAvailable
                                ? Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            )
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: isAvailable
                                  ? () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedYear,
                                    monthNum,
                                    1,
                                  );
                                });
                              }
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    monthName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (isAvailable
                                          ? Color(0xFF1E293B)
                                          : Colors.grey.shade400),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF06B6D4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onApply(_selectedMonth);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Apply Selection',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
