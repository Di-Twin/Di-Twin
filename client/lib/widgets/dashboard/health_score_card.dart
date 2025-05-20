import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/dashboard_provider.dart';
// Add import for SharedPreferences at the top of the file
import 'package:shared_preferences/shared_preferences.dart';

// Modify the HealthScoreCard class to be stateful and load the score from cache
class HealthScoreCard extends StatefulWidget {
  final Function(int)? onScoreUpdated; // Add this callback
  const HealthScoreCard({super.key, this.onScoreUpdated});

  @override
  State<HealthScoreCard> createState() => _HealthScoreCardState();
}

class _HealthScoreCardState extends State<HealthScoreCard> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;
  late DashboardProvider _dashboardProvider;
  List<Map<String, dynamic>> scores = [];
  int healthScore = 0;
  bool isLoading = true;

  // Modify the _HealthScoreCardState class to load the health score from cache first
  // Add this method to load the health score from cache
  Future<void> _loadHealthScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final score = prefs.getInt('health_score') ?? 0;

      setState(() {
        // Update the first score in the scores list if it exists
        if (scores.isNotEmpty) {
          scores[0]['score'] = score;
        } else {
          // Create a default health score entry if scores list is empty
          scores.add({
            'score': score,
            'title': 'Health Score',
            'description':
                'Based on your data, your health status is above average.',
            'backgroundColor': const Color(0xFFA855F7), // Purple
          });
        }
        _isLoading = false;
      });

      print('✅ Health score loaded from cache: $score');
    } catch (e) {
      print('❌ Error loading health score from cache: $e');
    }
  }

  // Modify the initState method to load the cached health score first
  @override
  void initState() {
    super.initState();
    _dashboardProvider = DashboardProvider();
    _loadHealthScore(); // Load cached score first
    _fetchHealthScores(); // Then fetch the latest scores

    // Auto-scroll effect
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (!mounted) return;
      if (_currentPage < scores.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (scores.isNotEmpty) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Modify the _fetchHealthScores method to save the health score to cache
  Future<void> _fetchHealthScores() async {
    try {
      // Get today's date in the format YYYY-MM-DD
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month}-${now.day}";

      final response = await _dashboardProvider.getHealthMetricsScores(dateStr);

      final List<Map<String, dynamic>> apiScores = [];

      // Get the health score
      final healthScore = response.data.healthScore ?? 0;

      // Save the health score to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('health_score', healthScore);
      print('✅ Health score saved to cache: $healthScore');

      // Always add health score
      apiScores.add({
        'score': healthScore,
        'title': 'Health Score',
        'description':
            'Based on your data, your health status is above average.',
        'backgroundColor': const Color(0xFFA855F7), // Purple
      });

      // Add other scores...
      apiScores.add({
        'score': response.data.metabolicScore ?? 0,
        'title': 'Metabolic Score',
        'description': 'Your metabolic health is good but can be improved.',
        'backgroundColor': const Color(0xFFEAB308), // Yellow
      });

      apiScores.add({
        'score': response.data.sleepScore ?? 0,
        'title': 'Sleep Score',
        'description': 'You have an excellent sleep routine!',
        'backgroundColor': const Color(0xFF22C55E), // Green
      });

      apiScores.add({
        'score': response.data.foodScore ?? 0,
        'title': 'Food Score',
        'description': 'Your nutrition intake is well-balanced.',
        'backgroundColor': const Color(0xFF3B82F6), // Blue
      });

      apiScores.add({
        'score': response.data.activityScore ?? 0,
        'title': 'Activity Score',
        'description': 'You are moderately active, aim for more movement.',
        'backgroundColor': const Color(0xFFF43F5E), // Red
      });

      if (widget.onScoreUpdated != null && apiScores.isNotEmpty) {
        // Pass the health score to the parent
        widget.onScoreUpdated!(apiScores[0]['score']);
      }

      setState(() {
        scores = apiScores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching health scores: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the loaded healthScore in your UI
    // Rest of your build method remains the same, but use healthScore instead of hardcoded values
    // ...
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
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : scores.isEmpty
                  ? Center(
                    child: Text(
                      'No scores available',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16),
                    ),
                  )
                  : PageView.builder(
                    key: const PageStorageKey<String>('healthScorePageView'),
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
