import 'package:client/core/network/api_client.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:client/features/medication_management/data/models/monthly_medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<List<ApiMedicationModel>> getUserMedications();
  Future<ApiMedicationModel> createOrUpdateMedication(Map<String, dynamic> medicationData);
  Future<DailyMedicationResponseModel> getDailyMedicationData(String date);
  Future<MonthlyMedicationModel> getMonthlyMedicationData(int year, int month);
  Future<MedicationActionResponseModel> takeMedication(String medicationId, String date, String time);
  Future<MedicationActionResponseModel> skipMedication(String medicationId, String date, String time, String? reason);
  Future<bool> deleteMedication(String medicationId);
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final ApiClient apiClient;

  MedicationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ApiMedicationModel>> getUserMedications() async {
    try {
      final response = await apiClient.get('/');

      if (response['success'] == true) {
        final List<dynamic> medicationsJson = response['data'] ?? [];
        return medicationsJson
            .map((json) => ApiMedicationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch medications');
      }
    } catch (e) {
      throw Exception('Failed to fetch medications: $e');
    }
  }

  @override
  Future<ApiMedicationModel> createOrUpdateMedication(Map<String, dynamic> medicationData) async {
    try {
      final response = await apiClient.post('/', body: medicationData);

      if (response['success'] == true) {
        return ApiMedicationModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to save medication');
      }
    } catch (e) {
      throw Exception('Failed to save medication: $e');
    }
  }

  @override
  Future<DailyMedicationResponseModel> getDailyMedicationData(String date) async {
    try {
      final response = await apiClient.get('/daily/$date');

      if (response['success'] == true) {
        return DailyMedicationResponseModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch daily medication data');
      }
    } catch (e) {
      throw Exception('Failed to fetch daily medication data: $e');
    }
  }

  @override
  Future<MonthlyMedicationModel> getMonthlyMedicationData(int year, int month) async {
    try {
      final response = await apiClient.get('/monthly/$year/$month');

      if (response['success'] == true) {
        return MonthlyMedicationModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch monthly medication data');
      }
    } catch (e) {
      throw Exception('Failed to fetch monthly medication data: $e');
    }
  }

  @override
  Future<MedicationActionResponseModel> takeMedication(String medicationId, String date, String time) async {
    try {
      final response = await apiClient.put('/take/$medicationId', body: {
        'date': date,
        'time': time,
      });

      if (response['success'] == true) {
        return MedicationActionResponseModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to mark medication as taken');
      }
    } catch (e) {
      throw Exception('Failed to mark medication as taken: $e');
    }
  }

  @override
  Future<MedicationActionResponseModel> skipMedication(String medicationId, String date, String time, String? reason) async {
    try {
      final body = {
        'date': date,
        'time': time,
      };

      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await apiClient.put('/skip/$medicationId', body: body);

      if (response['success'] == true) {
        return MedicationActionResponseModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to mark medication as skipped');
      }
    } catch (e) {
      throw Exception('Failed to mark medication as skipped: $e');
    }
  }

  @override
  Future<bool> deleteMedication(String medicationId) async {
    try {
      final response = await apiClient.delete('/$medicationId');

      if (response['success'] == true || response == true) {
        return true;
      } else {
        throw Exception('Failed to delete medication');
      }
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }
}
