import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthAssessmentLoading extends StatefulWidget {
  final Duration loadingDuration;
  final Function? onLoadingComplete;
  final Widget? nextScreen;

  const HealthAssessmentLoading({
    super.key,
    required this.loadingDuration,
    this.onLoadingComplete,
    this.nextScreen,
  });

  @override
  State<HealthAssessmentLoading> createState() =>
      _HealthAssessmentLoadingState();
}

class _HealthAssessmentLoadingState extends State<HealthAssessmentLoading> {
  String dots = '...';
  late Timer _dotTimer;
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _startNavigationTimer();
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dots = (dots == '...') ? '.' : (dots == '.') ? '..' : '...';
      });
    });
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(widget.loadingDuration, () {
      // Handle navigation after loading duration completes
      if (widget.onLoadingComplete != null) {
        widget.onLoadingComplete!();
      } else if (widget.nextScreen != null) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => widget.nextScreen!),
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _dotTimer.cancel();
    _navigationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(color: const Color(0xFF1E2A47)),

          // Top Right Image (Aligned to the Top)
          Positioned(
            top: 0, // Aligns to the top of the screen
            right: 0, // Aligns to the right
            child: Image.asset(
              'images/top_right_shape.png',
              fit: BoxFit.cover,
            ),
          ),

          // Bottom Left Image (Aligned to the Bottom)
          Positioned(
            bottom: 0, // Aligns to the bottom of the screen
            left: 0, // Aligns to the left
            child: Image.asset(
              'images/bottom_left_shape.png',
              fit: BoxFit.cover,
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plus Symbol (Image)
                Image.asset(
                  'images/plus_icon.png',
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.05),

                // Loading Text
                Text(
                  'Compiling Assessment data$dots',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: screenWidth * 0.05, // Dynamic font size
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),

                // Waiting Text
                Text(
                  'Please wait!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}