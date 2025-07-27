import 'package:client/features/leaderboard/data/datasource/leaderboard_datasource.dart';
import 'package:client/features/leaderboard/data/repository/leaderboard_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/usecases/get_daily_leaderboard.dart';
import 'package:client/features/leaderboard/domain/usecases/get_monthly_leaderboard.dart';
import '../controllers/leaderboard_controller.dart';

// Base URL provider
final baseUrlProvider = Provider<String>((ref) {
  return 'https://test-prod-f427.onrender.com';
});

// Http client provider
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// DataSource provider
final leaderboardDataSourceProvider = Provider<LeaderboardDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final baseUrl = ref.watch(baseUrlProvider);
  return LeaderboardRemoteDataSource(client: client, baseUrl: baseUrl);
});

// Repository provider
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final dataSource = ref.watch(leaderboardDataSourceProvider);
  return LeaderboardRepositoryImpl(dataSource: dataSource);
});

// Use case providers
final getDailyLeaderboardProvider = Provider<GetDailyLeaderboard>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return GetDailyLeaderboard(repository);
});

final getMonthlyLeaderboardProvider = Provider<GetMonthlyLeaderboard>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return GetMonthlyLeaderboard(repository);
});

// Leaderboard controller provider
final leaderboardControllerProvider = StateNotifierProvider<LeaderboardController, LeaderboardState>((ref) {
  final getDailyLeaderboard = ref.watch(getDailyLeaderboardProvider);
  final getMonthlyLeaderboard = ref.watch(getMonthlyLeaderboardProvider);
  
  return LeaderboardController(
    getDailyLeaderboard: getDailyLeaderboard,
    getMonthlyLeaderboard: getMonthlyLeaderboard,
  );
});