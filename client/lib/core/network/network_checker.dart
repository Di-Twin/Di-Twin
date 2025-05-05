import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class NetworkChecker {
  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      // First, check connectivity status
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('📡 Network Checker: No connectivity detected');
        return false;
      }
      
      print('📡 Network Checker: Connectivity detected, checking actual internet connection...');
      
      // Then verify actual internet connection by making a request to a reliable endpoint
      // Using multiple fallback endpoints in case one is blocked
      final endpoints = [
        'https://www.google.com',
        'https://www.apple.com',
        'https://www.cloudflare.com',
        'https://www.example.com'
      ];
      
      for (final endpoint in endpoints) {
        try {
          print('📡 Network Checker: Trying to connect to $endpoint');
          final response = await http.get(
            Uri.parse(endpoint),
          ).timeout(const Duration(seconds: 10)); // Increased timeout
          
          if (response.statusCode == 200) {
            print('📡 Network Checker: Internet connection available (verified with $endpoint)');
            return true;
          }
        } catch (e) {
          print('📡 Network Checker: Failed to connect to $endpoint: $e');
          // Continue to the next endpoint
        }
      }
      
      // If we've tried all endpoints and none worked
      print('📡 Network Checker: All connection attempts failed');
      return false;
    } catch (e) {
      print('📡 Network Checker: Error checking internet connection - $e');
      return false;
    }
  }

  /// Check if a specific host is reachable
  static Future<bool> isHostReachable(String host) async {
    try {
      print('📡 Network Checker: Checking if host $host is reachable...');
      final response = await http.get(
        Uri.https(host, '/'),
      ).timeout(const Duration(seconds: 5));
      
      // Any response means the host is reachable
      final isReachable = response.statusCode >= 200;
      print('📡 Network Checker: Host $host is ${isReachable ? 'reachable' : 'unreachable'}');
      return isReachable;
    } catch (e) {
      print('📡 Network Checker: Error checking host $host - $e');
      return false;
    }
  }
  
  /// Check if the API server is reachable
  static Future<bool> isApiServerReachable(String baseUrl) async {
    try {
      // Extract host from baseUrl
      final uri = Uri.parse(baseUrl);
      final host = uri.host;
      
      print('📡 Network Checker: Checking if API server at $host is reachable...');
      
      // First try a simple HEAD request which is lighter
      try {
        final response = await http.head(
          Uri.parse('$baseUrl/health'),
        ).timeout(const Duration(seconds: 10)); // Increased timeout
        
        final isReachable = response.statusCode >= 200 && response.statusCode < 500;
        print('📡 Network Checker: API server at $host is ${isReachable ? 'reachable' : 'unreachable'} (status: ${response.statusCode})');
        return isReachable;
      } catch (e) {
        print('📡 Network Checker: HEAD request failed, trying GET request...');
        
        // If HEAD fails, try GET
        final response = await http.get(
          Uri.parse(baseUrl),
        ).timeout(const Duration(seconds: 10)); // Increased timeout
        
        final isReachable = response.statusCode >= 200 && response.statusCode < 500;
        print('📡 Network Checker: API server at $host is ${isReachable ? 'reachable' : 'unreachable'} (status: ${response.statusCode})');
        return isReachable;
      }
    } catch (e) {
      print('📡 Network Checker: Error checking API server - $e');
      return false;
    }
  }
}
