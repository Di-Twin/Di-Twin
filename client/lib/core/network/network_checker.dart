import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkChecker {
  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      // First, check connectivity status
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Then verify actual internet connection by making a request
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check if a specific host is reachable
  static Future<bool> isHostReachable(String host) async {
    try {
      final response = await http.get(
        Uri.https(host, '/'),
      ).timeout(const Duration(seconds: 5));
      
      // Any response means the host is reachable
      return response.statusCode >= 200;
    } catch (e) {
      return false;
    }
  }
}
