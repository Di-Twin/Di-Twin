import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/painters/ideal_response_painter.dart';
import 'package:client/painters/actual_response_painter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SugarSpikeWidget extends StatefulWidget {
  final Map<String, dynamic> food;
  final double sugarSpike;
  final String impactLevel;
  final Color impactColor;

  const SugarSpikeWidget({
    super.key,
    required this.food,
    required this.sugarSpike,
    required this.impactLevel,
    required this.impactColor,
  });

  @override
  State<SugarSpikeWidget> createState() => _SugarSpikeWidgetState();
}

class _SugarSpikeWidgetState extends State<SugarSpikeWidget> {
  bool _isLoggingFood = false;
  String? _errorMessage;
  bool _foodLogged = false;

  Future<void> _logFoodToDatabase(String accessToken) async {
    if (_foodLogged) return;

    setState(() {
      _isLoggingFood = true;
      _errorMessage = null;
    });

    try {
      // Format today's date
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Prepare the food item data
      final foodItem = {
        "foodName": widget.food['name'],
        "serving_size": widget.food['weight'] ?? "1 serving",
        "serving_amount": 1,
        "macronutrients": {
          "energy_kcal": widget.food['calories'] ?? 0,
          "protein_g": widget.food['protein'] ?? 0,
          "carbohydrates_g": widget.food['carbs'] ?? 0,
          "fat_g": widget.food['fat'] ?? 0
        },
        "micronutrients": {
          "sodium_mg": 0,
          "potassium_mg": 0
        },
        "image_url": "",
        "gi": 0,
        "gl": 0,
        "source": "user entry",
        "mealType": widget.food['mealType'] ?? "snack"
      };

      // Prepare the request body
      final requestBody = {
        "date": today,
        "foodItems": [foodItem]
      };

      // Make the API call
      final response = await http.post(
        Uri.parse('https://api.yourbackend.com/api/food/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLoggingFood = false;
          _foodLogged = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food logged successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isLoggingFood = false;
          _errorMessage = 'Failed to log food. Server returned ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoggingFood = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Blood Sugar Impact',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                decoration: BoxDecoration(
                  color: widget.impactColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 14.sp,
                      color: widget.impactColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '+${widget.sugarSpike.toStringAsFixed(1)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.impactColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Simplified blood sugar response graph
          SizedBox(
            height: 100.h,
            child: Row(
              children: [
                // Y-axis label
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'High',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'Blood\nSugar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Low',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                // Graph area
                Expanded(
                  child: Stack(
                    children: [
                      // Background grid
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 1, color: const Color(0xFFE2E8F0)),
                            Container(height: 1, color: const Color(0xFFE2E8F0)),
                            Container(height: 1, color: const Color(0xFFE2E8F0)),
                          ],
                        ),
                      ),

                      // Ideal response curve
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: CustomPaint(painter: IdealResponsePainter()),
                      ),

                      // Actual response curve based on impact
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: CustomPaint(
                          painter: ActualResponsePainter(
                            _getCurveType(widget.impactLevel), 
                            widget.impactColor
                          ),
                        ),
                      ),

                      // Time labels
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0h',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '1h',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '2h',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '3h',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Impact description
          Text(
            _getImpactDescription(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          
          if (_errorMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Colors.red,
                ),
              ),
            ),
          ],
          
          SizedBox(height: 16.h),
          
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: _isLoggingFood || _foodLogged 
          //       ? null 
          //       : () {
          //           // In a production app, you would get this from your auth provider
          //           // This is a simplified approach for demonstration
          //           try {
          //             // Get access token from secure storage or state management
          //             const String accessToken = 'your_access_token_here'; 
          //             _logFoodToDatabase(accessToken);
          //           } catch (e) {
          //             setState(() {
          //               _errorMessage = 'Authentication error: Please log in again';
          //             });
          //           }
          //         },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: _foodLogged ? Colors.green : widget.impactColor,
          //       foregroundColor: Colors.white,
          //       disabledBackgroundColor: _foodLogged 
          //           ? Colors.green.withOpacity(0.7)
          //           : widget.impactColor.withOpacity(0.5),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12.r),
          //       ),
          //       padding: EdgeInsets.symmetric(vertical: 12.h),
          //     ),
          //     child: _isLoggingFood
          //         ? const CircularProgressIndicator(color: Colors.white)
          //         : Text(
          //             _foodLogged ? 'Food Logged ✓' : 'Log This Food',
          //             style: GoogleFonts.plusJakartaSans(
          //               fontSize: 16.sp,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //   ),
          // ),
        ],
      ),
    );
  }

  String _getCurveType(String impact) {
    if (impact == 'Minimal' || impact == 'Low') {
      return 'Low';
    } else if (impact == 'High' || impact == 'Very High') {
      return 'High';
    } else {
      return 'Moderate';
    }
  }

  String _getImpactDescription() {
    final foodName = widget.food['name'];
    
    switch (widget.impactLevel) {
      case 'Minimal':
        return '$foodName has a minimal impact on your blood sugar levels, making it an excellent choice for stable energy.';
      case 'Low':
        return '$foodName has a low impact on your blood sugar levels, providing steady energy without significant spikes.';
      case 'Moderate':
        return '$foodName causes a moderate rise in blood sugar. Consider pairing with protein or healthy fats to reduce the impact.';
      case 'High':
        return '$foodName may cause a significant blood sugar spike. Consider reducing portion size or pairing with fiber-rich foods.';
      case 'Very High':
        return '$foodName causes a very high blood sugar response. Consider alternatives or consume in small amounts with protein and fiber.';
      default:
        return 'Analyzing how $foodName affects your blood sugar levels...';
    }
  }
}
