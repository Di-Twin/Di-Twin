// water_intake_api_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaterIntakeApiProvider with ChangeNotifier {
  final String _baseUrl = 'https://test-prod-f427.onrender.com/api/health-metrics';
  final String _profileUrl = 'https://test-prod-f427.onrender.com/api/profiles';
  SharedPreferences? _prefs;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> _initSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
      throw 'Error loading app data';
    }
  }

  Future<String?> _getAuthToken() async {
    if (_prefs == null) {
      await _initSharedPreferences();
    }
    return _prefs?.getString('access_token');
  }

  // Get user profile including water intake target
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw 'Please login to view profile';
      }

      final response = await http.get(
        Uri.parse(_profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        }
        throw data['message'] ?? 'Failed to fetch profile';
      }
      throw _handleApiError(response);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      throw e.toString();
    }
  }

  // Update water intake target
  Future<bool> updateWaterIntakeTarget(int targetMl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw 'Please login to update water target';
      }

      // First get current profile to preserve other fields
      final currentProfile = await getUserProfile();
      
      final response = await http.patch(
        Uri.parse(_profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          ...currentProfile,
          'target_water_ml': targetMl,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      throw _handleApiError(response);
    } catch (e) {
      debugPrint('Error updating water intake target: $e');
      throw e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getWaterDashboard() async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw 'Please login to view water dashboard';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/water-dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        }
        throw data['message'] ?? 'Failed to fetch water dashboard';
      }
      throw _handleApiError(response);
    } catch (e) {
      debugPrint('Error fetching water dashboard: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getCurrentWaterData(String date) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw 'Please login to track water intake';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?date=$date'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }
      throw _handleApiError(response);
    } catch (e) {
      debugPrint('Error fetching current water data: $e');
      throw e.toString();
    }
  }

  Future<bool> submitWaterIntake(double amount, String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw 'Please login to track water intake';
      }

      // 1. Get current water intake data
      final currentData = await getCurrentWaterData(date);
      final currentIntake = (currentData['water_intake'] as List<dynamic>?)
              ?.map((e) => e.toDouble())
              .toList() ??
          [];

      // 2. Prepare updated data
      final newIntake = [...currentIntake, amount];
      final totalWater = newIntake.fold(0.0, (sum, amount) => sum + amount);

      // 3. Make API request
      final response = await http.patch(
        Uri.parse('$_baseUrl/?date=$date'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'water_intake': newIntake,
          'total_water_taken': totalWater,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      throw _handleApiError(response);
    } catch (e) {
      debugPrint('Error in submitWaterIntake: $e');
      throw e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getMonthlyWaterData(int year, int month) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw 'Please login to view monthly water data';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/water-monthly/$year/$month'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        }
        throw data['message'] ?? 'Failed to fetch monthly water data';
      }
      throw _handleApiError(response);
    } catch (e) {
      debugPrint('Error fetching monthly water data: $e');
      throw e.toString();
    }
  }


  String _handleApiError(http.Response response) {
    final status = response.statusCode;
    String message = 'Failed to update water intake';

    try {
      final errorData = json.decode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}

    if (status == 404) {
      message = 'API endpoint not found. Please contact support';
    } else if (status == 401) {
      message = 'Session expired. Please login again';
    } else if (status >= 500) {
      message = 'Server error. Please try again later';
    }

    debugPrint('API Error ${response.statusCode}: ${response.body}');
    return message;
  }
}