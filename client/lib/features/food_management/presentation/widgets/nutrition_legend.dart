import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionLegend extends StatelessWidget {
  const NutritionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Target legend
          Row(
            children: [
              _buildLegendDot(const Color(0xFFD0E2FF)),
              _buildLegendDot(const Color(0xFFFFD0D0)),
              _buildLegendDot(Colors.grey.shade300),
              const SizedBox(width: 8),
              Text(
                'Target',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          // Taken legend
          Row(
            children: [
              _buildLegendDot(const Color(0xFF1A73E8)),
              _buildLegendDot(const Color(0xFFFF6B6B)),
              _buildLegendDot(const Color(0xFF1E293B)),
              const SizedBox(width: 8),
              Text(
                'Taken',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
