import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/weight_local_datasource.dart';
import '../../data/datasources/weight_remote_datasource.dart';
import '../../data/repositories/weight_repository_impl.dart';
import '../../domain/repositories/weight_repository.dart';
import '../../domain/usecases/get_weight_progress_usecase.dart';
import '../../domain/usecases/update_weight_usecase.dart';
import '../../domain/usecases/get_weight_data_usecase.dart';
import '../../domain/usecases/check_target_achievement_usecase.dart';
import '../controllers/weight_controller.dart';

// Data Sources
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final weightRemoteDataSourceProvider = Provider<WeightRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return WeightRemoteDataSourceImpl(client: client);
});

final weightLocalDataSourceProvider = FutureProvider<WeightLocalDataSource>((ref) async {
  final sharedPrefs = await ref.watch(sharedPreferencesProvider.future);
  return WeightLocalDataSourceImpl(sharedPreferences: sharedPrefs);
});

// Repository
final weightRepositoryProvider = FutureProvider<WeightRepository>((ref) async {
  final remoteDataSource = ref.watch(weightRemoteDataSourceProvider);
  final localDataSource = await ref.watch(weightLocalDataSourceProvider.future);
  
  return WeightRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Use Cases
final getWeightProgressUseCaseProvider = FutureProvider<GetWeightProgressUseCase>((ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return GetWeightProgressUseCase(repository);
});

final updateWeightUseCaseProvider = FutureProvider<UpdateWeightUseCase>((ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return UpdateWeightUseCase(repository);
});

final getWeightDataUseCaseProvider = FutureProvider<GetWeightDataUseCase>((ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return GetWeightDataUseCase(repository);
});

final checkTargetAchievementUseCaseProvider = Provider<CheckTargetAchievementUseCase>((ref) {
  return CheckTargetAchievementUseCase();
});

// Weight Controller Provider - properly set up
final weightControllerProvider = StateNotifierProvider<WeightController, WeightState>((ref) {
  // We'll initialize this with a loading state and then update it
  return WeightController.loading();
});

// Initialization provider to set up the controller with dependencies
final weightControllerInitProvider = FutureProvider<void>((ref) async {
  final getWeightProgressUseCase = await ref.watch(getWeightProgressUseCaseProvider.future);
  final updateWeightUseCase = await ref.watch(updateWeightUseCaseProvider.future);
  final getWeightDataUseCase = await ref.watch(getWeightDataUseCaseProvider.future);
  final checkTargetAchievementUseCase = ref.watch(checkTargetAchievementUseCaseProvider);

  // Initialize the controller with dependencies
  final controller = ref.read(weightControllerProvider.notifier);
  controller.initialize(
    getWeightProgressUseCase,
    updateWeightUseCase,
    getWeightDataUseCase,
    checkTargetAchievementUseCase,
  );

  // Load initial data
  await controller.loadWeightProgress();
});