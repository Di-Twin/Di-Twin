import 'package:client/features/leaderboard/data/datasource/leaderboard_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/leaderboard.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardDataSource dataSource;

  LeaderboardRepositoryImpl({required this.dataSource});

  @override
  Future<Either<String, Leaderboard>> getDailyLeaderboard(String date) async {
    try {
      final result = await dataSource.getDailyLeaderboard(date);
      
      // Check if we got a "No rank found" response
      if (result.containsKey('message') && result['message'] == 'No rank found') {
        return const Left('No rank found for this date');
      }
      
      final leaderboardModel = LeaderboardModel.fromJson(result);
      
      // Map data model to domain entity
      final leaderboard = Leaderboard(
        userRank: leaderboardModel.userRank,
        totalUsers: leaderboardModel.totalUsers,
        entries: leaderboardModel.leaderboard.map((entry) {
          return LeaderboardEntry(
            rank: entry.rank,
            userId: entry.userId,
            username: entry.username,
            score: entry.score,
            isCurrentUser: entry.isCurrentUser,
          );
        }).toList(),
      );
      
      return Right(leaderboard);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Leaderboard>> getMonthlyLeaderboard(int year, int month) async {
    try {
      final result = await dataSource.getMonthlyLeaderboard(year, month);
      
      // Check if we got a "No rank found" response
      if (result.containsKey('message') && result['message'] == 'No rank found') {
        return const Left('No rank found for this month');
      }
      
      final leaderboardModel = LeaderboardModel.fromJson(result);
      
      // Map data model to domain entity
      final leaderboard = Leaderboard(
        userRank: leaderboardModel.userRank,
        totalUsers: leaderboardModel.totalUsers,
        entries: leaderboardModel.leaderboard.map((entry) {
          return LeaderboardEntry(
            rank: entry.rank,
            userId: entry.userId,
            username: entry.username,
            score: entry.score,
            isCurrentUser: entry.isCurrentUser,
          );
        }).toList(),
      );
      
      return Right(leaderboard);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
