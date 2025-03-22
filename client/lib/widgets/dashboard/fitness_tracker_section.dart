import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fitness_tracker_item.dart';

class FitnessTrackerSection extends StatelessWidget {
  const FitnessTrackerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fitness & Activity Tracker',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: const [
            FitnessTrackerItem(
              icon: Icons.fitness_center,
              title: 'Calories Burned',
              subtitle: '1000kcal',
              maxValue: '1500kcal',
              progress: 0.67,
              progressColor: Color(0xFFEF4444),
            ),
            Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            FitnessTrackerItem(
              icon: Icons.directions_walk,
              title: 'Steps Taken',
              subtitle: 'You\'ve taken 1000 steps.',
              progress: 0.5,
              progressColor: Color(0xFF3B82F6),
            ),
            Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            FitnessTrackerItem(
              icon: Icons.apple,
              title: 'Nutrition',
              subtitle: '',
              showChips: true,
            ),
            Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            FitnessTrackerItem(
              icon: Icons.nightlight_outlined,
              title: 'Sleep',
              subtitle: 'You\'ve taken 7 hours sleep.',
              progress: 0.7,
              progressColor: Color(0xFF06B6D4),
            ),
            Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            FitnessTrackerItem(
              icon: Icons.monitor_weight_outlined,
              title: 'Weight Loss',
              subtitle: '',
              showDots: true,
            ),
          ],
        ),
      ],
    );
  }
}
