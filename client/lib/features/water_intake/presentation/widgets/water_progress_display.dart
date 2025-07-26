import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/water_intake.dart';
import 'dart:math' as math;

class WaterProgressDisplay extends StatefulWidget {
  final WaterIntake todayIntake;

  const WaterProgressDisplay({
    super.key,
    required this.todayIntake,
  });

  @override
  State<WaterProgressDisplay> createState() => _WaterProgressDisplayState();
}

class _WaterProgressDisplayState extends State<WaterProgressDisplay>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.todayIntake.progressPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _progressController.forward();

    if (widget.todayIntake.progressPercentage >= 100) {
      _pulseController.repeat(reverse: true);
    }

    _shimmerController.repeat();
  }

  @override
  void didUpdateWidget(WaterProgressDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.todayIntake.progressPercentage != widget.todayIntake.progressPercentage) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.todayIntake.progressPercentage / 100,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));

      _progressController.reset();
      _progressController.forward();

      // Start pulse animation if goal achieved
      if (widget.todayIntake.progressPercentage >= 100 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (widget.todayIntake.progressPercentage < 100 && _pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.todayIntake.progressPercentage / 100;
    final isGoalAchieved = widget.todayIntake.progressPercentage >= 100;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 280.w,
        maxHeight: 160.h, // Reduced height since we removed components
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Circular Progress
          AnimatedBuilder(
            animation: Listenable.merge([_progressAnimation, _pulseAnimation, _shimmerAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: isGoalAchieved ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  child: Stack(
                    children: [
                      // Outer glow effect
                      if (isGoalAchieved)
                        Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),

                      // Background circle with gradient
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFF1F5F9),
                              const Color(0xFFE2E8F0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      // Progress circle with enhanced styling
                      CustomPaint(
                        size: Size(140.w, 140.w),
                        painter: EnhancedCircularProgressPainter(
                          progress: _progressAnimation.value,
                          shimmerProgress: _shimmerAnimation.value,
                          isGoalAchieved: isGoalAchieved,
                        ),
                      ),

                      // Center content with enhanced styling
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Water amount with gradient text
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: isGoalAchieved
                                    ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ]
                                    : [
                                  const Color(0xFF0EA5E9),
                                  const Color(0xFF0284C7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                '${widget.todayIntake.totalAmount.toInt()}ml',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // "Today" label with enhanced styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: isGoalAchieved
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : const Color(0xFF0EA5E9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Today',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isGoalAchieved
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF0EA5E9),
                                ),
                              ),
                            ),

                            // Achievement badge
                            if (isGoalAchieved) ...[
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFBBF24),
                                      const Color(0xFFF59E0B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '🎉',
                                  style: TextStyle(fontSize: 10.sp),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EnhancedCircularProgressPainter extends CustomPainter {
  final double progress;
  final double shimmerProgress;
  final bool isGoalAchieved;

  EnhancedCircularProgressPainter({
    required this.progress,
    required this.shimmerProgress,
    required this.isGoalAchieved,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track with inner shadow effect
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      // Main progress arc with gradient effect
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * progress),
        colors: isGoalAchieved
            ? [
          const Color(0xFF10B981),
          const Color(0xFF059669),
          const Color(0xFF047857),
          const Color(0xFF10B981),
        ]
            : [
          const Color(0xFF0EA5E9),
          const Color(0xFF0284C7),
          const Color(0xFF0369A1),
          const Color(0xFF0EA5E9),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      // Draw main progress arc
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Add shimmer effect
      if (shimmerProgress >= 0 && shimmerProgress <= 1) {
        final shimmerAngle = -math.pi / 2 + (2 * math.pi * progress * shimmerProgress);
        final shimmerPaint = Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          rect,
          shimmerAngle - 0.1,
          0.2,
          false,
          shimmerPaint,
        );
      }

      // Add glow effect for achieved goals
      if (isGoalAchieved) {
        final glowPaint = Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawArc(
          rect,
          -math.pi / 2,
          2 * math.pi * progress,
          false,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShimmerPainter extends CustomPainter {
  final double shimmerProgress;

  ShimmerPainter({required this.shimmerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (shimmerProgress < 0 || shimmerProgress > 1) return;

    final shimmerWidth = size.width * 0.3;
    final shimmerPosition = (size.width + shimmerWidth) * shimmerProgress - shimmerWidth;

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.6),
        Colors.white.withOpacity(0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(shimmerPosition, 0, shimmerWidth, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(shimmerPosition, 0, shimmerWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
