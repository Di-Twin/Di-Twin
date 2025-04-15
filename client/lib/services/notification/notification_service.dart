import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BehaviorSubject<ReceivedNotification>
  didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

  final BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();

  // Channel IDs
  static const String sleepChannelId = 'sleep_channel';
  static const String reductionChannelId = 'reduction_channel';
  static const String foodLogChannelId = 'food_log_channel';

  // Channel Names
  static const String sleepChannelName = 'Sleep Tracking';
  static const String reductionChannelName = 'Reduction Reminders';
  static const String foodLogChannelName = 'Food Logging';

  // Channel Descriptions
  static const String sleepChannelDesc = 'Notifications for sleep tracking';
  static const String reductionChannelDesc =
      'Reminders for reduction medication';
  static const String foodLogChannelDesc = 'Reminders to log your food intake';

  // Notification IDs
  int get sleepNotificationId => 1;
  int get reductionNotificationId => 2;
  int get foodLogNotificationId => 3;

  // Initialize notification service
  Future<void> init() async {
    await _configureLocalTimeZone();

    // Initialize without specifying an icon - use a resource that definitely exists
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    // Updated iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
        }
        selectNotificationSubject.add(response.payload);
      },
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  // Modified method to use timezone package directly without flutter_native_timezone
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    
    // Use a default timezone like UTC
    const String defaultTimeZone = 'Etc/UTC';
    tz.setLocalLocation(tz.getLocation(defaultTimeZone));
    
    // Log the timezone being used
    debugPrint('Using timezone: $defaultTimeZone');
    
    // Optionally, you could try to determine the timezone from DateTime.now()
    // This is not as accurate as device timezone but can be a reasonable fallback
    try {
      final DateTime now = DateTime.now();
      final Duration offset = now.timeZoneOffset;
      final int hours = offset.inHours;
      final int minutes = (offset.inMinutes % 60).abs();
      
      debugPrint('Device timezone offset: ${offset.isNegative ? '-' : '+'}$hours:${minutes.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('Error determining timezone offset: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Sleep tracking channel
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              sleepChannelId,
              sleepChannelName,
              description: sleepChannelDesc,
              importance: Importance.high,
              enableVibration: true,
              playSound: true,
              enableLights: true,
              ledColor: Colors.blue,
            ),
          );

      // Reduction reminder channel
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              reductionChannelId,
              reductionChannelName,
              description: reductionChannelDesc,
              importance: Importance.high,
              enableVibration: true,
              playSound: true,
              enableLights: true,
              ledColor: Colors.purple,
            ),
          );

      // Food log channel
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              foodLogChannelId,
              foodLogChannelName,
              description: foodLogChannelDesc,
              importance: Importance.high,
              enableVibration: true,
              playSound: true,
              enableLights: true,
              ledColor: Colors.green,
            ),
          );
    }
  }

  // Request notification permissions
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      // For Android, we don't need to explicitly request permission in newer versions
      // of the flutter_local_notifications package
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Check if the method exists before calling it
      if (androidImplementation != null) {
        try {
          await androidImplementation.requestNotificationsPermission();
        } catch (e) {
          debugPrint('Error requesting Android permissions: $e');
          // Fallback for older versions or if method doesn't exist
        }
      }
    }
  }

  // Show immediate notification
  Future<void> showNotification({
  required String channelId,
  required int notificationId,
  required String title,
  required String body,
  String? payload,
  NotificationDetails? notificationDetails,
}) async {
  try {
    // Try to show the notification
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails ?? await _getNotificationDetails(channelId),
      payload: payload,
    );
    debugPrint('Notification shown successfully: $title');
  } catch (e) {
    // If there's an error, log it and continue without throwing
    debugPrint('Error showing notification: $e');
    // We won't try to show a fallback notification since that's also failing
    // Just log the error and continue
  }
}

  // Schedule a notification
  Future<void> scheduleNotification({
    required String channelId,
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails ?? await _getNotificationDetails(channelId),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notification scheduled successfully for: ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  // Schedule a daily notification
  Future<void> scheduleDailyNotification({
    required String channelId,
    required int notificationId,
    required String title,
    required String body,
    required TimeOfDay scheduledTime,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        notificationDetails ?? await _getNotificationDetails(channelId),
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Daily notification scheduled successfully for: ${scheduledTime.hour}:${scheduledTime.minute}');
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
      rethrow;
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get notification details based on channel
  Future<NotificationDetails> _getNotificationDetails(String channelId) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics;

    switch (channelId) {
      case sleepChannelId:
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          sleepChannelId,
          sleepChannelName,
          channelDescription: sleepChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Sleep tracking',
          styleInformation: BigTextStyleInformation(''),
          color: Colors.blue,
          // Removed icon reference
        );
        break;
      case reductionChannelId:
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          reductionChannelId,
          reductionChannelName,
          channelDescription: reductionChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Reduction reminder',
          styleInformation: BigTextStyleInformation(''),
          color: Colors.purple,
          // Removed icon reference
        );
        break;
      case foodLogChannelId:
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          foodLogChannelId,
          foodLogChannelName,
          channelDescription: foodLogChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Food log reminder',
          styleInformation: BigTextStyleInformation(''),
          color: Colors.green,
          // Removed icon reference
        );
        break;
      default:
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
          // Removed icon reference
        );
    }

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  // Generate a unique notification ID
  int generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}
