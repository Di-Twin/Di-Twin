import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:client/features/medication_management/presentation/providers/medication_provider.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MedicationListPage extends StatefulWidget {
  final bool isEditMode;
  final Function(Medication)? onEdit;
  final Function(Medication)? onDelete;

  const MedicationListPage({
    super.key,
    this.isEditMode = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      if (provider.currentMedicationSchedule.isEmpty) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Medications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.isEditMode)
            IconButton(
              icon: Icon(Icons.add, size: 24.sp),
              onPressed: () {
                // Navigate to add medication page
                Navigator.pushNamed(context, '/add-medication');
              },
            ),
        ],
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                'Error: ${provider.errorMessage}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // Group medications by date
          final groupedMedications = _groupMedicationsByDate(provider);

          if (groupedMedications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: groupedMedications.length,
            itemBuilder: (context, index) {
              final date = groupedMedications.keys.elementAt(index);
              final medications = groupedMedications[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Text(
                      _formatDate(date),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: medications.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final medication = medications[index].medication;
                        final timeSlot = medications[index].timeSlot;
                        
                        return MedicationListItem(
                          medication: medication,
                          timing: timeSlot,
                          isEditMode: widget.isEditMode,
                          onEdit: widget.onEdit,
                          onDelete: widget.onDelete,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: !widget.isEditMode
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add medication page
                Navigator.pushNamed(context, '/add-medication');
              },
              child: const Icon(Icons.add),
            )
          : null,
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
            'No medications found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first medication to get started',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add medication page
              Navigator.pushNamed(context, '/add-medication');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Medication'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<MedicationWithTimeSlot>> _groupMedicationsByDate(MedicationProvider provider) {
    final Map<String, List<MedicationWithTimeSlot>> groupedMedications = {};

    // Get all medication schedules
    final schedules = provider.dateRange.map((date) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final status = provider.getMedicationStatusForDate(date);
      if (status == MedicationStatus.none) {
        return null;
      }
      
      // This is a placeholder. In a real implementation, you would fetch the actual schedule
      // for this date from the provider.
      return MedicationSchedule(date: dateStr, timeSlots: []);
    }).whereType<MedicationSchedule>().toList();

    // For each schedule, extract medications and group by date
    for (final schedule in schedules) {
      final medications = <MedicationWithTimeSlot>[];
      
      for (final timeSlot in schedule.timeSlots) {
        for (final medication in timeSlot.medications) {
          medications.add(
            MedicationWithTimeSlot(
              medication: medication,
              timeSlot: timeSlot.displayTime,
            ),
          );
        }
      }
      
      if (medications.isNotEmpty) {
        groupedMedications[schedule.date] = medications;
      }
    }

    return groupedMedications;
  }

  String _formatDate(String dateStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }
}

class MedicationWithTimeSlot {
  final Medication medication;
  final String timeSlot;

  MedicationWithTimeSlot({
    required this.medication,
    required this.timeSlot,
  });
}
