import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  final List<Map<String, dynamic>> _feedbackOptions = [
    {'label': 'Performance', 'isSelected': false},
    {'label': 'Bug', 'isSelected': false},
    {'label': 'UI', 'isSelected': false},
    {'label': 'UX', 'isSelected': true},
    {'label': 'Crashes', 'isSelected': false},
    {'label': 'Loading', 'isSelected': false},
    {'label': 'Support', 'isSelected': true},
    {'label': 'Security', 'isSelected': true},
    {'label': 'Pricing', 'isSelected': false},
    {'label': 'Animation', 'isSelected': false},
    {'label': 'Design', 'isSelected': false},
    {'label': 'Marketing', 'isSelected': false},
  ];

  Color _getChipColor(String label, bool isSelected) {
    if (!isSelected) return Colors.grey.shade100;

    switch (label) {
      case 'UX':
        return const Color(0xFF20B2AA); // Teal
      case 'Support':
        return const Color(0xFFFF5A5F); // Red
      case 'Security':
        return const Color(0xFF0066FF); // Blue
      default:
        return Colors.blue;
    }
  }

  Color _getTextColor(bool isSelected) {
    return isSelected ? Colors.white : const Color(0xFF1E293B);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF0066FF), Color(0xFF0055DD)],
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
              Container(
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

                    const SizedBox(height: 40),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Which Of The Area\nNeeds Improvement?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Feedback options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        children:
                            _feedbackOptions.map((option) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    option['isSelected'] =
                                        !option['isSelected'];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getChipColor(
                                      option['label'],
                                      option['isSelected'],
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    option['label'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _getTextColor(
                                        option['isSelected'],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Additional feedback text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Additional comments or feedback...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Get selected options
                            final selectedOptions =
                                _feedbackOptions
                                    .where((option) => option['isSelected'])
                                    .map((option) => option['label'])
                                    .toList();

                            // Get additional feedback
                            final additionalFeedback = _feedbackController.text;

                            // Show confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Feedback submitted successfully',
                                  style: GoogleFonts.plusJakartaSans(),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            // Navigate back after submission
                            Future.delayed(
                              const Duration(seconds: 1),
                              () => Navigator.pop(context),
                            );
                          },
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
                                'Submit Feedback',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check, size: 20),
                            ],
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
    );
  }
}
