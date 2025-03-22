import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'health_metric_card.dart';

class HealthMetricsSection extends StatelessWidget {
  const HealthMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Smart Health Metrics',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
              color: const Color(0xFF64748B),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              HealthMetricCard(
                title: 'Heart Rate',
                value: '78.2',
                unit: 'BPM',
                color: Color(0xFF2563EB),
                icon: Icons.favorite_border,
              ),
              SizedBox(width: 12),
              HealthMetricCard(
                title: 'Blood Pressure',
                value: '120',
                unit: 'mmHg',
                color: Color(0xFFEF4444),
                icon: Icons.show_chart,
                status: 'NORMAL',
              ),
              SizedBox(width: 12),
              HealthMetricCard(
                title: 'Sleep',
                value: '82',
                unit: 'hours',
                color: Color(0xFF06B6D4),
                icon: Icons.nightlight_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
