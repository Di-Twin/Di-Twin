import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:client/features/medication_management/domain/usecases/create_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/update_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/delete_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/take_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/skip_medication_usecase.dart';

/// Enhanced medication service that integrates with the API
class EnhancedMedicationService {
  final MedicationRemoteDataSource remoteDataSource;
  final CreateMedicationUseCase createMedicationUseCase;
  final UpdateMedicationUseCase updateMedicationUseCase;
  final DeleteMedicationUseCase deleteMedicationUseCase;
  final TakeMedicationUseCase takeMedicationUseCase;
  final SkipMedicationUseCase skipMedicationUseCase;

  EnhancedMedicationService({
    required this.remoteDataSource,
    required this.createMedicationUseCase,
    required this.updateMedicationUseCase,
    required this.deleteMedicationUseCase,
    required this.takeMedicationUseCase,
    required this.skipMedicationUseCase,
  });

  /// Save medication to the backend (create or update)
  Future<ApiMedicationModel> saveMedication({
    String? id, // Include for updates, omit for creation
    required String medicationName,
    required bool afterFood,
    required String frequency,
    required List<String> timings,
    required bool reminder,
    required String dose,
    required String startDate,
    required String endDate,
  }) async {
    try {
      if (id != null) {
        // Update existing medication
        final params = UpdateMedicationParams(
          id: id,
          medicationName: medicationName,
          afterFood: afterFood,
          frequency: frequency,
          timings: timings,
          reminder: reminder,
          dose: dose,
          startDate: startDate,
          endDate: endDate,
        );

        final result = await updateMedicationUseCase(params);
        return result.fold(
              (failure) => throw Exception(failure.message),
              (medication) => medication,
        );
      } else {
        // Create new medication
        final params = CreateMedicationParams(
          medicationName: medicationName,
          afterFood: afterFood,
          frequency: frequency,
          timings: timings,
          reminder: reminder,
          dose: dose,
          startDate: startDate,
          endDate: endDate,
        );

        final result = await createMedicationUseCase(params);
        return result.fold(
              (failure) => throw Exception(failure.message),
              (medication) => medication,
        );
      }
    } catch (e) {
      throw Exception('Failed to save medication: $e');
    }
  }

  /// Add medication to the backend (legacy method for backward compatibility)
  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String notes,
  }) async {
    try {
      // Convert legacy parameters to new format
      final params = CreateMedicationParams(
        medicationName: name,
        afterFood: notes.toLowerCase().contains('after'),
        frequency: frequency.toLowerCase(),
        timings: ['08:00'], // Default timing
        reminder: true,
        dose: dosage,
        startDate: DateTime.now().toIso8601String().split('T')[0],
        endDate: DateTime.now().add(Duration(days: 30)).toIso8601String().split('T')[0],
      );

      final result = await createMedicationUseCase(params);

      return result.fold(
            (failure) => throw Exception(failure.message),
            (medication) => {
          'id': medication.id,
          'name': medication.medicationName,
          'dosage': medication.dose,
          'frequency': medication.frequency,
          'notes': notes,
          'createdAt': medication.createdAt,
        },
      );
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  /// Get all medications
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final medications = await remoteDataSource.getUserMedications();

      return medications.map((med) => {
        'id': med.id,
        'name': med.medicationName,
        'afterFood': med.afterFood,
        'frequency': med.frequency,
        'timings': med.timings,
        'reminder': med.reminder,
        'dose': med.dose,
        'startDate': med.startDate,
        'endDate': med.endDate,
        'createdAt': med.createdAt,
        'updatedAt': med.updatedAt,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get medications: $e');
    }
  }

  /// Update medication status (taken/not taken)
  Future<bool> updateMedicationStatus(String medicationId, bool taken, {
    required String date,
    required String time,
    String? reason,
  }) async {
    try {
      if (taken) {
        final params = TakeMedicationParams(
          medicationId: medicationId,
          date: date,
          time: time,
        );

        final result = await takeMedicationUseCase(params);
        return result.fold(
              (failure) => false,
              (response) => true,
        );
      } else {
        final params = SkipMedicationParams(
          medicationId: medicationId,
          date: date,
          time: time,
          reason: reason,
        );

        final result = await skipMedicationUseCase(params);
        return result.fold(
              (failure) => false,
              (response) => true,
        );
      }
    } catch (e) {
      throw Exception('Failed to update medication status: $e');
    }
  }

  /// Delete medication
  Future<bool> deleteMedication(String medicationId) async {
    try {
      final result = await deleteMedicationUseCase(medicationId);
      return result.fold(
            (failure) => false,
            (success) => success,
      );
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }

  /// Get daily medication data
  Future<DailyMedicationResponseModel> getDailyMedicationData(String date) async {
    try {
      return await remoteDataSource.getDailyMedicationData(date);
    } catch (e) {
      throw Exception('Failed to get daily medication data: $e');
    }
  }

  /// Get monthly medication data
  Future<Map<String, dynamic>> getMonthlyMedicationData(int year, int month) async {
    try {
      final monthlyData = await remoteDataSource.getMonthlyMedicationData(year, month);

      return {
        'days': monthlyData.days.map((day) => {
          'date': day.date,
          'total': day.total,
          'taken': day.taken,
          'missed': day.missed,
          'pending': day.pending,
          'adherenceRate': day.adherenceRate,
          'medicationIds': day.medicationIds,
        }).toList(),
        'summary': {
          'total': monthlyData.summary.total,
          'taken': monthlyData.summary.taken,
          'missed': monthlyData.summary.missed,
          'adherenceRate': monthlyData.summary.adherenceRate,
        },
        'lastUpdated': monthlyData.lastUpdated,
        'healthMetricId': monthlyData.healthMetricId,
      };
    } catch (e) {
      throw Exception('Failed to get monthly medication data: $e');
    }
  }
}
