import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/utils/sugar_spike_calculator.dart';
import 'package:client/data/providers/activity_provider.dart';
import 'package:client/data/providers/sleep_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

class SugarSpikeGraph extends ConsumerStatefulWidget {
  final Map<String, dynamic> food;

  const SugarSpikeGraph({
    super.key,
    required this.food,
  });

  @override
  ConsumerState<SugarSpikeGraph> createState() => _SugarSpikeGraphState();
}

class _SugarSpikeGraphState extends ConsumerState<SugarSpikeGraph> {
  bool _isLoading = true;
  double _activityScore = 70; // Default value
  double _sleepHours = 7; // Default value
  double _lastActivityHours = 4; // Default value
  double _sugarSpike = 0;
  String _impactLevel = 'Calculating...';
  Color _impactColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current date for API calls
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;
      final formattedDate = DateFormat('yyyy-M-d').format(now);

      // Get activity score
      final activityProvider = ActivityProvider();
      final activityScore = await activityProvider.getMonthlyActivityScore(year, month);
      
      // Get sleep hours
      final sleepProvider = ref.read(sleepServiceProvider);
      final sleepData = await ref.watch(sleepDataProvider.future);
      double sleepHours = 7.0; // Default
      sleepHours = sleepData.data.durationSeconds / 3600; // Convert seconds to hours
          
      // Get last activity hours
      final lastActivityHours = await activityProvider.getLastActivityHours(formattedDate);

      // Calculate sugar spike
      final carbs = widget.food.containsKey('carbs') ? (widget.food['carbs'] as double) : 0.0;
      final fiber = widget.food.containsKey('fiber') ? (widget.food['fiber'] as double) : 0.0;
      final protein = widget.food.containsKey('protein') ? (widget.food['protein'] as double) : 0.0;
      
      // Estimate GI and GL based on carbs and fiber ratio
      // This is a simplified estimation - ideally you would have actual GI values
      final estimatedGI = _estimateGlycemicIndex(widget.food);
      final estimatedGL = (estimatedGI * carbs) / 100;
      
      // Calculate sugar spike
      final sugarSpike = estimateSugarSpikeAdvanced(
        estimatedGI,
        estimatedGL,
        carbs,
        fiber,
        protein,
        1800, // Default BMR - ideally from user profile
        activityScore,
        lastActivityHours,
        sleepHours,
      );

      // Determine impact level and color
      final impactData = _getImpactLevelAndColor(sugarSpike);

      setState(() {
        _activityScore = activityScore;
        _sleepHours = sleepHours;
        _lastActivityHours = lastActivityHours;
        _sugarSpike = sugarSpike;
        _impactLevel = impactData['level'];
        _impactColor = impactData['color'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      // Use default values if API calls fail
      final carbs = widget.food.containsKey('carbs') ? (widget.food['carbs'] as double) : 0.0;
      final fiber = widget.food.containsKey('fiber') ? (widget.food['fiber'] as double) : 0.0;
      final protein = widget.food.containsKey('protein') ? (widget.food['protein'] as double) : 0.0;
      
      final estimatedGI = _estimateGlycemicIndex(widget.food);
      final estimatedGL = (estimatedGI * carbs) / 100;
      
      final sugarSpike = estimateSugarSpikeAdvanced(
        estimatedGI,
        estimatedGL,
        carbs,
        fiber,
        protein,
        1800, // Default BMR
        70, // Default activity score
        4, // Default last activity hours
        7, // Default sleep hours
      );

      final impactData = _getImpactLevelAndColor(sugarSpike);

      setState(() {
        _sugarSpike = sugarSpike;
        _impactLevel = impactData['level'];
        _impactColor = impactData['color'];
        _isLoading = false;
      });
    }
  }

  // Estimate glycemic index based on food composition
  double _estimateGlycemicIndex(Map<String, dynamic> food) {
    // This is a simplified estimation
    // Ideally, you would have a database of GI values for common foods
    
    final carbs = food.containsKey('carbs') ? (food['carbs'] as double) : 0.0;
    final fiber = food.containsKey('fiber') ? (food['fiber'] as double) : 0.0;
    final protein = food.containsKey('protein') ? (food['protein'] as double) : 0.0;
    final fat = food.containsKey('fat') ? (food['fat'] as double) : 0.0;
    
    // Higher fiber and protein tend to lower GI
    // Higher simple carbs tend to raise GI
    
    // Base GI value
    double baseGI = 50;
    
    // Adjust based on fiber-to-carb ratio (higher fiber lowers GI)
    if (carbs > 0) {
      double fiberRatio = fiber / carbs;
      baseGI -= (fiberRatio * 30); // Reduce GI by up to 30 points for high fiber foods
    }
    
    // Adjust based on protein and fat (higher protein and fat lower GI)
    baseGI -= (protein * 0.2); // Reduce GI slightly for protein content
    baseGI -= (fat * 0.3); // Reduce GI slightly for fat content
    
    // Ensure GI is within valid range (0-100)
    return baseGI.clamp(0, 100);
  }

  // Get impact level and color based on sugar spike value
  Map<String, dynamic> _getImpactLevelAndColor(double sugarSpike) {
    if (sugarSpike < 1.0) {
      return {
        'level': 'Minimal',
        'color': Color(0xFF4CAF50), // Green
      };
    } else if (sugarSpike < 2.0) {
      return {
        'level': 'Low',
        'color': Color(0xFF8BC34A), // Light Green
      };
    } else if (sugarSpike < 3.0) {
      return {
        'level': 'Moderate',
        'color': Color(0xFFFFC107), // Amber
      };
    } else if (sugarSpike < 4.0) {
      return {
        'level': 'High',
        'color': Color(0xFFFF9800), // Orange
      };
    } else {
      return {
        'level': 'Very High',
        'color': Color(0xFFF44336), // Red
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Blood Sugar Response',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (!_isLoading)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                  decoration: BoxDecoration(
                    color: _impactColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 14.sp,
                        color: _impactColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '+${_sugarSpike.toStringAsFixed(1)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: _impactColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          
          if (_isLoading)
            Center(
              child: SizedBox(
                height: 150.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF0F67FE),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Calculating blood sugar response...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                // Sugar spike graph
                SizedBox(
                  height: 150.h,
                  child: CustomPaint(
                    size: Size(double.infinity, 150.h),
                    painter: SugarSpikePainter(
                      sugarSpike: _sugarSpike,
                      impactColor: _impactColor,
                    ),
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Impact description
                Text(
                  _getImpactDescription(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: Color(0xFF64748B),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Factors affecting response
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Factors Affecting Your Response',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildFactorRow(
                        icon: Icons.directions_run,
                        label: 'Activity Score',
                        value: '${_activityScore.toStringAsFixed(0)}/100',
                      ),
                      _buildFactorRow(
                        icon: Icons.bedtime,
                        label: 'Sleep Duration',
                        value: '${_sleepHours.toStringAsFixed(1)} hours',
                      ),
                      _buildFactorRow(
                        icon: Icons.access_time,
                        label: 'Last Activity',
                        value: '${_lastActivityHours.toStringAsFixed(1)} hours ago',
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFactorRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: Color(0xFF64748B),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Color(0xFF64748B),
            ),
          ),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  String _getImpactDescription() {
    final foodName = widget.food['name'];
    
    switch (_impactLevel) {
      case 'Minimal':
        return '$foodName has a minimal impact on your blood sugar levels, making it an excellent choice for stable energy.';
      case 'Low':
        return '$foodName has a low impact on your blood sugar levels, providing steady energy without significant spikes.';
      case 'Moderate':
        return '$foodName causes a moderate rise in blood sugar. Consider pairing with protein or healthy fats to reduce the impact.';
      case 'High':
        return '$foodName may cause a significant blood sugar spike. Consider reducing portion size or pairing with fiber-rich foods.';
      case 'Very High':
        return '$foodName causes a very high blood sugar response. Consider alternatives or consume in small amounts with protein and fiber.';
      default:
        return 'Analyzing how $foodName affects your blood sugar levels...';
    }
  }
}

// Custom painter for the sugar spike graph
class SugarSpikePainter extends CustomPainter {
  final double sugarSpike;
  final Color impactColor;

  SugarSpikePainter({
    required this.sugarSpike,
    required this.impactColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Paint for grid lines
    final gridPaint = Paint()
      ..color = Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Paint for baseline (ideal response)
    final baselinePaint = Paint()
      ..color = Color(0xFF94A3B8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Paint for actual response curve
    final curvePaint = Paint()
      ..color = impactColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Paint for area under curve
    final areaPaint = Paint()
      ..color = impactColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Draw horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
    
    // Draw vertical grid lines
    for (int i = 1; i < 4; i++) {
      final x = width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
    
    // Draw time labels
    final textStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 12,
    );
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    
    final labels = ['0h', '1h', '2h', '3h', '4h'];
    for (int i = 0; i < 5; i++) {
      final x = width * i / 4;
      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, height + 5));
    }
    
    // Draw baseline (ideal response)
    final baselinePath = Path();
    baselinePath.moveTo(0, height * 0.8);
    baselinePath.quadraticBezierTo(
      width * 0.5, height * 0.7,
      width, height * 0.8,
    );
    canvas.drawPath(baselinePath, baselinePaint);
    
    // Calculate peak height based on sugar spike
    // Map the spike value (typically 0-5) to a height percentage (0.8 to 0.1)
    // Higher spike = higher on the graph (lower y value)
    final peakHeight = height * (0.8 - (sugarSpike * 0.14)).clamp(0.1, 0.8);
    final peakX = width * 0.4; // Peak occurs around 1-1.5 hours
    
    // Draw actual response curve
    final curvePath = Path();
    curvePath.moveTo(0, height * 0.8); // Start at same point as baseline
    
    // First control point - rising quickly
    curvePath.cubicTo(
      width * 0.2, height * 0.6, // Control point 1
      width * 0.3, peakHeight, // Control point 2
      peakX, peakHeight, // Peak point
    );
    
    // Second part - falling more gradually
    curvePath.cubicTo(
      width * 0.5, peakHeight + (height * 0.05), // Control point 1
      width * 0.7, height * 0.7, // Control point 2
      width, height * 0.8, // End point (same as baseline end)
    );
    
    // Draw area under the curve
    final areaPath = Path.from(curvePath);
    areaPath.lineTo(width, height);
    areaPath.lineTo(0, height);
    areaPath.close();
    canvas.drawPath(areaPath, areaPaint);
    
    // Draw peak indicator
    final peakPaint = Paint()
      ..color = impactColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(peakX, peakHeight), 6, peakPaint);
    
    // Draw peak value
    final peakTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    
    final peakTextPainter = TextPainter(
      text: TextSpan(
        text: '+${sugarSpike.toStringAsFixed(1)}',
        style: peakTextStyle,
      ),
      textDirection: ui.TextDirection.ltr,
    );
    
    peakTextPainter.layout();
    
    // Draw background for peak value
    final textBgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(peakX, peakHeight - 15),
        width: peakTextPainter.width + 10,
        height: peakTextPainter.height + 6,
      ),
      Radius.circular(10),
    );
    
    canvas.drawRRect(textBgRect, peakPaint);
    
    // Draw peak value text
    peakTextPainter.paint(
      canvas,
      Offset(
        peakX - peakTextPainter.width / 2,
        peakHeight - 15 - peakTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
