import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class WeightInputPage extends ConsumerStatefulWidget {
  const WeightInputPage({super.key});

  @override
  ConsumerState<WeightInputPage> createState() => _WeightInputPageState();
}

class _WeightInputPageState extends ConsumerState<WeightInputPage>
    with SingleTickerProviderStateMixin {
  // State variables
  bool isLbs = true;
  double weight = 140.0;
  double _lastWeight = 140.0;

  // Scale parameters
  double scaleOffset = 0.0;
  final double scaleUnitSize = 20.0;

  // Physics scrolling variables
  double _dragVelocity = 0.0;
  bool _isDecelerating = false;

  @override
  void initState() {
    super.initState();
    scaleOffset = -weight;

    // Load weight from Riverpod state if available
    final savedWeight = ref.read(onboardingProvider).weight_kg;
    if (savedWeight > 0) {
      setState(() {
        weight = savedWeight;
        isLbs = false;
        scaleOffset = -weight;
      });
    }
  }

  // Unit conversion functions
  double lbsToKg(double lbs) => lbs * 0.453592;
  double kgToLbs(double kg) => kg * 2.20462;

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

  // Save weight to Riverpod state
  void saveWeight() {
    double weightInKg = isLbs ? lbsToKg(weight) : weight;

    // ✅ Round to 2 decimal places
    weightInKg = double.parse(weightInKg.toStringAsFixed(2));

    ref.read(onboardingProvider.notifier).updateWeightKg(weightInKg);
    print("✅ Saved Weight in KG: $weightInKg");
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
      if ((previousWeight.floor() != weight.floor())) {
        HapticFeedback.mediumImpact();
      }
    });

    Future.delayed(const Duration(milliseconds: 16), _decelerateScale);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 360 || size.height < 600;

    // Dynamic spacing based on screen size
    final topPadding = size.height * 0.02;
    final headerSpacing = size.height * 0.04;
    final contentSpacing =
        isSmallDevice ? size.height * 0.03 : size.height * 0.05;

    // Responsive text sizes
    final headingSize = isSmallDevice ? 24.0 : 30.0;
    final weightSize = isSmallDevice ? 60.0 : 80.0;
    final unitSize = isSmallDevice ? 18.0 : 24.0;

    // Responsive button dimensions
    final buttonWidth = size.width * 0.4;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topPadding),

              // Header with back button, progress bar and skip button
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: ProgressBar(totalSteps: 7, currentStep: 3),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              SizedBox(height: headerSpacing),

              // Title
              Text(
                'What is your weight?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: headingSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: contentSpacing),

              // Unit toggle buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    child: _unitButton('lbs', isLbs, buttonWidth),
                  ),
                  const SizedBox(width: 8),
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
                    child: _unitButton('kg', !isLbs, buttonWidth),
                  ),
                ],
              ),

              SizedBox(height: contentSpacing),

              // Weight display
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: weight.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: weightSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800],
                          ),
                        ),
                        TextSpan(
                          text: ' ${isLbs ? 'lbs' : 'kg'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: unitSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: contentSpacing),

              // Weight scale
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.15,
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
                            _startDeceleration();
                          },
                          child: CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
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
                  Positioned(
                    child: Image.asset(
                      'images/WeightIndicatorMain.png',
                      width: 40,
                      height: size.height * 0.12,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.02),
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    saveWeight(); // Save weight before proceeding
                    Navigator.pushNamed(context, '/questions/height');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitButton(String text, bool isActive, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E2B45) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF1E2B45) : Colors.grey[300]!,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey[700],
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

    // Scale text size based on canvas size
    final double textScale = size.height / 120;
    final double fontSize = 12 * textScale;

    // ✅ Fixed: Correct Weight Limits
    final double minValue = isLbs ? 44.1 : 20.0;
    final double maxValue = isLbs ? 330.7 : 150.0;

    // ✅ Allow Drawing a Few Units Beyond Min/Max
    final double minTick = (minValue - 1).floor().toDouble();
    final double maxTick = (maxValue + 1).ceil().toDouble();

    for (double i = minTick; i <= maxTick; i += 0.5) {
      // ✅ Increased Step Precision
      final double x = centerX + (i + offset) * unitSize;

      // Skip ticks that are off-screen for performance
      if (x < -50 || x > size.width + 50) continue;

      // ✅ Define Tick Styling
      bool isMajorTick = i % 5 == 0;
      bool isSubTick = i % 1 == 0;
      bool isEdgeTick = (i == 44.1 || i == 330.7); // ✅ Edge markers

      double tickHeight =
          isMajorTick
              ? size.height * 0.5
              : (isSubTick
                  ? size.height * 0.25
                  : (isEdgeTick ? size.height * 0.16 : size.height * 0.08));

      Paint tickPaint =
          Paint()
            ..color =
                isMajorTick
                    ? const Color(0xFF5D6A85)
                    : (isEdgeTick
                        ? const Color(0xFF00BFFF)
                        : const Color(0xFFBEC5D2))
            ..strokeWidth = isMajorTick ? 2.0 : 1.0;

      // ✅ Draw Tick Mark
      canvas.drawLine(
        Offset(x, centerY - tickHeight / 2),
        Offset(x, centerY + tickHeight / 2),
        tickPaint,
      );

      // ✅ Draw Labels for Major & Edge Ticks
      if (isMajorTick || isEdgeTick) {
        final TextSpan span = TextSpan(
          text: i.toStringAsFixed(1), // ✅ Force Decimal Display
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: fontSize,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
