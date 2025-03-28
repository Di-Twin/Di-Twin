import 'package:client/widgets/settings/notification_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDFE3E8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () => Navigator.pop(context),
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  // Title
                  Text(
                    'Notification',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  // Settings button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDFE3E8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationSettingsScreen(),
                          ),
                        );
                      },
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            // Notification list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Earlier section
                  _buildSectionHeader('Earlier', '3 total'),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF9747FF),
                    iconData: Icons.directions_run,
                    title: 'Activity Completed',
                    description: 'You have finished jogging',
                  ),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF20D7D7),
                    iconData: Icons.medical_services_outlined,
                    title: 'Monthly Health Insight',
                    description: 'Your monthly health insight is ready.',
                    hasDownloadButton: true,
                  ),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF5F6C86),
                    iconData: Icons.airline_seat_individual_suite,
                    title: 'Sleep More',
                    description: 'Take at least 8hr sleep',
                    rightText: '4.5h',
                  ),

                  // Yesterday section
                  const SizedBox(height: 16),
                  _buildSectionHeader('Yesterday', '3 total'),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF0066FF),
                    iconData: Icons.medical_information_outlined,
                    title: 'Medication Remainder',
                    description: 'Don\'t forget to take Amoxicilline',
                  ),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF20D7D7),
                    iconData: Icons.medical_services_outlined,
                    title: 'Monthly Health Insight',
                    description: 'Your monthly health insight is ready.',
                    hasDownloadButton: true,
                  ),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF5F6C86),
                    iconData: Icons.airline_seat_individual_suite,
                    title: 'Sleep More',
                    description: 'Take at least 8hr sleep',
                    rightText: '4.5h',
                  ),

                  // 22 March section
                  const SizedBox(height: 16),
                  _buildSectionHeader('22 March', '3 total'),
                  _buildNotificationCard(
                    iconColor: const Color(0xFF0066FF),
                    iconData: Icons.medical_information_outlined,
                    title: 'Medication Remainder',
                    description: 'Don\'t forget to take Amoxicilline',
                  ),

                  // Add some bottom padding
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required Color iconColor,
    required IconData iconData,
    required String title,
    required String description,
    String? rightText,
    bool hasDownloadButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),

                      // Right text if provided
                      if (rightText != null)
                        Text(
                          rightText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  // Download button if needed
                  if (hasDownloadButton)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xFF20D7D7),
                          size: 20,
                        ),
                        label: Text(
                          'Download PDF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF20D7D7),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6FAFA),
                          foregroundColor: const Color(0xFF20D7D7),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
    );
  }
}
