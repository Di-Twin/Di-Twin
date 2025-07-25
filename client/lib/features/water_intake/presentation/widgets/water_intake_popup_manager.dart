import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/widgets/dashboard/smart_water_intake_widget.dart';

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
      isScrollControlled: true, // Allows the sheet to be full height if needed
      backgroundColor: Colors.transparent, // For custom rounded corners
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const WaterIntakeBottomSheetContent(), // Use the renamed widget
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Render the wrapped child widget (e.g., your Dashboard)
  }
}
