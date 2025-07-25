import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaterIntakeIllustration extends StatefulWidget {
  const WaterIntakeIllustration({super.key});

  @override
  State<WaterIntakeIllustration> createState() => _WaterIntakeIllustrationState();
}

class _WaterIntakeIllustrationState extends State<WaterIntakeIllustration>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _floatController;
  late Animation<double> _waveAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        children: [
          // Background water effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WaterWavePainter(_waveAnimation.value),
                );
              },
            ),
          ),

          // Floating water drops
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Positioned(
                  left: (index * 60.w) + 20.w,
                  top: 50.h + _floatAnimation.value + (index * 10),
                  child: Icon(
                    Icons.water_drop,
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                    size: 20.sp + (index * 2),
                  ),
                );
              },
            );
          }),

          // Central water glass illustration
          Center(
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value / 2),
                  child: Container(
                    width: 80.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF06B6D4).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Water level
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF06B6D4).withOpacity(0.3),
                                  const Color(0xFF06B6D4).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.r),
                                bottomRight: Radius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        // Water surface animation
                        Positioned(
                          bottom: 78.h,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) {
                              return Container(
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4).withOpacity(0.8),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double animationValue;

  WaterWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          waveHeight * sin((x / waveLength * 2 * pi) + (animationValue * 2 * pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
