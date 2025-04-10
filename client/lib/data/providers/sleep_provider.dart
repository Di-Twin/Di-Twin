// lib/data/providers/sleep_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/API/sleep_data.dart';
import 'package:intl/intl.dart';

final sleepServiceProvider = Provider<SleepService>((ref) {
  return SleepService();
});

final sleepDataProvider = FutureProvider.autoDispose<SleepApiResponse>((ref) async {
  final sleepService = ref.watch(sleepServiceProvider);
  // Hardcoded date for testing - you can make this dynamic later
  // final date = '2025-4-6';
  final now = DateTime.now();
  final yesterday = now.subtract(Duration(days: 1));
  final formattedDate = DateFormat('yyyy-M-d').format(yesterday);

  return await sleepService.getDailySleepData(formattedDate);
});

// Provider for the sleep stage values
final sleepStageValuesProvider = Provider<Map<String, int>>((ref) {
  final sleepDataAsyncValue = ref.watch(sleepDataProvider);
  
  return sleepDataAsyncValue.when(
    data: (data) => data.data.stageValues,
    loading: () => {'AWAKE': 0, 'REM': 0, 'LIGHT': 0, 'DEEP': 0},
    error: (_, __) => {'AWAKE': 0, 'REM': 0, 'LIGHT': 0, 'DEEP': 0},
  );
});

// Provider for efficiency score
final sleepEfficiencyProvider = Provider<double>((ref) {
  final sleepDataAsyncValue = ref.watch(sleepDataProvider);
  
  return sleepDataAsyncValue.when(
    data: (data) => data.data.efficiencyScore,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

final MonthlysleepServiceProvider = Provider<SleepService>((ref) {
  return SleepService();
});

// Daily sleep data provider
final MonthlysleepDataProvider = FutureProvider.autoDispose<SleepApiResponse>((ref) async {
  final MonthlysleepService = ref.watch(MonthlysleepServiceProvider);
  final now = DateTime.now();
  final yesterday = now.subtract(Duration(days: 1));
  final formattedDate = DateFormat('yyyy-M-d').format(yesterday);
  return await MonthlysleepService.getDailySleepData(formattedDate);
});

// Sleep stage value provider
final MonthlysleepStageValuesProvider = Provider<Map<String, int>>((ref) {
  final MonthlysleepDataAsyncValue = ref.watch(MonthlysleepDataProvider);
  return MonthlysleepDataAsyncValue.when(
    data: (data) => data.data.stageValues,
    loading: () => {'AWAKE': 0, 'REM': 0, 'LIGHT': 0, 'DEEP': 0},
    error: (_, __) => {'AWAKE': 0, 'REM': 0, 'LIGHT': 0, 'DEEP': 0},
  );
});

// Efficiency score provider
final MonthlysleepEfficiencyProvider = Provider<double>((ref) {
  final MonthlysleepDataAsyncValue = ref.watch(MonthlysleepDataProvider);
  return MonthlysleepDataAsyncValue.when(
    data: (data) => data.data.efficiencyScore,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Monthly sleep data provider
final monthlySleepDataProvider = FutureProvider.autoDispose<MonthlySleepResponse>((ref) async {
  final MonthlysleepService = ref.read(MonthlysleepServiceProvider);
  final now = DateTime.now();
  return await MonthlysleepService.getMonthlySleepData(now.year, now.month);
});

// Monthly summary
final monthlySleepSummaryProvider = Provider<MonthlySleepSummary?>((ref) {
  return ref.watch(monthlySleepDataProvider).maybeWhen(
    data: (data) => data.summary,
    orElse: () => null,
  );
});

// Unique monthly sleep days
final MonthlyuniqueSleepDaysProvider = Provider<List<MonthlySleepSession>>((ref) {
  return ref.watch(monthlySleepDataProvider).maybeWhen(
    data: (data) => data.getUniqueDays(),
    orElse: () => [],
  );
});

// Activity map for calendar
final MonthlyactivityCalendarDataProvider = Provider<Map<int, bool>>((ref) {
  return ref.watch(monthlySleepDataProvider).maybeWhen(
    data: (data) => data.generateActivityMap(),
    orElse: () => {},
  );
});


