import 'package:flutter/material.dart';
import 'package:client/widgets/dashboard/app_header.dart';
import 'package:client/widgets/dashboard/health_score_card.dart';
import 'package:client/widgets/dashboard/health_metrics_section.dart';
import 'package:client/widgets/dashboard/fitness_tracker_section.dart';
import 'package:client/widgets/dashboard/medication_section.dart';
import 'package:client/widgets/dashboard/bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SafeArea(
                child: AppHeader(), // Prevents merging with the status bar
              ),
            ),
          ];
        },
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: const [
            SizedBox(height: 20),
            HealthScoreCard(),
            SizedBox(height: 20),
            HealthMetricsSection(),
            SizedBox(height: 20),
            FitnessTrackerSection(),
            SizedBox(height: 20),
            MedicationSection(),
            SizedBox(height: 20),
          ],
        ),
      ),

      /// **Bottom Navigation Bar**
      bottomNavigationBar: const BottomNavigation(),

      /// **Custom Floating Action Button with Rounded Rectangle Background**
      floatingActionButton: GestureDetector(
        onTap: () {
          // Add your camera function here
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB), // Background Color
            borderRadius: BorderRadius.circular(16), // Rounded Rectangle Shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 4), // Slight lift effect
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
