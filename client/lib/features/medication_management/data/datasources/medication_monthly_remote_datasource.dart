import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/core/network/api_client.dart';
import '../models/monthly_medication_model.dart';

abstract class MedicationMonthlyRemoteDataSource {
  Future<MonthlyMedicationModel> getMonthlyMedicationData(int year, int month);
}

class MedicationMonthlyRemoteDataSourceImpl implements MedicationMonthlyRemoteDataSource {
  final ApiClient apiClient;

  MedicationMonthlyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MonthlyMedicationModel> getMonthlyMedicationData(int year, int month) async {
    try {
      final response = await apiClient.get('/monthly/$year/$month');

      if (response['success'] == true) {
        return MonthlyMedicationModel.fromJson(response['data']);
      } else {
        print(response['message'] ?? 'Failed to fetch monthly medication data');
        throw Exception(response['message'] ?? 'Failed to fetch monthly medication data');
      }
    } catch (e) {
      throw Exception('Failed to fetch monthly medication data: $e');
    }
  }
}
