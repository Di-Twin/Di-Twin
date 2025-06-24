import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  // static final NotificationService _instance = NotificationService._internal();
  // factory NotificationService() => _instance;
  // NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // In NotificationService._internal()
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Add @ prefix

  final BehaviorSubject<ReceivedNotification>
  didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

  final BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();

  // Channel IDs
  static const String reductionChannelId = 'reduction_channel';
  static const String foodLogChannelId = 'food_log_channel';

  // Channel Names
  static const String reductionChannelName = 'Reduction Reminders';
  static const String foodLogChannelName = 'Food Logging';

  // Channel Descriptions
  static const String reductionChannelDesc =
      'Reminders for reduction medication';
  static const String foodLogChannelDesc = 'Reminders to log your food intake';

  // Notification IDs
  int get reductionNotificationId => 2;
  int get foodLogNotificationId => 3;

  // Initialize notification service
  Future<void> init() async {
    try {
      await _configureLocalTimeZone();

      // Request permissions for Android
      if (Platform.isAndroid) {
        final androidPlugin =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        // Request exact alarms permission
        await androidPlugin?.requestExactAlarmsPermission();

        // Request notification permission (Android 13+)
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      }

      // For iOS, request permissions
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true, // Add this for time-sensitive notifications
            );
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            requestCriticalPermission:
                true, // Add this for time-sensitive notifications
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

      await _createNotificationChannels();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Modified method to use timezone package directly without flutter_native_timezone
  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();

      // Get the device's local timezone
      final String timeZoneName = await _getLocalTimeZoneName();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Print for debugging
      final now = tz.TZDateTime.now(tz.local);
      debugPrint('Using timezone: $timeZoneName');
      debugPrint('Current time in timezone: $now');
    } catch (e) {
      debugPrint('Error configuring timezone: $e');
      // Fallback to UTC if all else fails
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<String> _getLocalTimeZoneName() async {
    try {
      // Works on both Android and iOS
      return await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      debugPrint('Error getting local timezone: $e');
      return 'UTC';
    }
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
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

  Future<void> testNotificationIn2Minutes() async {
    final now = DateTime.now().add(const Duration(minutes: 2));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      9999, // Unique ID
      'Test Notification',
      'This is a scheduled test notification',
      tz.TZDateTime.from(now, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Channel for test notifications',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'test_notification',
    );
    debugPrint('Test notification scheduled for ${now.toLocal()}');
  }

  // Show immediate notification
  Future<void> showNotification({
    required String channelId,
    required int notificationId,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String? sound,
    NotificationDetails? notificationDetails,
  }) async {
    debugPrint('Attempting to show notification: $title');
    try {
      final details =
          notificationDetails ??
          await _getNotificationDetails(
            channelId,
            imageUrl: imageUrl,
            sound: sound,
          );
      debugPrint('Notification details: $details');

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('Notification shown successfully: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
      debugPrint('Stack trace: ${e.toString()}');
    }
  }

  // Schedule a notification
  Future<void> scheduleDailyNotification({
    required String channelId,
    required int notificationId,
    required String title,
    required String body,
    required TimeOfDay scheduledTime,
    String? payload,
    String? imageUrl,
    String? sound,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      // If time already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint('Time passed, scheduling for next day at $scheduledDate');
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        await _getNotificationDetails(
          channelId,
          imageUrl: imageUrl,
          sound: sound,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Notification scheduled for: ${scheduledDate.toLocal()}');
    } catch (e, stackTrace) {
      debugPrint('Error scheduling notification: $e');
      debugPrint('Stack trace: $stackTrace');
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
  Future<NotificationDetails> _getNotificationDetails(
    String channelId, {
    String? imageUrl,
    String? sound,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics;

    switch (channelId) {
      case reductionChannelId:
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          reductionChannelId,
          reductionChannelName,
          channelDescription: reductionChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Reduction reminder',
          styleInformation:
              imageUrl != null
                  ? BigPictureStyleInformation(
                    FilePathAndroidBitmap(imageUrl),
                    hideExpandedLargeIcon: true,
                  )
                  : BigTextStyleInformation(''),
          color: Colors.purple,
          sound:
              sound != null ? RawResourceAndroidNotificationSound(sound) : null,
          largeIcon: imageUrl != null ? FilePathAndroidBitmap(imageUrl) : null,
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
          styleInformation:
              imageUrl != null
                  ? BigPictureStyleInformation(
                    FilePathAndroidBitmap(imageUrl),
                    hideExpandedLargeIcon: true,
                  )
                  : BigTextStyleInformation(''),
          color: Colors.green,
          sound:
              sound != null ? RawResourceAndroidNotificationSound(sound) : null,
          largeIcon: imageUrl != null ? FilePathAndroidBitmap(imageUrl) : null,
        );
        break;
      default:
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation:
              imageUrl != null
                  ? BigPictureStyleInformation(
                    FilePathAndroidBitmap(imageUrl),
                    hideExpandedLargeIcon: true,
                  )
                  : BigTextStyleInformation(''),
          sound:
              sound != null ? RawResourceAndroidNotificationSound(sound) : null,
          largeIcon: imageUrl != null ? FilePathAndroidBitmap(imageUrl) : null,
        );
    }

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: sound,
          attachments:
              imageUrl != null
                  ? [DarwinNotificationAttachment(imageUrl)]
                  : null,
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

  Future<void> testCustomNotification({
    required String title,
    required String body,
    String? imageUrl,
    String? sound,
  }) async {
    await showNotification(
      channelId: 'default_channel',
      notificationId: 9999,
      title: title,
      body: body,
      imageUrl: imageUrl,
      sound: sound,
      payload: json.encode({
        'type': 'test',
        'imageUrl': imageUrl,
        'sound': sound,
      }),
    );
    debugPrint('Custom notification sent with image: $imageUrl, sound: $sound');
  }
}
