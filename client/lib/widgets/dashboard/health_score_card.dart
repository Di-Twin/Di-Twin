import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthScoreCard extends StatefulWidget {
  const HealthScoreCard({super.key});

  @override
  _HealthScoreCardState createState() => _HealthScoreCardState();
}

class _HealthScoreCardState extends State<HealthScoreCard> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<Map<String, dynamic>> scores = [
    {
      'score': 88,
      'title': 'Health Score',
      'description': 'Based on your data, your health status is above average.',
      'backgroundColor': const Color(0xFFA855F7), // Purple
    },
    {
      'score': 75,
      'title': 'Metabolic Score',
      'description': 'Your metabolic health is good but can be improved.',
      'backgroundColor': const Color(0xFFEAB308), // Yellow
    },
    {
      'score': 90,
      'title': 'Sleep Score',
      'description': 'You have an excellent sleep routine!',
      'backgroundColor': const Color(0xFF22C55E), // Green
    },
    {
      'score': 82,
      'title': 'Food Score',
      'description': 'Your nutrition intake is well-balanced.',
      'backgroundColor': const Color(0xFF3B82F6), // Blue
    },
    {
      'score': 78,
      'title': 'Activity Score',
      'description': 'You are moderately active, aim for more movement.',
      'backgroundColor': const Color(0xFFF43F5E), // Red
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll effect
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < scores.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Di-Twin Scores',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          width: MediaQuery.of(context).size.width - 40, // Adjust width
          child: PageView.builder(
            key: const PageStorageKey<String>(
              'healthScorePageView',
            ), // Add a PageStorageKey
            controller: _pageController,
            itemCount: scores.length,
            itemBuilder: (context, index) {
              return _buildScoreCard(
                scores[index]['score'],
                scores[index]['title'],
                scores[index]['description'],
                scores[index]['backgroundColor'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    int score,
    String title,
    String description,
    Color backgroundColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center, // Center everything in the Stack
            children: [
              // Texture Image as Background
              Positioned(
                top: -5, // Adjust positioning to fine-tune the effect
                left: -5,
                child: Opacity(
                  opacity: 0.2, // Adjust visibility
                  child: Image.asset(
                    'images/testure_score.png',
                    width: 100, // Adjust size
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Score Box
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: backgroundColor, // Dynamic background color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
