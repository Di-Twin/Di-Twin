import 'package:flutter/material.dart';
import '../../domain/entities/sleep_entry.dart';
import '../../domain/usecases/start_sleep_usecase.dart';
import '../../domain/usecases/end_sleep_usecase.dart';
import '../../domain/usecases/get_todays_sleep_usecase.dart';
import '../../domain/usecases/get_last_night_sleep_usecase.dart';
import '../../domain/usecases/check_sleep_data_usecase.dart';
import 'dart:developer' as developer;

class SleepProvider extends ChangeNotifier {
  final StartSleepUseCase startSleepUseCase;
  final EndSleepUseCase endSleepUseCase;
  final GetTodaysSleepUseCase getTodaysSleepUseCase;
  final GetLastNightSleepUseCase getLastNightSleepUseCase;
  final CheckSleepDataUseCase checkSleepDataUseCase;

  SleepProvider({
    required this.startSleepUseCase,
    required this.endSleepUseCase,
    required this.getTodaysSleepUseCase,
    required this.getLastNightSleepUseCase,
    required this.checkSleepDataUseCase,
  });

  SleepEntry? _currentSleep;
  SleepEntry? _lastNightSleep;
  bool _isLoading = false;
  String? _errorMessage;

  SleepEntry? get currentSleep => _currentSleep;
  SleepEntry? get lastNightSleep => _lastNightSleep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveSleep => _currentSleep != null && _currentSleep!.isActive;

  Future<void> initialize() async {
    await loadTodaysSleep();
    await loadLastNightSleep();
  }

  Future<void> loadTodaysSleep() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await getTodaysSleepUseCase();
      result.fold(
            (failure) {
          _errorMessage = failure.message;
          developer.log('❌ Error loading today\'s sleep: ${failure.message}', name: 'SleepProvider');
        },
            (sleepEntry) {
          _currentSleep = sleepEntry;
          developer.log('✅ Loaded today\'s sleep: ${sleepEntry?.id}', name: 'SleepProvider');
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to load sleep data: $e';
      developer.log('❌ Exception loading today\'s sleep: $e', name: 'SleepProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLastNightSleep() async {
    try {
      final result = await getLastNightSleepUseCase();
      result.fold(
            (failure) {
          developer.log('❌ Error loading last night\'s sleep: ${failure.message}', name: 'SleepProvider');
        },
            (sleepEntry) {
          _lastNightSleep = sleepEntry;
          developer.log('✅ Loaded last night\'s sleep: ${sleepEntry?.id}', name: 'SleepProvider');
        },
      );
      notifyListeners();
    } catch (e) {
      developer.log('❌ Exception loading last night\'s sleep: $e', name: 'SleepProvider');
    }
  }

  Future<bool> startSleep({DateTime? customStartTime}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final startTime = customStartTime ?? DateTime.now();
      final result = await startSleepUseCase(startTime);

      return result.fold(
            (failure) {
          _errorMessage = failure.message;
          developer.log('❌ Error starting sleep: ${failure.message}', name: 'SleepProvider');
          return false;
        },
            (_) {
          developer.log('✅ Sleep started successfully', name: 'SleepProvider');
          loadTodaysSleep(); // Reload to get the new sleep entry
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to start sleep: $e';
      developer.log('❌ Exception starting sleep: $e', name: 'SleepProvider');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> endSleep({DateTime? customEndTime}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final endTime = customEndTime ?? DateTime.now();
      final result = await endSleepUseCase(endTime);

      return result.fold(
            (failure) {
          _errorMessage = failure.message;
          developer.log('❌ Error ending sleep: ${failure.message}', name: 'SleepProvider');
          return false;
        },
            (_) {
          developer.log('✅ Sleep ended successfully', name: 'SleepProvider');
          loadTodaysSleep(); // Reload to get the updated sleep entry
          loadLastNightSleep(); // Also reload last night's sleep
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to end sleep: $e';
      developer.log('❌ Exception ending sleep: $e', name: 'SleepProvider');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> hasSleepDataForToday() async {
    try {
      final result = await checkSleepDataUseCase();
      return result.fold(
            (failure) {
          developer.log('❌ Error checking sleep data: ${failure.message}', name: 'SleepProvider');
          return false;
        },
            (hasData) => hasData,
      );
    } catch (e) {
      developer.log('❌ Exception checking sleep data: $e', name: 'SleepProvider');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
