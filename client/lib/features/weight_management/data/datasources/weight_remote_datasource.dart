import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weight_model.dart';
import '../models/weight_range_model.dart';

abstract class WeightRemoteDataSource {
  Future<Map<String, double>> getWeightDataForPeriod(String period);
  Future<void> updateWeight(double weight, {DateTime? date});
  Future<WeightRangeModel?> getTargetWeightRange();
  Future<double?> getStartWeight();
  Future<Map<String, double>> getWeeklyWeightData();
  Future<Map<String, double>> getMonthlyWeightData();
  Future<Map<String, double>> getThreeMonthWeightData();
  Future<Map<String, double>> getSixMonthWeightData();
}

class WeightRemoteDataSourceImpl implements WeightRemoteDataSource {
  static const String baseUrl = 'https://test-prod-f427.onrender.com';
  final http.Client client;

  WeightRemoteDataSourceImpl({required this.client});

  /// Dynamically load headers with token from SharedPreferences
  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception("Access token not found in SharedPreferences");

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<Map<String, double>> getWeightDataForPeriod(String period) async {
    switch (period) {
      case 'Week':
        return await getWeeklyWeightData();
      case 'Month':
        return await getMonthlyWeightData();
      case '3 Month':
        return await getThreeMonthWeightData();
      case '6 Month':
        return await getSixMonthWeightData();
      default:
        return await getWeeklyWeightData();
    }
  }

  @override
  Future<Map<String, double>> getWeeklyWeightData() async {
    Map<String, double> weightMap = {};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-M-d').format(date);

      try {
        final headers = await _headers;
        final url = '$baseUrl/api/health-metrics/?date=$dateString';
        final response = await client.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final weight = data['data']?['weight'];
          if (weight != null) {
            weightMap[dateString] = weight.toDouble();
          }
        }
      } catch (e) {
        print('Error fetching data for $dateString: $e');
      }
    }

    return weightMap;
  }

  @override
  Future<Map<String, double>> getMonthlyWeightData() async {
    final now = DateTime.now();
    final url = '$baseUrl/api/health-metrics/weight/${now.year}/${now.month}';

    try {
      final headers = await _headers;
      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final days = data['data']['days'];

        Map<String, double> weightMap = {};
        for (var entry in days) {
          final date = entry['date'];
          final weight = entry['weight'];
          if (weight != null) {
            weightMap[date] = weight.toDouble();
          }
        }
        return weightMap;
      }
    } catch (e) {
      print('Error fetching monthly weight data: $e');
    }

    return {};
  }

  @override
  Future<Map<String, double>> getThreeMonthWeightData() async {
    Map<String, double> weightMap = {};

    for (int monthOffset = 2; monthOffset >= 0; monthOffset--) {
      final targetDate = DateTime.now().subtract(Duration(days: monthOffset * 30));
      final monthData = await _fetchMonthData(targetDate.year, targetDate.month);
      weightMap.addAll(monthData);
    }

    return weightMap;
  }

  @override
  Future<Map<String, double>> getSixMonthWeightData() async {
    Map<String, double> weightMap = {};

    for (int monthOffset = 5; monthOffset >= 0; monthOffset--) {
      final targetDate = DateTime.now().subtract(Duration(days: monthOffset * 30));
      final monthData = await _fetchMonthData(targetDate.year, targetDate.month);
      weightMap.addAll(monthData);
    }

    return weightMap;
  }

  Future<Map<String, double>> _fetchMonthData(int year, int month) async {
    final url = '$baseUrl/api/health-metrics/weight/$year/$month';

    try {
      final headers = await _headers;
      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final days = data['data']['days'];

        Map<String, double> weightMap = {};
        for (var entry in days) {
          final date = entry['date'];
          final weight = entry['weight'];
          if (weight != null) {
            weightMap[date] = weight.toDouble();
          }
        }
        return weightMap;
      }
    } catch (e) {
      print('Error fetching data for $year-$month: $e');
    }

    return {};
  }

  @override
  Future<void> updateWeight(double weight, {DateTime? date}) async {
    final dateToUse = date ?? DateTime.now();
    final dateString = DateFormat('yyyy-M-d').format(dateToUse);
    final url = '$baseUrl/api/health-metrics/?date=$dateString';

    final headers = await _headers;
    final response = await client.patch(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'weight': weight}),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<WeightRangeModel?> getTargetWeightRange() async {
    final url = '$baseUrl/api/profiles';
    final headers = await _headers;

    final response = await client.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final targetRange = data['data']['target_weight_range'];
      if (targetRange != null && targetRange is List && targetRange.length == 2) {
        return WeightRangeModel.fromJson(targetRange);
      }
    }
    return null;
  }

  @override
  Future<double?> getStartWeight() async {
    final url = '$baseUrl/api/profiles';
    final headers = await _headers;

    final response = await client.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final weight = data['data']['weight_kg'];
      return double.tryParse(weight.toString());
    }
    return null;
  }
}
