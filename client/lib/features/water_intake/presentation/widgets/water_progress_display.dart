// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:shared_preferences/shared_preferences.dart';

// class WaterProgressDisplay extends StatefulWidget {
//   final double dailyGoal; // Daily water intake goal in ml
//   final String? date; // Optional date parameter (defaults to today)

//   const WaterProgressDisplay({
//     super.key,
//     required this.dailyGoal,
//     this.date,
//   });

//   @override
//   State<WaterProgressDisplay> createState() => _WaterProgressDisplayState();
// }

// class _WaterProgressDisplayState extends State<WaterProgressDisplay>
//     with TickerProviderStateMixin {
//   late AnimationController _progressController;
//   late AnimationController _pulseController;
//   late AnimationController _shimmerController;
//   late Animation<double> _progressAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _shimmerAnimation;

//   List<double> _waterIntake = [];
//   double _totalWaterTaken = 0;
//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _fetchWaterData();
//   }

//   void _initializeAnimations() {
//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );

//     _progressAnimation = Tween<double>(begin: 0.0, end: _progressPercentage)
//         .animate(CurvedAnimation(
//       parent: _progressController,
//       curve: Curves.easeOutCubic,
//     ));

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
//       CurvedAnimation(
//         parent: _shimmerController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _progressController.forward();
//     _shimmerController.repeat();
//   }

//   double get _progressPercentage {
//     if (widget.dailyGoal <= 0) return 0;
//     return (_totalWaterTaken / widget.dailyGoal * 100).clamp(0, 100);
//   }

//   bool get _isGoalAchieved => _progressPercentage >= 100;

//   Future<void> _fetchWaterData() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('access_token');
      
//       if (token == null) {
//         throw Exception('Authentication required');
//       }

//       final date = widget.date ?? _getCurrentDate();
//       final response = await http.get(
//         Uri.parse('https://test-prod-f427.onrender.com/api/health-metrics/?date=$date'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           setState(() {
//             // Fix type conversion by ensuring we get doubles
//             _waterIntake = (data['data']['water_intake'] as List<dynamic>? ?? [])
//                 .map<double>((e) => (e as num).toDouble())
//                 .toList();
//             _totalWaterTaken = (data['data']['total_water_taken'] ?? 0).toDouble();
//             _isLoading = false;
//           });

//           _updateAnimations();
//         } else {
//           throw Exception(data['message'] ?? 'Failed to fetch water data');
//         }
//       } else {
//         throw Exception('Server responded with status ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching water data: $e');
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//     }
//   }

//   String _getCurrentDate() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//   }

//   void _updateAnimations() {
//     _progressAnimation = Tween<double>(
//       begin: _progressAnimation.value,
//       end: _progressPercentage / 100,
//     ).animate(CurvedAnimation(
//       parent: _progressController,
//       curve: Curves.easeOutCubic,
//     ));

//     _progressController.reset();
//     _progressController.forward();

//     if (_isGoalAchieved && !_pulseController.isAnimating) {
//       _pulseController.repeat(reverse: true);
//     } else if (!_isGoalAchieved && _pulseController.isAnimating) {
//       _pulseController.stop();
//       _pulseController.reset();
//     }
//   }

//   @override
//   void dispose() {
//     _progressController.dispose();
//     _pulseController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return _buildLoadingState();
//     }

//     if (_hasError) {
//       return _buildErrorState();
//     }

//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: 280.w,
//         maxHeight: 160.h,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AnimatedBuilder(
//             animation: Listenable.merge([
//               _progressAnimation,
//               _pulseAnimation,
//               _shimmerAnimation
//             ]),
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _isGoalAchieved ? _pulseAnimation.value : 1.0,
//                 child: Container(
//                   width: 140.w,
//                   height: 140.w,
//                   child: Stack(
//                     children: [
//                       if (_isGoalAchieved)
//                         Container(
//                           width: 140.w,
//                           height: 140.w,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF0EA5E9).withOpacity(0.3),
//                                 blurRadius: 20,
//                                 spreadRadius: 5,
//                               ),
//                             ],
//                           ),
//                         ),
//                       Container(
//                         width: 140.w,
//                         height: 140.w,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               const Color(0xFFF1F5F9),
//                               const Color(0xFFE2E8F0),
//                             ],
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                       ),
//                       CustomPaint(
//                         size: Size(140.w, 140.w),
//                         painter: EnhancedCircularProgressPainter(
//                           progress: _progressAnimation.value,
//                           shimmerProgress: _shimmerAnimation.value,
//                           isGoalAchieved: _isGoalAchieved,
//                         ),
//                       ),
//                       Positioned.fill(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ShaderMask(
//                               shaderCallback: (bounds) => LinearGradient(
//                                 colors: _isGoalAchieved
//                                     ? [
//                                         const Color(0xFF10B981),
//                                         const Color(0xFF059669),
//                                       ]
//                                     : [
//                                         const Color(0xFF0EA5E9),
//                                         const Color(0xFF0284C7),
//                                       ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ).createShader(bounds),
//                               child: Text(
//                                 '${_totalWaterTaken.toInt()}ml',
//                                 style: GoogleFonts.plusJakartaSans(
//                                   fontSize: 24.sp,
//                                   fontWeight: FontWeight.w900,
//                                   color: Colors.white,
//                                   letterSpacing: -0.5,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 2.h),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 8.w,
//                                 vertical: 2.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _isGoalAchieved
//                                     ? const Color(0xFF10B981).withOpacity(0.1)
//                                     : const Color(0xFF0EA5E9).withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Text(
//                                 'Today',
//                                 style: GoogleFonts.plusJakartaSans(
//                                   fontSize: 12.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: _isGoalAchieved
//                                       ? const Color(0xFF10B981)
//                                       : const Color(0xFF0EA5E9),
//                                 ),
//                               ),
//                             ),
//                             if (_isGoalAchieved) ...[
//                               SizedBox(height: 4.h),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6.w,
//                                   vertical: 1.h,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       const Color(0xFFFBBF24),
//                                       const Color(0xFFF59E0B),
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(6.r),
//                                 ),
//                                 child: Text(
//                                   '🎉',
//                                   style: TextStyle(fontSize: 10.sp),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       width: 140.w,
//       height: 140.w,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.grey[200],
//       ),
//       child: Center(
//         child: CircularProgressIndicator(
//           color: Colors.blue[400],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Container(
//       width: 140.w,
//       height: 140.w,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.grey[200],
//       ),
//       child: Center(
//         child: IconButton(
//           icon: Icon(Icons.refresh, color: Colors.red[400]),
//           onPressed: _fetchWaterData,
//         ),
//       ),
//     );
//   }
// }

// class EnhancedCircularProgressPainter extends CustomPainter {
//   final double progress;
//   final double shimmerProgress;
//   final bool isGoalAchieved;

//   EnhancedCircularProgressPainter({
//     required this.progress,
//     required this.shimmerProgress,
//     required this.isGoalAchieved,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 10;

//     // Background track with inner shadow effect
//     final backgroundPaint = Paint()
//       ..color = const Color(0xFFE2E8F0)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 8
//       ..strokeCap = StrokeCap.round;

//     canvas.drawCircle(center, radius, backgroundPaint);

//     if (progress > 0) {
//       // Main progress arc with gradient effect
//       final rect = Rect.fromCircle(center: center, radius: radius);
//       final gradient = SweepGradient(
//         startAngle: -math.pi / 2,
//         endAngle: -math.pi / 2 + (2 * math.pi * progress),
//         colors: isGoalAchieved
//             ? [
//           const Color(0xFF10B981),
//           const Color(0xFF059669),
//           const Color(0xFF047857),
//           const Color(0xFF10B981),
//         ]
//             : [
//           const Color(0xFF0EA5E9),
//           const Color(0xFF0284C7),
//           const Color(0xFF0369A1),
//           const Color(0xFF0EA5E9),
//         ],
//         stops: const [0.0, 0.3, 0.7, 1.0],
//       );

//       final progressPaint = Paint()
//         ..shader = gradient.createShader(rect)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 8
//         ..strokeCap = StrokeCap.round;

//       // Draw main progress arc
//       canvas.drawArc(
//         rect,
//         -math.pi / 2,
//         2 * math.pi * progress,
//         false,
//         progressPaint,
//       );

//       // Add shimmer effect
//       if (shimmerProgress >= 0 && shimmerProgress <= 1) {
//         final shimmerAngle = -math.pi / 2 + (2 * math.pi * progress * shimmerProgress);
//         final shimmerPaint = Paint()
//           ..color = Colors.white.withOpacity(0.6)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 8
//           ..strokeCap = StrokeCap.round;

//         canvas.drawArc(
//           rect,
//           shimmerAngle - 0.1,
//           0.2,
//           false,
//           shimmerPaint,
//         );
//       }

//       // Add glow effect for achieved goals
//       if (isGoalAchieved) {
//         final glowPaint = Paint()
//           ..color = const Color(0xFF10B981).withOpacity(0.3)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 12
//           ..strokeCap = StrokeCap.round
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

//         canvas.drawArc(
//           rect,
//           -math.pi / 2,
//           2 * math.pi * progress,
//           false,
//           glowPaint,
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class ShimmerPainter extends CustomPainter {
//   final double shimmerProgress;

//   ShimmerPainter({required this.shimmerProgress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (shimmerProgress < 0 || shimmerProgress > 1) return;

//     final shimmerWidth = size.width * 0.3;
//     final shimmerPosition = (size.width + shimmerWidth) * shimmerProgress - shimmerWidth;

//     final gradient = LinearGradient(
//       begin: Alignment.centerLeft,
//       end: Alignment.centerRight,
//       colors: [
//         Colors.transparent,
//         Colors.white.withOpacity(0.4),
//         Colors.white.withOpacity(0.6),
//         Colors.white.withOpacity(0.4),
//         Colors.transparent,
//       ],
//       stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
//     );

//     final paint = Paint()
//       ..shader = gradient.createShader(
//         Rect.fromLTWH(shimmerPosition, 0, shimmerWidth, size.height),
//       );

//     canvas.drawRect(
//       Rect.fromLTWH(shimmerPosition, 0, shimmerWidth, size.height),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class WaterProgressDisplay extends StatefulWidget {
  final double goal;
  final double consumed;

  const WaterProgressDisplay({
    super.key,
    required this.goal,
    required this.consumed,
  });

  @override
  State<WaterProgressDisplay> createState() => _WaterProgressDisplayState();
}

class _WaterProgressDisplayState extends State<WaterProgressDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: _progressPercentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  double get _progressPercentage {
    if (widget.goal <= 0) return 0;
    return (widget.consumed / widget.goal).clamp(0, 1);
  }

  bool get _isGoalAchieved => _progressPercentage >= 1;

  @override
  void didUpdateWidget(WaterProgressDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed || oldWidget.goal != widget.goal) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isGoalAchieved ? _pulseAnimation.value : 1,
          child: Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: _isGoalAchieved
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF1F5F9),
                        Color(0xFFE2E8F0),
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
                CustomPaint(
                  size: Size(140.w, 140.w),
                  painter: _WaterProgressPainter(
                    progress: _animation.value,
                    isGoalAchieved: _isGoalAchieved,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: _isGoalAchieved
                              ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  const Color(0xFF0EA5E9),
                                  const Color(0xFF0284C7),
                                ],
                        ).createShader(bounds),
                        child: Text(
                          '${widget.consumed.toInt()}ml',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _isGoalAchieved
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFF0EA5E9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _isGoalAchieved
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0EA5E9),
                          ),
                        ),
                      ),
                      if (_isGoalAchieved) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFBBF24),
                                Color(0xFFF59E0B),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text('🎉', style: TextStyle(fontSize: 10.sp)),
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
    );
  }
}

class _WaterProgressPainter extends CustomPainter {
  final double progress;
  final bool isGoalAchieved;

  _WaterProgressPainter({
    required this.progress,
    required this.isGoalAchieved,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      // Progress arc
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * progress),
        colors: isGoalAchieved
            ? [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ]
            : [
                const Color(0xFF0EA5E9),
                const Color(0xFF0284C7),
              ],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Glow effect for achieved goals
      if (isGoalAchieved) {
        final glowPaint = Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
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
  bool shouldRepaint(_WaterProgressPainter oldDelegate) =>
      progress != oldDelegate.progress || isGoalAchieved != oldDelegate.isGoalAchieved;
}