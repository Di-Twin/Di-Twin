import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactInformationScreen extends StatelessWidget {
  const ContactInformationScreen({super.key});

  final phonenumber = "+123 456 789";
  final email = "info@ditwin.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () => Navigator.pop(context),
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  // Title - aligned next to back button
                  const SizedBox(width: 16),
                  Text(
                    'Contact Information',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            // Logo and app version
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // App logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App version
                    Text(
                      'di-twin v1.0.0 BETA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Phone number
                    _buildContactItem(
                      icon: Icons.phone_iphone,
                      content: Text(phonenumber),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _buildContactItem(
                      icon: Icons.alternate_email,
                      content: Text(email),
                    ),

                    const SizedBox(height: 16),

                    // Address
                    _buildContactItem(
                      icon: Icons.location_on_outlined,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DiTwin Tower,',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Mjolnir Boulevard',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '44815 New Haven Street',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Las Vegas, Nevada',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E293B), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: content is Text ? content : content),
        ],
      ),
    );
  }
}
