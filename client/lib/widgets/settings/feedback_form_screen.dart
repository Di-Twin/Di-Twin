import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  // Static method to check if feedback should be shown
  static Future<bool> shouldShowFeedback() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we've already shown feedback in this session
    final hasShownThisSession = prefs.getBool('feedback_shown_this_session') ?? false;
    if (hasShownThisSession) {
      return false;
    }

    final lastShown = prefs.getInt('last_feedback_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if 3 days (259,200,000 milliseconds) have passed
    if (now - lastShown > 259200000) {
      // Mark that we've shown feedback in this session
      await prefs.setBool('feedback_shown_this_session', true);
      return true;
    }
    return false;
  }

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> with TickerProviderStateMixin {
  final TextEditingController _feedbackController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  final PageController _pageController = PageController();

  late AnimationController _animationController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  double _appRating = 0.0;
  String _selectedCategory = '';
  bool _isSubmitting = false;
  bool _submitError = false;
  String _errorMessage = '';

  // Feedback categories with icons and colors
  final List<Map<String, dynamic>> _feedbackCategories = [
    {
      'title': 'Bug Report',
      'subtitle': 'Something isn\'t working',
      'icon': Icons.bug_report_outlined,
      'color': Colors.red,
      'gradient': [Colors.red.shade400, Colors.red.shade600],
    },
    {
      'title': 'Feature Request',
      'subtitle': 'Suggest new features',
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
      'gradient': [Colors.amber.shade400, Colors.amber.shade600],
    },
    {
      'title': 'General Feedback',
      'subtitle': 'Share your thoughts',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
      'gradient': [Colors.blue.shade400, Colors.blue.shade600],
    },
    {
      'title': 'Compliment',
      'subtitle': 'Tell us what you love',
      'icon': Icons.favorite_outline,
      'color': Colors.green,
      'gradient': [Colors.green.shade400, Colors.green.shade600],
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _slideController.forward();

    // Update the timestamp when the form is actually shown
    _updateFeedbackTimestamp();
  }

  // Update the timestamp when the form is actually shown
  Future<void> _updateFeedbackTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('last_feedback_shown', now);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _confettiController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _slideController.reset();
      _slideController.forward();
    }
  }

  // Get access token from SharedPreferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Submit feedback to the backend API
  Future<void> _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
      _submitError = false;
      _errorMessage = '';
    });

    try {
      // Get access token
      final accessToken = await _getAccessToken();

      if (accessToken == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare feedback with category prefix
      String feedbackText = _feedbackController.text.trim();
      if (_selectedCategory.isNotEmpty) {
        feedbackText = '$_selectedCategory: $feedbackText';
      }

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'feedback': feedbackText,
      };

      // Add rating only if it's provided (greater than 0)
      if (_appRating > 0) {
        requestData['rating'] = _appRating.toInt();
      }

      // Make API request
      final response = await http.post(
        Uri.parse('https://test-prod-f427.onrender.com/api/users/feedback'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      // Check response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        debugPrint('Feedback submitted successfully!');
        _confettiController.play();
        await _saveFeedbackSubmission();

        // Show success and close after delay
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        // Handle error
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to submit feedback');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _submitError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = _currentStep >= index;
          final isCurrent = _currentStep == index;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: isActive
                      ? LinearGradient(
                    colors: [
                      const Color(0xFF667EEA),
                      const Color(0xFF764BA2),
                    ],
                  )
                      : null,
                  color: isActive ? null : Colors.grey.shade200,
                ),
                child: isCurrent
                    ? AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667EEA),
                              const Color(0xFF764BA2),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667EEA).withOpacity(0.1),
                          const Color(0xFF764BA2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.feedback_outlined,
                      size: 48,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'What type of feedback\nwould you like to share?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose the category that best describes your feedback',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Category Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: _feedbackCategories.map((category) {
                  final isSelected = _selectedCategory == category['title'];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['title'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: category['gradient'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : category['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category['icon'],
                                size: 24,
                                color: isSelected
                                    ? Colors.white
                                    : category['color'],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category['title'],
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['subtitle'],
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: category['color'],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade300,
                            Colors.amber.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Rate Your Experience',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How would you rate DTwin overall?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Rating Section
            Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Center the rating bar properly
                  Center(
                    child: RatingBar.builder(
                      initialRating: _appRating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 50,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.star_rounded,
                          color: index < _appRating
                              ? Colors.amber.shade400
                              : Colors.grey.shade300,
                        ),
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _appRating = rating;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _appRating > 0
                        ? Container(
                      key: ValueKey(_appRating),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getRatingGradient(),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRatingText(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : Container(
                      key: const ValueKey('empty'),
                      child: Text(
                        'Tap the stars to rate',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Color> _getRatingGradient() {
    if (_appRating >= 4) return [Colors.green.shade400, Colors.green.shade600];
    if (_appRating >= 3) return [Colors.blue.shade400, Colors.blue.shade600];
    if (_appRating >= 2) return [Colors.orange.shade400, Colors.orange.shade600];
    return [Colors.red.shade400, Colors.red.shade600];
  }

  String _getRatingText() {
    if (_appRating >= 5) return 'Excellent! 🎉';
    if (_appRating >= 4) return 'Great! 😊';
    if (_appRating >= 3) return 'Good 👍';
    if (_appRating >= 2) return 'Okay 😐';
    return 'We\'ll improve! 💪';
  }

  Widget _buildCommentStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667EEA).withOpacity(0.1),
                          const Color(0xFF764BA2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 48,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Share Your Thoughts',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tell us more about your experience with DTwin',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Selected Category Display
            if (_selectedCategory.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.1),
                      const Color(0xFF764BA2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: const Color(0xFF667EEA),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Category: $_selectedCategory',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Text Input - Fixed height to prevent keyboard issues
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: _feedbackController,
                    maxLines: null,
                    expands: true,
                    maxLength: 1000,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Write your feedback here...\n\nBe specific about what you liked or what could be improved.',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      counterText: '', // Hide the default counter
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF1A1A1A),
                      height: 1.5,
                    ),
                  ),
                  // Custom character counter positioned inside
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_feedbackController.text.length}/1000',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tips
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Specific examples help us understand your feedback better!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.amber,
              ],
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        Text(
          'Thank You!',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Your feedback has been submitted successfully. We appreciate you taking the time to help us improve DTwin!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade600,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Submission Failed',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: _submitFeedback,
            icon: Icon(Icons.refresh_rounded),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to text changes to update character counter
    _feedbackController.addListener(() {
      setState(() {});
    });

    return WillPopScope(
      onWillPop: () async => !_isSubmitting,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF8FAFC),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Feedback',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                // Progress Indicator
                if (!_isSubmitting) _buildProgressIndicator(),

                const SizedBox(height: 20),

                // Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: _isSubmitting
                        ? (_submitError ? _buildErrorView() : _buildSuccessView())
                        : PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildCategoryStep(),
                        _buildRatingStep(),
                        _buildCommentStep(),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                if (!_isSubmitting)
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 24,
                    ),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF667EEA),
                                side: BorderSide(
                                  color: const Color(0xFF667EEA),
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Back',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                        if (_currentStep > 0) const SizedBox(width: 16),

                        Expanded(
                          flex: _currentStep == 0 ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: _canProceed() ? _nextStep : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep < 2 ? 'Continue' : 'Submit Feedback',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep < 2
                                      ? Icons.arrow_forward_rounded
                                      : Icons.send_rounded,
                                  size: 20,
                                ),
                              ],
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
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedCategory.isNotEmpty;
      case 1:
        return true; // Rating is optional
      case 2:
        return _feedbackController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }
}
