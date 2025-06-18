import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyScoreCard extends StatefulWidget {
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
  State<MonthlyScoreCard> createState() => _MonthlyScoreCardState();
}

class _MonthlyScoreCardState extends State<MonthlyScoreCard> {
  double? _monthlyScore;
  int _mealCount = 0;
  double _totalCalories = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyFoodData();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  Future<void> _fetchMonthlyFoodData() async {
    if (!mounted) return; // Check if widget is still mounted
    
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('access_token');
      final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlODE0NDQ3NS0yY2E1LTQ3YTQtOTUwOS1mMDhjYWZlNWYwZjUiLCJtb2JpbGUiOiIrOTE5ODc2NTQzMjEwIiwiaWF0IjoxNzUwMjI2ODExLCJleHAiOjE3NTAzMTMyMTF9.WPyZtTeVboyYUf_-gs4tsPNuLAKndQbQvT6X8qp4T8Q';
      final now = DateTime.now();

      if (token == null) {
        if (mounted) {
          setState(() {
            _monthlyScore = null;
            _mealCount = 0;
            _totalCalories = 0;
            _isLoading = false;
            _hasError = true;
          });
        }
        return;
      }

      final url = Uri.parse(
        'https://test-prod-f427.onrender.com/api/food/monthly/${now.year}/${now.month}',
      );
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return; // Check again after async operation

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          final summary = data['summary'];
          final days = data['days'] as List;

          final score = (summary['monthlyFoodScore'] as num?)?.toDouble() ?? 0;
          final meals = summary['totalMealCount'] ?? 0;
          final calories = days.fold<double>(
            0.0,
            (sum, item) => sum + ((item['calories'] ?? 0) as num).toDouble(),
          );

          if (mounted) {
            setState(() {
              _monthlyScore = score;
              _mealCount = meals;
              _totalCalories = calories;
              _isLoading = false;
              _hasError = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _monthlyScore = null;
              _mealCount = 0;
              _totalCalories = 0;
              _isLoading = false;
              _hasError = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _monthlyScore = null;
            _mealCount = 0;
            _totalCalories = 0;
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      print('Error fetching monthly food data: $e');
      if (mounted) {
        setState(() {
          _monthlyScore = null;
          _mealCount = 0;
          _totalCalories = 0;
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Widget _buildScoreWidget() {
    if (_isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    final scoreText = Text(
      '${_monthlyScore?.toStringAsFixed(0) ?? '--'}',
      style: GoogleFonts.plusJakartaSans(
        fontSize: widget.isSmallScreen ? 18 : 24, // Reduced font size
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    // Only apply animations if they are provided and not loading
    if (widget.scoreScaleAnimation != null &&
        widget.scoreOpacityAnimation != null &&
        widget.scoreRotationAnimation != null &&
        !_isLoading) {
      return ScaleTransition(
        scale: widget.scoreScaleAnimation!,
        child: FadeTransition(
          opacity: widget.scoreOpacityAnimation!,
          child: RotationTransition(
            turns: widget.scoreRotationAnimation!,
            child: scoreText,
          ),
        ),
      );
    }

    return scoreText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: widget.isSmallScreen ? 8 : 12, // Reduced padding
        horizontal: widget.isSmallScreen ? 10 : 16, // Reduced padding
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use LayoutBuilder to handle different screen sizes
          final availableWidth = constraints.maxWidth;
          final isVerySmall = availableWidth < 300;
          
          if (isVerySmall) {
            // Stack layout for very small screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row - Icon and score
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '🥗',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildScoreWidget(),
                          Text(
                            'Food score',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Bottom row - Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCompactStatItem(
                      Icons.local_fire_department,
                      _totalCalories.toStringAsFixed(0),
                      'kcal',
                      true,
                    ),
                    _buildCompactStatItem(
                      Icons.restaurant,
                      _mealCount.toString(),
                      'meals',
                      true,
                    ),
                  ],
                ),
              ],
            );
          }
          
          // Regular row layout for larger screens
          return Row(
            children: [
              // Left side - Score and title
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(widget.isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '🥗',
                        style: TextStyle(
                          fontSize: widget.isSmallScreen ? 14 : 18,
                        ),
                      ),
                    ),
                    SizedBox(width: widget.isSmallScreen ? 6 : 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildScoreWidget(),
                          Text(
                            'Food score',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: widget.isSmallScreen ? 10 : 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right side - Stats
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCompactStatItem(
                      Icons.local_fire_department,
                      _totalCalories.toStringAsFixed(0),
                      'kcal',
                      widget.isSmallScreen,
                    ),
                    SizedBox(width: widget.isSmallScreen ? 6 : 12),
                    _buildCompactStatItem(
                      Icons.restaurant,
                      _mealCount.toString(),
                      'meals',
                      widget.isSmallScreen,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: Colors.white, 
              size: isSmallScreen ? 12 : 14,
            ),
            SizedBox(width: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 8 : 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
