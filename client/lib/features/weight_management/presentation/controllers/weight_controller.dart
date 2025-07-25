import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weight_progress_entity.dart';
import '../../domain/usecases/get_weight_progress_usecase.dart';
import '../../domain/usecases/update_weight_usecase.dart';
import '../../domain/usecases/get_weight_data_usecase.dart';
import '../../domain/usecases/check_target_achievement_usecase.dart';

class WeightState {
  final WeightProgressEntity? progress;
  final Map<String, double> chartData;
  final String selectedPeriod;
  final bool isLoading;
  final bool isChartLoading;
  final bool isInitialized;
  final String? error;

  const WeightState({
    this.progress,
    this.chartData = const {},
    this.selectedPeriod = 'Week',
    this.isLoading = false,
    this.isChartLoading = false,
    this.isInitialized = false,
    this.error,
  });

  WeightState copyWith({
    WeightProgressEntity? progress,
    Map<String, double>? chartData,
    String? selectedPeriod,
    bool? isLoading,
    bool? isChartLoading,
    bool? isInitialized,
    String? error,
  }) {
    return WeightState(
      progress: progress ?? this.progress,
      chartData: chartData ?? this.chartData,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      isChartLoading: isChartLoading ?? this.isChartLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}

class WeightController extends StateNotifier<WeightState> {
  GetWeightProgressUseCase? _getWeightProgressUseCase;
  UpdateWeightUseCase? _updateWeightUseCase;
  GetWeightDataUseCase? _getWeightDataUseCase;
  CheckTargetAchievementUseCase? _checkTargetAchievementUseCase;

  WeightController() : super(const WeightState());

  // Named constructor for loading state
  WeightController.loading() : super(const WeightState(isLoading: true));

  // Initialize the controller with use cases
  void initialize(
    GetWeightProgressUseCase getWeightProgressUseCase,
    UpdateWeightUseCase updateWeightUseCase,
    GetWeightDataUseCase getWeightDataUseCase,
    CheckTargetAchievementUseCase checkTargetAchievementUseCase,
  ) {
    _getWeightProgressUseCase = getWeightProgressUseCase;
    _updateWeightUseCase = updateWeightUseCase;
    _getWeightDataUseCase = getWeightDataUseCase;
    _checkTargetAchievementUseCase = checkTargetAchievementUseCase;
    
    state = state.copyWith(isInitialized: true);
  }

  Future<void> loadWeightProgress() async {
    if (!state.isInitialized || _getWeightProgressUseCase == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final progress = await _getWeightProgressUseCase!();
      state = state.copyWith(progress: progress, isLoading: false);
      
      // Load initial chart data
      await loadWeightData(state.selectedPeriod);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadWeightData(String period) async {
    if (!state.isInitialized || _getWeightDataUseCase == null) return;
    
    state = state.copyWith(isChartLoading: true, selectedPeriod: period);
    
    try {
      final chartData = await _getWeightDataUseCase!(period);
      state = state.copyWith(chartData: chartData, isChartLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isChartLoading: false);
    }
  }

  Future<void> updateWeight(double weight) async {
    if (!state.isInitialized || 
        _updateWeightUseCase == null || 
        _checkTargetAchievementUseCase == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final previousWeight = state.progress?.currentWeight ?? weight;
      final targetRange = state.progress?.targetRange;
      
      final wasTargetAchieved = targetRange != null && 
          _checkTargetAchievementUseCase!(previousWeight, targetRange);
      
      await _updateWeightUseCase!(weight);
      
      // Reload progress after update
      await loadWeightProgress();
      
      final isTargetNowAchieved = targetRange != null && 
          _checkTargetAchievementUseCase!(weight, targetRange);
      
      // Handle target achievement celebration
      if (!wasTargetAchieved && isTargetNowAchieved) {
        // Trigger celebration - this would be handled by the UI
        // You can add a callback or state flag here
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  bool isTargetAchieved() {
    final progress = state.progress;
    if (!state.isInitialized ||
        _checkTargetAchievementUseCase == null ||
        progress?.currentWeight == null || 
        progress?.targetRange == null) {
      return false;
    }
    return _checkTargetAchievementUseCase!(
      progress!.currentWeight!,
      progress.targetRange!,
    );
  }

  Future<bool> shouldShowWeightPopup() async {
    if (!state.isInitialized || _getWeightProgressUseCase == null) return false;
    
    try {
      // This would need to be implemented in the use case or repository
      // For now, return false as a placeholder
      return false;
    } catch (e) {
      return false;
    }
  }
}