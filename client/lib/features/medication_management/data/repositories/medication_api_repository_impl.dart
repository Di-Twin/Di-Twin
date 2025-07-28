import 'package:client/core/errors/failures.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/medication_management/data/datasources/medication_local_datasource.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:client/features/medication_management/data/models/medication_model.dart';
import 'package:client/features/medication_management/data/models/medication_schedule_model.dart';
import 'package:client/features/medication_management/data/models/medication_time_slot_model.dart';
import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:client/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Repository implementation that uses both API and local data sources
class MedicationApiRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final MedicationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MedicationApiRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MedicationSchedule>>> getMedicationSchedules() async {
    try {
      if (await networkInfo.isConnected) {
        // Try to fetch from API first
        try {
          final apiMedications = await remoteDataSource.getUserMedications();

          // Convert API medications to local format and cache them
          await _cacheApiMedications(apiMedications);

          // Get schedules from local cache
          final schedules = await localDataSource.getMedicationSchedules();
          return Right(schedules);
        } catch (e) {
          // If API fails, fall back to local data
          print('API failed, falling back to local data: $e');
          final schedules = await localDataSource.getMedicationSchedules();
          return Right(schedules);
        }
      } else {
        // No internet, use local data
        final schedules = await localDataSource.getMedicationSchedules();
        return Right(schedules);
      }
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get medication schedules: $e'));
    }
  }

  @override
  Future<Either<Failure, MedicationSchedule>> getMedicationScheduleForDate(String date) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          // Fetch daily data from API
          final dailyData = await remoteDataSource.getDailyMedicationData(date);

          // Convert to local format
          final schedule = _convertDailyDataToSchedule(date, dailyData);
          return Right(schedule);
        } catch (e) {
          // Fall back to local data
          print('API failed for daily data, falling back to local: $e');
          final schedule = await localDataSource.getMedicationScheduleForDate(date);
          return Right(schedule);
        }
      } else {
        // Use local data
        final schedule = await localDataSource.getMedicationScheduleForDate(date);
        return Right(schedule);
      }
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get medication schedule for date: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMedicationStatus(String medicationId, bool taken) async {
    try {
      // Always update local data first for immediate UI feedback
      await localDataSource.updateMedicationStatus(medicationId, taken);

      if (await networkInfo.isConnected) {
        try {
          // Extract date and time from medication ID (assuming format includes this info)
          final now = DateTime.now();
          final date = DateFormat('yyyy-MM-dd').format(now);
          final time = DateFormat('HH:mm').format(now);

          if (taken) {
            await remoteDataSource.takeMedication(medicationId, date, time);
          } else {
            await remoteDataSource.skipMedication(medicationId, date, time, null);
          }
        } catch (e) {
          print('Failed to sync medication status to API: $e');
          // Don't fail the operation if API sync fails
        }
      }

      return Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update medication status: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> addMedication(Medication medication, String date, String time) async {
    try {
      // Add to local data first
      final medicationModel = MedicationModel.fromEntity(medication);
      await localDataSource.addMedication(medicationModel, date, time);

      if (await networkInfo.isConnected) {
        try {
          // Create medication data for API
          final medicationData = {
            'medicationName': medication.name,
            'afterFood': medication.instruction?.toLowerCase().contains('after') ?? false,
            'frequency': 'daily', // Default frequency
            'timings': [time],
            'reminder': true,
            'dose': medication.dosage ?? '1 unit',
            'startDate': date,
            'endDate': DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 30))), // Default 30 days
          };

          await remoteDataSource.createOrUpdateMedication(medicationData);
        } catch (e) {
          print('Failed to sync new medication to API: $e');
          // Don't fail the operation if API sync fails
        }
      }

      return Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add medication: $e'));
    }
  }

  /// Cache API medications in local storage
  Future<void> _cacheApiMedications(List<ApiMedicationModel> apiMedications) async {
    try {
      // This is a simplified caching approach
      // In a real implementation, you might want to clear existing cache first
      // and then populate with API data

      for (final apiMed in apiMedications) {
        final medication = apiMed.toEntity();
        final medicationModel = MedicationModel.fromEntity(medication);

        // Add medication for each timing
        for (final timing in apiMed.timings) {
          await localDataSource.addMedication(
              medicationModel,
              apiMed.startDate,
              timing
          );
        }
      }
    } catch (e) {
      print('Failed to cache API medications: $e');
    }
  }

  /// Convert daily API data to local schedule format
  MedicationSchedule _convertDailyDataToSchedule(String date, DailyMedicationResponseModel dailyData) {
    // Group medications by time
    final Map<String, List<MedicationModel>> timeSlots = {};

    for (final dailyMed in dailyData.medications) {
      final time = dailyMed.time;
      final medication = MedicationModel(
        id: dailyMed.id,
        name: dailyMed.medicationName,
        dosage: dailyMed.dose,
        instruction: dailyMed.afterFood ? 'After Food' : 'Before Food',
        icon: Icons.medication,
        taken: dailyMed.status == 'taken',
      );

      if (!timeSlots.containsKey(time)) {
        timeSlots[time] = [];
      }
      timeSlots[time]!.add(medication);
    }

    // Convert to time slot models
    final List<MedicationTimeSlotModel> timeSlotModels = [];
    timeSlots.forEach((time, medications) {
      final displayTime = _formatDisplayTime(time);
      timeSlotModels.add(MedicationTimeSlotModel(
        time: time,
        displayTime: displayTime,
        medications: medications,
      ));
    });

    // Sort by time
    timeSlotModels.sort((a, b) => a.time.compareTo(b.time));

    return MedicationScheduleModel(
      date: date,
      timeSlots: timeSlotModels,
    );
  }

  String _formatDisplayTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:$minute $period';
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }
}
