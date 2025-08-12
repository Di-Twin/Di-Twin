import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/medication_management/data/datasources/medication_local_datasource.dart';
import 'package:client/features/medication_management/data/datasources/medication_remote_datasource.dart';
import 'package:client/features/medication_management/data/repositories/medication_api_repository_impl.dart';
import 'package:client/features/medication_management/domain/usecases/create_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/update_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/get_daily_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/take_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/skip_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/delete_medication_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/get_user_medications_usecase.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

// API Client Provider
final medicationApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: 'https://test-prod-f427.onrender.com/api/medication',
    httpClient: http.Client(),
  );
});

// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

// Remote Data Source Provider
final medicationRemoteDataSourceProvider = Provider<MedicationRemoteDataSource>((ref) {
  final apiClient = ref.read(medicationApiClientProvider);
  return MedicationRemoteDataSourceImpl(apiClient: apiClient);
});

// Local Data Source Provider
final medicationLocalDataSourceProvider = Provider<MedicationLocalDataSource>((ref) {
  return MedicationLocalDataSourceImpl();
});

// API Repository Provider
final medicationApiRepositoryProvider = Provider<MedicationApiRepositoryImpl>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  final localDataSource = ref.read(medicationLocalDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return MedicationApiRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Use Case Providers
final createMedicationUseCaseProvider = Provider<CreateMedicationUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return CreateMedicationUseCase(remoteDataSource: remoteDataSource);
});

final updateMedicationUseCaseProvider = Provider<UpdateMedicationUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return UpdateMedicationUseCase(remoteDataSource: remoteDataSource);
});

final getDailyMedicationUseCaseProvider = Provider<GetDailyMedicationUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return GetDailyMedicationUseCase(remoteDataSource: remoteDataSource);
});

final takeMedicationUseCaseProvider = Provider<TakeMedicationUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return TakeMedicationUseCase(remoteDataSource: remoteDataSource);
});

final skipMedicationUseCaseProvider = Provider<SkipMedicationUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return SkipMedicationUseCase(remoteDataSource: remoteDataSource);
});

final deleteMedicationUseCaseProvider = Provider<DeleteMedicationUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return DeleteMedicationUseCase(remoteDataSource: remoteDataSource);
});

final getUserMedicationsUseCaseProvider = Provider<GetUserMedicationsUseCase>((ref) {
  final remoteDataSource = ref.read(medicationRemoteDataSourceProvider);
  return GetUserMedicationsUseCase(remoteDataSource: remoteDataSource);
});

// State Providers for UI
final userMedicationsProvider = FutureProvider<List<ApiMedicationModel>>((ref) async {
  final useCase = ref.read(getUserMedicationsUseCaseProvider);
  final result = await useCase();

  return result.fold(
        (failure) => throw Exception(failure.message),
        (medications) => medications,
  );
});

final dailyMedicationProvider = FutureProvider.family<DailyMedicationResponseModel, String>((ref, date) async {
  final useCase = ref.read(getDailyMedicationUseCaseProvider);
  final result = await useCase(date);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (dailyData) => dailyData,
  );
});

// Medication Actions Provider
final medicationActionsProvider = Provider<MedicationActionsNotifier>((ref) {
  return MedicationActionsNotifier(ref);
});

class MedicationActionsNotifier {
  final Ref ref;

  MedicationActionsNotifier(this.ref);

  Future<bool> takeMedication(String medicationId, String date, String time) async {
    try {
      final useCase = ref.read(takeMedicationUseCaseProvider);
      final params = TakeMedicationParams(
        medicationId: medicationId,
        date: date,
        time: time,
      );

      final result = await useCase(params);

      return result.fold(
            (failure) {
          print('Failed to take medication: ${failure.message}');
          return false;
        },
            (response) {
          // Refresh the daily medication data
          ref.invalidate(dailyMedicationProvider(date));
          return true;
        },
      );
    } catch (e) {
      print('Error taking medication: $e');
      return false;
    }
  }

  Future<bool> skipMedication(String medicationId, String date, String time, {String? reason}) async {
    try {
      final useCase = ref.read(skipMedicationUseCaseProvider);
      final params = SkipMedicationParams(
        medicationId: medicationId,
        date: date,
        time: time,
        reason: reason,
      );

      final result = await useCase(params);

      return result.fold(
            (failure) {
          print('Failed to skip medication: ${failure.message}');
          return false;
        },
            (response) {
          // Refresh the daily medication data
          ref.invalidate(dailyMedicationProvider(date));
          return true;
        },
      );
    } catch (e) {
      print('Error skipping medication: $e');
      return false;
    }
  }

  Future<bool> deleteMedication(String medicationId) async {
    try {
      final useCase = ref.read(deleteMedicationUseCaseProvider);
      final result = await useCase(medicationId);

      return result.fold(
            (failure) {
          print('Failed to delete medication: ${failure.message}');
          return false;
        },
            (success) {
          // Refresh both user medications list and daily medication data
          ref.invalidate(userMedicationsProvider);
          // Invalidate all daily medication providers
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          ref.invalidate(dailyMedicationProvider(today));
          return success;
        },
      );
    } catch (e) {
      print('Error deleting medication: $e');
      return false;
    }
  }

  Future<ApiMedicationModel?> createMedication(CreateMedicationParams params) async {
    try {
      final useCase = ref.read(createMedicationUseCaseProvider);
      final result = await useCase(params);

      return result.fold(
            (failure) {
          print('Failed to create medication: ${failure.message}');
          return null;
        },
            (medication) {
          // Refresh the user medications list
          ref.invalidate(userMedicationsProvider);
          return medication;
        },
      );
    } catch (e) {
      print('Error creating medication: $e');
      return null;
    }
  }

  Future<ApiMedicationModel?> updateMedication(UpdateMedicationParams params) async {
    try {
      final useCase = ref.read(updateMedicationUseCaseProvider);
      final result = await useCase(params);

      return result.fold(
            (failure) {
          print('Failed to update medication: ${failure.message}');
          return null;
        },
            (medication) {
          // Refresh the user medications list
          ref.invalidate(userMedicationsProvider);
          return medication;
        },
      );
    } catch (e) {
      print('Error updating medication: $e');
      return null;
    }
  }
}
