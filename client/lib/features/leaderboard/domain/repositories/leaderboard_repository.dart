import 'package:dartz/dartz.dart';
import '../entities/leaderboard.dart';

abstract class LeaderboardRepository {
  Future<Either<String, Leaderboard>> getDailyLeaderboard(String date);
  Future<Either<String, Leaderboard>> getMonthlyLeaderboard(int year, int month);
}

