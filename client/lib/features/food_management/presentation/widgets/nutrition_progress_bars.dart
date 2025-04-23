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
            // First row
            Row(
              children: [
                // Blue progress bar (longer)
                Expanded(
                  flex: 7,
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
                        width: screenWidth *
                            0.7 *
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
                const SizedBox(width: 8),
                // Light blue progress bar (shorter)
                Expanded(
                  flex: 3,
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
                        width: screenWidth *
                            0.3 *
                            currentData['lightBlueProgress'] *
                            progressAnimation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF4D8EFF),
                              Color(0xFF81ACFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4D8EFF).withOpacity(0.3),
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
            ),

            const SizedBox(height: 12),

            // Second row
            Row(
              children: [
                // Red progress bar (shorter)
                Expanded(
                  flex: 4,
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
                        width: screenWidth *
                            0.4 *
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
                const SizedBox(width: 8),
                // Pink progress bar (longer)
                Expanded(
                  flex: 6,
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
                        width: screenWidth *
                            0.6 *
                            currentData['pinkProgress'] *
                            progressAnimation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFFF8E8E),
                              Color(0xFFFFC0C0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8E8E).withOpacity(0.3),
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
            ),

            const SizedBox(height: 12),

            // Third row
            Row(
              children: [
                // Navy progress bar (longer)
                Expanded(
                  flex: 8,
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
                        width: screenWidth *
                            0.8 *
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
                const SizedBox(width: 8),
                // Gray progress bar (shorter)
                Expanded(
                  flex: 2,
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
                        width: screenWidth *
                            0.2 *
                            currentData['grayProgress'] *
                            progressAnimation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF64748B),
                              Color(0xFF94A3B8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF64748B).withOpacity(0.3),
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
            ),
          ],
        );
      },
    );
  }
}
