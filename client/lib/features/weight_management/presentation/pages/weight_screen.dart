import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/weight_providers.dart';
import '../controllers/weight_controller.dart';
import '../widgets/weight_chart_widget.dart';
import '../widgets/weight_input_dialog.dart';

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key});

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  final List<String> periods = ['Week', 'Month', '3 Month', '6 Month'];

  @override
  void initState() {
    super.initState();
    // Initialize the controller when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weightControllerInitProvider);
    });
  }

  void _showWeightPopup({bool isTargetAchieved = false}) {
    final controller = ref.read(weightControllerProvider.notifier);
    final state = ref.read(weightControllerProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WeightInputDialog(
        currentWeight: state.progress?.currentWeight,
        isTargetAchieved: isTargetAchieved,
        onWeightSaved: (weight) async {
          await controller.updateWeight(weight);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(weightControllerInitProvider);
    final state = ref.watch(weightControllerProvider);
    final controller = ref.read(weightControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: initAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0066FF)),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error loading weight data',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(weightControllerInitProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (_) => _buildWeightScreen(state, controller),
        ),
      ),
    );
  }

  Widget _buildWeightScreen(WeightState state, WeightController controller) {
    final progress = state.progress;

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await controller.loadWeightProgress();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header Section
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0066FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
            bottom: 20,
          ),
          child: Column(
            children: [
              // Navigation Bar
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Weight',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: state.isLoading ? null : () => _showWeightPopup(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Current Weight Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current Weight',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'BMI: N/A', // TODO: Implement BMI display
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Weight Value with Target Achievement Indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    progress?.currentWeight?.toStringAsFixed(2) ?? '--.--',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'kg',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (controller.isTargetAchieved())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Target Achieved!',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Time Period Selector
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: periods.map((period) {
              final isSelected = period == state.selectedPeriod;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await controller.loadWeightData(period);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E2B3C)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Weight Chart
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: WeightChartWidget(
              weightData: state.chartData,
              targetRange: progress?.targetRange,
              selectedPeriod: state.selectedPeriod,
              isLoading: state.isChartLoading,
            ),
          ),
        ),
        // Goals Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goals',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2B3C),
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 24),
            ],
          ),
        ),
        // Goal Cards
        Row(
          children: [
            Expanded(
              child: _buildGoalCard(
                title: 'Start Weight',
                value: progress?.startWeight?.toStringAsFixed(2) ?? '--.--',
                iconColor: Colors.purple.shade100,
                iconBgColor: Colors.purple.shade50,
                icon: Icons.folder,
              ),
            ),
            Expanded(
              child: _buildGoalCard(
                title: 'Target Range',
                value: progress?.targetRange?.toString() ?? '--.-- - --.--',
                iconColor: Colors.red.shade300,
                iconBgColor: Colors.red.shade50,
                icon: Icons.flag,
                isAchieved: controller.isTargetAchieved(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
    required IconData icon,
    bool isAchieved = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isAchieved ? Border.all(color: Colors.green, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isAchieved ? Colors.green.shade50 : iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAchieved ? Icons.emoji_events : icon,
                  color: isAchieved ? Colors.green : iconColor,
                  size: 24,
                ),
              ),
              if (isAchieved) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Achieved!',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title == 'Target Range' ? value : '$value kg',
            style: GoogleFonts.plusJakartaSans(
              fontSize: title == 'Target Range' ? 24 : 36,
              fontWeight: FontWeight.bold,
              color: isAchieved ? Colors.green : const Color(0xFF1E2B3C),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}