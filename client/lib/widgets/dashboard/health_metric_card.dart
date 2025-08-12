import 'package:client/features/sleep_management/sleep_management_stats_page.dart';
import 'package:client/features/sleep_management/sleep_my_stats.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/health_stats/heart_rate_detail.dart';
import 'package:client/features/health_stats/blood_pressure_detail.dart';

class HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final String? status;
  final List<Map<String, dynamic>>? heartRateData;

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.status,
    this.heartRateData,
  });

  void _navigateToDetails(BuildContext context) {
    Widget page;
    switch (title) {
      case 'Heart Rate':
        page = const HeartRatePage();
        break;
      case 'SPO2':
        page = const SPO2Page();
        break;
      case 'Sleep':
        // page = MySleepScreen(
        //   userJoinDate: DateTime(
        //     2023,
        //     1,
        //     15,
        //   ), // Replace with actual user join date
        // );
        page = const SleepManagementStats();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 180,
        height: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Icon Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 16),
              ],
            ),
            const SizedBox(height: 6),

            // Graph based on metric type
            _buildGraphForMetric(),

            const Spacer(),

            // Status Tag (if available)
            if (status != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            const Spacer(),

            // Value and Unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphForMetric() {
    switch (title) {
      case 'Heart Rate':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 50,
            width: 156, // Match the card width minus padding
            alignment: Alignment.center,
            // If the GIF is in your assets folder:
            child: Image.asset(
              'images/heart_rate.gif', // Update this path to the location of your GIF
              fit: BoxFit.cover,
              width: 156,
              height: 50,
              gaplessPlayback: true, // Ensures smooth looping
              repeat: ImageRepeat.noRepeat,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                return Container(
                  height: 50,
                  width: 156,
                  color: Colors.white.withOpacity(0.2),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Fallback in case the GIF fails to load
                return Container(
                  height: 50,
                  width: 156,
                  color: Colors.white.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: Text(
                    "Failed to load GIF",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      case 'Blood Pressure':
        return _buildBloodPressureGraph();
      case 'Sleep':
        return _buildSleepGraph();
      default:
        return Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Graph Placeholder",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        );
    }
  }

  Widget _buildBloodPressureGraph() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: BloodPressureGraphPainter(color: Colors.white),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildSleepGraph() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: SleepGraphPainter(color: Colors.white),
        size: Size.infinite,
      ),
    );
  }
}

class BloodPressureGraphPainter extends CustomPainter {
  final Color color;

  BloodPressureGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

    // Draw a simple blood pressure graph
    final path = Path();

    // Starting point
    path.moveTo(0, size.height * 0.5);

    // Draw some peaks and valleys to represent blood pressure
    for (int i = 0; i < 4; i++) {
      final segmentWidth = size.width / 4;
      final x1 = segmentWidth * i;
      final x2 = segmentWidth * (i + 0.5);
      final x3 = segmentWidth * (i + 1);

      final y1 = size.height * 0.5;
      final y2 =
          size.height * (0.3 + (i % 2) * 0.4); // Alternate between high and low

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
      path.lineTo(x3, y1);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SleepGraphPainter extends CustomPainter {
  final Color color;

  SleepGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

    // Draw a simple sleep cycle graph
    final path = Path();

    // Starting point
    path.moveTo(0, size.height * 0.7);

    // Draw sleep cycles (REM, deep sleep, light sleep)
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width * 0.9, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}