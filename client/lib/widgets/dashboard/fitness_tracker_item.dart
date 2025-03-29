import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FitnessTrackerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double? progress;
  final Color? progressColor;
  final String? maxValue;
  final bool showChips;
  final bool showDots;
  final VoidCallback? onTap; // Add this line

  const FitnessTrackerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.progress,
    this.progressColor,
    this.maxValue,
    this.showChips = false,
    this.showDots = false,
    this.onTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wrap with GestureDetector
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF64748B), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],

                      if (progress != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  color: progressColor,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            if (maxValue != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                maxValue!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      if (showChips) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildChip('Vitamin A', const Color(0xFF06B6D4)),
                            _buildChip('Ibuprofen', const Color(0xFF06B6D4)),
                            _buildChip('2+', const Color(0xFF06B6D4)),
                          ],
                        ),
                      ],
                      if (showDots) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(
                            6,
                            (index) => _buildDot(
                              index < 3
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 24,
      height: 6,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
