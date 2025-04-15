import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../services/notification/channels/sleep_notification_channel.dart';
import '../../services/notification/models/sleep_log_model.dart';

class SleepNotificationHandler {
  final SleepNotificationChannel _sleepChannel = SleepNotificationChannel();
  final String _apiEndpoint = 'https://your-api-endpoint.com/sleep-logs';
  
  // Current sleep session
  SleepLogModel? _currentSession;
  
  // Start sleep tracking
  Future<void> startSleepTracking() async {
    final String sessionId = const Uuid().v4();
    final DateTime startTime = DateTime.now();
    
    _currentSession = SleepLogModel(
      sessionId: sessionId,
      startTime: startTime,
    );
    
    // Show sleep tracking notification
    await _sleepChannel.showSleepTrackingNotification(
      isTracking: true,
      startTime: startTime,
      sessionId: sessionId,
    );
  }
  
  // Stop sleep tracking and send data to API
  Future<void> stopSleepTracking() async {
    if (_currentSession == null) {
      debugPrint('No active sleep session to stop');
      return;
    }
    
    // Update current session with end time
    final DateTime endTime = DateTime.now();
    _currentSession = SleepLogModel(
      sessionId: _currentSession!.sessionId,
      startTime: _currentSession!.startTime,
      endTime: endTime,
    );
    
    // Send data to API
    await _sendSleepDataToApi(_currentSession!);
    
    // Cancel the ongoing notification
    await _sleepChannel.cancelSleepTrackingNotification();
    
    // Reset current session
    _currentSession = null;
  }
  
  // Send sleep data to API
  Future<void> _sendSleepDataToApi(SleepLogModel sleepLog) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(sleepLog.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Sleep data sent successfully');
      } else {
        debugPrint('Failed to send sleep data: ${response.statusCode}');
        // Could implement retry logic here
      }
    } catch (e) {
      debugPrint('Error sending sleep data: $e');
      // Could save locally for later sync
    }
  }
  
  // Schedule a sleep reminder
  Future<void> scheduleSleepReminder(TimeOfDay bedtime) async {
    await _sleepChannel.scheduleSleepReminder(
      reminderTime: bedtime,
      message: 'Time to prepare for sleep. Maintaining a consistent sleep schedule is important for your health.',
    );
  }
  
  // Handle notification response
  Future<void> handleNotificationResponse(String? payload) async {
    if (payload == null) return;
    
    try {
      final Map<String, dynamic> data = json.decode(payload);
      
      // Handle sleep start action
      if (data.containsKey('SLEEP_START') && data['SLEEP_START'] == true) {
        await startSleepTracking();
      } 
      // Handle sleep stop action
      else if (data.containsKey('SLEEP_STOP') && data['SLEEP_STOP'] == true) {
        await stopSleepTracking();
      }
    } catch (e) {
      debugPrint('Error handling sleep notification response: $e');
    }
  }
  
  // Check if sleep tracking is active
  bool get isTrackingActive => _currentSession != null;
  
  // Get current session
  SleepLogModel? get currentSession => _currentSession;
}
