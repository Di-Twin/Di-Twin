// Update the BottomNavigation class to handle the Fitbit connection drawer
import 'package:client/features/dashboard/dashboard.dart';
import 'package:client/features/dashboard/settings_page.dart';
import 'package:client/features/food_management/presentation/pages/food_intelligence_page.dart';
import 'package:client/features/activity_management/presentation/pages/activity_today_page.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home_outlined, true, "home"),
          _buildNavItem(context, Icons.bar_chart_outlined, false, "activity"),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(context, Icons.restaurant_menu_outlined, false, "food"),
          _buildNavItem(context, Icons.settings_outlined, false, "settings"),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    bool isActive,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        if (route == "settings") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        } else if (route == "home") {
          // Navigate to Dashboard
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (route == "food") {
          // Navigate to Dashboard
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodIntelligencePage(),
            ),
          );
        } else if (route == "activity") {
          // Navigate to Dashboard
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityTodayPage()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration:
            isActive
                ? BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
          size: 28,
        ),
      ),
    );
  }
}
