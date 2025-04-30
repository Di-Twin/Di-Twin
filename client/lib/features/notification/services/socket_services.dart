import 'dart:convert';
import 'dart:async';
import 'package:client/features/notification/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../managers/notification_manager.dart';

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  
  IO.Socket? socket;
  bool _isConnected = false;
  String? _userId;
  DateTime? _lastPingTime;
  DateTime? _lastPongTime;
  Timer? _pingTimer;
  Timer? _connectionVerificationTimer;
  Timer? _apiConnectionCheckTimer;
  
  // Connection status
  bool _isVerified = false;
  int _messageCount = 0;
  DateTime? _lastMessageTime;
  bool _serverConfirmedConnection = false;
  
  // API service
  final ApiService _apiService = ApiService();
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isVerified => _isVerified || _messageCount > 0 || _serverConfirmedConnection;
  String? get userId => _userId;
  int get messageCount => _messageCount;
  DateTime? get lastMessageTime => _lastMessageTime;
  bool get serverConfirmedConnection => _serverConfirmedConnection;
  
  String get connectionStatus {
    if (!_isConnected) return 'Disconnected';
    if (_serverConfirmedConnection) return 'Connected (Server Confirmed)';
    if (_messageCount > 0) return 'Connected (Active: $_messageCount msgs)';
    if (_isVerified) return 'Connected (Verified)';
    return 'Connected (Unverified)';
  }
  
  // Meal timings from server
  Map<String, String>? _mealTimings;
  Map<String, String>? get mealTimings => _mealTimings;
  
  // Connection logs
  List<String> _connectionLogs = [];
  List<String> get connectionLogs => _connectionLogs;
  
  // Track processed message IDs to prevent duplicates
  final Set<String> _processedMessageIds = <String>{};
  
  SocketService._internal();

  // Initialize the socket with user auth
  void initSocket(String userId, {String? accessToken}) {
    _userId = userId;
    
    // Initialize API service if access token is provided
    if (accessToken != null) {
      _apiService.initialize(accessToken: accessToken, userId: userId);
      _addLog('API Service initialized with user ID: $userId');
      
      // Start API connection check
      _startApiConnectionCheck();
    }
    
    try {
      _addLog('Initializing Socket.IO connection for user: $userId');
      
      // Disconnect existing socket if any
      if (socket != null) {
        socket!.disconnect();
      }
      
      socket = IO.io('https://test-prod-f427.onrender.com', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {'userId': userId},
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionAttempts': 10,
        'forceNew': true,
        'query': {'userId': userId},
      });
      
      _setupSocketListeners();
      
    } catch (e) {
      _addLog('Error initializing Socket.IO: $e');
    }
  }
  
  void _setupSocketListeners() {
    socket?.onConnect((_) {
      _addLog('Socket.IO connected');
      _isConnected = true;
      _startConnectionVerification();
      notifyListeners();
      
      // Request meal timings from server
      _requestMealTimings();
      
      // Send test notifications after successful connection
      // _sendTestNotificationsAfterConnection();
      
      // Check connection status with API
      _checkConnectionWithApi();
    });
    
    socket?.onDisconnect((_) {
      _addLog('Socket.IO disconnected');
      _isConnected = false;
      _isVerified = false;
      _serverConfirmedConnection = false;
      _stopConnectionVerification();
      notifyListeners();
    });
    
    socket?.onConnectError((error) {
      _addLog('Socket.IO connection error: $error');
      _isConnected = false;
      _isVerified = false;
      _serverConfirmedConnection = false;
      notifyListeners();
    });
    
    socket?.onError((error) {
      _addLog('Socket.IO error: $error');
    });
    
    // Listen for ANY event (for verification purposes)
    socket?.onAny((event, data) {
      _addLog('Received event: $event');
      _messageCount++;
      _lastMessageTime = DateTime.now();
      
      // If we receive any event, the connection is working
      if (!_isVerified) {
        _isVerified = true;
        notifyListeners();
      }
    });
    
    // Listen for notifications
    socket?.on('notification', (data) {
      _addLog('Received notification via Socket.IO: $data');
      
      // Check for duplicate messages
      String messageId = '';
      if (data is Map) {
        messageId = data['id']?.toString() ?? '';
      } else if (data is String) {
        try {
          final jsonData = json.decode(data);
          messageId = jsonData['id']?.toString() ?? '';
        } catch (e) {
          // Not valid JSON, generate a hash from the string
          messageId = data.hashCode.toString();
        }
      }
      
      if (messageId.isNotEmpty && _processedMessageIds.contains(messageId)) {
        _addLog('Skipping duplicate message: $messageId');
        return;
      }
      
      if (messageId.isNotEmpty) {
        _processedMessageIds.add(messageId);
        // Limit the size of the set
        if (_processedMessageIds.length > 100) {
          _processedMessageIds.remove(_processedMessageIds.first);
        }
      }
      
      _handleNotification(data);
    });
    
    // Listen for custom events
    socket?.on('message', (data) {
      _addLog('Received message: $data');
      _handleNotification(data);
    });
    
    socket?.on('reminder', (data) {
      _addLog('Received reminder: $data');
      _handleNotification(data);
    });
    
    // Listen for meal timings
    socket?.on('meal_timings', (data) {
      _addLog('Received meal timings: $data');
      _processMealTimings(data);
    });
    
    // Listen for ping/pong for connection verification
    // Try multiple event names since we don't know what the server uses
    socket?.on('pong', (data) {
      _lastPongTime = DateTime.now();
      _isVerified = true;
      _addLog('Received pong from server: $data');
      notifyListeners();
    });
    
    socket?.on('ping', (data) {
      // Some servers send pings instead of expecting them
      _addLog('Received ping from server: $data');
      // Respond with pong
      socket?.emit('pong', {'timestamp': DateTime.now().toIso8601String()});
      _isVerified = true;
      notifyListeners();
    });
    
    // Socket.IO built-in ping/pong
    socket?.on('connect', (_) {
      _isVerified = true;
      notifyListeners();
    });
  }
  
  // Start API connection check
  void _startApiConnectionCheck() {
    _apiConnectionCheckTimer?.cancel();
    _apiConnectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnectionWithApi();
    });
    
    // Check immediately
    _checkConnectionWithApi();
  }
  
  // Check connection with API
  Future<void> _checkConnectionWithApi() async {
    if (!_apiService.isInitialized) return;
    
    try {
      final result = await _apiService.checkConnectionStatus();
      _addLog('API connection check result: $result');
      
      if (result['success'] == true) {
        _serverConfirmedConnection = result['isConnected'] == true;
        notifyListeners();
      }
    } catch (e) {
      _addLog('Error checking connection with API: $e');
    }
  }
  
  // Send test notification via API
  Future<Map<String, dynamic>> sendTestNotificationViaApi() async {
    if (!_apiService.isInitialized) {
      return {'success': false, 'error': 'API service not initialized'};
    }
    
    try {
      final result = await _apiService.sendTestNotification();
      _addLog('API test notification result: $result');
      return result;
    } catch (e) {
      _addLog('Error sending test notification via API: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Start connection verification
  void _startConnectionVerification() {
    _stopConnectionVerification();
    
    // Send ping every 30 seconds to verify connection
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendPing();
    });
    
    // Check connection status every 5 seconds
    _connectionVerificationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _verifyConnection();
    });
    
    // Send initial ping immediately
    _sendPing();
  }
  
  // Stop connection verification
  void _stopConnectionVerification() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _connectionVerificationTimer?.cancel();
    _connectionVerificationTimer = null;
    _apiConnectionCheckTimer?.cancel();
    _apiConnectionCheckTimer = null;
  }
  
  // Send ping to server - try multiple event names
  void _sendPing() {
    if (_isConnected && socket != null) {
      try {
        _lastPingTime = DateTime.now();
        
        // Try standard ping
        socket!.emit('ping', {
          'userId': _userId,
          'timestamp': _lastPingTime!.toIso8601String(),
          'client': 'flutter',
        });
        
        // Also try a custom event that might trigger a response
        socket!.emit('client_ping', {
          'userId': _userId,
          'timestamp': _lastPingTime!.toIso8601String(),
        });
        
        // Try a heartbeat event
        socket!.emit('heartbeat', {
          'userId': _userId,
          'timestamp': _lastPingTime!.toIso8601String(),
        });
        
        _addLog('Sent ping to server (multiple formats)');
      } catch (e) {
        _addLog('Error sending ping: $e');
      }
    }
  }
  
  // Verify connection by checking ping/pong or any message activity
  void _verifyConnection() {
    if (!_isConnected) {
      _isVerified = false;
      return;
    }
    
    // If server confirmed connection via API, we're verified
    if (_serverConfirmedConnection) {
      _isVerified = true;
      return;
    }
    
    // If we've received any messages, the connection is working
    if (_messageCount > 0 && _lastMessageTime != null) {
      final now = DateTime.now();
      // If we received a message in the last 2 minutes, consider connection verified
      if (now.difference(_lastMessageTime!).inMinutes < 2) {
        _isVerified = true;
        return;
      }
    }
    
    // If we've never received a pong, connection is not verified
    // But we'll keep trying and not disconnect
    if (_lastPongTime == null) {
      _isVerified = false;
      return;
    }
    
    // If last pong is older than 60 seconds, connection is not verified
    final now = DateTime.now();
    if (now.difference(_lastPongTime!).inSeconds > 60) {
      _isVerified = false;
      _addLog('Connection verification failed: Last pong too old');
      
      // Don't reconnect automatically, let the user decide
      return;
    }
    
    _isVerified = true;
  }
  
  // Request meal timings from server
  void _requestMealTimings() {
    if (_isConnected && socket != null) {
      try {
        socket!.emit('get_meal_timings', {
          'userId': _userId,
        });
        
        // Also try alternative event names
        socket!.emit('getMealTimings', {
          'userId': _userId,
        });
        
        socket!.emit('fetch_meal_timings', {
          'userId': _userId,
        });
        
        _addLog('Requested meal timings from server');
      } catch (e) {
        _addLog('Error requesting meal timings: $e');
      }
    }
  }
  
  // Process meal timings from server
  void _processMealTimings(dynamic data) {
    try {
      Map<String, dynamic> timingsData;
      
      if (data is String) {
        timingsData = json.decode(data);
      } else if (data is Map) {
        timingsData = Map<String, dynamic>.from(data);
      } else {
        _addLog('Unsupported meal timings format: ${data.runtimeType}');
        return;
      }
      
      // Extract meal_timings field
      if (timingsData.containsKey('meal_timings')) {
        var mealTimingsMap = timingsData['meal_timings'];
        if (mealTimingsMap is Map) {
          _mealTimings = Map<String, String>.from(mealTimingsMap);
          _addLog('Processed meal timings: $_mealTimings');
          
          // Schedule notifications for meal timings
          _scheduleMealNotifications();
          
          notifyListeners();
        }
      } else {
        // Try to use the data directly if it has time fields
        bool hasMealTimes = false;
        Map<String, String> directTimings = {};
        
        ['breakfast', 'lunch', 'dinner', 'snack'].forEach((meal) {
          if (timingsData.containsKey(meal)) {
            directTimings[meal] = timingsData[meal].toString();
            hasMealTimes = true;
          }
        });
        
        if (hasMealTimes) {
          _mealTimings = directTimings;
          _addLog('Processed direct meal timings: $_mealTimings');
          _scheduleMealNotifications();
          notifyListeners();
        }
      }
    } catch (e) {
      _addLog('Error processing meal timings: $e');
    }
  }
  
  // Schedule notifications for meal timings
  void _scheduleMealNotifications() {
    if (_mealTimings == null) return;
    
    _mealTimings!.forEach((meal, timeString) {
      try {
        // Parse time string (HH:MM)
        final parts = timeString.split(':');
        if (parts.length != 2) return;
        
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        
        if (hour == null || minute == null) return;
        
        // Get current time
        final now = DateTime.now();
        
        // Create target time for today
        var targetTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        
        // If target time is in the past, schedule for tomorrow
        if (targetTime.isBefore(now)) {
          targetTime = targetTime.add(const Duration(days: 1));
        }
        
        // Calculate delay
        final delay = targetTime.difference(now);
        
        // Schedule notification
        _addLog('Scheduling $meal notification for $timeString (in ${delay.inMinutes} minutes)');
        
        Timer(delay, () {
          _showMealNotification(meal);
        });
        
      } catch (e) {
        _addLog('Error scheduling notification for $meal: $e');
      }
    });
  }
  
  // Show meal notification
  void _showMealNotification(String meal) {
    final capitalizedMeal = meal.substring(0, 1).toUpperCase() + meal.substring(1);
    
    // Create a unique ID for this notification
    final notificationId = 'meal_${meal}_${DateTime.now().millisecondsSinceEpoch}';
    
    NotificationManager.showSystemNotification(
      NotificationModel(
        id: notificationId,
        title: '$capitalizedMeal Time',
        message: 'It\'s time for your $meal. Don\'t forget to log your meal!',
        type: 'food_log_reminder',
        timestamp: DateTime.now(),
        payload: json.encode({
          'type': 'food_log_reminder',
          'mealType': capitalizedMeal,
          'action': 'log_meal',
        }),
      ),
    );
  }
  
  void _handleNotification(dynamic data) {
    try {
      // Convert data to the correct format
      Map<String, dynamic> notificationData;
      
      if (data is String) {
        // If data is a string, try to parse it as JSON
        notificationData = json.decode(data);
      } else if (data is Map) {
        // If data is already a Map, convert it to Map<String, dynamic>
        notificationData = Map<String, dynamic>.from(data);
      } else {
        // If data is in another format, create a basic notification
        notificationData = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'New Notification',
          'message': data.toString(),
          'type': 'general',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      
      // Ensure required fields exist
      notificationData['id'] = notificationData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      notificationData['title'] = notificationData['title'] ?? 'New Notification';
      notificationData['message'] = notificationData['message'] ?? '';
      notificationData['type'] = notificationData['type'] ?? 'general';
      notificationData['timestamp'] = notificationData['timestamp'] ?? DateTime.now().toIso8601String();
      
      // Process the notification
      NotificationManager.processWebSocketMessage(notificationData);
    } catch (e) {
      _addLog('Error processing Socket.IO message: $e');
    }
  }
  
  // // Send test notifications after connection is established
  // void _sendTestNotificationsAfterConnection() {
  //   if (_isConnected) {
  //     // Wait a moment to ensure connection is stable
  //     Future.delayed(const Duration(seconds: 1), () {
  //       // Show a welcome notification
  //       NotificationManager.showInAppNotification(
  //         NotificationModel(
  //           id: 'socket_connected_${DateTime.now().millisecondsSinceEpoch}',
  //           title: 'WebSocket Connected',
  //           message: 'You are now receiving real-time notifications',
  //           type: 'system',
  //           timestamp: DateTime.now(),
  //         ),
  //       );
        
  //       // Emit a test event to the server (if the server supports it)
  //       emit('client_connected', {
  //         'userId': _userId,
  //         'timestamp': DateTime.now().toIso8601String(),
  //         'device': 'mobile',
  //       });
  //     });
  //   }
  // }
  
  // Send a message through the socket
  void emit(String event, dynamic data) {
    if (_isConnected && socket != null) {
      try {
        socket!.emit(event, data);
        _addLog('Emitted $event: $data');
      } catch (e) {
        _addLog('Error emitting event: $e');
      }
    } else {
      _addLog('Cannot emit event: Socket not connected');
    }
  }
  
  // Send a test notification locally (without server)
  void sendLocalTestNotification() {
    if (_isConnected) {
      final testData = {
        'id': 'local_test_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Test Notification',
        'message': 'This is a test notification from Socket.IO',
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'action': 'test',
          'userId': _userId,
        }
      };
      
      _handleNotification(testData);
    }
  }
  
  // Test meal timings
  void testMealTimings(Map<String, String> timings) {
    _mealTimings = timings;
    _addLog('Set test meal timings: $_mealTimings');
    _scheduleMealNotifications();
    notifyListeners();
  }
  
  // Manually set meal timings (for testing)
  void setMealTimings(Map<String, String> timings) {
    _mealTimings = timings;
    _addLog('Manually set meal timings: $_mealTimings');
    _scheduleMealNotifications();
    notifyListeners();
  }
  
  // Force verification (for testing)
  void forceVerification() {
    _isVerified = true;
    notifyListeners();
  }
  
  // Reconnect to the socket
  void reconnect() {
    if (socket != null && _userId != null) {
      _addLog('Attempting to reconnect Socket.IO');
      
      // Completely reinitialize the socket
      initSocket(_userId!);
    }
  }
  
  // Disconnect from the socket
  void disconnect() {
    if (socket != null) {
      _addLog('Disconnecting Socket.IO');
      _stopConnectionVerification();
      socket!.disconnect();
      _isConnected = false;
      _isVerified = false;
      _serverConfirmedConnection = false;
      notifyListeners();
    }
  }
  
  // Add log entry
  void _addLog(String message) {
    debugPrint('SocketService: $message');
    _connectionLogs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    
    // Keep only the last 100 logs
    if (_connectionLogs.length > 100) {
      _connectionLogs = _connectionLogs.sublist(_connectionLogs.length - 100);
    }
  }
  
  // Clear logs
  void clearLogs() {
    _connectionLogs.clear();
    notifyListeners();
  }
  
  // Dispose the socket
  void dispose() {
    disconnect();
    socket = null;
  }
}
