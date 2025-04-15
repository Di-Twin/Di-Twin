import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification/notification_service.dart';
import '../../services/notification/channels/sleep_notification_channel.dart';
import '../../services/notification/channels/reduction_notification_channel.dart';
import '../../services/notification/channels/food_log_notification_channel.dart';
import '../../features/sleep_management/sleep_notification_handler.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Sleep notification channel provider
final sleepNotificationChannelProvider = Provider<SleepNotificationChannel>((ref) {
  return SleepNotificationChannel();
});

// Reduction notification channel provider
final reductionNotificationChannelProvider = Provider<ReductionNotificationChannel>((ref) {
  return ReductionNotificationChannel();
});

// Food log notification channel provider
final foodLogNotificationChannelProvider = Provider<FoodLogNotificationChannel>((ref) {
  return FoodLogNotificationChannel();
});

// Sleep notification handler provider
final sleepNotificationHandlerProvider = Provider<SleepNotificationHandler>((ref) {
  return SleepNotificationHandler();
});

// Sleep tracking state provider
final sleepTrackingStateProvider = StateProvider<bool>((ref) {
  return false;
});

// Current sleep session provider
final currentSleepSessionProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});

// Scheduled notifications provider
final scheduledNotificationsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [];
});
