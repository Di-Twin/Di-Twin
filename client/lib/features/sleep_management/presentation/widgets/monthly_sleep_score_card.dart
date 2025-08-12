import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/sleep_provider.dart';
import 'package:client/core/network/api_client.dart';

class MonthlySleepScoreCard extends ConsumerStatefulWidget {
  final bool isSmallScreen;
  final Animation<double>? scoreScaleAnimation;
  final Animation<double>? scoreOpacityAnimation;
  final Animation<double>? scoreRotationAnimation;
  final int selectedMonth;
  final int selectedYear;

  const MonthlySleepScoreCard({
    super.key,
    required this.isSmallScreen,
    required this.selectedMonth,
    required this.selectedYear,
    this.scoreScaleAnimation,
    this.scoreOpacityAnimation,
    this.scoreRotationAnimation,
  });

  @override
  ConsumerState<MonthlySleepScoreCard> createState() => _MonthlySleepScoreCardState();
}

class _MonthlySleepScoreCardState extends ConsumerState<MonthlySleepScoreCard> {
  double? _monthlySleepScore;
  int _sleepSessionCount = 0;
  double _averageDuration = 0;
  double _averageEfficiency = 0;
  bool _isLoading = true;
  bool _hasError = false;
  late ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(
      baseUrl: 'https://dtwinapi.onrender.com',
      httpClient: http.Client(),
    );
    _fetchMonthlySleepData();
  }

  @override
  void didUpdateWidget(MonthlySleepScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth ||
        oldWidget.selectedYear != widget.selectedYear) {
      _fetchMonthlySleepData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchMonthlySleepData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Call the new monthly sleep score API endpoint
      final response = await _apiClient.get(
        '/api/sleep/score/monthly/${widget.selectedYear}/${widget.selectedMonth}',
        requiresAuth: true,
      );

      if (mounted && response['success'] == true) {
        final data = response['data'];
        setState(() {
          _monthlySleepScore = data['monthly_sleep_score']?.toDouble();
          // Keep existing mock data for other metrics until we have real endpoints
          _sleepSessionCount = 28; // Mock data
          _averageDuration = 7.5; // Mock data
          _averageEfficiency = 85.0; // Mock data
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      print('Error fetching monthly sleep data: $e');
      if (mounted) {
        setState(() {
          _monthlySleepScore = null;
          _sleepSessionCount = 0;
          _averageDuration = 0;
          _averageEfficiency = 0;
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
      _monthlySleepScore?.toStringAsFixed(0) ?? '--',
      style: GoogleFonts.plusJakartaSans(
        fontSize: widget.isSmallScreen ? 18 : 24,
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
        vertical: widget.isSmallScreen ? 8 : 12,
        horizontal: widget.isSmallScreen ? 10 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                      child: Icon(
                        Icons.nightlight_outlined,
                        color: Colors.white,
                        size: 14,
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
                            'Sleep score',
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
                      Icons.access_time,
                      _averageDuration.toStringAsFixed(1),
                      'hrs avg',
                      true,
                    ),
                    _buildCompactStatItem(
                      Icons.hotel,
                      _sleepSessionCount.toString(),
                      'sessions',
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
                      child: Icon(
                        Icons.nightlight_outlined,
                        color: Colors.white,
                        size: widget.isSmallScreen ? 14 : 18,
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
                            'Sleep score',
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
                      Icons.access_time,
                      _averageDuration.toStringAsFixed(1),
                      'hrs avg',
                      widget.isSmallScreen,
                    ),
                    SizedBox(width: widget.isSmallScreen ? 6 : 12),
                    _buildCompactStatItem(
                      Icons.hotel,
                      _sleepSessionCount.toString(),
                      'sessions',
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
