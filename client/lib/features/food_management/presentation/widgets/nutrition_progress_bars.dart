import 'package:flutter/material.dart';

class NutritionProgressBars extends StatelessWidget {
  final Map<String, dynamic> currentData;
  final Animation<double> progressAnimation;

  const NutritionProgressBars({
    super.key,
    required this.currentData,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0E2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Foreground (animated)
                  Container(
                    height: 40,
                    width: (screenWidth - 48) *
                        currentData['blueProgress'] *
                        progressAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF1A73E8),
                          Color(0xFF4D8EFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A73E8).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD0D0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Foreground (animated)
                  Container(
                    height: 40,
                    width: (screenWidth - 48) *
                        currentData['redProgress'] *
                        progressAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFF8E8E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Foreground (animated)
                  Container(
                    height: 40,
                    width: (screenWidth - 48) *
                        currentData['navyProgress'] *
                        progressAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF334155),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
