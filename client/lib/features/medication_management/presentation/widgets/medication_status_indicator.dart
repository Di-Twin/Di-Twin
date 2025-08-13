import 'package:client/features/medication_management/presentation/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicationStatusIndicator extends StatelessWidget {
  final MedicationStatus status;
  final bool isSelected;
  final Color accentColor;
  final Color errorColor;

  const MedicationStatusIndicator({
    super.key,
    required this.status,
    required this.isSelected,
    required this.accentColor,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MedicationStatus.complete:
        return Icon(
          Icons.check_circle,
          color: isSelected ? Colors.white : accentColor,
          size: 18.sp, // Increased size
        );
      case MedicationStatus.partial:
        return Icon(
          Icons.timelapse,
          color: isSelected ? Colors.white : Colors.orange,
          size: 18.sp, // Increased size
        );
      case MedicationStatus.incomplete:
        return Icon(
          Icons.cancel,
          color: isSelected ? Colors.white : errorColor,
          size: 18.sp,
        );
      case MedicationStatus.none:
      default:
        return SizedBox(
          height: 18.sp,
          width: 18.sp,
        ); // Empty space to maintain layout
    }
  }
}
