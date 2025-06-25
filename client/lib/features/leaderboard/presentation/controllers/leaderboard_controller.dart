import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/usecases/get_daily_leaderboard.dart';
import '../../domain/usecases/get_monthly_leaderboard.dart';

enum LeaderboardType { daily, monthly }

enum LeaderboardStatus { initial, loading, loaded, error }

class LeaderboardState {
  final LeaderboardStatus status;
  final Leaderboard? leaderboard;
  final String? errorMessage;
  final LeaderboardType currentType;
  final String selectedDate; // For daily
  final int selectedYear; // For monthly
  final int selectedMonth; // For monthly

  LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.leaderboard,
    this.errorMessage,
    this.currentType = LeaderboardType.daily,
    String? selectedDate,
    int? selectedYear,
    int? selectedMonth,
  }) : 
    selectedDate = selectedDate ?? DateTime.now().toString().substring(0, 10),
    selectedYear = selectedYear ?? DateTime.now().year,
    selectedMonth = selectedMonth ?? DateTime.now().month;

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    Leaderboard? leaderboard,
    String? errorMessage,
    LeaderboardType? currentType,
    String? selectedDate,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage,
      currentType: currentType ?? this.currentType,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class LeaderboardController extends StateNotifier<LeaderboardState> {
  final GetDailyLeaderboard getDailyLeaderboard;
  final GetMonthlyLeaderboard getMonthlyLeaderboard;

  LeaderboardController({
    required this.getDailyLeaderboard,
    required this.getMonthlyLeaderboard,
  }) : super(LeaderboardState());

  Future<void> loadLeaderboard() async {
    state = state.copyWith(status: LeaderboardStatus.loading);

    if (state.currentType == LeaderboardType.daily) {
      await _loadDailyLeaderboard(state.selectedDate);
    } else {
      await _loadMonthlyLeaderboard(state.selectedYear, state.selectedMonth);
    }
  }

  Future<void> _loadDailyLeaderboard(String date) async {
    final result = await getDailyLeaderboard(date);

    result.fold(
      (errorMessage) {
        state = state.copyWith(
          status: LeaderboardStatus.error,
          errorMessage: errorMessage,
        );
      },
      (leaderboard) {
        state = state.copyWith(
          status: LeaderboardStatus.loaded,
          leaderboard: leaderboard,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> _loadMonthlyLeaderboard(int year, int month) async {
    final result = await getMonthlyLeaderboard(year, month);

    result.fold(
      (errorMessage) {
        state = state.copyWith(
          status: LeaderboardStatus.error,
          errorMessage: errorMessage,
        );
      },
      (leaderboard) {
        state = state.copyWith(
          status: LeaderboardStatus.loaded,
          leaderboard: leaderboard,
          errorMessage: null,
        );
      },
    );
  }

  void changeType(LeaderboardType type) {
    state = state.copyWith(
      currentType: type,
      status: LeaderboardStatus.initial,
    );
    loadLeaderboard();
  }

  void selectDate(String date) {
    state = state.copyWith(
      selectedDate: date,
      currentType: LeaderboardType.daily,
      status: LeaderboardStatus.initial,
    );
    loadLeaderboard();
  }

  void selectMonth(int year, int month) {
    state = state.copyWith(
      selectedYear: year,
      selectedMonth: month,
      currentType: LeaderboardType.monthly,
      status: LeaderboardStatus.initial,
    );
    loadLeaderboard();
  }
}
