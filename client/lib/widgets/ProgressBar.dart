import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    return Container(
      width: 100,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}