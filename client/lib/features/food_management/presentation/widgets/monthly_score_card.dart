import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyScoreCard extends StatelessWidget {
  final bool isSmallScreen;
  final Animation<double>? scoreScaleAnimation;
  final Animation<double>? scoreOpacityAnimation;
  final Animation<double>? scoreRotationAnimation;

  const MonthlyScoreCard({
    super.key,
    required this.isSmallScreen,
    this.scoreScaleAnimation,
    this.scoreOpacityAnimation,
    this.scoreRotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 10 : 16,
        horizontal: isSmallScreen ? 12 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF66BB6A),
          ], // Green color scheme for nutrition
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left side - Score and title
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '🥗',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 20),
                  ), // Food emoji
                ),
                SizedBox(width: isSmallScreen ? 6 : 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    scoreScaleAnimation != null && 
                    scoreOpacityAnimation != null && 
                    scoreRotationAnimation != null
                        ? ScaleTransition(
                            scale: scoreScaleAnimation!,
                            child: FadeTransition(
                              opacity: scoreOpacityAnimation!,
                              child: RotationTransition(
                                turns: scoreRotationAnimation!,
                                child: Text(
                                  '78',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: isSmallScreen ? 20 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            '78',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isSmallScreen ? 20 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    Text(
                      'This month Food score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 10 : 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right side - Stats in a row
          Row(
            children: [
              _buildCompactStatItem(
                Icons.local_fire_department,
                '2,450',
                'kcal',
                isSmallScreen,
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              _buildCompactStatItem(
                Icons.restaurant,
                '32',
                'meals',
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(
    IconData icon,
    String value,
    String label,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: isSmallScreen ? 12 : 16),
            SizedBox(width: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 10 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 8 : 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
