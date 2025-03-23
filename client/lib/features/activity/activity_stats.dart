import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class ActivityStats extends StatefulWidget {
  const ActivityStats({Key? key}) : super(key: key);

  @override
  State<ActivityStats> createState() => _ActivityStatsState();
}

class _ActivityStatsState extends State<ActivityStats> with TickerProviderStateMixin {
  final Map<String, dynamic> activityData = {
    'Yoga': {
      'value': 72,
      'color': const Color(0xFF1E293B),
    },
    'Jogging': {
      'value': 48,
      'color': const Color(0xFF3B82F6),
    },
    'Biking': {
      'value': 11,
      'color': const Color(0xFFEF4444),
    },
    'Hiking': {
      'value': 8,
      'color': const Color(0xFF8B5CF6),
    },
    'Tennis': {
      'value': 21,
      'color': const Color(0xFF94A3B8),
    },
  };

  // Animation controllers for each activity block
  late final Map<String, AnimationController> _controllers = {};
  late final List<AnimationController> _decorativeControllers = [];
  
  // Additional decorative blocks
  final List<Map<String, dynamic>> _decorativeBlocks = [];
  final int _numDecorativeBlocks = 8;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers for activity blocks
    activityData.forEach((key, value) {
      _controllers[key] = AnimationController(
        duration: Duration(milliseconds: 800 + _random.nextInt(700)),
        vsync: this,
      );
    });
    
    // Generate decorative blocks with random positions
    for (int i = 0; i < _numDecorativeBlocks; i++) {
      _decorativeBlocks.add({
        'xPos': 0.1 + _random.nextDouble() * 0.8, // Random x position between 0.1 and 0.9
        'yPos': 0.1 + _random.nextDouble() * 0.8, // Random y position between 0.1 and 0.9
        'size': 0.05 + _random.nextDouble() * 0.1, // Random size between 0.05 and 0.15
        'rotation': (_random.nextDouble() - 0.5) * 0.8, // Random rotation between -0.4 and 0.4
      });
      
      _decorativeControllers.add(
        AnimationController(
          duration: Duration(milliseconds: 600 + _random.nextInt(800)),
          vsync: this,
        ),
      );
    }
    
    // Start animations with staggered delays
    _startAnimations();
  }
  
  void _startAnimations() async {
    // Start activity block animations with staggered delay
    int delay = 100;
    activityData.forEach((key, value) async {
      await Future.delayed(Duration(milliseconds: delay));
      _controllers[key]?.forward();
      delay += 200;
    });
    
    // Start decorative block animations with staggered delay
    delay = 150;
    for (var controller in _decorativeControllers) {
      await Future.delayed(Duration(milliseconds: delay));
      controller.forward();
      delay += 150;
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    _controllers.values.forEach((controller) => controller.dispose());
    _decorativeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_horiz, size: 24.sp, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'Activity Stats',
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 16.h),
                _buildActivityLegend(),
                SizedBox(height: 24.h),
                _buildActivityBlocks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLegend() {
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: activityData.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: entry.value['color'],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              entry.key,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActivityBlocks() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          
          return Stack(
            children: [
              // Decorative blocks
              ..._buildDecorativeBlocks(maxWidth, maxHeight),
              
              // Activity blocks - positioning to match the image
              // Jogging - Blue 48
              _buildAnimatedBlock(
                'Jogging',
                activityData['Jogging']['value'],
                activityData['Jogging']['color'],
                controller: _controllers['Jogging']!,
                left: maxWidth * 0.05,
                top: maxWidth * 0.45,
                targetTop: maxHeight * 0.25,
                width: maxWidth * 0.42,
                height: maxWidth * 0.42,
              ),
              
              // Tennis - Gray 21
              _buildAnimatedBlock(
                'Tennis',
                activityData['Tennis']['value'],
                activityData['Tennis']['color'],
                controller: _controllers['Tennis']!,
                right: maxWidth * 0.08,
                top: -maxWidth * 0.28,
                targetTop: maxHeight * 0.2,
                width: maxWidth * 0.3,
                height: maxWidth * 0.3,
              ),
              
              // Biking - Red 11
              _buildAnimatedBlock(
                'Biking',
                activityData['Biking']['value'],
                activityData['Biking']['color'],
                controller: _controllers['Biking']!,
                right: maxWidth * 0.05,
                top: -maxWidth * 0.3,
                targetTop: maxHeight * 0.4,
                width: maxWidth * 0.3,
                height: maxWidth * 0.3,
              ),
              
              // Hiking - Purple 8
              _buildAnimatedBlock(
                'Hiking',
                activityData['Hiking']['value'],
                activityData['Hiking']['color'],
                controller: _controllers['Hiking']!,
                left: maxWidth * 0.06,
                top: -maxWidth * 0.2,
                targetTop: maxHeight * 0.65,
                width: maxWidth * 0.2,
                height: maxWidth * 0.2,
              ),
              
              // Yoga - Dark Blue 72
              _buildAnimatedBlock(
                'Yoga',
                activityData['Yoga']['value'],
                activityData['Yoga']['color'],
                controller: _controllers['Yoga']!,
                left: maxWidth * 0.35,
                top: -maxWidth * 0.55,
                targetTop: maxHeight * 0.55,
                width: maxWidth * 0.55,
                height: maxWidth * 0.55,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDecorativeBlocks(double maxWidth, double maxHeight) {
    List<Widget> blocks = [];
    
    for (int i = 0; i < _decorativeBlocks.length; i++) {
      final block = _decorativeBlocks[i];
      final controller = _decorativeControllers[i];
      
      blocks.add(
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // Animation for falling and bouncing effect
            final animation = CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutBack,
            );
            
            // Calculate position based on animation value
            final startY = -maxWidth * block['size'];
            final targetY = maxHeight * block['yPos'];
            final currentY = startY + (targetY - startY) * animation.value;
            
            return Positioned(
              left: maxWidth * block['xPos'],
              top: currentY,
              child: Transform.rotate(
                angle: block['rotation'],
                child: Container(
                  width: maxWidth * block['size'],
                  height: maxWidth * block['size'],
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return blocks;
  }

  Widget _buildAnimatedBlock(
    String activity,
    int value,
    Color color, {
    required AnimationController controller,
    double? left,
    double? right,
    required double top,
    required double targetTop,
    required double width,
    required double height,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Animation for falling and bouncing effect
        final animation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        );
        
        // Calculate current position based on animation value
        final currentTop = top + (targetTop - top) * animation.value;
        
        return Positioned(
          left: left,
          right: right,
          top: currentTop,
          child: _buildActivityBlock(
            activity,
            value,
            color,
            width: width,
            height: height,
          ),
        );
      },
    );
  }

  Widget _buildActivityBlock(String activity, int value, Color color, {required double width, required double height}) {
    // Calculate rotation based on activity to make it consistent and match the image
    double rotation = 0.0;
    switch (activity) {
      case 'Jogging':
        rotation = -0.1;
        break;
      case 'Tennis':
        rotation = 0.15;
        break;
      case 'Biking':
        rotation = 0.2;
        break;
      case 'Hiking':
        rotation = -0.15;
        break;
      case 'Yoga':
        rotation = 0.0;
        break;
    }
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: width * 0.4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}