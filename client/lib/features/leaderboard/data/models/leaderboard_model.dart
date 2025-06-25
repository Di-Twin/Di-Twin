class LeaderboardEntryModel {
  final int rank;
  final String userId;
  final String username;
  final double score;
  final bool isCurrentUser;

  LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'],
      userId: json['userId'],
      username: json['username'],
      score: json['score']?.toDouble() ?? 0.0,
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

class LeaderboardModel {
  final int userRank;
  final int totalUsers;
  final List<LeaderboardEntryModel> leaderboard;

  LeaderboardModel({
    required this.userRank,
    required this.totalUsers,
    required this.leaderboard,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      userRank: json['userRank'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      leaderboard: (json['leaderboard'] as List?)
              ?.map((entry) => LeaderboardEntryModel.fromJson(entry))
              .toList() ??
          [],
    );
  }

  factory LeaderboardModel.empty() {
    return LeaderboardModel(
      userRank: 0,
      totalUsers: 0,
      leaderboard: [],
    );
  }
}
