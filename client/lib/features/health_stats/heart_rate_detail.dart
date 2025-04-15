import 'package:client/data/API/heart_data.dart';
import 'package:client/data/providers/heart_provider.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({Key? key}) : super(key: key);

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  final HeartProvider _heartProvider = HeartProvider();
  bool isLoading = true;
  String errorMessage = '';
  
  HeartRateData? heartRateData;
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
    _fetchHeartRateData();
  }

  Future<void> _fetchHeartRateData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get today's date in YYYY-MM-DD format
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Fetch heart rate data
      final response = await _heartProvider.getHeartRateData(today);
      
      // Update state with fetched data
      setState(() {
        heartRateData = response.data;
        
        // Calculate average heart rate if data points are available
        int avgHeartRate = 0;
        if (heartRateData?.heartRateData != null && 
            heartRateData!.heartRateData!.isNotEmpty) {
          int sum = 0;
          for (var point in heartRateData!.heartRateData!) {
            sum += point.value;
          }
          avgHeartRate = (sum / heartRateData!.heartRateData!.length).round();
        } else {
          // Use resting heart rate as fallback
          avgHeartRate = heartRateData?.restingHeartRate ?? 0;
        }
        
        // Update display data
        displayData = {
          'min': heartRateData?.minHeartRate ?? 0,
          'max': heartRateData?.maxHeartRate ?? 0,
          'avg': avgHeartRate,
          'status': _determineHeartRateStatus(avgHeartRate),
          'healthStatus': _determineHealthStatus(avgHeartRate),
          'abnormality': _determineAbnormality(avgHeartRate),
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
          'abnormality': 'Heart rate data unavailable',
        };
      });
    }
  }
  
  String _determineHeartRateStatus(int heartRate) {
    if (heartRate == 0) return 'No Data';
    if (heartRate < 60) return 'Low';
    if (heartRate < 100) return 'Normal';
    return 'High';
  }
  
  String _determineHealthStatus(int heartRate) {
    if (heartRate == 0) return 'Unavailable';
    if (heartRate >= 60 && heartRate < 100) return 'Healthy';
    return 'Needs Attention';
  }
  
  String _determineAbnormality(int heartRate) {
    if (heartRate == 0) return 'Heart rate data unavailable';
    if (heartRate < 60) return 'Heart rate below normal range';
    if (heartRate < 100) return 'No health abnormality';
    return 'Heart rate above normal range';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage fill for the graph (100% would be at 200bpm)
    // Sending half the value to the graph as requested
    const maxFill = 200.0; // Maximum possible heart rate for scaling
    
    // Only calculate percentages if values are greater than 0
    final avgPercentage = displayData['avg'] > 0 ? (displayData['avg'] / 200) * 100 : 0.0;
final minPercentage = displayData['min'] > 0 ? (displayData['min'] / 200) * 100 : 0.0;
final maxPercentage = displayData['max'] > 0 ? (displayData['max'] / 200) * 100 : 0.0;
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
                              'Heart Rate',
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
                                      // Max Heart Rate
                                      buildStatCard(
                                        value: displayData['max'],
                                        label: 'Max Heart Rate',
                                        color: const Color(0xFFEF4444),
                                      ),
                                      SizedBox(height: 25),
                                      
                                      // Min Heart Rate
                                      buildStatCard(
                                        value: displayData['min'],
                                        label: 'Min Heart Rate',
                                        color: const Color(0xFF1E293B),
                                      ),
                                      SizedBox(height: 25),

                                      // Average Heart Rate
                                      buildStatCard(
                                        value: displayData['avg'],
                                        label: 'Avg Heart Rate',
                                        color: const Color(0xFF3B82F6),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomButton(
                      height: 50,
                      text: "View Detailed Report",
                      iconPath: 'images/SignInAddIcon.png',
                      onPressed: () {
                        Navigator.pushNamed(context, '/dashboard');
                      },
                    ),
                  ),
                ],
              ),
            ),
            // The graph - positioned at the right edge of the screen
            if (!isLoading) Positioned(
              right: -130,
              top: 100,
              bottom: 200,
              child: AnimatedHeartRateGraphq(
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
                      value > 0 ? 'bpm' : '',
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

// Custom widget for the heart rate graph
class AnimatedHeartRateGraphq extends StatelessWidget {
  final double avgPercentage;
  final double minPercentage;
  final double maxPercentage;

  const AnimatedHeartRateGraphq({
    Key? key,
    required this.avgPercentage,
    required this.minPercentage,
    required this.maxPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: MediaQuery.of(context).size.height * 0.7,
      child: CustomPaint(
        painter: HeartRateGraphPainter(
          avgPercentage: avgPercentage,
          minPercentage: minPercentage,
          maxPercentage: maxPercentage,
        ),
      ),
    );
  }
}

// Custom painter for the heart rate graph
// Custom painter for the heart rate graph
class HeartRateGraphPainter extends CustomPainter {
  final double avgPercentage;
  final double minPercentage;
  final double maxPercentage;

  HeartRateGraphPainter({
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
  bool shouldRepaint(covariant HeartRateGraphPainter oldDelegate) {
    return oldDelegate.avgPercentage != avgPercentage ||
        oldDelegate.minPercentage != minPercentage ||
        oldDelegate.maxPercentage != maxPercentage;
  }
}