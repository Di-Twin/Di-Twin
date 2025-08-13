class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final double score;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.isCurrentUser,
  });
}

class Leaderboard {
  final int userRank;
  final int totalUsers;
  final List<LeaderboardEntry> entries;

  Leaderboard({
    required this.userRank,
    required this.totalUsers,
    required this.entries,
  });
}
