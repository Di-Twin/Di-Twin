// lib/core/network/network_info.dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  // Update constructor to use named parameters with default value
  NetworkInfoImpl({InternetConnectionChecker? connectionChecker})
      : connectionChecker = connectionChecker ?? InternetConnectionChecker.createInstance();

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
