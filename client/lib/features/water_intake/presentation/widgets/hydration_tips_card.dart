import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class HydrationTipsCard extends StatefulWidget {
  const HydrationTipsCard({super.key});

  @override
  State<HydrationTipsCard> createState() => _HydrationTipsCardState();
}

class _HydrationTipsCardState extends State<HydrationTipsCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _currentTipIndex = 0;

  final List<Map<String, dynamic>> _tips = [
    {
      'icon': '💡',
      'title': 'Start Your Day Right',
      'description': 'Drink a glass of water as soon as you wake up to kickstart your metabolism.',
      'color': Color(0xFF06B6D4),
    },
    {
      'icon': '⏰',
      'title': 'Set Regular Reminders',
      'description': 'Use hourly reminders to maintain consistent hydration throughout the day.',
      'color': Color(0xFF8B5CF6),
    },
    {
      'icon': '🍋',
      'title': 'Add Natural Flavor',
      'description': 'Infuse your water with lemon, cucumber, or mint for variety and taste.',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': '🏃‍♂️',
      'title': 'Hydrate Before Exercise',
      'description': 'Drink water 30 minutes before workouts to optimize performance.',
      'color': Color(0xFFEF4444),
    },
    {
      'icon': '🌡️',
      'title': 'Monitor Your Urine',
      'description': 'Light yellow indicates good hydration, dark yellow means drink more.',
      'color': Color(0xFF10B981),
    },
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();

    // Auto-rotate tips every 10 seconds
    _startTipRotation();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _nextTip();
        _startTipRotation();
      }
    });
  }

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
    });

    _slideController.reset();
    _slideController.forward();
  }

  void _previousTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex - 1 + _tips.length) % _tips.length;
    });

    _slideController.reset();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTip = _tips[_currentTipIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            currentTip['color'].withOpacity(0.1),
            currentTip['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentTip['color'].withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hydration Tips',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _previousTip,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: currentTip['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: currentTip['color'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _nextTip,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: currentTip['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: currentTip['color'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tip content with animation
            SlideTransition(
              position: _slideAnimation,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currentTip['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentTip['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTip['title'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentTip['description'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Progress indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _tips.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentTipIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentTipIndex
                        ? currentTip['color']
                        : currentTip['color'].withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
