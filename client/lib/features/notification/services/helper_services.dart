import 'package:flutter/material.dart';
import 'api_services.dart';
import 'firebase_services.dart';

class NotificationHelperService {
  static final NotificationHelperService _instance = NotificationHelperService._internal();
  factory NotificationHelperService() => _instance;
  
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isInitialized = false;
  
  NotificationHelperService._internal();
  
  // Initialize with user credentials
  Future<void> initialize({required String accessToken, required String userId}) async {
    if (_isInitialized) return;
    
    try {
      // Initialize API service
      _apiService.initialize(accessToken: accessToken, userId: userId);
      
      // Initialize Firebase service
      await _firebaseService.initialize();
      
      _isInitialized = true;
      debugPrint('Notification Helper Service initialized with FCM only');
    } catch (e) {
      debugPrint('Error initializing Notification Helper Service: $e');
      rethrow;
    }
  }
  
  // Send a notification via FCM
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
    String? recipientId,
  }) async {
    try {
      return await _apiService.sendNotification(
        title: title,
        message: message,
        type: type,
        data: data,
        recipientId: recipientId,
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get FCM token
  String? get fcmToken => _firebaseService.token;
  
  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}
