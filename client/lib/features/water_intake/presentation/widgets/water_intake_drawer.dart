import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/providers/water_intake_provider.dart';

class WaterIntakeDrawer extends StatefulWidget {
  final String currentSlot;
  final VoidCallback onClose;
  final Function(double) onWaterAdded;

  const WaterIntakeDrawer({
    super.key,
    required this.currentSlot,
    required this.onClose,
    required this.onWaterAdded,
  });

  @override
  State<WaterIntakeDrawer> createState() => _WaterIntakeDrawerState();
}

class _WaterIntakeDrawerState extends State<WaterIntakeDrawer> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _dragController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _dragAnimation;

  double _selectedAmount = 250.0;
  bool _isCustomAmount = false;
  bool _isSubmitting = false;

  // Drag variables
  double _dragOffset = 0.0;
  bool _isDragging = false;
  final double _dragThreshold = 100.0;

  final List<double> _quickAmounts = [150, 250, 350, 500];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dragController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _dragAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = 0.0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    setState(() {
      _isDragging = false;
    });

    if (_dragOffset > _dragThreshold) {
      _showCloseConfirmation();
    } else {
      _dragController.forward().then((_) {
        setState(() {
          _dragOffset = 0.0;
        });
        _dragController.reset();
      });
    }
  }

  void _showCloseConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                SizedBox(height: 24.h),

                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 32.sp,
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  'Skip Hydration?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Are you sure you want to skip your hydration reminder?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: const Color(0xFF10B981),
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Staying hydrated helps maintain your energy and focus throughout the day.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _closeDrawer();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Skip for Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _dragOffset = 0.0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Stay & Hydrate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  void _closeDrawer() {
    _slideController.reverse().then((_) {
      widget.onClose();
    });
  }

  Map<String, dynamic> _getSlotInfo() {
    switch (widget.currentSlot) {
      case 'Morning':
        return {
          'name': 'Morning Hydration',
          'time': '6:00 - 10:00 AM',
          'color': const Color(0xFF3B82F6),
          'icon': '🌅',
          'message': 'Start your day with proper hydration!',
        };
      case 'Mid-Morning':
        return {
          'name': 'Mid-Morning Boost',
          'time': '10:00 - 12:00 PM',
          'color': const Color(0xFF06B6D4),
          'icon': '☕',
          'message': 'Keep your energy levels up!',
        };
      case 'Lunch':
        return {
          'name': 'Lunch Time',
          'time': '12:00 - 2:00 PM',
          'color': const Color(0xFF10B981),
          'icon': '🍽️',
          'message': 'Stay hydrated during your meal time!',
        };
      case 'Afternoon':
        return {
          'name': 'Afternoon Boost',
          'time': '2:00 - 6:00 PM',
          'color': const Color(0xFFF59E0B),
          'icon': '☀️',
          'message': 'Beat the afternoon slump with water!',
        };
      case 'Evening':
        return {
          'name': 'Evening Wind Down',
          'time': '6:00 - 10:00 PM',
          'color': const Color(0xFF8B5CF6),
          'icon': '🌙',
          'message': 'Wind down with some hydration!',
        };
      default:
        return {
          'name': 'Hydration Reminder',
          'time': 'Now',
          'color': const Color(0xFF06B6D4),
          'icon': '💧',
          'message': 'Time to hydrate!',
        };
    }
  }

  Future<void> _submitWaterIntake() async {
    if (_isSubmitting) return;

    final waterProvider = Provider.of<WaterIntakeProvider>(context, listen: false);
    final amount = _selectedAmount;

    if (amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await waterProvider.addWaterIntake(amount, slot: widget.currentSlot);

      if (success) {
        widget.onWaterAdded(amount);
        _showSuccessAnimation(amount);

        await Future.delayed(const Duration(milliseconds: 1500));
        _closeDrawer();
      } else {
        _showErrorSnackBar('Failed to add water intake. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessAnimation(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Great job! 🎉',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${amount.toInt()}ml logged successfully',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildQuickOption(String label, double value) {
    final isSelected = _selectedAmount == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotInfo = _getSlotInfo();

    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height + _dragOffset,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5, // Reduced from 0.6
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: _isDragging
                                ? slotInfo['color'].withOpacity(0.6)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        if (_isDragging && _dragOffset > 20)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              _dragOffset > _dragThreshold
                                  ? 'Release to skip'
                                  : 'Drag down to skip',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: _dragOffset > _dragThreshold
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Header - more compact
                  Container(
                    margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          slotInfo['color'].withOpacity(0.1),
                          slotInfo['color'].withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: slotInfo['color'].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: slotInfo['color'].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              slotInfo['icon'],
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slotInfo['name'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                slotInfo['message'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: slotInfo['color'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content area
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How much water did you drink?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Amount display similar to goal setting
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '${_selectedAmount.toInt()}ml',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w800,
                                    color: slotInfo['color'],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${(_selectedAmount / 250).toStringAsFixed(1)} glasses',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Slider similar to goal setting
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: slotInfo['color'],
                              inactiveTrackColor: const Color(0xFFE5E7EB),
                              thumbColor: slotInfo['color'],
                              overlayColor: slotInfo['color'].withOpacity(0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                            ),
                            child: Slider(
                              value: _selectedAmount,
                              min: 50,
                              max: 1000,
                              divisions: 19,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAmount = value;
                                });
                              },
                            ),
                          ),

                          // Quick options similar to goal setting
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickOption('150ml', 150),
                              _buildQuickOption('250ml', 250),
                              _buildQuickOption('350ml', 350),
                              _buildQuickOption('500ml', 500),
                            ],
                          ),

                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _showCloseConfirmation,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitWaterIntake,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: slotInfo['color'],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              'Add Water Intake',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
