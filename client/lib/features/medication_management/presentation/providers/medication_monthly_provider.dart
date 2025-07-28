import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/medication_monthly_remote_datasource.dart';
import '../../data/repositories/medication_monthly_repository_impl.dart';
import '../../domain/usecases/get_monthly_medication_usecase.dart';
import '../../data/models/monthly_medication_model.dart';
import 'package:http/http.dart' as http;

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: 'https://test-prod-f427.onrender.com/api/medication',
    httpClient: http.Client(),
  );
});

// Data Source Provider
final medicationMonthlyRemoteDataSourceProvider = Provider<MedicationMonthlyRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MedicationMonthlyRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository Provider
final medicationMonthlyRepositoryProvider = Provider<MedicationMonthlyRepositoryImpl>((ref) {
  final remoteDataSource = ref.read(medicationMonthlyRemoteDataSourceProvider);
  return MedicationMonthlyRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Provider
final getMonthlyMedicationUseCaseProvider = Provider<GetMonthlyMedicationUseCase>((ref) {
  final repository = ref.read(medicationMonthlyRepositoryProvider);
  return GetMonthlyMedicationUseCase(repository: repository);
});

// State Provider for selected month/year
final selectedMonthYearProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Monthly Medication Data Provider
final monthlyMedicationDataProvider = FutureProvider.family<MonthlyMedicationModel, DateTime>((ref, dateTime) async {
  final useCase = ref.read(getMonthlyMedicationUseCaseProvider);
  return await useCase.call(dateTime.year, dateTime.month);
});

// Current Monthly Medication Data Provider
final currentMonthlyMedicationProvider = FutureProvider<MonthlyMedicationModel>((ref) async {
  final selectedDate = ref.watch(selectedMonthYearProvider);
  final useCase = ref.read(getMonthlyMedicationUseCaseProvider);
  return await useCase.call(selectedDate.year, selectedDate.month);
});
