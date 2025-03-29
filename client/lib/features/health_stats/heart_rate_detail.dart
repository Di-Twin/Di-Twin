import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/health_stats/smart_health_analysis.dart'; // Import the analysis screen

class HeartRateDetailScreen extends StatelessWidget {
  const HeartRateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 48,
                    height: 48,
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

                  const SizedBox(width: 16),

                  // Title
                  Text(
                    'Heart Rate',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  const Spacer(),

                  // Menu
                  const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF64748B),
                    size: 28,
                  ),
                ],
              ),
            ),

            // Main content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFDBFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Healthy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Normal status
                      Text(
                        'Normal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),

                      // Subtitle
                      Text(
                        'No health abnormality',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Stats section
                      Text(
                        'Stats',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Heart rate cards (with further reduced width)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            _buildHeartRateCard(
                              value: '85',
                              label: 'Avg Heart Rate',
                              color: const Color(0xFF2563EB),
                            ),
                            const SizedBox(height: 16),
                            _buildHeartRateCard(
                              value: '75',
                              label: 'Min Heart Rate',
                              color: const Color(0xFF1E293B),
                            ),
                            const SizedBox(height: 16),
                            _buildHeartRateCard(
                              value: '95',
                              label: 'Max Heart Rate',
                              color: const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ),

                      // Additional space at the bottom for comfortable scrolling
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the SmartHealthAnalysisScreen when button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SmartHealthAnalysisScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Detailed Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.add, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with value
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
              height: 1.0, // Reduce line height
            ),
          ),

          // Unit aligned at the bottom adjacent to the number
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end, // Align items at the bottom
            children: [
              Text(
                'bpm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom section with label and indicator
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
