import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../features/medication_management/presentation/pages/medication_management_add.dart';
import '../../features/medication_management/presentation/pages/medication_management_day.dart';
import '../../features/medication_management/presentation/providers/medication_monthly_provider.dart';
import '../../features/medication_management/data/models/monthly_medication_model.dart';

class MedicationSection extends ConsumerWidget {
  const MedicationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMonthYearProvider);
    final monthlyDataAsync = ref.watch(currentMonthlyMedicationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// **Title & See All**
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medication Management',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicationsManagementDay()),
                );
              },
              child: Text(
                'See All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// **White Card UI**
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: monthlyDataAsync.when(
            data: (monthlyData) => _buildMedicationContent(context, ref, selectedDate, monthlyData),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationContent(BuildContext context, WidgetRef ref, DateTime selectedDate, MonthlyMedicationModel monthlyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// **Top Section - Medication Count & Add Button**
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${monthlyData.summary.total}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Medications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const Spacer(),

            /// **Adherence Rate**
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${monthlyData.summary.adherenceRate}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _getAdherenceColor(double.tryParse(monthlyData.summary.adherenceRate) ?? 0),
                  ),
                ),
                Text(
                  'Adherence',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            /// **Add Button**
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationManagementAddPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        /// **Month Navigation**
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _changeMonth(ref, -1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () => _changeMonth(ref, 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        /// **Medication Calendar Grid**
        _buildCalendarGrid(selectedDate, monthlyData),
        const SizedBox(height: 16),

        /// **Summary Stats**
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem('Taken', monthlyData.summary.taken, const Color(0xFF10B981)),
            _buildSummaryItem('Missed', monthlyData.summary.missed, const Color(0xFFEF4444)),
            _buildSummaryItem('Total', monthlyData.summary.total, const Color(0xFF64748B)),
          ],
        ),
        const SizedBox(height: 16),

        /// **Legend**
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFF10B981), 'Taken'),
              const SizedBox(width: 24),
              _buildLegendItem(const Color(0xFFEF4444), 'Missed'),
              const SizedBox(width: 24),
              _buildLegendItem(const Color(0xFFFBBF24), 'Pending'),
              const SizedBox(width: 24),
              _buildLegendItem(const Color(0xFFE2E8F0), 'No Data'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading medication data...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.error_outline,
          color: const Color(0xFFEF4444),
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load medication data',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSummaryItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  void _changeMonth(WidgetRef ref, int monthChange) {
    final currentDate = ref.read(selectedMonthYearProvider);
    final newDate = DateTime(
      currentDate.year,
      currentDate.month + monthChange,
      1,
    );
    ref.read(selectedMonthYearProvider.notifier).state = newDate;
  }

  Color _getAdherenceColor(double adherenceRate) {
    if (adherenceRate >= 80) return const Color(0xFF10B981); // Green
    if (adherenceRate >= 60) return const Color(0xFFFBBF24); // Yellow
    return const Color(0xFFEF4444); // Red
  }

  /// **Calendar Grid**
  Widget _buildCalendarGrid(DateTime selectedDate, MonthlyMedicationModel monthlyData) {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Convert to 0-6 (Sunday = 0)

    // Create a map for quick lookup of medication data by day
    final Map<int, MedicationDayModel> dayDataMap = {};
    for (final dayData in monthlyData.days) {
      final date = DateTime.parse(dayData.date);
      dayDataMap[date.day] = dayData;
    }

    return Column(
      children: [
        // Week day headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 42, // 6 weeks * 7 days
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              // Empty cell for days outside current month
              return Container();
            }

            final dayData = dayDataMap[dayNumber];
            final color = _getDayColor(dayData);
            final isToday = _isToday(selectedDate.year, selectedDate.month, dayNumber);

            return GestureDetector(
              onTap: dayData != null ? () => _showDayDetails(context, dayData) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNumber.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(color),
                        ),
                      ),
                      if (dayData != null && dayData.total > 0)
                        Text(
                          '${dayData.taken}/${dayData.total}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor(color).withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getDayColor(MedicationDayModel? dayData) {
    if (dayData == null || dayData.total == 0) {
      return const Color(0xFFF8FAFC); // Very light gray for no data
    }

    switch (dayData.primaryStatus) {
      case MedicationDayStatus.taken:
        return const Color(0xFF10B981); // Green for fully taken
      case MedicationDayStatus.missed:
        return const Color(0xFFEF4444); // Red for missed
      case MedicationDayStatus.pending:
        return const Color(0xFFFBBF24); // Yellow for pending
      case MedicationDayStatus.partial:
        return const Color(0xFF8B5CF6); // Purple for partial
      default:
        return const Color(0xFFE2E8F0); // Light gray
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be dark or light
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  bool _isToday(int year, int month, int day) {
    final today = DateTime.now();
    return today.year == year && today.month == month && today.day == day;
  }

  void _showDayDetails(BuildContext context, MedicationDayModel dayData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.parse(dayData.date)),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailItem('Total', dayData.total, const Color(0xFF64748B)),
                _buildDetailItem('Taken', dayData.taken, const Color(0xFF10B981)),
                _buildDetailItem('Missed', dayData.missed, const Color(0xFFEF4444)),
                _buildDetailItem('Pending', dayData.pending, const Color(0xFFFBBF24)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Adherence Rate: ${dayData.adherenceRate}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getAdherenceColor(double.tryParse(dayData.adherenceRate) ?? 0),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  /// **Legend Row**
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
