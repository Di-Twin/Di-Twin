import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../notification_service.dart';

class FoodLogNotificationChannel {
  final NotificationService _notificationService = NotificationService();
  
  // Food log notification actions
  static const String _foodLogNowAction = 'FOOD_LOG_NOW';
  static const String _foodLogLaterAction = 'FOOD_LOG_LATER';
  
  // Show food log reminder notification
  Future<void> showFoodLogReminder({
    required String mealType,
    String? customMessage,
  }) async {
    final String title = 'Food Log Reminder';
    final String body = customMessage ?? 'Time to log your $mealType. Keeping track helps you stay on track!';
    
    final String payload = json.encode({
      'type': 'food_log_reminder',
      'mealType': mealType,
      'time': DateTime.now().toIso8601String(),
    });
    
    // Create custom notification details with action buttons
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      NotificationService.foodLogChannelId,
      NotificationService.foodLogChannelName,
      channelDescription: NotificationService.foodLogChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.green,
      colorized: true,
      category: AndroidNotificationCategory.reminder,
      actions: [
        const AndroidNotificationAction(
          _foodLogNowAction,
          'Log Now',
          // Remove the icon reference that's causing the error
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          _foodLogLaterAction,
          'Remind Later',
          // Remove the icon reference that's causing the error
          showsUserInterface: false,
        ),
      ],
    );
    
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'foodLogReminder',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationService.showNotification(
      channelId: NotificationService.foodLogChannelId,
      notificationId: _notificationService.generateUniqueId(),
      title: title,
      body: body,
      payload: payload,
      notificationDetails: notificationDetails,
    );
  }
  
  // Schedule a food log reminder notification
  Future<void> scheduleFoodLogReminder({
    required String mealType,
    required TimeOfDay reminderTime,
    String? customMessage,
    bool isDaily = true,
    List<int>? daysOfWeek,
  }) async {
    final String title = 'Food Log Reminder';
    final String body = customMessage ?? 'Time to log your $mealType!';
    
    final String payload = json.encode({
      'type': 'food_log_reminder',
      'mealType': mealType,
    });
    
    await _notificationService.scheduleDailyNotification(
      channelId: NotificationService.foodLogChannelId,
      notificationId: _notificationService.generateUniqueId(),
      title: title,
      body: body,
      scheduledTime: reminderTime,
      payload: payload,
    );
  }
  
  // Schedule multiple meal reminders
  Future<void> scheduleAllMealReminders({
    required Map<String, TimeOfDay> mealSchedule,
  }) async {
    for (final entry in mealSchedule.entries) {
      await scheduleFoodLogReminder(
        mealType: entry.key,
        reminderTime: entry.value,
      );
    }
  }
  
  // Cancel all food log reminders
  Future<void> cancelAllFoodLogReminders() async {
    // This would require keeping track of all food log notification IDs
    // For now, we'll just cancel the default one
    await _notificationService.cancelNotification(
      _notificationService.foodLogNotificationId,
    );
  }
}
