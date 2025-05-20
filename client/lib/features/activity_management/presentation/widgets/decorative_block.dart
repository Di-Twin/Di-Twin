import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DecorativeBlock extends StatelessWidget {
  final AnimationController controller;
  final double xPos;
  final double yPos;
  final double size;
  final double rotation;
  final double maxWidth;
  final double maxHeight;
  
  const DecorativeBlock({
    super.key,
    required this.controller,
    required this.xPos,
    required this.yPos,
    required this.size,
    required this.rotation,
    required this.maxWidth,
    required this.maxHeight,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Animation for falling and bouncing effect
        final animation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        );
        
        // Calculate position based on animation value
        final startY = -maxWidth * size;
        final targetY = maxHeight * yPos;
        final currentY = startY + (targetY - startY) * animation.value;
        
        return Positioned(
          left: maxWidth * xPos,
          top: currentY,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: maxWidth * size,
              height: maxWidth * size,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
