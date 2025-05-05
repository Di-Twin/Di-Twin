import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/network_checker.dart';
import 'package:http/http.dart' as http;

class ApiErrorHandler {
  // Handle API errors and return user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Authentication failed. Please log in again.';
        case 403:
          return 'You don\'t have permission to access this resource.';
        case 404:
          return 'The requested resource was not found.';
        case 408:
        case 504:
          return 'Request timed out. Please try again.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return error.message;
      }
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Show error dialog with retry option
  static Future<void> showErrorDialog(
    BuildContext context, 
    String message, 
    {VoidCallback? onRetry}
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text('Retry'),
            ),
        ],
      ),
    );
  }

  // Check network and API server before making requests
  static Future<bool> checkConnectivity(
    BuildContext context, 
    String baseUrl,
  ) async {
    // Check internet connection
    final hasInternet = await NetworkChecker.hasInternetConnection();
    if (!hasInternet) {
      if (context.mounted) {
        showErrorDialog(
          context, 
          'No internet connection. Please check your network settings.',
          onRetry: () => checkConnectivity(context, baseUrl),
        );
      }
      return false;
    }

    // Check if API server is reachable
    final isServerReachable = await NetworkChecker.isApiServerReachable(baseUrl);
    if (!isServerReachable) {
      if (context.mounted) {
        showErrorDialog(
          context, 
          'Cannot connect to the server. Please try again later.',
          onRetry: () => checkConnectivity(context, baseUrl),
        );
      }
      return false;
    }

    return true;
  }

  // Wrapper for API calls with error handling
  static Future<T?> handleApiCall<T>({
    required BuildContext context,
    required Future<T> Function() apiCall,
    required String errorMessage,
    VoidCallback? onError,
  }) async {
    try {
      return await apiCall();
    } on ApiException catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context,
          getErrorMessage(e),
          onRetry: onError,
        );
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context,
          '$errorMessage: ${e.toString()}',
          onRetry: onError,
        );
      }
      return null;
    }
  }

  // Add this method to the ApiErrorHandler class
  static Future<bool> testApiConnection(String baseUrl) async {
    try {
      print('🔍 Testing API connection to $baseUrl...');
      
      // Try to make a simple request to the API server
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      print('🔍 API test response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('🔍 API connection test failed: $e');
      return false;
    }
  }
}
