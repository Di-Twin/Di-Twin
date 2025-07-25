import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/water_intake_provider.dart';
import 'water_notification_card.dart';

class WaterReminderService extends StatefulWidget {
  final Widget child;

  const WaterReminderService({
    super.key,
    required this.child,
  });

  @override
  State<WaterReminderService> createState() => _WaterReminderServiceState();
}

class _WaterReminderServiceState extends State<WaterReminderService> {
  Timer? _reminderTimer;
  bool _showNotification = false;

  @override
  void initState() {
    super.initState();
    _startReminderService();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startReminderService() {
    // Check every 30 minutes if user needs a reminder
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkAndShowReminder();
    });

    // Initial check after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _checkAndShowReminder();
    });
  }

  void _checkAndShowReminder() {
    if (!mounted) return;

    final provider = Provider.of<WaterIntakeProvider>(context, listen: false);
    final todayIntake = provider.todayIntake;
    final now = DateTime.now();

    // Don't show reminders too early or too late
    if (now.hour < 7 || now.hour > 22) return;

    // Don't show if goal is already achieved
    if (todayIntake.isGoalAchieved) {
      setState(() {
        _showNotification = false;
      });
      return;
    }

    // Check if it's time for a reminder based on the schedule
    final reminderTimes = provider.reminderTimes;
    final currentTime = TimeOfDay.fromDateTime(now);

    bool shouldShowReminder = false;

    for (final reminderTime in reminderTimes) {
      final reminderMinutes = reminderTime.hour * 60 + reminderTime.minute;
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;

      // Show reminder if we're within 15 minutes of a scheduled time
      if ((currentMinutes - reminderMinutes).abs() <= 15) {
        shouldShowReminder = true;
        break;
      }
    }

    // Also show reminder if user hasn't logged water in the last 2 hours
    if (!shouldShowReminder && todayIntake.intakes.isNotEmpty) {
      final lastIntake = todayIntake.intakes.last;
      final timeSinceLastIntake = now.difference(lastIntake.timestamp);

      if (timeSinceLastIntake.inHours >= 2) {
        shouldShowReminder = true;
      }
    }

    // Show reminder if no water logged today and it's past 9 AM
    if (!shouldShowReminder && todayIntake.intakes.isEmpty && now.hour >= 9) {
      shouldShowReminder = true;
    }

    setState(() {
      _showNotification = shouldShowReminder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showNotification)
          const WaterNotificationCard(),
      ],
    );
  }
}
