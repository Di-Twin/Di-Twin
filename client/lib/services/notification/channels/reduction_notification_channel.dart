import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../notification_service.dart';

class ReductionNotificationChannel {
  final NotificationService _notificationService = NotificationService();
  
  // Reduction reminder notification actions
  static const String _reductionTakenAction = 'REDUCTION_TAKEN';
  static const String _reductionSkipAction = 'REDUCTION_SKIP';
  static const String _reductionRemindAction = 'REDUCTION_REMIND';
  
  // Show reduction reminder notification
  Future<void> showReductionReminder({
    required String medicationName,
    required String dosage,
    String? instructions,
  }) async {
    final String title = 'Time for Your $medicationName';
    final String body = dosage.isNotEmpty
        ? '$dosage. ${instructions ?? "Take as prescribed."}'
        : 'It\'s time to take your reduction medication. ${instructions ?? ""}';
    
    final String payload = json.encode({
      'type': 'reduction_reminder',
      'medicationName': medicationName,
      'dosage': dosage,
      'time': DateTime.now().toIso8601String(),
    });
    
    // Create custom notification details with action buttons
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      NotificationService.reductionChannelId,
      NotificationService.reductionChannelName,
      channelDescription: NotificationService.reductionChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.purple,
      colorized: true,
      category: AndroidNotificationCategory.reminder,
      actions: [
        const AndroidNotificationAction(
          _reductionTakenAction,
          'Taken',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          _reductionSkipAction,
          'Skip',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          _reductionRemindAction,
          'Remind Later',
          showsUserInterface: false,
        ),
      ],
    );
    
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'reductionReminder',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationService.showNotification(
      channelId: NotificationService.reductionChannelId,
      notificationId: _notificationService.generateUniqueId(),
      title: title,
      body: body,
      payload: payload,
      notificationDetails: notificationDetails,
    );
  }
  
  // Schedule a reduction reminder notification
  Future<void> scheduleReductionReminder({
    required String medicationName,
    required String dosage,
    required TimeOfDay reminderTime,
    String? instructions,
    bool isDaily = true,
    List<int>? daysOfWeek,
  }) async {
    final String title = 'Reduction Reminder';
    
    // Simpler time formatting
    final String formattedTime = '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}';
    final String amPm = reminderTime.hour >= 12 ? 'PM' : 'AM';
    final int displayHour = reminderTime.hour > 12 ? reminderTime.hour - 12 : (reminderTime.hour == 0 ? 12 : reminderTime.hour);
    
    final String body = '$medicationName $dosage due at $displayHour:${reminderTime.minute.toString().padLeft(2, '0')} $amPm';
    
    final String payload = json.encode({
      'type': 'reduction_reminder',
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
    });
    
    await _notificationService.scheduleDailyNotification(
      channelId: NotificationService.reductionChannelId,
      notificationId: _notificationService.generateUniqueId(),
      title: title,
      body: body,
      scheduledTime: reminderTime,
      payload: payload,
    );
  }
  
  // Schedule a one-time reduction reminder
  Future<void> scheduleOneTimeReductionReminder({
    required String medicationName,
    required String dosage,
    required DateTime reminderTime,
    String? instructions,
  }) async {
    final String title = 'Reduction Reminder';
    final String body = 'Time to take $medicationName $dosage. ${instructions ?? ""}';
    
    final String payload = json.encode({
      'type': 'reduction_reminder',
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
    });
    
    await _notificationService.scheduleNotification(
      channelId: NotificationService.reductionChannelId,
      notificationId: _notificationService.generateUniqueId(),
      title: title,
      body: body,
      scheduledDate: reminderTime,
      payload: payload,
    );
  }
  
  // Cancel all reduction reminders
  Future<void> cancelAllReductionReminders() async {
    // This would require keeping track of all reduction notification IDs
    // For now, we'll just cancel the default one
    await _notificationService.cancelNotification(
      _notificationService.reductionNotificationId,
    );
  }
}
