import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Added to match the style of both screens

class SmartHealthAnalysisScreen extends StatelessWidget {
  const SmartHealthAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () {
                        // Navigate back when the back button is pressed
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left,
                            color: Color(0xFF1E293B),
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title
                    Text(
                      'Smart Health Analysis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const Spacer(),

                    // Menu
                    const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                  ],
                ),
              ),

              // Heart Rate Stats
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heart Rate Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFECDCD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite,
                              color: Color(0xFFEF4444),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Heart Rate Stats',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Heart Rate Value - Centered
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFECDCD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite,
                                color: Color(0xFFEF4444),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '95',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'BPM',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Time Period Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTimePeriodButton('Day', true),
                          _buildTimePeriodButton('Week', false),
                          _buildTimePeriodButton('Month', false),
                          _buildTimePeriodButton('3 Month', false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Graph Area Placeholder
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Heart Rate Graph Placeholder',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Blood Pressure Stats
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blood Pressure Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFDBFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.water_drop,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Blood Pressure Stats',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Blood Pressure Value - Centered
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBFDBFE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.water_drop,
                                color: Color(0xFF2563EB),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '120',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'mmHg',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Time Period Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTimePeriodButton('Day', true),
                          _buildTimePeriodButton('Week', false),
                          _buildTimePeriodButton('Month', false),
                          _buildTimePeriodButton('3 Month', false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Graph Area Placeholder
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Blood Pressure Graph Placeholder',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodButton(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
