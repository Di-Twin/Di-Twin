import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../notification_service.dart';
import '../models/sleep_log_model.dart';

class SleepNotificationChannel {
  final NotificationService _notificationService = NotificationService();
  
  // Sleep tracking notification ID
  static const int _sleepNotificationId = 1;
  
  // Sleep tracking notification actions
  static const String _sleepStartAction = 'SLEEP_START';
  static const String _sleepStopAction = 'SLEEP_STOP';
  
  // Sleep tracking notification payload keys
  static const String _sleepStartTimeKey = 'sleepStartTime';
  static const String _sleepStopTimeKey = 'sleepStopTime';
  static const String _sleepSessionIdKey = 'sleepSessionId';
  
  // Show sleep tracking notification
  Future<void> showSleepTrackingNotification({
    required bool isTracking,
    DateTime? startTime,
    String? sessionId,
  }) async {
    final String title = isTracking 
        ? 'Sleep Tracking Active' 
        : 'Track Your Sleep';
    
    final String body = isTracking
        ? 'Started at ${DateFormat('hh:mm a').format(startTime!)}. Tap to stop tracking.'
        : 'Tap to start tracking your sleep.';
    
    final String payload = isTracking
        ? json.encode({
            _sleepStartAction: true,
            _sleepStartTimeKey: startTime!.toIso8601String(),
            _sleepSessionIdKey: sessionId,
          })
        : json.encode({
            _sleepStartAction: false,
          });
    
    // Create custom notification details with action buttons
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      NotificationService.sleepChannelId,
      NotificationService.sleepChannelName,
      channelDescription: NotificationService.sleepChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: isTracking, // Make notification persistent when tracking
      autoCancel: !isTracking,
      color: Colors.indigo,
      colorized: true,
      category: AndroidNotificationCategory.service,
      actions: [
        if (isTracking)
          const AndroidNotificationAction(
            _sleepStopAction,
            'Stop Tracking',
            // Remove the icon reference that's causing the error
            showsUserInterface: true,
          )
        else
          const AndroidNotificationAction(
            _sleepStartAction,
            'Start Tracking',
            // Remove the icon reference that's causing the error
            showsUserInterface: true,
          ),
      ],
    );
    
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'sleepTracking',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationService.showNotification(
      channelId: NotificationService.sleepChannelId,
      notificationId: _sleepNotificationId,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: notificationDetails,
    );
  }
  
  // Schedule a sleep reminder notification
  Future<void> scheduleSleepReminder({
    required TimeOfDay reminderTime,
    required String message,
  }) async {
    final String title = 'Sleep Reminder';
    final String body = message.isNotEmpty 
        ? message 
        : 'Time to prepare for sleep. Tap to start tracking.';
    
    await _notificationService.scheduleDailyNotification(
      channelId: NotificationService.sleepChannelId,
      notificationId: _notificationService.generateUniqueId(),
      title: title,
      body: body,
      scheduledTime: reminderTime,
      payload: json.encode({
        'type': 'sleep_reminder',
      }),
    );
  }
  
  // Cancel sleep tracking notification
  Future<void> cancelSleepTrackingNotification() async {
    await _notificationService.cancelNotification(_sleepNotificationId);
  }
  
  // Parse sleep notification payload
  SleepLogModel? parseSleepPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    
    try {
      final Map<String, dynamic> data = json.decode(payload);
      
      if (data.containsKey(_sleepStartTimeKey) && 
          data.containsKey(_sleepSessionIdKey)) {
        return SleepLogModel(
          sessionId: data[_sleepSessionIdKey],
          startTime: DateTime.parse(data[_sleepStartTimeKey]),
          endTime: data.containsKey(_sleepStopTimeKey) 
              ? DateTime.parse(data[_sleepStopTimeKey]) 
              : null,
        );
      }
    } catch (e) {
      debugPrint('Error parsing sleep payload: $e');
    }
    
    return null;
  }
}
