import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EditMealTimeSheet extends StatefulWidget {
  final String mealType;
  final String currentTimeRange;
  final Function(String, String) onSave;

  const EditMealTimeSheet({
    super.key,
    required this.mealType,
    required this.currentTimeRange,
    required this.onSave,
  });

  @override
  State<EditMealTimeSheet> createState() => _EditMealTimeSheetState();
}

class _EditMealTimeSheetState extends State<EditMealTimeSheet> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    
    // Parse the current time range
    if (widget.currentTimeRange.contains('-')) {
      final parts = widget.currentTimeRange.split('-');
      _startTime = _parseTimeString(parts[0].trim());
      _endTime = _parseTimeString(parts[1].trim());
    } else {
      // Default times if parsing fails
      _startTime = TimeOfDay(hour: 8, minute: 0);
      _endTime = TimeOfDay(hour: 10, minute: 0);
    }
  }

  // Parse time string like "08:00" to TimeOfDay
  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      // Default time if parsing fails
      return TimeOfDay(hour: 8, minute: 0);
    }
  }

  // Format TimeOfDay to string like "08:00"
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Select start time
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        
        // Ensure end time is after start time
        if (_endTime.hour < _startTime.hour || 
            (_endTime.hour == _startTime.hour && _endTime.minute < _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 2,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  // Select end time
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        
        // Ensure start time is before end time
        if (_startTime.hour > _endTime.hour || 
            (_startTime.hour == _endTime.hour && _startTime.minute > _endTime.minute)) {
          _startTime = TimeOfDay(
            hour: _endTime.hour - 2,
            minute: _endTime.minute,
          );
        }
      });
    }
  }

  // Save the time range
  void _saveTimeRange() {
    final newTimeRange = '${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}';
    widget.onSave(widget.mealType, newTimeRange);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)} Time',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          Divider(color: Color(0xFFE2E8F0)),

          // Time selection
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Time Range',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Start time selector
                InkWell(
                  onTap: _selectStartTime,
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Start Time',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatTimeOfDay(_startTime),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F67FE),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.access_time,
                              color: Color(0xFF0F67FE),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // End time selector
                InkWell(
                  onTap: _selectEndTime,
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'End Time',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatTimeOfDay(_endTime),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F67FE),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.access_time,
                              color: Color(0xFF0F67FE),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          // Save button
          Padding(
            padding: EdgeInsets.all(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _saveTimeRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
