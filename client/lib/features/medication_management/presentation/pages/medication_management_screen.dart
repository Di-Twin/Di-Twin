import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/medication_management/presentation/providers/medication_api_provider.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_edit.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_add_step2.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';

class MedicationManagementListPage extends ConsumerStatefulWidget {
  const MedicationManagementListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationManagementListPage> createState() =>
      _MedicationManagementListPageState();
}

class _MedicationManagementListPageState
    extends ConsumerState<MedicationManagementListPage> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final userMedicationsAsync = ref.watch(userMedicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'My Medications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0F67FE),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      body: userMedicationsAsync.when(
        data: (medications) {
          if (medications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userMedicationsProvider);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                return _buildMedicationItem(medications[index]);
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F67FE)),
          ),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationPage(),
            ),
          );

          if (result == true) {
            // Refresh the list if a medication was added
            ref.invalidate(userMedicationsProvider);
          }
        },
        backgroundColor: const Color(0xFF0F67FE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No medications added yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to add your first medication',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load medications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(userMedicationsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F67FE),
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(ApiMedicationModel medication) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
                Icons.medication,
                color: const Color(0xFF0F67FE),
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
                  medication.medicationName,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF242E49),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${medication.dose} • ${medication.frequency}',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF6B7280),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  medication.timings.join(', '),
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (medication.reminder)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 12.sp,
                          color: const Color(0xFF0F67FE),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Reminders enabled',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F67FE),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_isEditMode)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: const Color(0xFF0F67FE),
                    size: 22.sp,
                  ),
                  onPressed: () => _editMedication(medication),
                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 22.sp),
                  onPressed: () => _deleteMedication(medication),
                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _editMedication(ApiMedicationModel medication) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationManagementEdit(medication: medication),
      ),
    );

    if (result == true) {
      // Refresh the list if medication was updated
      ref.invalidate(userMedicationsProvider);
    }
  }

  Future<void> _deleteMedication(ApiMedicationModel medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Medication',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete ${medication.medicationName}?',
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final actions = ref.read(medicationActionsProvider);
      final success = await actions.deleteMedication(medication.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medication deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // The provider will automatically refresh due to invalidation in the action
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete medication'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
