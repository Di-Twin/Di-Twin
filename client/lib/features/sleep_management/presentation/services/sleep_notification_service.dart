import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/sleep_provider.dart';
import 'dart:developer' as developer;

class SleepNotificationService {
  static final SleepNotificationService _instance = SleepNotificationService._internal();
  factory SleepNotificationService() => _instance;
  SleepNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String _sleepChannelId = 'sleep_reminders';
  static const String _sleepChannelName = 'Sleep Reminders';
  static const String _sleepChannelDesc = 'Notifications for bedtime reminders';
  static const int _bedtimeNotificationId = 1001;
  static const String _notificationEnabledKey = 'sleep_notifications_enabled';

  bool _isInitialized = false;
  SleepProvider? _sleepProvider;

  Future<void> initialize(SleepProvider sleepProvider) async {
    if (_isInitialized) return;

    _sleepProvider = sleepProvider;

    try {
      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _createNotificationChannel();
      await _scheduleDailyBedtimeNotification();

      _isInitialized = true;
      developer.log('✅ Sleep notification service initialized', name: 'SleepNotificationService');
    } catch (e) {
      developer.log('❌ Error initializing sleep notification service: $e', name: 'SleepNotificationService');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _sleepChannelId,
      _sleepChannelName,
      description: _sleepChannelDesc,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Colors.deepPurple,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _scheduleDailyBedtimeNotification() async {
    try {
      // Check if notifications are enabled
      if (!await isNotificationEnabled()) {
        developer.log('🔕 Sleep notifications are disabled', name: 'SleepNotificationService');
        return;
      }

      // Cancel existing notification
      await _flutterLocalNotificationsPlugin.cancel(_bedtimeNotificationId);

      // Schedule for 11:00 PM daily
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        23, // 11 PM
        0,  // 0 minutes
      );

      // If 11 PM has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        _sleepChannelId,
        _sleepChannelName,
        channelDescription: _sleepChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Bedtime reminder',
        styleInformation: BigTextStyleInformation(
          'It\'s your bedtime 🌙 Time to rest! Tap to start tracking your sleep.',
        ),
        color: Colors.deepPurple,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'start_sleep',
            'Start Sleep',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_sleep'),
          ),
          AndroidNotificationAction(
            'dismiss',
            'Not Now',
          ),
        ],
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'sleep_category',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _bedtimeNotificationId,
        'Bedtime Reminder 🌙',
        'It\'s your bedtime 🌙 Time to rest!',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'bedtime_reminder',
      );

      developer.log('✅ Bedtime notification scheduled for: ${scheduledDate.toLocal()}', name: 'SleepNotificationService');
    } catch (e) {
      developer.log('❌ Error scheduling bedtime notification: $e', name: 'SleepNotificationService');
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    developer.log('🔔 Sleep notification tapped: ${response.payload}', name: 'SleepNotificationService');

    if (response.payload == 'bedtime_reminder') {
      // Check if user already has sleep data for today
      if (_sleepProvider != null) {
        final hasData = await _sleepProvider!.hasSleepDataForToday();

        if (!hasData) {
          // Handle notification action
          if (response.actionId == 'start_sleep') {
            await _handleStartSleepFromNotification();
          } else {
            // Default tap - navigate to sleep screen or show dialog
            await _handleBedtimeNotificationTap();
          }
        } else {
          developer.log('ℹ️ User already has sleep data for today', name: 'SleepNotificationService');
        }
      }
    }
  }

  Future<void> _handleStartSleepFromNotification() async {
    try {
      if (_sleepProvider != null) {
        final success = await _sleepProvider!.startSleep();
        if (success) {
          await _showSleepStartedNotification();
          developer.log('✅ Sleep started from notification', name: 'SleepNotificationService');
        }
      }
    } catch (e) {
      developer.log('❌ Error starting sleep from notification: $e', name: 'SleepNotificationService');
    }
  }

  Future<void> _handleBedtimeNotificationTap() async {
    // This could navigate to a sleep screen or show a dialog
    // For now, we'll just log it
    developer.log('🌙 Bedtime notification tapped - should navigate to sleep screen', name: 'SleepNotificationService');
  }

  Future<void> _showSleepStartedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      _sleepChannelId,
      _sleepChannelName,
      channelDescription: 'Sleep tracking started',
      importance: Importance.low,
      priority: Priority.low,
      ticker: 'Sleep started',
      styleInformation: BigTextStyleInformation(
        'Sleep tracking started. Have a good night! 😴',
      ),
      color: Colors.deepPurple,
      autoCancel: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      _bedtimeNotificationId + 1,
      'Sleep Started 😴',
      'Sleep tracking started. Have a good night!',
      platformChannelSpecifics,
      payload: 'sleep_started',
    );
  }

  // Check if user should receive bedtime notification
  Future<bool> shouldShowBedtimeNotification() async {
    if (_sleepProvider == null) return false;

    try {
      // Check if user already has sleep data for today
      final hasData = await _sleepProvider!.hasSleepDataForToday();
      return !hasData;
    } catch (e) {
      developer.log('❌ Error checking if should show bedtime notification: $e', name: 'SleepNotificationService');
      return false;
    }
  }

  // Enable/disable notifications
  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, enabled);

      if (enabled) {
        await _scheduleDailyBedtimeNotification();
      } else {
        await _flutterLocalNotificationsPlugin.cancel(_bedtimeNotificationId);
      }

      developer.log('${enabled ? '✅' : '🔕'} Sleep notifications ${enabled ? 'enabled' : 'disabled'}', name: 'SleepNotificationService');
    } catch (e) {
      developer.log('❌ Error setting notification enabled: $e', name: 'SleepNotificationService');
    }
  }

  Future<bool> isNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationEnabledKey) ?? true; // Default to enabled
    } catch (e) {
      developer.log('❌ Error checking if notification enabled: $e', name: 'SleepNotificationService');
      return true;
    }
  }

  // Manual trigger for testing
  Future<void> triggerTestBedtimeNotification() async {
    if (!await isNotificationEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      _sleepChannelId,
      _sleepChannelName,
      channelDescription: _sleepChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Test bedtime reminder',
      styleInformation: BigTextStyleInformation(
        'Test: It\'s your bedtime 🌙 Time to rest!',
      ),
      color: Colors.deepPurple,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'start_sleep',
          'Start Sleep',
        ),
        AndroidNotificationAction(
          'dismiss',
          'Not Now',
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      9999, // Test notification ID
      'Test Bedtime Reminder 🌙',
      'It\'s your bedtime 🌙 Time to rest!',
      platformChannelSpecifics,
      payload: 'bedtime_reminder',
    );

    developer.log('🧪 Test bedtime notification triggered', name: 'SleepNotificationService');
  }
}
