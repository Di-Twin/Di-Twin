// 🔴ToDo : Add text field to weight


import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/services.dart';

class WeightInputPage extends StatefulWidget {
  const WeightInputPage({super.key});

  @override
  State<WeightInputPage> createState() => _WeightInputPageState();
}

class _WeightInputPageState extends State<WeightInputPage>
    with SingleTickerProviderStateMixin {
  // State variables
  bool isLbs = true;
  double weight = 140.0;
  int currentStep = 0;
  final int totalSteps = 5;

  double _lastWeight = 140.0;

  // Scale parameters
  double scaleOffset = 0.0;
  final double scaleUnitSize = 20.0;
  final double scaleVisibleUnits = 30;

  // Physics scrolling variables
  double _dragVelocity = 0.0;
  bool _isDecelerating = false;

  @override
  void initState() {
    super.initState();
    scaleOffset = -weight;
  }

  // Unit conversion functions
  double lbsToKg(double lbs) {
    return lbs * 0.453592;
  }

  double kgToLbs(double kg) {
    return kg * 2.20462;
  }

  // Weight calculation and validation
  void updateWeightFromScale() {
    weight = -scaleOffset;

    double minWeight = isLbs ? 44.09 : 20.0;
    double maxWeight = isLbs ? 330.69 : 150.0;

    if (weight < minWeight) {
      weight = minWeight;
      scaleOffset = -minWeight;
    } else if (weight > maxWeight) {
      weight = maxWeight;
      scaleOffset = -maxWeight;
    }
  }

  // Physics-based animation handlers
  void _startDeceleration() {
    if (_isDecelerating) return;

    _isDecelerating = true;
    _decelerateScale();
  }

  void _decelerateScale() {
    if (!_isDecelerating || _dragVelocity.abs() < 0.1) {
      _isDecelerating = false;
      return;
    }

    _dragVelocity *= 0.97;

    double previousWeight = weight;

    setState(() {
      scaleOffset += _dragVelocity;
      updateWeightFromScale();

      if (previousWeight.floor() != weight.floor()) {
        HapticFeedback.mediumImpact();
      }
    });

    Future.delayed(const Duration(milliseconds: 16), _decelerateScale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0.w, vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with navigation and progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 24.sp,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey[700],
                    ),
                  ),

                  // Progress tracker
                  SizedBox(
                    width: 0.5.sw,
                    child: ProgressBar(
                      totalSteps: totalSteps,
                      currentStep: currentStep + 1,
                    ),
                  ),

                  // Skip button
                  TextButton(
                    onPressed: () {
                      // Handle skip action
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // Page title/question
              Text(
                'What is your weight?',
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Unit selector toggle (lbs/kg)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LBS selector
                  GestureDetector(
                    onTap: () {
                      if (!isLbs) {
                        setState(() {
                          weight = kgToLbs(weight);
                          isLbs = true;
                          scaleOffset = -weight;
                          _lastWeight = weight;
                          HapticFeedback.mediumImpact();
                        });
                      }
                    },
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isLbs ? const Color(0xFF1E2B45) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color:
                              isLbs
                                  ? const Color(0xFF1E2B45)
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'lbs',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isLbs ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // KG selector
                  GestureDetector(
                    onTap: () {
                      if (isLbs) {
                        setState(() {
                          weight = lbsToKg(weight);
                          isLbs = false;
                          scaleOffset = -weight;
                          _lastWeight = weight;
                          HapticFeedback.mediumImpact();
                        });
                      }
                    },
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: !isLbs ? const Color(0xFF1E2B45) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color:
                              !isLbs
                                  ? const Color(0xFF1E2B45)
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'kg',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: !isLbs ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // Weight display with units
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            isLbs
                                ? weight.toStringAsFixed(1)
                                : weight.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontSize: 80.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      TextSpan(
                        text: ' ${isLbs ? 'lbs' : 'kg'}',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Custom interactive weight scale slider with physics-based scrolling and haptic feedback
              Stack(
                alignment: Alignment.center,
                children: [
                  // Scale widget with drag gesture handling
                  SizedBox(
                    height: 120.h,
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            _isDecelerating = false;
                            setState(() {
                              scaleOffset += details.delta.dx / scaleUnitSize;
                              _dragVelocity = details.delta.dx / scaleUnitSize;
                              updateWeightFromScale();
                              if ((weight - _lastWeight).abs() >= 1.0) {
                                HapticFeedback.mediumImpact();
                                _lastWeight = weight;
                              }
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            _dragVelocity =
                                details.velocity.pixelsPerSecond.dx /
                                (200 * scaleUnitSize);

                            if (_dragVelocity.abs() > 0.3) {
                              _dragVelocity = _dragVelocity > 0 ? 0.8 : -0.8;
                            }

                            _startDeceleration();
                          },
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, 120.h),
                            painter: ScalePainter(
                              offset: scaleOffset,
                              unitSize: scaleUnitSize,
                              isLbs: isLbs,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Center indicator marker
                  Positioned(
                    child: Image.asset(
                      'images/WeightIndicatorMain.png',
                      width: 40.w,
                      height: 100.h,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Navigation button
              CustomButton(
                text: "Continue",
                iconPath: 'images/SignInAddIcon.png',
                onPressed: () {
                  Navigator.pushNamed(context, '/questions/height');
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Scale painter for custom rendering of the weight scale
class ScalePainter extends CustomPainter {
  final double offset;
  final double unitSize;
  final bool isLbs;

  ScalePainter({
    required this.offset,
    required this.unitSize,
    required this.isLbs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double centerX = size.width / 2;

    // Calculate visible range
    final double halfWidth = size.width / 2;
    final double unitsVisible = halfWidth / unitSize;

    final double minUnit = -offset - unitsVisible;
    final double maxUnit = -offset + unitsVisible;

    final int minTick = minUnit.floor();
    final int maxTick = maxUnit.ceil();

    // Weight limits
    final double minValue = isLbs ? 44.09 : 20.0;
    final double maxValue = isLbs ? 330.69 : 150.0;

    // Draw ticks and labels
    for (int i = minTick; i <= maxTick; i++) {
      if (i < minValue || i > maxValue) continue;

      final double x = centerX + (i + offset) * unitSize;

      // Tick styling
      final bool isMajorTick = i % 5 == 0;
      final bool isSubTick = i % 1 == 0;

      double tickHeight = 10.0;
      Paint tickPaint = Paint()..color = Colors.grey[400]!;

      if (isMajorTick) {
        tickHeight = 60.h;
        tickPaint
          ..color = const Color(0xFF5D6A85)
          ..strokeWidth = 2.0;
      } else if (isSubTick) {
        tickHeight = 30.h;
        tickPaint
          ..color = const Color(0xFFBEC5D2)
          ..strokeWidth = 1.0;
      }

      // Draw tick mark
      canvas.drawLine(
        Offset(x, centerY - tickHeight / 2),
        Offset(x, centerY + tickHeight / 2),
        tickPaint,
      );

      // Draw labels for major ticks
      if (isMajorTick) {
        final String label = i.toString();

        final TextSpan span = TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );

        final TextPainter textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, centerY + tickHeight / 2 + 5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}