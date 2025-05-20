import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/notification_manager.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase if not already initialized
    await Firebase.initializeApp();
    
    debugPrint('Handling a background message: ${message.messageId}');
    
    // Process the notification
    NotificationManager.processFirebaseMessage(message);
  } catch (e) {
    debugPrint('Error in background handler: $e');
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;
  
  // API endpoint for sending token to server
  final String _tokenEndpoint = 'https://test-prod-f427.onrender.com/api/notifications/token';
  
  FirebaseService._internal();

  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Initialize Firebase and FCM
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // Request notification permissions with error handling
      await _requestPermissions();
      
      // Get FCM token
      await _getFcmToken();
      
      // Configure message handlers
      _configureMessageHandlers();
      
      _isInitialized = true;
      debugPrint('Firebase service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase service: $e');
      // Don't mark as initialized if there was an error
      rethrow;
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false, // Changed to false to reduce permission requests
      );
      
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      // Continue even if permissions fail - the app should still work
    }
  }

  // Get FCM token and send to server
  Future<void> _getFcmToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      
      if (_fcmToken != null) {
        debugPrint('FCM Token: $_fcmToken');
        await _sendTokenToServer(_fcmToken!);
      }
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _sendTokenToServer(newToken);
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      // Continue without token - we can try again later
    }
  }

  // Configure message handlers
  void _configureMessageHandlers() {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification!.title}');
        }
        
        // Process the notification
        NotificationManager.processFirebaseMessage(message);
      });

      // Handle messages opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('App opened from terminated state via notification');
          NotificationManager.handleNotificationTap(json.encode(message.data));
        }
      });

      // Handle messages opened from background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from background state via notification');
        NotificationManager.handleNotificationTap(json.encode(message.data));
      });
    } catch (e) {
      debugPrint('Error configuring message handlers: $e');
    }
  }

  // Send FCM token to server
  Future<void> _sendTokenToServer(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      debugPrint('❌ Access token not found in SharedPreferences');
      return;
    }

    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'token': token,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('✅ Token sent to server successfully');
    } else {
      debugPrint('❌ Failed to send token to server: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
    }
  } catch (e) {
    debugPrint('⚠️ Error sending token to server: $e');
  }
}


  // Get the current FCM token
  String? get token => _fcmToken;
  
  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }
  
  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}
