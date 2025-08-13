import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../../../../utils/token_manager.dart';
import '../models/sleep_entry_model.dart';
import 'dart:developer' as developer;

abstract class SleepRemoteDataSource {
  Future<void> submitSleepData(SleepEntryModel sleepEntry);
  Future<List<SleepEntryModel>> getSleepHistory();
}

class SleepRemoteDataSourceImpl implements SleepRemoteDataSource {
  final ApiClient _apiClient;

  SleepRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<void> submitSleepData(SleepEntryModel sleepEntry) async {
    try {
      developer.log('🌙 Submitting sleep data to API...', name: 'SleepRemoteDataSource');

      final requestBody = {
        'date': sleepEntry.date.toIso8601String().split('T')[0],
        'startTime': sleepEntry.startTime.toUtc().toIso8601String(),
        'endTime': sleepEntry.endTime?.toUtc().toIso8601String(),
        'sourceDevice': sleepEntry.sourceDevice,
        'durationSeconds': sleepEntry.durationSeconds,
      };

      developer.log('📤 Sleep data payload: $requestBody', name: 'SleepRemoteDataSource');

      final response = await _apiClient.post(
        '/connect/manual-entry/sleep',
        body: requestBody,
        requiresAuth: true,
      );

      if (response['success'] == true) {
        developer.log('✅ Sleep data submitted successfully', name: 'SleepRemoteDataSource');
      } else {
        throw Exception('API returned error: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      developer.log('❌ Error submitting sleep data: $e', name: 'SleepRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<List<SleepEntryModel>> getSleepHistory() async {
    try {
      developer.log('📥 Fetching sleep history from API...', name: 'SleepRemoteDataSource');

      final response = await _apiClient.get(
        '/connect/manual-entry/sleep/history',
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> sleepData = response['data'];
        final sleepEntries = sleepData.map((json) => SleepEntryModel.fromJson(json)).toList();

        developer.log('✅ Fetched ${sleepEntries.length} sleep entries', name: 'SleepRemoteDataSource');
        return sleepEntries;
      } else {
        throw Exception('API returned error: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      developer.log('❌ Error fetching sleep history: $e', name: 'SleepRemoteDataSource');
      rethrow;
    }
  }
}
