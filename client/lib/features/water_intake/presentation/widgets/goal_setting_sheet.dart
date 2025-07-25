import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/providers/water_intake_provider.dart';

class GoalSettingSheet extends StatefulWidget {
  const GoalSettingSheet({super.key});

  @override
  State<GoalSettingSheet> createState() => _GoalSettingSheetState();
}

class _GoalSettingSheetState extends State<GoalSettingSheet> {
  double _selectedGoal = 2000;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WaterIntakeProvider>();
    _selectedGoal = provider.todayIntake.goalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Daily Goal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Choose your daily water intake goal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 32),

                // Goal selector
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${_selectedGoal.toInt()}ml',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${(_selectedGoal / 250).toInt()} glasses',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF3B82F6),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: const Color(0xFF3B82F6),
                    overlayColor: const Color(0xFF3B82F6).withOpacity(0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: _selectedGoal,
                    min: 1000,
                    max: 4000,
                    divisions: 12,
                    onChanged: (value) {
                      setState(() {
                        _selectedGoal = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Quick options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickOption('1.5L', 1500),
                    _buildQuickOption('2L', 2000),
                    _buildQuickOption('2.5L', 2500),
                    _buildQuickOption('3L', 3000),
                  ],
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Save Goal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
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
    );
  }

  Widget _buildQuickOption(String label, double value) {
    final isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<WaterIntakeProvider>().updateGoal(_selectedGoal);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily goal updated to ${_selectedGoal.toInt()}ml',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update goal. Please try again.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
