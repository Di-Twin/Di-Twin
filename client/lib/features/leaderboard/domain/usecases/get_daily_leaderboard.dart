import 'package:dartz/dartz.dart';
import '../entities/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';

class GetDailyLeaderboard {
  final LeaderboardRepository repository;

  GetDailyLeaderboard(this.repository);

  Future<Either<String, Leaderboard>> call(String date) {
    return repository.getDailyLeaderboard(date);
  }
}