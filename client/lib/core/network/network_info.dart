// lib/core/network/network_info.dart
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:async';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  // Update constructor to use named parameters with default value
  NetworkInfoImpl({InternetConnectionChecker? connectionChecker})
      : connectionChecker = connectionChecker ?? InternetConnectionChecker.createInstance();

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
  
  @override
  Stream<bool> get connectionStream => connectionChecker.onStatusChange
      .map((status) => status == InternetConnectionStatus.connected);
      
  // Add a method to actively check connection with timeout
  Future<bool> checkConnectionWithTimeout({int timeoutSeconds = 5}) async {
    try {
      return await connectionChecker.hasConnection
          .timeout(Duration(seconds: timeoutSeconds));
    } on TimeoutException {
      print('Network check timed out after $timeoutSeconds seconds');
      return false;
    } catch (e) {
      print('Error checking network connection: $e');
      return false;
    }
  }
}
