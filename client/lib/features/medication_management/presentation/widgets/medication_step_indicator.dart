import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicationStepIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Color primaryColor;
  final Color borderColor;

  const MedicationStepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.primaryColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  State<MedicationStepIndicator> createState() => _MedicationStepIndicatorState();
}

class _MedicationStepIndicatorState extends State<MedicationStepIndicator> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getIconForStep(int step) {
    switch (step) {
      case 0:
        return Icons.medication;
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.date_range;
      case 3:
        return Icons.notifications;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.totalSteps, (index) {
          bool isActive = index <= widget.currentStep;
          bool isCurrent = index == widget.currentStep;

          return Row(
            children: [
              // Step circle
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: isCurrent ? 50.w : 40.w,
                height: isCurrent ? 50.w : 40.w,
                decoration: BoxDecoration(
                  color: isActive ? widget.primaryColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? widget.primaryColor : widget.borderColor,
                    width: 1.5.w,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isCurrent
                    ? AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Icon(
                              _getIconForStep(index),
                              color: Colors.white,
                              size: 24.r,
                            ),
                          );
                        },
                      )
                    : Icon(
                        isActive ? Icons.check : _getIconForStep(index),
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        size: 20.r,
                      ),
              ),

              // Connector line (except for last item)
              if (index < widget.totalSteps - 1)
                Container(
                  width: 30.w,
                  height: 2.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: index < widget.currentStep ? widget.primaryColor : widget.borderColor,
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
