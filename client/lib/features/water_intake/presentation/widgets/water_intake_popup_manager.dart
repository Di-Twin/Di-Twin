import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'water_intake_drawer.dart';

class WaterIntakePopupManager extends StatefulWidget {
  final Widget child; // The widget that this manager wraps (e.g., your Dashboard content)

  const WaterIntakePopupManager({super.key, required this.child});

  @override
  State<WaterIntakePopupManager> createState() => _WaterIntakePopupManagerState();
}

class _WaterIntakePopupManagerState extends State<WaterIntakePopupManager> {
  static const String _lastShownDateKey = 'last_water_intake_popup_shown_date';
  static const int _daysInterval = 3; // Show every 3 days

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWaterIntakePopup();
    });
  }

  Future<void> _checkAndShowWaterIntakePopup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownDateString = prefs.getString(_lastShownDateKey);

    DateTime? lastShownDate;
    if (lastShownDateString != null) {
      lastShownDate = DateTime.tryParse(lastShownDateString);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool shouldShow = false;

    if (lastShownDate == null) {
      // Never shown before, show it
      shouldShow = true;
    } else {
      final lastShownDay = DateTime(lastShownDate.year, lastShownDate.month, lastShownDate.day);
      final difference = today.difference(lastShownDay).inDays;

      if (difference >= _daysInterval) {
        shouldShow = true;
      }
    }

    if (shouldShow) {
      _showWaterIntakePopup();
      // Update the last shown date immediately after showing
      await prefs.setString(_lastShownDateKey, today.toIso8601String());
    }
  }

  void _showWaterIntakePopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false, // Prevent dismissal by clicking outside
      enableDrag: false, // Prevent dismissal by dragging
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            // Intercept back button and show confirmation instead
            return false; // Don't allow default back behavior
          },
          child: WaterIntakeDrawer(
            currentSlot: _getCurrentSlot(),
            onClose: () {
              Navigator.of(context).pop();
            },
            onWaterAdded: (amount) {
              // Handle water logging here
              print('Water logged: ${amount}ml');
            },
          ),
        );
      },
    );
  }

  String _getCurrentSlot() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 10) {
      return 'Morning';
    } else if (hour >= 10 && hour < 12) {
      return 'Mid-Morning';
    } else if (hour >= 12 && hour < 14) {
      return 'Lunch';
    } else if (hour >= 14 && hour < 18) {
      return 'Afternoon';
    } else if (hour >= 18 && hour < 22) {
      return 'Evening';
    } else {
      return 'Evening'; // Default for late night/early morning
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Render the wrapped child widget (e.g., your Dashboard)
  }
}
