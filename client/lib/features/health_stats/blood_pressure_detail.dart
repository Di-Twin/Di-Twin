import 'package:client/data/API/health_metrics_data.dart';
import 'package:client/data/providers/health_metrics_provider.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SPO2Page extends StatefulWidget {
  const SPO2Page({super.key});

  @override
  State<SPO2Page> createState() => _SPO2PageState();
}

class _SPO2PageState extends State<SPO2Page> {
  final HealthMetricsProvider _healthMetricsProvider = HealthMetricsProvider();
  bool isLoading = true;
  String errorMessage = '';
  
  HealthMetrics? spo2Data;
  Map<String, dynamic> displayData = {
    'avg': 0,
    'min': 0,
    'max': 0,
    'status': 'Loading...',
    'healthStatus': 'Loading...',
    'abnormality': 'Fetching health data...',
  };

  @override
  void initState() {
    super.initState();
    _fetchSPO2Data();
  }

  Future<void> _fetchSPO2Data() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get today's date in YYYY-MM-DD format
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Fetch SPO2 data
      final response = await _healthMetricsProvider.getHealthMetrics(today);
      
      // Update state with fetched data
      setState(() {
        spo2Data = response.data;
        
        // Get SPO2 values from the health metrics
        int avgSPO2 = spo2Data?.spo2Avg ?? 0;
        int minSPO2 = spo2Data?.spo2Min ?? 0;
        int maxSPO2 = spo2Data?.spo2Max ?? 0;
        
        // Update display data
        displayData = {
          'min': minSPO2,
          'max': maxSPO2,
          'avg': avgSPO2,
          'status': _determineSPO2Status(avgSPO2),
          'healthStatus': _determineHealthStatus(avgSPO2),
          'abnormality': _determineAbnormality(avgSPO2),
        };
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        // Set default values in case of error
        displayData = {
          'avg': 0,
          'min': 0,
          'max': 0,
          'status': 'No Data',
          'healthStatus': 'Unavailable',
          'abnormality': 'SPO2 data unavailable',
        };
      });
    }
  }
  
  String _determineSPO2Status(int spo2) {
    if (spo2 == 0) return 'No Data';
    if (spo2 < 90) return 'Low';
    if (spo2 >= 90 && spo2 <= 100) return 'Normal';
    return 'Invalid';
  }
  
  String _determineHealthStatus(int spo2) {
    if (spo2 == 0) return 'Unavailable';
    if (spo2 >= 95 && spo2 <= 100) return 'Healthy';
    if (spo2 >= 90 && spo2 < 95) return 'Acceptable';
    return 'Needs Attention';
  }
  
  String _determineAbnormality(int spo2) {
    if (spo2 == 0) return 'SPO2 data unavailable';
    if (spo2 < 90) return 'Blood oxygen level below normal range';
    if (spo2 >= 90 && spo2 < 95) return 'Blood oxygen slightly below optimal level';
    if (spo2 >= 95 && spo2 <= 100) return 'No health abnormality';
    return 'Invalid SPO2 reading';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage fill for the graph (100% would be at 100% SPO2)
    // Scale appropriately for SPO2 which ranges from 0-100%
    final avgPercentage = displayData['avg'] > 0 ? displayData['avg'].toDouble() : 0.0;
    final minPercentage = displayData['min'] > 0 ? displayData['min'].toDouble() : 0.0;
    final maxPercentage = displayData['max'] > 0 ? displayData['max'].toDouble() : 0.0;
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: const Color(0xFFF8FAFC), // slate-50
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  size: 20,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Blood Oxygen',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            size: 24,
                            color: Color(0xFF1E293B),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: isLoading 
                    ? Center(child: CircularProgressIndicator()) 
                    : errorMessage.isNotEmpty && displayData['avg'] == 0
                      ? Center(
                          child: Text(
                            'Error: $errorMessage',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Indicator
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  displayData['healthStatus'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ),

                            // Status Title
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayData['status'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayData['abnormality'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stats Section
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stats',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Stats layout in column
                                  Column(
                                    children: [
                                      // Max SPO2
                                      buildStatCard(
                                        value: displayData['max'],
                                        label: 'Max SPO2',
                                        color: const Color(0xFFEF4444),
                                        unit: '%',
                                      ),
                                      SizedBox(height: 25),
                                      
                                      // Min SPO2
                                      buildStatCard(
                                        value: displayData['min'],
                                        label: 'Min SPO2',
                                        color: const Color(0xFF1E293B),
                                        unit: '%',
                                      ),
                                      SizedBox(height: 25),

                                      // Average SPO2
                                      buildStatCard(
                                        value: displayData['avg'],
                                        label: 'Avg SPO2',
                                        color: const Color(0xFF3B82F6),
                                        unit: '%',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),

                  // Footer Button
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: CustomButton(
                  //     height: 50,
                  //     text: "View Detailed Report",
                  //     iconPath: 'images/SignInAddIcon.png',
                  //     onPressed: () {
                  //       Navigator.pushNamed(context, '/dashboard');
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
            // The graph - positioned at the right edge of the screen
            if (!isLoading) Positioned(
              right: -130,
              top: 100,
              bottom: 200,
              child: AnimatedSPO2Graph(
                avgPercentage: avgPercentage,
                minPercentage: minPercentage,
                maxPercentage: maxPercentage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build stat cards with consistent style
  Widget buildStatCard({
    required int value,
    required String label,
    required Color color,
    required String unit,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value > 0 ? '$value' : '---',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value > 0 ? unit : '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the SPO2 graph
class AnimatedSPO2Graph extends StatelessWidget {
  final double avgPercentage;
  final double minPercentage;
  final double maxPercentage;

  const AnimatedSPO2Graph({
    super.key,
    required this.avgPercentage,
    required this.minPercentage,
    required this.maxPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: MediaQuery.of(context).size.height * 0.7,
      child: CustomPaint(
        painter: SPO2GraphPainter(
          avgPercentage: avgPercentage,
          minPercentage: minPercentage,
          maxPercentage: maxPercentage,
        ),
      ),
    );
  }
}

// Custom painter for the SPO2 graph
class SPO2GraphPainter extends CustomPainter {
  final double avgPercentage;
  final double minPercentage;
  final double maxPercentage;

  SPO2GraphPainter({
    required this.avgPercentage,
    required this.minPercentage,
    required this.maxPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;

    // Draw the filled rings according to their percentages
    _drawFilledRing(
      canvas,
      Rect.fromLTWH(0, 0, width, height),
      const Color(0xFF0066FF),
      28,
      avgPercentage / 2,
      startAngle: 220,
    );

    _drawFilledRing(
      canvas,
      Rect.fromLTWH(55, 55, width - 110, height - 110),
      const Color(0xFF1E293B),
      28,
      minPercentage / 2,
      startAngle: 220,
    );

    _drawFilledRing(
      canvas,
      Rect.fromLTWH(110, 110, width - 220, height - 220),
      const Color(0xFFFF4D6D),
      28,
      maxPercentage / 2,
      startAngle: 220,
    );
  }

  void _drawFilledRing(Canvas canvas, Rect rect, Color color, double strokeWidth, double percentage, {double startAngle = -90}) {
    // Create the base empty paint
    final emptyPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    // Create the filled paint
    final filledPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    // Create the rounded rectangle shape
    final radius = Radius.circular(rect.width / 2);
    final rrect = RRect.fromRectAndRadius(rect, radius);
    
    // Draw the complete empty ring
    canvas.drawRRect(rrect, emptyPaint);
    
    // Only draw filled portion if there's a value
    if (percentage > 0) {
      // Calculate how much of the path to draw based on percentage
      // First we need the total length of the path
      final path = Path()
        ..addRRect(rrect);
      
      // Calculate the filled length
      final pathMetrics = path.computeMetrics().first;
      final totalLength = pathMetrics.length;
      
      // Calculate starting point based on startAngle
      // The path follows: top -> right -> bottom -> left -> top
      // So we need to calculate the starting offset
      final angleOffset = (startAngle + 90) / 360 * totalLength;
      
      // Calculate the filled length
      final filledLength = totalLength * (percentage / 100);
      
      // Extract the filled portion of the path
      final filledPath = Path();
      
      // If the path wraps around, we need to handle it
      if (angleOffset + filledLength > totalLength) {
        // First part (from offset to end)
        filledPath.addPath(
          pathMetrics.extractPath(angleOffset, totalLength),
          Offset.zero,
        );
        
        // Second part (from start to remaining length)
        filledPath.addPath(
          pathMetrics.extractPath(0, (angleOffset + filledLength) % totalLength),
          Offset.zero,
        );
      } else {
        // Normal case - just extract the path from offset
        filledPath.addPath(
          pathMetrics.extractPath(angleOffset, angleOffset + filledLength),
          Offset.zero,
        );
      }
      
      // Draw the filled portion
      canvas.drawPath(filledPath, filledPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SPO2GraphPainter oldDelegate) {
    return oldDelegate.avgPercentage != avgPercentage ||
        oldDelegate.minPercentage != minPercentage ||
        oldDelegate.maxPercentage != maxPercentage;
  }
}