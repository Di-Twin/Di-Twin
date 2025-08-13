import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Food Data Model
class FoodData {
  final String id;
  final DateTime sessionTime;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  FoodData({
    required this.id,
    required this.sessionTime,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });

  factory FoodData.fromJson(Map<String, dynamic> json) {
    return FoodData(
      id: json['id'],
      sessionTime: DateTime.parse(json['sessionTime']),
      totalCalories: json['totalCalories']?.toDouble() ?? 0.0,
      totalProtein: json['totalProtein']?.toDouble() ?? 0.0,
      totalCarbs: json['totalCarbs']?.toDouble() ?? 0.0,
      totalFats: json['totalFats']?.toDouble() ?? 0.0,
    );
  }
}

// Calories Data Model
class CaloriesData {
  final double target;
  final double taken;
  final double burned;

  CaloriesData({
    required this.target,
    required this.taken,
    required this.burned,
  });

  double get netCalories => taken - burned;
  double get total => target + taken + burned;

  // Calculate proportions for chart display with safe defaults
  double get targetProportion => total > 0 ? target / total : 0.4;
  double get takenProportion => total > 0 ? taken / total : 0.3;
  double get burnedProportion => total > 0 ? burned / total : 0.3;
}

class FunctionalCaloriesChartWidget extends StatefulWidget {
  final double? caloriesBurned;
  final double? targetCalories;

  const FunctionalCaloriesChartWidget({
    super.key,
    this.caloriesBurned,
    this.targetCalories = 2000, // Default target
  });

  @override
  State<FunctionalCaloriesChartWidget> createState() =>
      _FunctionalCaloriesChartWidgetState();
}

class _FunctionalCaloriesChartWidgetState
    extends State<FunctionalCaloriesChartWidget> {
  static const String baseUrl = 'https://test-prod-f427.onrender.com';

  CaloriesData? _caloriesData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCaloriesData();
  }

  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  Future<void> _loadCaloriesData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        setState(() {
          _error = 'No access token found';
          _isLoading = false;
        });
        return;
      }

      // Get today's date in YYYY-MM-DD format
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Fetch food data for calories taken
      final foodUrl = Uri.parse('$baseUrl/api/food/daily/$dateString');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.get(foodUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final foodData = FoodData.fromJson(jsonData['data']);

          setState(() {
            _caloriesData = CaloriesData(
              target: widget.targetCalories ?? 2000,
              taken: foodData.totalCalories,
              burned: widget.caloriesBurned ?? 0,
            );
            _isLoading = false;
          });
        } else {
          // No food data for today, use default values
          setState(() {
            _caloriesData = CaloriesData(
              target: widget.targetCalories ?? 2000,
              taken: 0,
              burned: widget.caloriesBurned ?? 0,
            );
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        // Handle 404 (no data) specifically
        setState(() {
          _caloriesData = CaloriesData(
            target: widget.targetCalories ?? 2000,
            taken: 0,
            burned: widget.caloriesBurned ?? 0,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch food data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading calories data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return Column(
      children: [
        SizedBox(height: 16.h),
        _caloriesData != null ? _buildChartLegend() : _buildEmptyLegend(),
        SizedBox(height: 16.h),
        _caloriesData != null
            ? _buildCaloriesBreakdown()
            : _buildEmptyBreakdown(),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Center(
        child: Text(
          'No data available',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: const Color(0xFF8F9BB3),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Empty Target Box
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFD9E4F5).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Target',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '--',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Empty Taken Box
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5A5F).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Taken',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '--',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Empty Burned Box
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Burned',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '--',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBreakdown() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          'No calories data available',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: const Color(0xFF8F9BB3),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesChart() {
    final data = _caloriesData!;

    return Container(
      height: 48.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: [
          // Target section
          Expanded(
            flex: (data.targetProportion * 10).round().clamp(1, 10),
            child: Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E4F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    bottomLeft: Radius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
          // Taken section
          Expanded(
            flex: (data.takenProportion * 10).round().clamp(1, 10),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A5F),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // Burned section
          Expanded(
            flex: (data.burnedProportion * 10).round().clamp(1, 10),
            child: Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.r),
                    bottomRight: Radius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Target Box
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFD9E4F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Target',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_caloriesData!.target.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Taken Box
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5A5F),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Taken',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_caloriesData!.taken.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Burned Box
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Burned',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_caloriesData!.burned.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesBreakdown() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calories Breakdown',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 12.h),
          _buildBreakdownRow(
            'Daily Target',
            _caloriesData!.target,
            const Color(0xFFD9E4F5),
          ),
          _buildBreakdownRow(
            'Calories Consumed',
            _caloriesData!.taken,
            const Color(0xFFFF5A5F),
          ),
          _buildBreakdownRow(
            'Calories Burned',
            _caloriesData!.burned,
            const Color(0xFF0066FF),
          ),
          Divider(height: 24.h, color: const Color(0xFFE5E5E5)),
          _buildBreakdownRow(
            'Net Calories',
            _caloriesData!.netCalories,
            _caloriesData!.netCalories >= 0
                ? const Color(0xFFFF5A5F)
                : const Color(0xFF0066FF),
            isNet: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double value,
    Color color, {
    bool isNet = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: isNet ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF1A1F36),
                ),
              ),
            ],
          ),
          Text(
            '${isNet && value >= 0 ? '+' : ''}${value.toStringAsFixed(0)} kcal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isNet ? color : const Color(0xFF1A1F36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200.h,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            'Error loading calories data',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(onPressed: _loadCaloriesData, child: Text('Retry')),
        ],
      ),
    );
  }
}
