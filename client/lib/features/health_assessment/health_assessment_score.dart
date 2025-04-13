import 'package:client/data/API/health_score_data.dart';
import 'package:client/widgets/CustomSecondaryButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class HealthAssessmentScore extends ConsumerStatefulWidget {
  const HealthAssessmentScore({super.key});

  @override
  ConsumerState<HealthAssessmentScore> createState() => _HealthAssessmentScoreState();
}

class _HealthAssessmentScoreState extends ConsumerState<HealthAssessmentScore> {
  final HealthScoreService _healthScoreService = HealthScoreService();
  bool _isLoading = true;
  int _score = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHealthScore();
  }

  Future<void> _fetchHealthScore() async {
  try {
    final onboarding = ref.read(onboardingProvider);

    if (onboarding.age == null ||
        onboarding.weight_kg == null ||
        onboarding.height_cm == null ||
        onboarding.gender == null) {
      throw Exception("Missing onboarding data");
    }

    final score = calculateScore(
      age: onboarding.age,
      weight: onboarding.weight_kg,
      height: onboarding.height_cm,
      gender: onboarding.gender,
    );

    setState(() {
      _score = score;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}

  int calculateScore({
    required int age,
    required double weight,
    required double height,
    required String gender,
  }) {
    final bmiValue = weight / ((height / 100) * (height / 100));
    final ageScore = (100 - age * 0.5).clamp(0, 100);
    double bmiScore;

    if (bmiValue < 18.5) {
      bmiScore = 70 + (bmiValue - 18.5) * 6;
    } else if (bmiValue <= 25) {
      bmiScore = 100 - ((bmiValue - 21.75) * (bmiValue - 21.75) * 4);
    } else {
      bmiScore = 85 - ((bmiValue - 25) * 3);
    }

    final genderFactor = gender.toLowerCase() == 'female' ? 1.05 : 1.0;
    double finalScore = (ageScore * 0.3 + bmiScore * 0.7) * genderFactor;
    return finalScore.clamp(0, 100).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_errorMessage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchHealthScore,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final Color primaryColor =
        _score >= 40 ? const Color(0xFF0066FF) : const Color(0xFFFF4D67);
    final Color backgroundColor =
        _score >= 40 ? const Color(0xFF0066FF) : const Color(0xFFFF4D67);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          image: const DecorationImage(
            image: AssetImage("images/texture.png"),
            fit: BoxFit.cover,
            opacity: 15,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main Box - Score Display
                      Container(
                        width: 220,
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            // Plus Icon at the top
                            Positioned(
                              top: -30,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            // Score Number
                            Center(
                              child: Text(
                                _score.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 150,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            // Middle Box (50% opacity)
                            Positioned(
                              bottom: -15,
                              child: Container(
                                width: 200,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.50),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            // Smallest Box (15% opacity)
                            Positioned(
                              bottom: -30,
                              child: Container(
                                width: 180,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Text and Buttons
              const SizedBox(height: 24),
              Text(
                "You're All Set Up.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your health score is $_score.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // AI Suggestions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "16 AI Suggestions",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomSecondaryButton(
                  text: "Let's Get Healthy",
                  iconPath: "images/SignInAddIcon.png",
                  width: 200,
                  height: 50,
                  onPressed: () {
                    Navigator.pushNamed(context, '/avatar');
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
