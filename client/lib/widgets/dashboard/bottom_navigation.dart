import 'package:client/features/dashboard/settings_page.dart';
import 'package:client/features/food_management/food_management_score.dart';
import 'package:flutter/material.dart';
import 'package:client/features/dashboard/dashboard.dart';

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
              builder: (context) => const FoodIntelligenceScreen(),
            ),
          );
        } else if (route == "activity") {
          // Navigate to Dashboard
          Navigator.pushNamed(context, '/questions/goal');
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

/// **Floating Action Button (FAB)**
class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF2563EB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded Square
      ),
      elevation: 6,
      onPressed: () {},
      child: const Icon(
        Icons.camera_alt_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

/// **Main Scaffold with FAB & Bottom Nav**
class BottomNavBarScreen extends StatelessWidget {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigation(),
      floatingActionButton: const CustomFAB(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .centerDocked, // Ensures FAB is placed inside BottomAppBar
    );
  }
}
