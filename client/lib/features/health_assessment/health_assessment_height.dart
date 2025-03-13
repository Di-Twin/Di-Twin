import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/services.dart';

class HeightInputPage extends StatefulWidget {
  const HeightInputPage({super.key});

  @override
  State<HeightInputPage> createState() => _HeightInputPageState();
}

class _HeightInputPageState extends State<HeightInputPage>
    with SingleTickerProviderStateMixin {
  // STATE VARIABLES
  bool isInches = true;
  double height = 70.0; // Default height in inches (5'10")
  int currentStep = 0;
  final int totalSteps = 5;

  double _lastHeight = 70.0;

  // SCALE PARAMETERS
  double scaleOffset = 0.0;
  final double scaleUnitSize = 20.0;
  final double scaleVisibleUnits = 30;

  // PHYSICS SCROLLING PARAMETERS
  double _dragVelocity = 0.0;
  bool _isDecelerating = false;

  @override
  void initState() {
    super.initState();
    scaleOffset = -height;
  }

  // UNIT CONVERSION METHODS
  double inchesToCm(double inches) {
    return inches * 2.54;
  }

  double cmToInches(double cm) {
    return cm / 2.54;
  }

  // HEIGHT CALCULATION FROM SCALE
  void updateHeightFromScale() {
    height = -scaleOffset;

    double minHeight = isInches ? (50 / 2.54) : 50.0;
    double maxHeight = isInches ? (220 / 2.54) : 220.0;

    if (height < minHeight) {
      height = minHeight;
      scaleOffset = -minHeight;
    } else if (height > maxHeight) {
      height = maxHeight;
      scaleOffset = -maxHeight;
    }
  }

  // PHYSICS-BASED DECELERATION
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

    double previousHeight = height;

    setState(() {
      scaleOffset += _dragVelocity;
      updateHeightFromScale();

      if (previousHeight.floor() != height.floor()) {
        HapticFeedback.mediumImpact();
      }
    });

    Future.delayed(const Duration(milliseconds: 16), _decelerateScale);
  }

  // HEIGHT FORMATTING
  String formattedHeight() {
  if (isInches) {
    int totalInches = height.round();
    int feet = totalInches ~/ 12;  // Divide to get feet
    int inches = totalInches % 12; // Get remaining inches

    // ✅ FIX: Convert `12 inches` into `1 extra foot`
    if (inches == 12) {
      feet += 1;
      inches = 0; // Reset inches to `0`
    }

    return inches == 0 ? "$feet'" : "$feet' $inches\"";
  } else {
    return "${height.toStringAsFixed(1)} cm";
  }
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
              // HEADER WITH NAVIGATION AND PROGRESS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

                  SizedBox(
                    width: 0.5.sw,
                    child: ProgressBar(
                      totalSteps: totalSteps,
                      currentStep: currentStep + 1,
                    ),
                  ),

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

              // QUESTION HEADER
              Text(
                'What is your height?',
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // UNIT SELECTION TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // INCHES OPTION
                  GestureDetector(
                    onTap: () {
                      if (!isInches) {
                        setState(() {
                          height = cmToInches(height);
                          isInches = true;
                          scaleOffset = -height;
                          _lastHeight = height;
                          HapticFeedback.mediumImpact();
                        });
                      }
                    },
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color:
                            isInches ? const Color(0xFF1E2B45) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color:
                              isInches
                                  ? const Color(0xFF1E2B45)
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'inches',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isInches ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // CM OPTION
                  GestureDetector(
                    onTap: () {
                      if (isInches) {
                        setState(() {
                          height = inchesToCm(height);
                          isInches = false;
                          scaleOffset = -height;
                          _lastHeight = height;
                          HapticFeedback.mediumImpact();
                        });
                      }
                    },
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color:
                            !isInches ? const Color(0xFF1E2B45) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color:
                              !isInches
                                  ? const Color(0xFF1E2B45)
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'cm',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  !isInches ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // VERTICAL SCALE SLIDER WITH INTERACTIVE CONTROLS
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120.w,
                          height: 500.h,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                // DRAG GESTURE HANDLER
                                onVerticalDragUpdate: (details) {
                                  _isDecelerating = false;
                                  setState(() {
                                    scaleOffset +=
                                        details.delta.dy / scaleUnitSize;
                                    _dragVelocity =
                                        details.delta.dy / scaleUnitSize;
                                    updateHeightFromScale();
                                    if ((height - _lastHeight).abs() >= 1.0) {
                                      HapticFeedback.mediumImpact();
                                      _lastHeight = height;
                                    }
                                  });
                                },
                                // DRAG END PHYSICS
                                onVerticalDragEnd: (details) {
                                  _dragVelocity =
                                      details.velocity.pixelsPerSecond.dy /
                                      (200 * scaleUnitSize);

                                  _dragVelocity = _dragVelocity.clamp(
                                    -0.8,
                                    0.8,
                                  );

                                  _startDeceleration();
                                },
                                child: CustomPaint(
                                  size: Size(120.w, constraints.maxHeight),
                                  painter: VerticalScalePainter(
                                    offset: scaleOffset,
                                    unitSize: scaleUnitSize,
                                    isInches: isInches,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // POINTER INDICATOR
                        IgnorePointer(
                          ignoring: true,
                          child: Transform.rotate(
                            angle: 3.14159 / 2,
                            child: Container(
                              width: 100.h,
                              height: 100.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'images/WeightIndicatorMain.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // HEIGHT DISPLAY
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            isInches
                                ? formattedHeight()
                                : height.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontSize: 70.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      TextSpan(
                        text: isInches ? '' : ' cm',
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
              SizedBox(height: 10.h),
              // CONTINUE BUTTON
              CustomButton(
                text: "Continue",
                iconPath: 'images/SignInAddIcon.png',
                onPressed: () {
                  Navigator.pushNamed(context, '/questions/age');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CUSTOM SCALE PAINTER FOR HEIGHT VISUALIZATION
// Custom Scale Painter for Height Input
class VerticalScalePainter extends CustomPainter {
  final double offset;
  final double unitSize;
  final bool isInches;

  VerticalScalePainter({
    required this.offset,
    required this.unitSize,
    required this.isInches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final double halfHeight = size.height / 2;
    final double unitsVisible = halfHeight / unitSize;

    // ✅ FIXED: Correct min/max height values
    final double minValueCm = 50.0;
    final double maxValueCm = 220.0;
    final double minValueInches = minValueCm / 2.54;
    final double maxValueInches = maxValueCm / 2.54;

    final double minValue = isInches ? minValueInches : minValueCm;
    final double maxValue = isInches ? maxValueInches : maxValueCm;

    final double minUnit = -offset - unitsVisible;
    final double maxUnit = -offset + unitsVisible;

    final int minTick = minUnit.floor();
    final int maxTick = maxUnit.ceil();

    // DRAW TICK MARKS
    for (int i = minTick; i <= maxTick; i++) {
      if (i < minValue || i > maxValue) continue;

      final double y = centerY + (i + offset) * unitSize;

      // ✅ FIXED: Proper major tick placement for inches
      final bool isMajorTick = isInches ? (i % 12 == 0) : (i % 10 == 0);
      final bool isSubTick = isInches ? (i % 1 == 0) : (i % 1 == 0);

      double tickWidth = 10.0;
      Paint tickPaint = Paint()..color = Colors.grey[400]!;

      if (isMajorTick) {
        tickWidth = 60.w;
        tickPaint
          ..color = const Color(0xFF5D6A85)
          ..strokeWidth = 2.0;
      } else if (isSubTick) {
        tickWidth = 30.w;
        tickPaint
          ..color = const Color(0xFFBEC5D2)
          ..strokeWidth = 1.0;
      }

      // ✅ Draw Tick Mark
      canvas.drawLine(
        Offset(centerX - tickWidth / 2, y),
        Offset(centerX + tickWidth / 2, y),
        tickPaint,
      );

      // ✅ FIXED: Proper Inches & CM Labeling
      if (isMajorTick) {
        String label;
        if (isInches) {
          int feet = (i / 12).floor();
          int inches = (i % 12).round();
          label = inches == 0 ? "$feet'" : "$feet' $inches\"";
        } else {
          label = "$i cm";
        }

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
          Offset(centerX + tickWidth / 2 + 5, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
