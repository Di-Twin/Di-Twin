import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                    'About Us',
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
                    'ditwin v1.0.0 BETA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Menu items
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.notifications_none_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),

                          const SizedBox(height: 16),

                          _buildMenuItem(
                            icon: Icons.star_outline,
                            title: 'Rate Our App',
                            onTap: () {},
                          ),

                          const SizedBox(height: 16),

                          _buildMenuItem(
                            icon: Icons.science_outlined,
                            title: 'Developer',
                            onTap: () {},
                          ),

                          const SizedBox(height: 16),

                          _buildMenuItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'Submit Feedback',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Social media links
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Be',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildSocialIcon(Icons.facebook, () {}),
                        const SizedBox(width: 24),
                        _buildSocialIcon(Icons.camera_alt_outlined, () {}),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1E293B)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: const Color(0xFF1E293B), size: 28),
    );
  }
}
