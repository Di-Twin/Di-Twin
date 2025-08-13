import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/utils/token_manager.dart';
import 'package:client/features/dashboard/dashboard.dart';
import 'package:client/features/welcome/WelcomePage.dart';

class Startpage extends StatefulWidget {
  const Startpage({super.key});

  @override
  _StartpageState createState() => _StartpageState();
}

class _StartpageState extends State<Startpage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation init
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // Check auth and navigate after splash
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash animation to complete
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      // Check if user has valid token
      final token = await TokenManager.getAccessToken();

      if (token != null && token.isNotEmpty) {
        // Validate token by checking if it's still valid 
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');

        if (userId != null && userId.isNotEmpty) {
          // Token exists and user ID exists, go to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          return;
        }
      }

      // No valid token or user ID, go to welcome page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );

    } catch (e) {
      // Error checking auth, go to welcome page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('images/LandingPageBG.png', fit: BoxFit.cover),

          // Fade in quote
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"Health is the complete harmony of the body and soul."',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "— Aristotle",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F67FE),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Simple loader
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF0F67FE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
