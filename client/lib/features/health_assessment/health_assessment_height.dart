import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class HeightInputPage extends ConsumerStatefulWidget {
  const HeightInputPage({super.key});

  @override
  ConsumerState<HeightInputPage> createState() => _HeightInputPageState();
}

class _HeightInputPageState extends ConsumerState<HeightInputPage>
    with SingleTickerProviderStateMixin {
  // STATE VARIABLES
  bool isInches = true;
  double height = 70.0; // Default height in inches (5'10")
  int currentStep = 0;
  final int totalSteps = 5;

  double _lastHeight = 70.0;

  // SCALE PARAMETERS
  double scaleOffset = 0.0;
  late double scaleUnitSize;
  final double scaleVisibleUnits = 30;

  // PHYSICS SCROLLING PARAMETERS
  double _dragVelocity = 0.0;
  bool _isDecelerating = false;

  @override
  void initState() {
    super.initState();
    scaleOffset = -height;
  }

  // Adjust scale unit size based on screen height
  double _getScaleUnitSize() {
    // Base the unit size on a percentage of the screen height
    return MediaQuery.of(context).size.height * 0.025;
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
      int feet = totalInches ~/ 12; // Divide to get feet
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
    // Get device size
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Calculate responsive values
    final double verticalSpacing = screenHeight * 0.02;
    final double horizontalPadding = screenWidth * 0.06;

    // Update scale unit size based on screen height
    scaleUnitSize = _getScaleUnitSize();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER WITH NAVIGATION AND PROGRESS
              SizedBox(height: verticalSpacing),
              Row(
                children: [
                  _buildBackButton(context),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(child: ProgressBar(totalSteps: 7, currentStep: 4)),
                  SizedBox(width: screenWidth * 0.04),
                  _buildSkipButton(),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),

              // QUESTION HEADER
              _buildQuestionHeader(),

              SizedBox(height: screenHeight * 0.04),

              // UNIT SELECTION TOGGLE
              _buildUnitToggle(screenWidth),

              SizedBox(height: screenHeight * 0.04),

              // VERTICAL SCALE SLIDER WITH INTERACTIVE CONTROLS
              Expanded(child: _buildHeightScale()),

              // HEIGHT DISPLAY
              _buildHeightDisplay(),

              SizedBox(height: verticalSpacing),

              // CONTINUE BUTTON
              _buildContinueButton(context),

              SizedBox(height: verticalSpacing * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.12;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(child: Icon(Icons.arrow_back_ios_new, size: size * 0.4)),
      ),
    );
  }

  Widget _buildSkipButton() {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Text(
      'Skip',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16 * textScaleFactor,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildQuestionHeader() {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final double fontSize = MediaQuery.of(context).size.width * 0.07;

    return Text(
      'What is your height?',
      style: GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildUnitToggle(double screenWidth) {
    final double toggleWidth = screenWidth * 0.4;
    final double toggleHeight = MediaQuery.of(context).size.height * 0.06;
    final double fontSize = screenWidth * 0.04;

    return Row(
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
            width: toggleWidth,
            padding: EdgeInsets.symmetric(vertical: toggleHeight * 0.25),
            decoration: BoxDecoration(
              color: isInches ? const Color(0xFF1E2B45) : Colors.white,
              borderRadius: BorderRadius.circular(toggleHeight * 0.2),
              border: Border.all(
                color: isInches ? const Color(0xFF1E2B45) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                'inches',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isInches ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
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
            width: toggleWidth,
            padding: EdgeInsets.symmetric(vertical: toggleHeight * 0.25),
            decoration: BoxDecoration(
              color: !isInches ? const Color(0xFF1E2B45) : Colors.white,
              borderRadius: BorderRadius.circular(toggleHeight * 0.2),
              border: Border.all(
                color: !isInches ? const Color(0xFF1E2B45) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                'cm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: !isInches ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeightScale() {
    final double scaleWidth = MediaQuery.of(context).size.width * 0.3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: scaleWidth,
              height: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    // DRAG GESTURE HANDLER
                    onVerticalDragUpdate: (details) {
                      _isDecelerating = false;
                      setState(() {
                        scaleOffset += details.delta.dy / scaleUnitSize;
                        _dragVelocity = details.delta.dy / scaleUnitSize;
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

                      _dragVelocity = _dragVelocity.clamp(-0.8, 0.8);

                      _startDeceleration();
                    },
                    child: CustomPaint(
                      size: Size(scaleWidth, constraints.maxHeight),
                      painter: VerticalScalePainter(
                        offset: scaleOffset,
                        unitSize: scaleUnitSize,
                        isInches: isInches,
                        screenWidth: MediaQuery.of(context).size.width,
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
                  width: MediaQuery.of(context).size.height * 0.15,
                  height: scaleWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/WeightIndicatorMain.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeightDisplay() {
    final double displayFontSize = MediaQuery.of(context).size.width * 0.15;
    final double unitFontSize = MediaQuery.of(context).size.width * 0.05;

    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: isInches ? formattedHeight() : height.toStringAsFixed(1),
              style: GoogleFonts.plusJakartaSans(
                fontSize: displayFontSize,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
              ),
            ),
            TextSpan(
              text: isInches ? '' : ' cm',
              style: GoogleFonts.plusJakartaSans(
                fontSize: unitFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return CustomButton(
      text: "Continue",
      iconPath: 'images/SignInAddIcon.png',
      onPressed: () {
        final onboardingNotifier = ref.read(onboardingProvider.notifier);

        onboardingNotifier.updateHeightCm(
          isInches ? inchesToCm(height) : height, // Convert only if in inches
        );

        print("✅ Height saved: ${ref.read(onboardingProvider).height_cm} cm");

        Navigator.pushNamed(context, '/questions/age');
      },
    );
  }
}

// Custom Scale Painter for Height Input
class VerticalScalePainter extends CustomPainter {
  final double offset;
  final double unitSize;
  final bool isInches;
  final double screenWidth;

  VerticalScalePainter({
    required this.offset,
    required this.unitSize,
    required this.isInches,
    required this.screenWidth,
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

    // Calculate responsive tick sizes
    final double majorTickWidth = size.width * 0.8;
    final double minorTickWidth = size.width * 0.4;
    final double textSize = screenWidth * 0.03;

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
        tickWidth = majorTickWidth;
        tickPaint
          ..color = const Color(0xFF5D6A85)
          ..strokeWidth = 2.0;
      } else if (isSubTick) {
        tickWidth = minorTickWidth;
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
            fontSize: textSize,
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
