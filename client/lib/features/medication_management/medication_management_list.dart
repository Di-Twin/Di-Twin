import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationsList extends StatelessWidget {
  final List<Medication> medications;
  final bool isEditMode;
  final Function(Medication)? onEdit;
  final Function(Medication)? onDelete;

  const MedicationsList({
    super.key,
    required this.medications,
    this.isEditMode = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medications.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _MedicationItem(
                medication: medications[index],
                isEditMode: isEditMode,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
          ),
        ],
      ),
    );
  }
}

class Medication {
  final String name;
  final String timing;

  const Medication({required this.name, required this.timing});
}

class _MedicationItem extends StatelessWidget {
  final Medication medication;
  final bool isEditMode;
  final Function(Medication)? onEdit;
  final Function(Medication)? onDelete;

  const _MedicationItem({
    required this.medication,
    required this.isEditMode,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F67FE).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.medical_services_outlined,
                color: Colors.black,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF242E49),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  medication.timing,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF6B7280),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isEditMode)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: const Color(0xFF0F67FE),
                    size: 22.sp,
                  ),
                  onPressed: onEdit != null ? () => onEdit!(medication) : null,
                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red, size: 22.sp),
                  onPressed:
                      onDelete != null ? () => onDelete!(medication) : null,
                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
