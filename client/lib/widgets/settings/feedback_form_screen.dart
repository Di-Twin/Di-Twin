import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  // Static method to check if feedback should be shown
  static Future<bool> shouldShowFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt('last_feedback_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check if 3 days (259,200,000 milliseconds) have passed
    if (now - lastShown > 259200000) {
      // Update the last shown timestamp
      await prefs.setInt('last_feedback_shown', now);
      return true;
    }
    return false;
  }

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> with TickerProviderStateMixin {
  final TextEditingController _feedbackController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentStep = 0;
  double _appRating = 4.0;
  String _selectedMood = 'happy';
  bool _isSubmitting = false;
  
  // Track selected categories
  final Map<String, bool> _categorySelections = {
    'Performance': false,
    'UI Design': false,
    'Features': false,
    'Usability': false,
    'Content': false,
  };
  
  // Track improvement areas
  final Map<String, bool> _improvementAreas = {
    'Speed': false,
    'Accuracy': false,
    'Notifications': false,
    'Data Sync': false,
    'Battery Usage': false,
    'Connectivity': false,
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuint,
    ));
    
    _animationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _confettiController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  // Method to save feedback submission time
  Future<void> _saveFeedbackSubmission() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('last_feedback_shown', now);
    await prefs.setInt('last_feedback_submitted', now);
  }
  
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _slideController.reset();
      _slideController.forward();
    } else {
      _submitFeedback();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }
  
  void _submitFeedback() {
    setState(() {
      _isSubmitting = true;
    });
    
    // Simulate submission
    Future.delayed(const Duration(seconds: 1), () {
      _confettiController.play();
      _saveFeedbackSubmission();
      
      // Show success and close after delay
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    });
  }
  
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            width: _currentStep == index ? 30 : 20,
            height: 8,
            decoration: BoxDecoration(
              color: _currentStep >= index 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildRatingStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_rc5d0f8i.json',
            height: 180,
            repeat: true,
          ),
          const SizedBox(height: 20),
          Text(
            'How would you rate your experience?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          RatingBar.builder(
            initialRating: _appRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 50,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star_rounded,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _appRating = rating;
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            _appRating >= 4 ? 'Awesome!' : 
            _appRating >= 3 ? 'Good!' : 
            _appRating >= 2 ? 'Okay' : 'We\'ll improve!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _appRating >= 4 ? Colors.green : 
                    _appRating >= 3 ? Colors.blue : 
                    _appRating >= 2 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodStep() {
    final moods = {
      'love': {'emoji': '😍', 'color': Colors.pink},
      'happy': {'emoji': '😊', 'color': Colors.amber},
      'neutral': {'emoji': '😐', 'color': Colors.blue},
      'confused': {'emoji': '🤔', 'color': Colors.orange},
      'sad': {'emoji': '😔', 'color': Colors.purple},
    };
    
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How do you feel about DTwin?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: moods.entries.map((entry) {
              final isSelected = _selectedMood == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = entry.key;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? entry.value['color'] as Color
                      : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                        ? entry.value['color'] as Color
                        : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: (entry.value['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.value['emoji'] as String,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key.capitalize(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            _getMoodMessage(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  String _getMoodMessage() {
    switch (_selectedMood) {
      case 'love':
        return 'We\'re thrilled you love DTwin! 💖';
      case 'happy':
        return 'Glad to hear you\'re enjoying DTwin! 😊';
      case 'neutral':
        return 'Thanks for your feedback. We\'ll keep improving! 👍';
      case 'confused':
        return 'We\'ll work on making things clearer! 🤝';
      case 'sad':
        return 'We\'re sorry to hear that. We\'ll do better! 🙏';
      default:
        return 'Thanks for sharing your feelings!';
    }
  }
  
  Widget _buildCategoryStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'What aspects do you like most?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _categorySelections.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _categorySelections[entry.key] = !entry.value;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: entry.value 
                      ? const Color(0xFF0066FF)
                      : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: entry.value ? [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.value ? Icons.check_circle : Icons.circle_outlined,
                        color: entry.value ? Colors.white : Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: entry.value ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Text(
            'What could we improve?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _improvementAreas.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _improvementAreas[entry.key] = !entry.value;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: entry.value 
                      ? const Color(0xFFFF5A5F)
                      : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: entry.value ? [
                      BoxShadow(
                        color: const Color(0xFFFF5A5F).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.value ? Icons.check_circle : Icons.circle_outlined,
                        color: entry.value ? Colors.white : Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: entry.value ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Any additional thoughts?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your feedback helps us improve DTwin',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your experience with us...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Specific examples help us understand your feedback better!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.1,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
        ),
        Lottie.network(
          'https://assets1.lottiefiles.com/packages/lf20_touohxv0.json',
          height: 200,
          repeat: false,
        ),
        const SizedBox(height: 20),
        Text(
          'Thank You!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your feedback helps us make DTwin better for everyone.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Text(
                '+50 Health Points!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              const Color(0xFF0066FF),
              const Color(0xFF0055DD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // White container with form
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle indicator
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Progress indicator
                    if (!_isSubmitting) _buildProgressIndicator(),
                    
                    const SizedBox(height: 30),
                    
                    // Content based on current step
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _isSubmitting
                        ? _buildSuccessView()
                        : [
                            _buildRatingStep(),
                            _buildMoodStep(),
                            _buildCategoryStep(),
                            _buildCommentStep(),
                          ][_currentStep],
                    ),

                    const SizedBox(height: 40),

                    // Navigation buttons
                    if (!_isSubmitting)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          children: [
                            // Back button (except on first step)
                            if (_currentStep > 0)
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: _previousStep,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1E293B),
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: Text(
                                      'Back',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            if (_currentStep > 0)
                              const SizedBox(width: 16),
                            
                            // Next/Submit button
                            Expanded(
                              flex: _currentStep == 0 ? 1 : 2,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0066FF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep < 3 ? 'Next' : 'Submit Feedback',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _currentStep < 3 
                                          ? Icons.arrow_forward
                                          : Icons.check_circle,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
