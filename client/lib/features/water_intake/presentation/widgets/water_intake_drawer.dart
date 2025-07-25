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
  late Animation<Offset> _slideAnimation;

  double _selectedAmount = 250.0;
  final TextEditingController _customAmountController = TextEditingController();
  bool _isCustomAmount = false;

  final List<double> _quickAmounts = [150, 250, 350, 500];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _customAmountController.dispose();
    super.dispose();
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
      case 'Lunch':
        return {
          'name': 'Lunch Time',
          'time': '11:00 AM - 2:00 PM',
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
          'time': '6:00 - 9:00 PM',
          'color': const Color(0xFF8B5CF6),
          'icon': '🌙',
          'message': 'Wind down with some hydration!',
        };
      default:
        return {
          'name': 'Hydration Time',
          'time': 'Now',
          'color': const Color(0xFF06B6D4),
          'icon': '💧',
          'message': 'Time to hydrate!',
        };
    }
  }

  Future<void> _submitWaterIntake() async {
    final waterProvider = Provider.of<WaterIntakeProvider>(context, listen: false);

    final amount = _isCustomAmount
        ? double.tryParse(_customAmountController.text) ?? 0
        : _selectedAmount;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await waterProvider.addWaterIntake(amount, slot: widget.currentSlot);

    if (success) {
      widget.onWaterAdded(amount);
      widget.onClose();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add water intake. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotInfo = _getSlotInfo();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header with gradient
            Container(
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.all(20.w),
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
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: slotInfo['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        slotInfo['icon'],
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slotInfo['name'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          slotInfo['time'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          slotInfo['message'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
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

            // Amount selection
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How much water did you drink?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Quick amount buttons
                    if (!_isCustomAmount) ...[
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: _quickAmounts.map((amount) {
                          final isSelected = _selectedAmount == amount;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAmount = amount;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? slotInfo['color']
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected
                                      ? slotInfo['color']
                                      : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${amount.toInt()}ml',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.h),

                      // Custom amount toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCustomAmount = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16.sp,
                                color: const Color(0xFF64748B),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Enter custom amount',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Custom amount input
                    if (_isCustomAmount) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custom Amount (ml)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: _customAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter amount in ml',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                    color: slotInfo['color'],
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCustomAmount = false;
                                  _customAmountController.clear();
                                });
                              },
                              child: Text(
                                'Back to quick amounts',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: slotInfo['color'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<WaterIntakeProvider>(
                      builder: (context, waterProvider, child) {
                        return ElevatedButton(
                          onPressed: waterProvider.isSubmitting
                              ? null
                              : _submitWaterIntake,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: slotInfo['color'],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: waterProvider.isSubmitting
                              ? SizedBox(
                            width: 20.w,
                            height: 20.w,
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
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
