import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  // Local notifications plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String generalChannelId = 'general_channel';
  static const String reductionChannelId = 'reduction_channel';
  static const String foodLogChannelId = 'food_log_channel';

  // Notification callback
  static Function(String?)? onNotificationTap;

  // Initialization status
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Add a set to track recently processed notification IDs to prevent duplicates
  static final Set<String> _processedNotificationIds = <String>{};
  // Track when notifications were processed to clean up old entries
  static final Map<String, DateTime> _notificationProcessTimes =
      <String, DateTime>{};
  // Maximum time to consider a notification as a duplicate (in seconds)
  static const int _deduplicationTimeWindow = 10;

  // Initialize notification services
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            notificationCategories: [
              DarwinNotificationCategory(
                'reductionReminder',
                actions: [
                  DarwinNotificationAction.plain('REDUCTION_TAKEN', 'Taken'),
                  DarwinNotificationAction.plain('REDUCTION_SKIP', 'Skip'),
                  DarwinNotificationAction.plain(
                    'REDUCTION_REMIND',
                    'Remind Later',
                  ),
                ],
              ),
              DarwinNotificationCategory(
                'foodLogReminder',
                actions: [
                  DarwinNotificationAction.plain('FOOD_LOG_NOW', 'Log Now'),
                  DarwinNotificationAction.plain(
                    'FOOD_LOG_LATER',
                    'Remind Later',
                  ),
                ],
              ),
            ],
          );

      // Initialize settings
      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
          if (onNotificationTap != null) {
            onNotificationTap!(details.payload);
          }
        },
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      _isInitialized = true;
      debugPrint('Notification system initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification system: $e');
      // Don't mark as initialized if there was an error
    }
  }

  // Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        // General channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            generalChannelId,
            'General Notifications',
            description: 'General app notifications',
            importance: Importance.high,
          ),
        );

        // Reduction reminder channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            reductionChannelId,
            'Reduction Reminders',
            description: 'Reminders for reduction medication',
            importance: Importance.high,
            enableVibration: true,
            enableLights: true,
            ledColor: Colors.purple,
          ),
        );

        // Food log channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            foodLogChannelId,
            'Food Logging',
            description: 'Reminders to log your food intake',
            importance: Importance.high,
            enableVibration: true,
            enableLights: true,
            ledColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating notification channels: $e');
      // Continue even if channel creation fails
    }
  }

  // Clean up old notification IDs from the deduplication set
  static void _cleanupOldNotificationIds() {
    final now = DateTime.now();
    final idsToRemove = <String>[];

    _notificationProcessTimes.forEach((id, time) {
      if (now.difference(time).inSeconds > _deduplicationTimeWindow) {
        idsToRemove.add(id);
      }
    });

    for (final id in idsToRemove) {
      _processedNotificationIds.remove(id);
      _notificationProcessTimes.remove(id);
    }
  }

  // Check if a notification is a duplicate
  static bool _isDuplicate(String notificationId) {
    // Clean up old entries first
    _cleanupOldNotificationIds();

    // Check if this ID has been processed recently
    if (_processedNotificationIds.contains(notificationId)) {
      debugPrint('Duplicate notification detected: $notificationId');
      return true;
    }

    // Not a duplicate, add to processed set
    _processedNotificationIds.add(notificationId);
    _notificationProcessTimes[notificationId] = DateTime.now();

    // Limit the size of the sets to prevent memory issues
    if (_processedNotificationIds.length > 100) {
      final oldestId =
          _notificationProcessTimes.entries
              .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
              .key;
      _processedNotificationIds.remove(oldestId);
      _notificationProcessTimes.remove(oldestId);
    }

    return false;
  }

  // Show system notification
  static Future<void> showSystemNotification(
    NotificationModel notification,
  ) async {
    if (!_isInitialized) {
      debugPrint('Notification system not initialized. Initializing now...');
      await initialize();
    }

    try {
      // Generate a consistent ID for deduplication
      final dedupeId = 'system_${notification.id}_${notification.type}';

      // Skip if this is a duplicate
      if (_isDuplicate(dedupeId)) {
        return;
      }

      String channelId = generalChannelId;

      // Determine channel based on notification type
      if (notification.type.contains('reduction') ||
          notification.type.contains('medication')) {
        channelId = reductionChannelId;
      } else if (notification.type.contains('food')) {
        channelId = foodLogChannelId;
      }

      // Create notification details
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId
              .split('_')
              .map(
                (word) =>
                    word.substring(0, 1).toUpperCase() + word.substring(1),
              )
              .join(' '),
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          color: getNotificationColor(notification.type),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: notification.sound,
          attachments:
              notification.imageUrl != null
                  ? [DarwinNotificationAttachment(notification.imageUrl!)]
                  : null,
        ),
      );
      
      // Show notification
      await _notificationsPlugin.show(
        notification.id.hashCode,
        notification.title,
        notification.message,
        platformChannelSpecifics,
        payload: notification.payload,
      );
    } catch (e) {
      debugPrint('Error showing system notification: $e');
    }
  }

  // Process FCM message
  static void processFirebaseMessage(RemoteMessage message) {
    try {
      // Generate a consistent ID for deduplication
      final messageId = message.messageId ?? const Uuid().v4();
      final dedupeId = 'fcm_$messageId';

      // Skip if this is a duplicate
      if (_isDuplicate(dedupeId)) {
        debugPrint('Skipping duplicate Firebase message: $messageId');
        return;
      }

      final notification = NotificationModel(
        id: messageId,
        title: message.notification?.title ?? 'New Notification',
        message: message.notification?.body ?? '',
        type: message.data['type'] ?? 'general',
        timestamp: DateTime.now(),
        payload: json.encode(message.data),
        imageUrl: message.data['imageUrl'],
        sound: message.data['sound'],
      );

      // Show system notification
      showSystemNotification(notification);
    } catch (e) {
      debugPrint('Error processing Firebase message: $e');
    }
  }

  // Handle notification tap
  static void handleNotificationTap(String? payload) {
    if (payload == null) return;

    try {
      final data = json.decode(payload);
      final type = data['type'] as String? ?? '';

      // Navigate based on notification type
      if (type.contains('reduction') || type.contains('medication')) {
        // Navigate to medication screen
        debugPrint('Navigate to medication screen');
      } else if (type.contains('food')) {
        // Navigate to food log screen
        debugPrint('Navigate to food log screen');
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Get notification color based on type
  static Color getNotificationColor(String type) {
    // Use the same color (#0F67FE) for all notification types
    return const Color(0xFF0F67FE);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  // Notification model
  static NotificationModel createNotification({
    required String id,
    required String title,
    required String message,
    required String type,
    required DateTime timestamp,
    String? payload,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      payload: payload,
    );
  }
}

// Define NotificationModel as a separate class outside of NotificationManager
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final String? payload;
  final String? imageUrl;
  final String? sound;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.payload,
    this.imageUrl,
    this.sound,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'] ?? 'general',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      payload: json['payload'],
      imageUrl: json['imageUrl'],
      sound: json['sound'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
      'imageUrl': imageUrl,
      'sound': sound,
    };
  }
}
