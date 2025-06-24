import 'package:flutter/material.dart';
import 'api_services.dart';
import 'firebase_services.dart';

class NotificationHelperService {
  static final NotificationHelperService _instance = NotificationHelperService._internal();
  factory NotificationHelperService() => _instance;
  
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isInitialized = false;
  bool _preferWebsocket = true; // Default to WebSocket if available
  
  NotificationHelperService._internal();
  
  // Initialize with user credentials
  Future<void> initialize({required String accessToken, required String userId}) async {
    if (_isInitialized) return;
    
    try {
      // Initialize API service
      _apiService.initialize(accessToken: accessToken, userId: userId);
      
      // Initialize Firebase service
      await _firebaseService.initialize();
      
      // Check connection status
      await checkConnectionStatus();
      
      _isInitialized = true;
      debugPrint('Notification Helper Service initialized');
    } catch (e) {
      debugPrint('Error initializing Notification Helper Service: $e');
      rethrow;
    }
  }
  
  // Check connection status and determine notification method
  Future<void> checkConnectionStatus() async {
    try {
      final response = await _apiService.checkConnectionStatus();
      
      if (response['success'] == true) {
        _preferWebsocket = response['isConnected'] == true;
        debugPrint('Connection status: WebSocket is ${_preferWebsocket ? "connected" : "disconnected"}');
        debugPrint('Using ${_preferWebsocket ? "WebSocket" : "FCM"} for notifications');
      } else {
        // If check fails, default to FCM
        _preferWebsocket = false;
        debugPrint('Connection check failed, defaulting to FCM');
      }
    } catch (e) {
      // If error occurs, default to FCM
      _preferWebsocket = false;
      debugPrint('Error checking connection status: $e');
      debugPrint('Defaulting to FCM for notifications');
    }
  }
  
  // Send a notification, automatically choosing the best method
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
    String? recipientId,
  }) async {
    try {
      // Refresh connection status before sending
      await checkConnectionStatus();
      
      // Fall back to FCM via API
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
  
  // Get notification delivery method
  String get deliveryMethod => _preferWebsocket ? 'WebSocket' : 'FCM';
  
  // Get FCM token
  String? get fcmToken => _firebaseService.token;
  
  // Force refresh connection status
  Future<void> refreshConnectionStatus() async {
    await checkConnectionStatus();
  }
}
