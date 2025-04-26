import 'package:flutter/material.dart';
import 'activity_block.dart';

class AnimatedActivityBlock extends StatelessWidget {
  final String activity;
  final int value;
  final Color color;
  final AnimationController controller;
  final double? left;
  final double? right;
  final double top;
  final double targetTop;
  final double width;
  final double height;
  final double rotation;
  
  const AnimatedActivityBlock({
    super.key,
    required this.activity,
    required this.value,
    required this.color,
    required this.controller,
    this.left,
    this.right,
    required this.top,
    required this.targetTop,
    required this.width,
    required this.height,
    this.rotation = 0.0,
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
        
        // Calculate current position based on animation value
        final currentTop = top + (targetTop - top) * animation.value;
        
        return Positioned(
          left: left,
          right: right,
          top: currentTop,
          child: ActivityBlock(
            activity: activity,
            value: value,
            color: color,
            width: width,
            height: height,
            rotation: rotation,
          ),
        );
      },
    );
  }
}
